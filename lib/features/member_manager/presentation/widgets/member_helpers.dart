import 'dart:async';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/member_status.dart';
import 'package:club_fitness/core/services/url_services.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:club_fitness/core/exceptions/failure.dart';

String formatShortDate(DateTime d) {
  const m = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${m[d.month - 1]} ${d.year}';
}

String formatTime(DateTime d) {
  final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final period = d.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String formatDuration(Duration d) {
  if (d.isNegative) return '—';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return h > 0 ? '${h}h ${m}m' : '${m}m';
}

/// wa.me needs digits only, with country code. Defaults to India (+91).
String normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) return '91$digits';
  if (digits.length == 11 && digits.startsWith('0')) {
    return '91${digits.substring(1)}';
  }
  return digits;
}

// ── Plan / trainer labels (used by type-ahead fields) ───────────────────────

String planLabel(MembershipPlanMiniEntity p) =>
    '${p.name} - ₹${p.price} (${p.durationDays} days)';

String planSearchText(MembershipPlanMiniEntity p) =>
    '${p.name} ${p.price} ${p.durationDays}';

String planSubtitle(MembershipPlanMiniEntity p) =>
    '₹${p.price}  •  ${p.durationDays} days';

// ── Colors (kept to the essentials: success / error / neutral) ──────────────

Color memberStatusColor(MemberStatus status) => switch (status) {
  MemberStatus.active => AppTheme.success,
  MemberStatus.expired => AppTheme.error,
  MemberStatus.suspended => AppTheme.error,
  MemberStatus.trial => AppTheme.textSecondary,
};

Color feeStatusColor(String feeStatus) => switch (feeStatus) {
  'paid' => AppTheme.success,
  'overdue' => AppTheme.error,
  _ => AppTheme.textSecondary,
};

BoxDecoration sheetFieldDecoration() => BoxDecoration(
  color: AppTheme.surface,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: Colors.white.withAOpacity(0.06), width: 1),
);

// ── WhatsApp messages ───────────────────────────────────────────────────────

String buildWelcomeMessage(AddMemberResult r) {
  final b = StringBuffer()
    ..writeln('Hi ${r.name}, welcome to Club Fitness! 💪')
    ..writeln()
    ..writeln('We are excited to have you with us.');

  if (r.planName != null) {
    b
      ..writeln()
      ..writeln('*Your membership details*')
      ..writeln('Plan: ${r.planName}');
    if (r.startDate != null) {
      b.writeln('Starts: ${formatShortDate(r.startDate!)}');
    }
    if (r.endDate != null) {
      b.writeln('Ends: ${formatShortDate(r.endDate!.subtract(1.min))}');
    }
    if (r.planPrice != null) b.writeln('Amount: ₹${r.planPrice}');
  }

  b
    ..writeln()
    ..write('Let us know if you need anything. See you at the gym! 🏋️');
  return b.toString();
}

String buildRenewMessage(RenewResult r, MemberEntity m) {
  final b = StringBuffer()
    ..writeln('Hi ${m.name}, your Club Fitness membership has been renewed! 💪')
    ..writeln()
    ..writeln('Thank you for continuing your fitness journey with us.');

  if (r.planName.isNotEmpty) {
    b
      ..writeln()
      ..writeln('*Your renewed membership details*')
      ..writeln('Plan: ${r.planName}');

    if (r.startDate.isNotEmpty) {
      b.writeln('Starts: ${formatShortDate(r.startDate.toDateTime)}');
    }
    if (r.endDate.isNotEmpty) {
      b.writeln(
        'Ends: ${formatShortDate(r.endDate.toDateTime.subtract(1.min))}',
      );
    }
    if (r.planPrice != 0) b.writeln('Amount: ₹${r.planPrice}');
  }

  b
    ..writeln()
    ..write('Keep pushing towards your goals. See you at the gym! 🏋️');
  return b.toString();
}

String buildReminderMessage(MemberEntity? m, [MemberListEntity? l]) {
  final now = DateTime.now();
  final end = m?.membershipEndDate ?? l!.expiryDateTime;
  final expired = end.isBefore(now);
  final b = StringBuffer();
  String name = m?.name ?? l?.name ?? '';
  String planName = m?.membershipPlan.name ?? l?.plan ?? '';
  num price = m?.membershipPlan.price ?? l?.amount ?? 0;
  num daysLeft = m?.daysLeft ?? l?.daysLeft ?? 0;

  if (expired) {
    final daysOverdue = now.difference(end).inDays;
    b
      ..writeln('Hi $name, your Club Fitness membership has expired. ⏰')
      ..writeln()
      ..writeln(
        'Please renew at the earliest to continue your fitness journey with us.',
      )
      ..writeln()
      ..writeln('*Your membership details*')
      ..writeln('Plan: $planName')
      ..writeln('Expired on: ${formatShortDate(end)}');
    if (daysOverdue > 0) {
      b.writeln(
        'Overdue by: $daysOverdue ${daysOverdue == 1 ? 'day' : 'days'}',
      );
    }
    b
      ..writeln('Renewal amount: ₹$price')
      ..writeln()
      ..write('Let us know if you need any help with the renewal. 🏋️');
  } else {
    final when = daysLeft <= 0
        ? 'today'
        : daysLeft == 1
        ? 'tomorrow'
        : 'in $daysLeft days';
    b
      ..writeln('Hi $name, your Club Fitness membership expires $when. ⏰')
      ..writeln()
      ..writeln('Renew in time to keep your workouts going without a break.')
      ..writeln()
      ..writeln('*Your membership details*')
      ..writeln('Plan: $planName')
      ..writeln('Expires on: ${formatShortDate(end)}')
      ..writeln('Renewal amount: ₹$price')
      ..writeln()
      ..write('Let us know if you need anything. See you at the gym! 💪');
  }
  return b.toString();
}

// ── Action plumbing ─────────────────────────────────────────────────────────

/// Shows a blocking loader, fires [event], waits for the bloc to emit a
/// terminal state (per [isDone]), closes the loader and returns that state.
Future<MembersActionsState> dispatchMemberAction(
  BuildContext context,
  MembersActionsEvent event, {
  required bool Function(MembersActionsState) isDone,
}) async {
  final bloc = context.read<MembersActionsBloc>();
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator.adaptive()),
    ),
  );
  final result = bloc.stream.firstWhere(isDone);
  bloc.add(event);
  final state = await result;
  if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  return state;
}

void finishMemberAction(
  BuildContext context, {
  Failure? failure,
  required String successMessage,
  required String? memberId,
}) {
  if (!context.mounted) return;
  if (failure != null) {
    context.showToastFromFailure(failure);
    return;
  }
  context.showToast(successMessage, type: ToastificationType.success);
  if (memberId != null) {
    context.read<MemberDetailBloc>().add(GetMemberDetailsEvent(memberId));
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required IconData icon,
  required Color color,
  required String title,
  required String prefix,
  required String highlight,
  required String suffix,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color.withAOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 26),
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13.5,
            height: 1.4,
          ),
          children: [
            TextSpan(text: prefix),
            TextSpan(
              text: highlight,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
            TextSpan(text: suffix),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelLabel,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            confirmLabel,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
  return ok == true;
}

// ── Member actions ──────────────────────────────────────────────────────────

Future<void> suspendMember(BuildContext context, MemberEntity m) async {
  final ok = await confirmDialog(
    context,
    icon: Icons.block_rounded,
    color: AppTheme.error,
    title: 'Suspend Member',
    prefix: 'Suspend ',
    highlight: m.name,
    suffix: '? They will be blocked from entering the gym until reactivated.',
    confirmLabel: 'Suspend',
  );
  if (!ok || !context.mounted) return;

  final state = await dispatchMemberAction(
    context,
    SuspendMemberEvent(id: m.id),
    isDone: (s) =>
        s is SuspendMemberSuccessState || s is SuspendMemberFailureState,
  );
  if (!context.mounted) return;
  finishMemberAction(
    context,
    failure: state is SuspendMemberFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is SuspendMemberSuccessState
        ? state.message
        : '${m.name} has been suspended',
  );
}

Future<void> reactivateMember(BuildContext context, MemberEntity m) async {
  final ok = await confirmDialog(
    context,
    icon: Icons.check_circle_rounded,
    color: AppTheme.success,
    title: 'Reactivate Member',
    prefix: 'Restore gym access for ',
    highlight: m.name,
    suffix: '?',
    confirmLabel: 'Reactivate',
  );
  if (!ok || !context.mounted) return;

  final state = await dispatchMemberAction(
    context,
    ReactivateMemberEvent(id: m.id),
    isDone: (s) =>
        s is ReactivateMemberSuccessState || s is ReactivateMemberFailureState,
  );
  if (!context.mounted) return;
  finishMemberAction(
    context,
    failure: state is ReactivateMemberFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is ReactivateMemberSuccessState
        ? state.message
        : '${m.name} has been reactivated',
  );
}

/// The endpoint de-activates unless force=true.
Future<void> deleteMember(
  BuildContext context,
  MemberEntity? m,
  MemberListEntity? ml,
) async {
  if (m == null && ml == null) return;
  final name = m?.name ?? ml!.name;
  final id = m?.id ?? ml!.id;

  final mode = await showModalBottomSheet<DeleteMode>(
    context: context,
    backgroundColor: AppTheme.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => DeleteModeSheet(memberName: name),
  );
  if (mode == null || !context.mounted) return;

  if (mode == DeleteMode.deactivate) {
    final ok = await confirmDialog(
      context,
      icon: Icons.person_off_rounded,
      color: AppTheme.error,
      title: 'Deactivate Member',
      prefix: 'Deactivate ',
      highlight: name,
      suffix:
          '? They will be blocked from the gym and marked as suspended. All fees, attendance and history are kept, and you can reactivate them anytime.',
      confirmLabel: 'Deactivate',
    );
    if (!ok || !context.mounted) return;

    final state = await dispatchMemberAction(
      context,
      DeleteMemberEvent(id: id),
      isDone: (s) =>
          s is DeleteMemberSuccessState || s is DeleteMemberFailureState,
    );
    if (!context.mounted) return;
    finishMemberAction(
      context,
      failure: state is DeleteMemberFailureState ? state.failure : null,
      memberId: m?.id,
      successMessage: '$name has been deactivated',
    );
    return;
  }

  // Permanent delete: requires typing DELETE
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => PermanentDeleteDialog(memberName: name),
  );
  if (confirmed != true || !context.mounted) return;

  final state = await dispatchMemberAction(
    context,
    DeleteMemberEvent(id: id, force: true),
    isDone: (s) =>
        s is DeleteMemberSuccessState || s is DeleteMemberFailureState,
  );
  if (!context.mounted) return;

  if (state is DeleteMemberFailureState) {
    // e.g. 409 when the user authored workout plans, announcements or documents
    context.showToastFromFailure(state.failure);
    return;
  }
  context.showToast(
    state is DeleteMemberSuccessState
        ? state.message
        : '$name has been permanently deleted',
    type: ToastificationType.success,
  );
  // The member no longer exists, so reloading the details would 404. Leave the
  // screen; the list refreshes itself when the detail route pops.
  Navigator.of(context).pop();
}

Future<void> renewMember(BuildContext context, MemberEntity m) async {
  final configBloc = context.read<MembersConfigBloc>();
  final result = await showModalBottomSheet<RenewResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: configBloc,
      child: RenewMembershipSheet(member: m),
    ),
  );
  if (result == null || !context.mounted) return;

  final state = await dispatchMemberAction(
    context,
    RenewMembershipEvent(
      id: m.id,
      planId: result.planId,
      startOverride: result.startOverride,
      paidAmount: result.paidAmount ?? 0,
      paymentMethod: result.paymentMethod ?? '',
      notes: result.notes ?? '',
      receiptPath: result.receiptPath,
      offerId: result.offerId,
      offerCode: result.offerCode,
      waiveRemaining: result.waiveRemaining,
    ),
    isDone: (s) =>
        s is RenewMembershipSuccessState || s is RenewMembershipFailureState,
  );
  if (!context.mounted) return;
  finishMemberAction(
    context,
    failure: state is RenewMembershipFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is RenewMembershipSuccessState
        ? state.renew.message
        : 'Membership renewed',
  );
  final send = await confirmDialog(
    context,
    icon: Icons.chat_rounded,
    color: const Color(0xFF25D366),
    title: 'Membership Renewed',
    prefix: 'New Membership for ',
    highlight: m.name,
    suffix: ' was renewed successfully. Send a message on WhatsApp?',
    confirmLabel: 'Send on WhatsApp',
    cancelLabel: 'Skip',
  );
  if (!send || !context.mounted) return;

  await UrlServices.whatsappMessage(
    number: normalizePhone(m.phone),
    message: buildRenewMessage(result, m),
  );
}

Future<void> revertLastRenewal(BuildContext context, MemberEntity m) async {
  final ok = await confirmDialog(
    context,
    icon: Icons.undo_rounded,
    color: AppTheme.error,
    title: 'Revert Last Renewal',
    prefix: 'Undo the most recent renewal for ',
    highlight: m.name,
    suffix:
        '? The fee record (and any linked remainder/offer redemption) will be deleted and the previous membership plan and dates restored.',
    confirmLabel: 'Revert',
  );
  if (!ok || !context.mounted) return;

  final state = await dispatchMemberAction(
    context,
    RevertLastRenewalEvent(id: m.id),
    isDone: (s) =>
        s is RevertLastRenewalSuccessState ||
        s is RevertLastRenewalFailureState,
  );
  if (!context.mounted) return;
  finishMemberAction(
    context,
    failure: state is RevertLastRenewalFailureState ? state.failure : null,
    memberId: m.id,
    successMessage: state is RevertLastRenewalSuccessState
        ? state.message
        : 'Last renewal reverted',
  );
}

Future<void> showSendReminderDialog(
  BuildContext context, {
  required String name,
  required VoidCallback onEmail,
  required VoidCallback onWhatsapp,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppTheme.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text(
        'Send Reminder',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        'How would you like to remind $name?',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 44),
                side: const BorderSide(color: AppTheme.success, width: 1.5),
                foregroundColor: AppTheme.success,
              ),
              icon: const Icon(Icons.chat_rounded, size: 18),
              label: const Text('WhatsApp'),
              onPressed: () {
                Navigator.pop(dialogContext);
                onWhatsapp();
              },
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.email_rounded, size: 18),
              label: const Text('Email'),
              onPressed: () {
                Navigator.pop(dialogContext);
                onEmail();
              },
            ),
          ],
        ),
      ],
    ),
  );
}
