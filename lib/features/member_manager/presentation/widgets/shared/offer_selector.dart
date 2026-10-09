
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/features/member_manager/member_manager.dart';
import 'package:flutter/material.dart';

class OfferSelector extends StatelessWidget {
  final List<PlanOfferEntity> offers;
  final PlanOfferEntity? selected;
  final ValueChanged<PlanOfferEntity?> onChanged;
  final TextEditingController codeController;

  /// When set, shows "(was ₹x)" next to the payable amount.
  final num? originalPrice;

  const OfferSelector({
    super.key,
    required this.offers,
    required this.selected,
    required this.onChanged,
    required this.codeController,
    this.originalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SheetLabel('Offer (optional)'),
        const SizedBox(height: 10),
        if (offers.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: offers.map((o) {
              final isSelected = selected?.id == o.id;
              return SelectChip(
                label: '${o.name} (-₹${o.discountAmount})',
                selected: isSelected,
                onTap: () {
                  if (!isSelected) codeController.clear();
                  onChanged(isSelected ? null : o);
                },
              );
            }).toList(),
          ),
        const SizedBox(height: 10),
        Container(
          decoration: sheetFieldDecoration(),
          child: TextField(
            controller: codeController,
            enabled: selected == null,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Have an offer code?',
              hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              prefixIcon: Icon(
                Icons.local_offer_outlined,
                color: AppTheme.textSecondary,
                size: 18,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: 10),
          Text(
            originalPrice == null
                ? 'Payable: ₹${selected!.finalAmount}'
                : 'Payable: ₹${selected!.finalAmount}  (was ₹$originalPrice)',
            style: const TextStyle(
              color: AppTheme.success,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ],
    );
  }
}