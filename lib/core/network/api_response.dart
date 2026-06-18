/// Generic wrapper for all API responses.
/// Decoded manually via the [ApiClient.decoder] callback — no codegen needed.
class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode = 200,
  });

  final bool success;
  final String? message;
  final T? data;
  final int statusCode;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      ApiResponse(
        success: json['success'] as bool? ?? true,
        message: json['message'] as String?,
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        statusCode: json['statusCode'] as int? ?? 200,
      );
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<T> items;
  final int total;
  final int page;
  final int limit;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) =>
      PaginatedResponse(
        items: (json['items'] as List<dynamic>)
            .map((e) => fromJsonT(e))
            .toList(),
        total: json['total'] as int,
        page: json['page'] as int,
        limit: json['limit'] as int,
      );
}
