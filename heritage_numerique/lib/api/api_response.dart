/// Classe de base pour toutes les réponses API
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error(String message, {int? statusCode, Map<String, dynamic>? errors}) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'],
      errors: json['errors'],
    );
  }
}

/// Classe pour gérer les erreurs API
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}

/// Classe utilitaire pour les requêtes API
class ApiUtils {
  /// Gérer les réponses API et les erreurs
  static ApiResponse<T> handleResponse<T>(
    dynamic response,
    T Function(dynamic) fromJson, {
    String? errorMessage,
  }) {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          fromJson(response.data),
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          errorMessage ?? 'Erreur lors de la requête',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        errorMessage ?? 'Erreur lors du traitement de la réponse: $e',
      );
    }
  }

  /// Gérer les erreurs de requête
  static ApiResponse<T> handleError<T>(dynamic error, {String? errorMessage}) {
    if (error.response != null) {
      return ApiResponse.error(
        errorMessage ?? error.response.data['message'] ?? 'Erreur serveur',
        statusCode: error.response.statusCode,
        errors: error.response.data,
      );
    } else {
      return ApiResponse.error(
        errorMessage ?? 'Erreur de connexion: ${error.message}',
      );
    }
  }
}
