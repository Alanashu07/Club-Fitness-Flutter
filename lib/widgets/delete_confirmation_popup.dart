import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:club_fitness/core/constants/constants.dart';
import 'package:club_fitness/core/utils/utils.dart';

import 'common_widgets.dart';

class DeleteConfirmationPopup extends StatefulWidget {
  final String? title;
  final String? itemName;
  final String? description;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const DeleteConfirmationPopup({
    super.key,
    this.title,
    this.itemName,
    this.description,
    this.onConfirm,
    this.onCancel,
  });

  @override
  State<DeleteConfirmationPopup> createState() =>
      _DeleteConfirmationPopupState();

  static Future<bool?> show(
    BuildContext context, {
    String? title,
    String? itemName,
    String? description,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        alignment: Alignment.center,
        constraints: BoxConstraints(maxHeight: 60.percentToHeight),
        insetPadding: EdgeInsets.zero,
        child: DeleteConfirmationPopup(
          title: title,
          itemName: itemName,
          description: description,
          onConfirm: onConfirm,
          onCancel: onCancel,
        ),
      ),
    );
  }
}

class _DeleteConfirmationPopupState extends State<DeleteConfirmationPopup>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _shakeAnimation;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _handleConfirm() async {
    // Trigger shake animation
    _shakeController.forward();

    setState(() {
      isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 1500));

    if (widget.onConfirm != null) {
      widget.onConfirm!();
    }

    if (mounted) {
      context.pop();
      _showSuccessDialog();
    }
  }

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    _shakeAnimation.value *
                        8 *
                        (0.5 - ((_shakeController.value * 4) % 1 - 0.5).abs()) *
                        (isLoading ? 1 : 0),
                    0,
                  ),
                  child: Container(
                    margin: 20.w.horizontal,
                    padding: 24.w.horizontal + 28.h.vertical,
                    decoration: BoxDecoration(
                      borderRadius: 20.w.borderRadius,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(0.15.opacityToAlpha),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header Section with Warning Icon
                          Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.red.shade500,
                                  Colors.red.shade600,
                                ],
                              ),
                              borderRadius: 30.w.borderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withAlpha(
                                    0.3.opacityToAlpha,
                                  ),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.delete_forever_rounded,
                              size: 30.w,
                              color: Colors.white,
                            ),
                          ),

                          16.h.height,

                          // Title
                          TextWidget(
                            widget.title ?? 'Delete Item',
                            color: const Color(0xFF1F2937),
                            style: FontConstant.oxygenLargeBold,
                            textAlign: TextAlign.center,
                          ),

                          8.h.height,

                          // Item Name (if provided)
                          if (widget.itemName != null) ...[
                            Container(
                              padding: 8.w.horizontal + 4.h.vertical,
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: 8.w.borderRadius,
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: TextWidget(
                                '"${widget.itemName}"',
                                color: Colors.red.shade700,
                                style: FontConstant.oxygenMedium,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                                fontSize: 12.sp,
                                maxLines: null,
                              ),
                            ),
                            12.h.height,
                          ],

                          // Description
                          TextWidget(
                            widget.description ??
                                'This action cannot be undone. Are you sure you want to permanently delete this item?',
                            color: const Color(0xFF6B7280),
                            style: FontConstant.oxygenSmall,
                            textAlign: TextAlign.center,
                            maxLines: null,
                          ),

                          32.h.height,

                          // Warning Box
                          Container(
                            width: double.infinity,
                            padding: 16.w.horizontal + 12.h.vertical,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: 12.w.borderRadius,
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: Colors.red.shade600,
                                  size: 20.w,
                                ),
                                12.w.width,
                                Expanded(
                                  child: TextWidget(
                                    'This action is permanent and cannot be reversed',
                                    color: Colors.red.shade700,
                                    style: FontConstant.oxygenSmall,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    maxLines: null,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          24.h.height,

                          // Action Buttons
                          Row(
                            children: [
                              // Cancel Button
                              Expanded(
                                child: Container(
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    borderRadius: 12.w.borderRadius,
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed: isLoading ? null : _handleCancel,
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF6B7280),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: 12.w.borderRadius,
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: FontConstant.oxygenMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: isLoading
                                            ? const Color(0xFFD1D5DB)
                                            : const Color(0xFF6B7280),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              16.w.width,

                              // Delete Button
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isLoading
                                          ? [
                                              Colors.grey.shade400,
                                              Colors.grey.shade500,
                                            ]
                                          : [
                                              Colors.red.shade500,
                                              Colors.red.shade600,
                                            ],
                                    ),
                                    borderRadius: 12.w.borderRadius,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            (isLoading
                                                    ? Colors.grey
                                                    : Colors.red)
                                                .withAlpha(0.3.opacityToAlpha),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : _handleConfirm,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: 12.w.borderRadius,
                                      ),
                                    ),
                                    child: isLoading
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 16.w,
                                                height: 16.w,
                                                child:
                                                    const CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                              ),
                                              8.w.width,
                                              Text(
                                                'Deleting...',
                                                style: FontConstant.oxygenMedium
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            'Yes, Delete',
                                            style: FontConstant.oxygenMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: 20.w.borderRadius),
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: 24.w.horizontal + 24.h.vertical,
          decoration: BoxDecoration(
            borderRadius: 20.w.borderRadius,
            color: Colors.white,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: 30.w.borderRadius,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 30.w,
                  color: Colors.green.shade600,
                ),
              ),
              20.h.height,
              Text(
                'Successfully Deleted! ✅',
                style: FontConstant.oxygenLargeBold.copyWith(
                  color: const Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              12.h.height,
              Text(
                'The item has been permanently removed from your account.',
                style: FontConstant.oxygenMedium.copyWith(
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              24.h.height,
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: 12.w.borderRadius,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: FontConstant.oxygenMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
