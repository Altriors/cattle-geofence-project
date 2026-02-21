import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/alert_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';
import '../../widgets/alert_card.dart' as widgets;
import 'alerts_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    AlertsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Cattle Monitor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Live status indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Live',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Row
              FutureBuilder<Map<String, int>>(
                future: FirebaseService.getStatistics(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {};
                  return Row(
                    children: [
                      _StatCard(
                        label: 'Total Alerts',
                        value: '${stats['total'] ?? 0}',
                        icon: Icons.notifications,
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Boundary Crossed',
                        value: '${stats['crossed'] ?? 0}',
                        icon: Icons.warning_rounded,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        label: 'Unresolved',
                        value: '${stats['unresolved'] ?? 0}',
                        icon: Icons.pending_actions,
                        color: AppColors.warning,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Active Boundary Alerts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🚨 Active Boundary Alerts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AlertsScreen(),
                        ),
                      );
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              StreamBuilder<List<Alert>>(
                stream: FirebaseService.getUnresolvedAlertsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _EmptyState(
                      icon: Icons.check_circle_outline,
                      message: 'No active boundary alerts',
                      color: AppColors.success,
                    );
                  }

                  final alerts = snapshot.data!;
                  return Column(
                    children: alerts
                        .take(3)
                        .map((alert) => widgets.AlertCard(
                              alert: alert,
                              onTap: () => _showAlertDetail(context, alert),
                              onResolve: () =>
                                  FirebaseService.resolveAlert(alert.id),
                            ))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Recent Detections
              const Text(
                '📷 Recent Detections',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              StreamBuilder<List<Alert>>(
                stream: FirebaseService.getTodayAlertsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _EmptyState(
                      icon: Icons.videocam_off,
                      message: 'No detections today',
                      color: AppColors.textSecondary,
                    );
                  }

                  final alerts = snapshot.data!;
                  return Column(
                    children: alerts
                        .take(5)
                        .map((alert) => widgets.AlertCard(
                              alert: alert,
                              onTap: () => _showAlertDetail(context, alert),
                              onResolve: alert.boundaryCrossed && !alert.resolved
                                  ? () => FirebaseService.resolveAlert(alert.id)
                                  : null,
                              onDelete: () =>
                                  FirebaseService.deleteAlert(alert.id),
                            ))
                        .toList(),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDetail(BuildContext context, Alert alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AlertDetailSheet(alert: alert),
    );
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: color.withOpacity(0.5)),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: color, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Alert Detail Bottom Sheet ──────────────────────────────────────────────

class _AlertDetailSheet extends StatelessWidget {
  final Alert alert;

  const _AlertDetailSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Row(
            children: [
              CircleAvatar(
                backgroundColor: alert.boundaryCrossed
                    ? AppColors.danger
                    : AppColors.success,
                child: Icon(
                  alert.boundaryCrossed
                      ? Icons.warning_rounded
                      : Icons.check_circle_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                alert.boundaryCrossed
                    ? '🚨 Boundary Crossed'
                    : '✅ Cattle Detected',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          _DetailRow(label: 'Alert ID', value: alert.id),
          _DetailRow(
              label: 'Cattle Count', value: alert.cattleCount.toString()),
          if (alert.cattleId != null)
            _DetailRow(label: 'Cattle ID', value: alert.cattleId.toString()),
          _DetailRow(label: 'Camera', value: alert.camera),
          _DetailRow(
              label: 'Status',
              value: alert.boundaryCrossed ? 'BOUNDARY ALERT' : 'Normal'),
          _DetailRow(label: 'Resolved', value: alert.resolved ? 'Yes' : 'No'),
          _DetailRow(
              label: 'Time',
              value: Helpers.formatDateTime(alert.timestamp)),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              if (alert.boundaryCrossed && !alert.resolved)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      FirebaseService.resolveAlert(alert.id);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Mark Resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              if (alert.boundaryCrossed && !alert.resolved)
                const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}