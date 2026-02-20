import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../models/alert_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cattle Boundary Alerts'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh handled by StreamBuilder
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('alerts')
            .orderBy('timestamp', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No alerts yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final alerts = snapshot.data!.docs
              .map((doc) => Alert.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              return AlertCard(alert: alerts[index]);
            },
          );
        },
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final Alert alert;

  const AlertCard({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeAgo = _getTimeAgo(alert.timestamp);
    final formattedTime = DateFormat('HH:mm:ss').format(alert.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      color: alert.boundaryCrossed ? Colors.red.shade50 : Colors.white,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: alert.boundaryCrossed ? Colors.red : Colors.green,
          child: Icon(
            alert.boundaryCrossed ? Icons.warning : Icons.check_circle,
            color: Colors.white,
          ),
        ),
        title: Text(
          alert.boundaryCrossed
              ? '🚨 Boundary Crossed!'
              : '✅ Cattle Detected',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: alert.boundaryCrossed ? Colors.red.shade900 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Cattle Count: ${alert.cattleCount}'),
            if (alert.cattleId != null) Text('Cattle ID: ${alert.cattleId}'),
            Text('Camera: ${alert.camera}'),
            Text('Time: $formattedTime ($timeAgo)'),
          ],
        ),
        trailing: alert.resolved
            ? const Icon(Icons.check, color: Colors.green)
            : null,
        isThreeLine: true,
        onTap: () {
          _showAlertDetails(context, alert);
        },
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showAlertDetails(BuildContext context, Alert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(alert.boundaryCrossed ? 'Boundary Crossed' : 'Detection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Alert ID', alert.id),
            _buildDetailRow('Cattle Count', alert.cattleCount.toString()),
            if (alert.cattleId != null)
              _buildDetailRow('Cattle ID', alert.cattleId.toString()),
            _buildDetailRow('Camera', alert.camera),
            _buildDetailRow('Status', alert.boundaryCrossed ? 'ALERT' : 'Normal'),
            _buildDetailRow('Resolved', alert.resolved ? 'Yes' : 'No'),
            _buildDetailRow(
              'Timestamp',
              DateFormat('dd MMM yyyy, HH:mm:ss').format(alert.timestamp),
            ),
          ],
        ),
        actions: [
          if (!alert.resolved)
            TextButton(
              onPressed: () {
                _markAsResolved(context, alert.id);
              },
              child: const Text('Mark as Resolved'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _markAsResolved(BuildContext context, String alertId) {
    FirebaseFirestore.instance
        .collection('alerts')
        .doc(alertId)
        .update({'resolved': true}).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alert marked as resolved')),
      );
    });
  }
}