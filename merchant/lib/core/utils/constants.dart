class Constants {
  // Base URL untuk berbagai platform:
  // Android Emulator: http://10.0.2.2:3000
  // iOS Simulator: http://localhost:3000 atau http://127.0.0.1:3000
  // Physical Device: http://<IP_KOMPUTER>:3000
  // Web: http://localhost:3000
  static const String baseUrl = 'http://10.0.2.2:3000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS/Web
  // static const String baseUrl = 'http://192.168.1.xxx:3000'; // Physical Device

  static const int pageSize = 20;
  static const String databaseName = 'merchant_products.db';
  static const int databaseVersion = 1;

  // Sync Constants
  static const Duration syncRetryDelay = Duration(seconds: 5);
  static const int maxSyncRetries = 3;

  // Table Names
  static const String productsTable = 'products';
  static const String pendingActionsTable = 'pending_actions';
}
