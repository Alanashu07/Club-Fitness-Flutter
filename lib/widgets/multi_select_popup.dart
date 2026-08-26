import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:club_fitness/widgets/common_widgets.dart';

// Generic multi-select popup widget
class MultiSelectPopup<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String title;
  final String Function(T)? displayBuilder;
  final dynamic Function(T)? keyBuilder;
  final Function(List<T>) onConfirm;
  final VoidCallback onCancel;

  const MultiSelectPopup({
    super.key,
    required this.items,
    required this.title,
    required this.onConfirm,
    required this.onCancel,
    this.displayBuilder,
    this.selectedItems = const [],
    this.keyBuilder,
  });

  @override
  State<MultiSelectPopup<T>> createState() => _MultiSelectPopupState<T>();
}

class _MultiSelectPopupState<T> extends State<MultiSelectPopup<T>> {
  List<T> selectedItems = [];

  void _toggleItem(T item) {
    setState(() {
      if (_isSelected(item)) {
        selectedItems.removeWhere((e) {
          if (widget.keyBuilder != null) {
            return widget.keyBuilder!(e) == widget.keyBuilder!(item);
          }
          return e == item;
        });
      } else {
        selectedItems.add(item);
      }
    });
  }

  String _getDisplayText(T item) {
    if (widget.displayBuilder != null) {
      return widget.displayBuilder!(item);
    }
    return item.toString();
  }

  @override
  initState() {
    super.initState();
    selectedItems = [...widget.selectedItems];
  }

  bool _isSelected(T item) {
    if (widget.keyBuilder != null) {
      final key = widget.keyBuilder!(item);
      return selectedItems.any((e) => widget.keyBuilder!(e) == key);
    }
    return selectedItems.contains(item);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              width: context.width,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    widget.title,
                    color: Colors.black87,
                    style: FontConstant.oxygenMediumBold,
                  ),
                  GestureDetector(
                    onTap: widget.onCancel,
                    child: Icon(Icons.close, color: Colors.grey, size: 20.w),
                  ),
                ],
              ),
            ),

            // Items List
            Container(
              constraints: BoxConstraints(maxHeight: 65.percentToHeight),
              child: widget.items.isEmpty
                  ? Container(
                      height: 200,
                      alignment: Alignment.center,
                      child: const Text(
                        'No items available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        final item = widget.items[index];
                        final isSelected = _isSelected(item);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: GestureDetector(
                            onTap: () => _toggleItem(item),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withAOpacity(
                                        0.1,
                                      )
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : Colors.grey.withAOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 14.w,
                                    height: 14.w,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : Colors.grey,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          )
                                        : null,
                                  ),
                                  Expanded(
                                    child: TextWidget(
                                      _getDisplayText(item),
                                      color: Colors.black87,
                                      bold: isSelected,
                                      style: FontConstant.oxygenSmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                padding: const EdgeInsets.all(16),
                width: 90.percentToWidth,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      '${selectedItems.length} selected',
                      style: FontConstant.oxygenSmall,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: widget.onCancel,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => widget.onConfirm(selectedItems),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
