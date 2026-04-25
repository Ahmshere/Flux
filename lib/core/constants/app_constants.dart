class AppConstants {
  AppConstants._();

  // API
  static const apiBaseUrl = 'https://api.exchangerate.host';
  static const apiTimeout = Duration(seconds: 10);

  // Cache
  static const cacheTtl = Duration(hours: 12);

  // Background refresh
  static const bgRefreshInterval = Duration(minutes: 30);

  // Hive boxes
  static const ratesBox     = 'rates_cache';
  static const favoritesBox = 'favorites';

  // Pro
  static const proProductId = 'kurso_pro_monthly';

  // Supported currencies (порядок отображения)
  static const supportedCodes = [
    'USD', 'EUR', 'ILS', 'GBP', 'JPY',
    'CHF', 'CAD', 'AUD', 'CNY', 'AED',
    'RUB', 'BTC', 'ETH',
  ];
}
