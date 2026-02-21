import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/colors.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Card
          _SectionCard(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    auth.user?.displayName?.isNotEmpty == true
                        ? auth.user!.displayName![0].toUpperCase()
                        : 'F',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  auth.user?.displayName ?? 'Farmer',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(auth.user?.email ?? ''),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const _SectionTitle(title: 'Notifications'),
          _SectionCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_active,
                title: 'Push Notifications',
                subtitle: 'Receive boundary alert notifications',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.primary,
                ),
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.volume_up,
                title: 'Alert Sound',
                subtitle: 'Play sound on boundary cross',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const _SectionTitle(title: 'Camera'),
          _SectionCard(
            children: [
              _SettingsTile(
                icon: Icons.videocam,
                title: 'Camera Source',
                subtitle: 'Camera 1 (Default)',
                onTap: () {},
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.speed,
                title: 'Detection Sensitivity',
                subtitle: 'High',
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),
          const _SectionTitle(title: 'Alerts'),
          _SectionCard(
            children: [
              _SettingsTile(
                icon: Icons.delete_sweep,
                title: 'Clear Resolved Alerts',
                subtitle: 'Remove all resolved alerts',
                onTap: () => _confirmClearAlerts(context),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const _SectionTitle(title: 'Account'),
          _SectionCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              const Divider(height: 1, indent: 56),
              _SettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                iconColor: AppColors.danger,
                titleColor: AppColors.danger,
                onTap: () => _confirmSignOut(context, auth),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await auth.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _confirmClearAlerts(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear Resolved Alerts'),
        content: const Text(
            'This will permanently delete all resolved alerts. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resolved alerts cleared')),
              );
            },
            child: const Text('Clear',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}