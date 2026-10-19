// ─────────────────────────────────────────────────────────────────────────────
// Model: mirrors the response of  DELETE /account/delete
// ─────────────────────────────────────────────────────────────────────────────

/// Matches the `mode` the endpoint accepts.
enum DeletionMode {
  soft,
  hard;

  String get apiValue => name; // 'soft' | 'hard'
}

/// Matches `status` returned by the endpoint.
enum AccountDeletionStatus {
  deleted('DELETED'),
  deactivated('DEACTIVATED'),
  pendingAdminDeletion('PENDING_ADMIN_DELETION'),
  alreadyPending('ALREADY_PENDING'),
  alreadyDeactivated('ALREADY_DEACTIVATED'),
  invalidRequest('INVALID_REQUEST'),
  notAllowed('NOT_ALLOWED'),
  notFound('NOT_FOUND'),
  failed('FAILED'),
  unknown('UNKNOWN');

  const AccountDeletionStatus(this.value);
  final String value;

  static AccountDeletionStatus parse(String? raw) =>
      AccountDeletionStatus.values.firstWhere(
        (s) => s.value == raw,
        orElse: () => AccountDeletionStatus.unknown,
      );

  bool get isFailure => const {
        invalidRequest,
        notAllowed,
        notFound,
        failed,
        unknown,
      }.contains(this);
}