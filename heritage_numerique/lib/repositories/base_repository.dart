import 'package:heritage_numerique/api/api_client.dart';
import 'package:heritage_numerique/api/api_response.dart';

/// Repository de base pour toutes les opérations API
abstract class BaseRepository {
  final ApiClient _apiClient = ApiClient();

  ApiClient get apiClient => _apiClient;

  /// Méthode utilitaire pour gérer les réponses GET
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.get(endpoint, queryParameters: queryParams);
      return ApiUtils.handleResponse(response, fromJson ?? (data) => data);
    } catch (error) {
      return ApiUtils.handleError(error);
    }
  }

  /// Méthode utilitaire pour gérer les réponses POST
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.post(endpoint, data: data, queryParameters: queryParams);
      return ApiUtils.handleResponse(response, fromJson ?? (data) => data);
    } catch (error) {
      return ApiUtils.handleError(error);
    }
  }

  /// Méthode utilitaire pour gérer les réponses PUT
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.put(endpoint, data: data, queryParameters: queryParams);
      return ApiUtils.handleResponse(response, fromJson ?? (data) => data);
    } catch (error) {
      return ApiUtils.handleError(error);
    }
  }

  /// Méthode utilitaire pour gérer les réponses DELETE
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.delete(endpoint, queryParameters: queryParams);
      return ApiUtils.handleResponse(response, fromJson ?? (data) => data);
    } catch (error) {
      return ApiUtils.handleError(error);
    }
  }

  /// Méthode utilitaire pour l'upload de fichiers
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    Map<String, dynamic>? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _apiClient.uploadFile(endpoint, filePath, data: data);
      return ApiUtils.handleResponse(response, fromJson ?? (data) => data);
    } catch (error) {
      return ApiUtils.handleError(error);
    }
  }
}
