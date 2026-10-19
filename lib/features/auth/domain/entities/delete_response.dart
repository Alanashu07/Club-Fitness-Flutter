import 'auth_entities.dart';

class AccountDeletionResponse {
  const AccountDeletionResponse({
    required this.status,
    required this.message,
    this.title,
    this.mode,
    this.accountState,
    this.logout = false,
    this.requestedAt,
  });

  final AccountDeletionStatus status;
  final String message; // always user-facing, success or failure
  final String? title; // from error.title (failures only)
  final String? mode;
  final String? accountState; // DELETED | DEACTIVATED | SUSPENDED
  final bool logout; // client must clear session when true
  final DateTime? requestedAt;

  factory AccountDeletionResponse.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;
    return AccountDeletionResponse(
      status: AccountDeletionStatus.parse(json['status'] as String?),
      message: (json['message'] ?? error?['message'] ?? _genericError) as String,
      title: error?['title'] as String?,
      mode: json['mode'] as String?,
      accountState: json['accountState'] as String?,
      logout: json['logout'] == true,
      requestedAt: DateTime.tryParse('${json['requestedAt'] ?? ''}'),
    );
  }

  static const String _genericError =
      'Something went wrong and your account was not changed. Please try again later.';

  factory AccountDeletionResponse.networkFailure() => const AccountDeletionResponse(
        status: AccountDeletionStatus.failed,
        title: 'Could not delete account',
        message: _genericError,
      );
}

/// Performs the API call (send `confirm: true` + `mode`). Must return the parsed
/// body even for 4xx/5xx responses, since failures use the same shape.
typedef DeletionSubmit = Future<AccountDeletionResponse> Function(DeletionMode mode);