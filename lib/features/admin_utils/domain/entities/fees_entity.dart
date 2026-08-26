import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter/material.dart';

class FeesEntity {
  final String id;
  final String memberId;
  final String memberName;
  final String memberPhone;
  final String memberEmail;
  final String plan;
  final String planId;
  final num amount;
  final num paidAmount;
  final String status;
  final String dueDate;
  final String paidDate;
  final String paymentMethod;
  final String receiptUrl;
  final String notes;
  final num overdueDays;
  final String createdAt;
  final String updatedAt;

  const FeesEntity({
    this.id = '',
    this.memberId = '',
    this.memberName = '',
    this.memberPhone = '',
    this.memberEmail = '',
    this.plan = '',
    this.planId = '',
    this.amount = 0,
    this.paidAmount = 0,
    this.status = '',
    this.dueDate = '',
    this.paidDate = '',
    this.paymentMethod = '',
    this.receiptUrl = '',
    this.notes = '',
    this.overdueDays = 0,
    this.createdAt = '',
    this.updatedAt = '',
  });

  @override
  String toString() {
    return 'FeesEntity('
      'id: $id, '
      'memberId: $memberId, '
      'memberName: $memberName, '
      'memberPhone: $memberPhone, '
      'memberEmail: $memberEmail, '
      'plan: $plan, '
      'planId: $planId, '
      'amount: $amount, '
      'paidAmount: $paidAmount, '
      'status: $status, '
      'dueDate: $dueDate, '
      'paidDate: $paidDate, '
      'paymentMethod: $paymentMethod, '
      'receiptUrl: $receiptUrl, '
      'notes: $notes, '
      'overdueDays: $overdueDays, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is FeesEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  Color get memberColor {
    final colors = AppTheme.palette;
    return colors[Randomizer.clampInt(memberId.hashCode, colors.length)];
  }

  String get memberInitials => memberName.twoLetters;
}

enum FeeStatus { paid, pending, overdue, partial, waived }

enum PaymentMethod { cash, bankTransfer, upi, other }

extension FeesExtension on FeesEntity {
  FeeStatus get statusEnum => FeeStatus.values.byName(status.toLowerCase());

  PaymentMethod get paymentMethodEnum {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return PaymentMethod.cash;
      case 'bank transfer':
      case 'bank_transfer':
      case 'banktransfer':
        return PaymentMethod.bankTransfer;
      case 'upi':
        return PaymentMethod.upi;
      default:
        return PaymentMethod.other;
    }
  }
}