class AppConfig {
  const AppConfig._();

  static const backendBaseUrl = String.fromEnvironment(
    'BACKEND_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/',
  );

  static const coinGeckoBaseUrl = String.fromEnvironment(
    'COINGECKO_BASE_URL',
    defaultValue: 'https://api.coingecko.com/api/v3/',
  );

  static const coinGeckoApiKey = String.fromEnvironment(
    'COINGECKO_API_KEY',
    defaultValue: 'CG-Wu4E9yhdxZKoAnGqJhZLG2j4',
  );
}
