import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/colors.dart';
import '../../utils/helpers.dart';

class AlertDetailScreen extends StatelessWidget {
  final Alert alert;

  const AlertDetailScreen({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Alert Details'),
        backgroundColor: alert.boundaryCrossed ? AppColors.danger : AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: alert.boundaryCrossed
                    ? AppColors.danger.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: alert.boundaryCrossed
                      ? AppColors.danger.withOpacity(0.3)
                      : AppColors.success.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    alert.boundaryCrossed
                        ? Icons.warning_rounded
                        : Icons.check_circle_rounded,
                    color: alert.boundaryCrossed
                        ? AppColors.danger
                        : AppColors.success,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.boundaryCrossed
                              ? '🚨 Boundary Crossed!'
                              : '✅ Cattle Detected',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: alert.boundaryCrossed
                                ? AppColors.danger
                                : AppColors.success,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.getTimeAgo(alert.timestamp),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alert.resolved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Resolved',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Details Card
            _DetailCard(
              title: 'Detection Info',
              children: [
                _DetailRow(
                    icon: Icons.fingerprint, label: 'Alert ID', value: alert.id),
                _DetailRow(
                  icon: Icons.pets,
                  label: 'Cattle Count',
                  value: alert.cattleCount.toString(),
                ),
                if (alert.cattleId != null)
                  _DetailRow(
                    icon: Icons.tag,
                    label: 'Cattle ID',
                    value: alert.cattleId.toString(),
                  ),
                _DetailRow(
                  icon: Icons.videocam,
                  label: 'Camera',
                  value: alert.camera,
                ),
              ],
            ),

            const SizedBox(height: 12),

            _DetailCard(
              title: 'Status Info',
              children: [
                _DetailRow(
                  icon: Icons.fence,
                  label: 'Boundary',
                  value: alert.boundaryCrossed ? 'CROSSED ⚠️' : 'Within bounds ✅',
                ),
                _DetailRow(
                  icon: Icons.task_alt,
                  label: 'Resolved',
                  value: alert.resolved ? 'Yes ✅' : 'No ❌',
                ),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Timestamp',
                  value: Helpers.formatDateTime(alert.timestamp),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons
            if (alert.boundaryCrossed && !alert.resolved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await FirebaseService.resolveAlert(alert.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Alert marked as resolved')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Resolved'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                label: const Text('Delete Alert',
                    style: TextStyle(color: AppColors.danger)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseService.deleteAlert(alert.id);
              if (context.mounted) {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}