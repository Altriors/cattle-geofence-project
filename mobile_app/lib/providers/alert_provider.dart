import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';
import '../services/firebase_service.dart';

class AlertProvider extends ChangeNotifier {
  List<Alert> _alerts = [];
  List<Alert> _unresolvedAlerts = [];
  bool _isLoading = false;
  String? _error;

  List<Alert> get alerts => _alerts;
  List<Alert> get unresolvedAlerts => _unresolvedAlerts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalAlerts => _alerts.length;
  int get crossedCount =>
      _alerts.where((a) => a.boundaryCrossed).length;
  int get unresolvedCount =>
      _alerts.where((a) => a.boundaryCrossed && !a.resolved).length;

  AlertProvider() {
    _listenToAlerts();
    _listenToUnresolved();
  }

  void _listenToAlerts() {
    FirebaseService.getAlertsStream().listen(
      (alerts) {
        _alerts = alerts;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void _listenToUnresolved() {
    FirebaseService.getUnresolvedAlertsStream().listen((alerts) {
      _unresolvedAlerts = alerts;
      notifyListeners();
    });
  }

  Future<void> resolveAlert(String alertId) async {
    try {
      await FirebaseService.resolveAlert(alertId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      await FirebaseService.deleteAlert(alertId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}