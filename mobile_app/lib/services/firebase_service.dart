import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../utils/constants.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Get alerts stream
  static Stream<List<Alert>> getAlertsStream({int limit = 50}) {
    return _db
        .collection(AppConstants.alertsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList());
  }
  
  // Get alerts for today
  static Stream<List<Alert>> getTodayAlertsStream() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return _db
        .collection(AppConstants.alertsCollection)
        .where('timestamp', isGreaterThan: Timestamp.fromDate(startOfDay))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList());
  }
  
  // Get unresolved alerts
  static Stream<List<Alert>> getUnresolvedAlertsStream() {
    return _db
        .collection(AppConstants.alertsCollection)
        .where('resolved', isEqualTo: false)
        .where('boundary_crossed', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Alert.fromFirestore(doc)).toList());
  }
  
  // Mark alert as resolved
  static Future<void> resolveAlert(String alertId) {
    return _db
        .collection(AppConstants.alertsCollection)
        .doc(alertId)
        .update({'resolved': true});
  }
  
  // Delete alert
  static Future<void> deleteAlert(String alertId) {
    return _db
        .collection(AppConstants.alertsCollection)
        .doc(alertId)
        .delete();
  }
  
  // Get statistics
  static Future<Map<String, int>> getStatistics() async {
    final alerts = await _db
        .collection(AppConstants.alertsCollection)
        .get();
    
    int totalAlerts = alerts.docs.length;
    int crossedAlerts = alerts.docs
        .where((doc) => (doc.data()['boundary_crossed'] ?? false) == true)
        .length;
    int resolvedAlerts = alerts.docs
        .where((doc) => (doc.data()['resolved'] ?? false) == true)
        .length;
    
    return {
      'total': totalAlerts,
      'crossed': crossedAlerts,
      'resolved': resolvedAlerts,
      'unresolved': crossedAlerts - resolvedAlerts,
    };
  }
}