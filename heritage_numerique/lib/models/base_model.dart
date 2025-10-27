/// Modèle de base pour toutes les entités
abstract class BaseModel {
  Map<String, dynamic> toJson();
}

/// Modèle pour les réponses paginées
class PaginatedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;
  final int size;
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
    required this.size,
    required this.first,
    required this.last,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      content: (json['content'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['number'] ?? 0,
      size: json['size'] ?? 0,
      first: json['first'] ?? false,
      last: json['last'] ?? false,
    );
  }
}

/// Modèle pour les filtres de recherche
class SearchFilter {
  final String? query;
  final int? page;
  final int? size;
  final String? sortBy;
  final String? sortDirection;
  final Map<String, dynamic>? additionalFilters;

  SearchFilter({
    this.query,
    this.page,
    this.size,
    this.sortBy,
    this.sortDirection,
    this.additionalFilters,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (query != null && query!.isNotEmpty) {
      params['q'] = query;
    }
    if (page != null) {
      params['page'] = page;
    }
    if (size != null) {
      params['size'] = size;
    }
    if (sortBy != null && sortBy!.isNotEmpty) {
      params['sort'] = sortDirection == 'desc' ? '$sortBy,desc' : sortBy;
    }
    
    if (additionalFilters != null) {
      params.addAll(additionalFilters!);
    }
    
    return params;
  }
}
