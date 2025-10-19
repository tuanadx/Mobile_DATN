class GoongConfig {
  // API keys cho Goong
  static const String apiKey = 'PQrW93KH2byinPvRY3oWF4IhG7sY0oP5vSf4Ci0h';
  static const String mapTileKey = 'CgOCNmcJ3DsMPgPM6ASv3sCMFXKaXOQh5l5eh1cj';
  
  // URLs cho các loại bản đồ khác nhau
  static String get mapStyleUrl => 
      'https://tiles.goong.io/assets/goong_map_highlight.json?api_key=$mapTileKey';
  
  static String get satelliteStyleUrl => 
      'https://tiles.goong.io/assets/goong_satellite.json?api_key=$mapTileKey';
  
  // Base URL cho Goong API
  static const String baseUrl = 'https://rsapi.goong.io';
  
  // Endpoints
  static const String autocompleteEndpoint = '/Place/AutoComplete';
  static const String placeDetailEndpoint = '/Place/Detail';
  
  // Vị trí mặc định (Hà Nội)
  static const double defaultLatitude = 21.03357551700003;
  static const double defaultLongitude = 105.81911236900004;
  static const double defaultZoom = 14.0;
}
