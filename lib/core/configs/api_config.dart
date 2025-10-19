class ApiConfig {
  static const String baseUrl = 'https://6874e988-9ce7-4eff-97ef-8becf9b5b8fb.mock.pstmn.io';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers mặc định
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
