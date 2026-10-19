import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  // Soft is pre-selected: it is the reversible option.
  DeletionMode _mode = DeletionMode.soft;
  bool _loading = false;

  Future<void> _onContinue() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(mode: _mode),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _loading = true);
    context.read<AuthBloc>().add(RequestDeleteAccountEvent(mode: _mode));
  }

  void _onAccountGone(AccountDeletionResponse response) async {
    if (!mounted) return;
    setState(() => _loading = false);
    await _showResult(response);
    if (response.logout && mounted) {
      context.logout();
    }
  }

  Future<void> _showResult(AccountDeletionResponse r) {
    final (IconData icon, Color color, String title) = switch (r.status) {
      AccountDeletionStatus.deleted => (
        Icons.check_circle_outline,
        AppTheme.success,
        'Account deleted',
      ),
      AccountDeletionStatus.deactivated => (
        Icons.check_circle_outline,
        AppTheme.success,
        'Account de-activated',
      ),
      AccountDeletionStatus.alreadyDeactivated => (
        Icons.info_outline,
        AppTheme.textSecondary,
        'Already de-activated',
      ),
      AccountDeletionStatus.pendingAdminDeletion => (
        Icons.hourglass_top_rounded,
        AppTheme.warning,
        'Account suspended',
      ),
      AccountDeletionStatus.alreadyPending => (
        Icons.hourglass_top_rounded,
        AppTheme.warning,
        'Request already submitted',
      ),
      _ => (
        Icons.error_outline,
        AppTheme.error,
        r.title ?? 'Could not delete account',
      ),
    };

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(icon, color: color, size: 44),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(
          r.message, // same message the API returns, shown as-is
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHard = _mode == DeletionMode.hard;

    return PopScope(
      canPop: !_loading, // block back navigation while the request is running
      child: Scaffold(
        appBar: AppBar(title: const Text('Delete Account')),
        body: SafeArea(
          child: BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is DeleteAccountSucceeded) {
                _onAccountGone(state.response);
              }
              if (state is AuthLogoutState) {
                context.go(Routes.login);
              }
              if (state is DeleteAccountFailed) {
                context.showToastFromFailure(state.failure);
              }
              if (state is AuthFailure) {
                context.showToastFromFailure(state.failure);
              }
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _WarningBanner(),
                      const SizedBox(height: 24),
                      const Text(
                        'Choose what you want to do',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _OptionCard(
                        selected: _mode == DeletionMode.soft,
                        icon: Icons.pause_circle_outline,
                        accent: AppTheme.warning,
                        title: 'De-activate my account',
                        subtitle:
                            'Your account is suspended and you are signed out. Your data is kept, '
                            'and the gym can restore your account later if you ask.',
                        onTap: _loading
                            ? null
                            : () => setState(() => _mode = DeletionMode.soft),
                      ),
                      const SizedBox(height: 12),
                      _OptionCard(
                        selected: isHard,
                        icon: Icons.delete_forever_outlined,
                        accent: AppTheme.error,
                        title: 'Delete permanently',
                        subtitle:
                            'Your account and its history (fees, orders, bookings, measurements, '
                            'attendance and more) are erased and cannot be recovered.',
                        note:
                            'If we cannot delete it right now, your account will be suspended instead '
                            'and an admin will delete it after reviewing your request.',
                        onTap: _loading
                            ? null
                            : () => setState(() => _mode = DeletionMode.hard),
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isHard
                              ? AppTheme.error
                              : AppTheme.primary,
                        ),
                        onPressed: _loading ? null : _onContinue,
                        child: Text(
                          isHard
                              ? 'Delete my account'
                              : 'De-activate my account',
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).maybePop(),
                        child: const Text('Keep my account'),
                      ),
                    ],
                  ),
                ),
                if (_loading)
                  Positioned.fill(
                    child: ColoredBox(
                      color: AppTheme.background.withAOpacity(0.7),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confirmation dialog (last chance to back out)
// ─────────────────────────────────────────────────────────────────────────────

class _ConfirmDialog extends StatefulWidget {
  const _ConfirmDialog({required this.mode});
  final DeletionMode mode;

  @override
  State<_ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<_ConfirmDialog> {
  static const _phrase = 'DELETE';
  final _controller = TextEditingController();

  bool get _isHard => widget.mode == DeletionMode.hard;
  bool get _canConfirm =>
      !_isHard || _controller.text.trim().toUpperCase() == _phrase;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _isHard ? AppTheme.error : AppTheme.warning;

    return AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      icon: Icon(Icons.warning_amber_rounded, color: accent, size: 44),
      title: Text(
        _isHard ? 'Delete your account?' : 'De-activate your account?',
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _isHard
                ? 'This permanently erases your account and history. If it cannot be '
                      'done right now, your account will be suspended until an admin deletes it.'
                : 'You will be signed out and your account will be suspended. '
                      'Your data is kept.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
          ),
          if (_isHard) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Type DELETE to confirm',
              ),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            disabledBackgroundColor: AppTheme.cardBorder,
            minimumSize: const Size(double.infinity, 48),
          ),
          onPressed: _canConfirm ? () => Navigator.of(context).pop(true) : null,
          child: Text(_isHard ? 'Yes, delete' : 'Yes, de-activate'),
        ),
        const SizedBox(height: 8),
        TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(double.infinity, 44),
          ),
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Keep my account',
            style: TextStyle(color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withAOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.error.withAOpacity(0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppTheme.error),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You will lose access to the app and your gym door access. '
              'Please make sure you no longer need your membership, bookings or fee history.',
              style: TextStyle(color: AppTheme.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.selected,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.note,
  });

  final bool selected;
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String? note;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? accent : AppTheme.cardBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (note != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppTheme.warning,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            note!,
                            style: const TextStyle(
                              color: AppTheme.warning,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? accent : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
