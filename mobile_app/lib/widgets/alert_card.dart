import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alert_model.dart';
import '../utils/colors.dart';
import '../utils/helpers.dart';

class AlertCard extends StatelessWidget {
  final Alert alert;
  final VoidCallback? onTap;
  final VoidCallback? onResolve;
  final VoidCallback? onDelete;

  const AlertCard({
    Key? key,
    required this.alert,
    this.onTap,
    this.onResolve,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: alert.boundaryCrossed 
          ? Colors.red.shade50 
          : AppColors.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: alert.boundaryCrossed 
                        ? AppColors.danger 
                        : AppColors.success,
                    child: Icon(
                      alert.boundaryCrossed 
                          ? Icons.warning_rounded 
                          : Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
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
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: alert.boundaryCrossed 
                                ? AppColors.danger 
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Helpers.getTimeAgo(alert.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (alert.resolved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Resolved',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.pets,
                    'Cattle: ${alert.cattleCount}',
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.videocam,
                    alert.camera,
                  ),
                  const SizedBox(width: 8),
                  _buildInfoChip(
                    Icons.access_time,
                    Helpers.formatTime(alert.timestamp),
                  ),
                ],
              ),
              if (onResolve != null || onDelete != null)
                const SizedBox(height: 12),
              if (onResolve != null || onDelete != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onResolve != null && !alert.resolved)
                      TextButton.icon(
                        onPressed: onResolve,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Resolve'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                        ),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.danger,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}