import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heritage_numerique/config/api_config.dart';

/// Client API centralisé pour toutes les requêtes HTTP
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ));

    // Intercepteur pour ajouter le token d'authentification
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Récupérer le token depuis le stockage local
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        print('🚀 API Request: ${options.method} ${options.path}');
        print('📤 Headers: ${options.headers}');
        if (options.data != null) {
          print('📤 Data: ${options.data}');
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
        print('📥 Data: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) {
        print('❌ API Error: ${error.response?.statusCode} ${error.requestOptions.path}');
        print('📥 Error Data: ${error.response?.data}');
        handler.next(error);
      },
    ));
  }

  /// GET request
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  /// PUT request
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters);
  }

  /// DELETE request
  Future<Response> delete(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.delete(path, queryParameters: queryParameters);
  }

  /// Upload de fichier
  Future<Response> uploadFile(String path, String filePath, {Map<String, dynamic>? data}) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      ...?data,
    });
    
    return await _dio.post(path, data: formData);
  }
}
