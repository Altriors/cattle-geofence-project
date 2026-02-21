class AppConstants {
  static const String appName = 'Cattle Geo-Fence Monitor';
  static const String version = '1.0.0';
  
  // Colors
  static const primaryColor = 0xFF4CAF50;
  static const dangerColor = 0xFFE53935;
  static const warningColor = 0xFFFFA726;
  
  // Firebase Collections
  static const alertsCollection = 'alerts';
  static const usersCollection = 'users';
  static const camerasCollection = 'cameras';
  
  // Alert Types
  static const alertTypeCrossed = 'boundary_crossed';
  static const alertTypeDetection = 'detection';
}