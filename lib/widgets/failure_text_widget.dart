import 'package:flutter/material.dart';
import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/widgets/common_widgets.dart';
import '../../config/theme/theme.dart';
import '../../core/constants/constants.dart';

enum FailureType { general, network, server, timeout }

class FailureTextWidget extends StatefulWidget {
  final Failure failure;
  final Color? textColor;
  final Color? primaryColor;
  final VoidCallback onRetry;

  const FailureTextWidget(this.failure, {
    super.key,
    this.textColor,
    this.primaryColor,
    required this.onRetry,
  });

  @override
  State<FailureTextWidget> createState() => _FailureTextWidgetState();

  static FailureTextWidget forceLogin(String screenName) => FailureTextWidget(
    ForceLoginFailure(
      title: 'Login Required',
      message:
          'To Access $screenName, you must be an authorized user. Plase login to access $screenName.',
      code: 403,
    ),
    onRetry: () {},
  );
}

class _FailureTextWidgetState extends State<FailureTextWidget>
    with TickerProviderStateMixin {
  FailureType get getType {
    switch (widget.failure.code) {
      case >= 500 && < 600:
        return FailureType.server;
      case -1:
        return FailureType.network;
      case -2:
        return FailureType.timeout;
      default:
        return FailureType.general;
    }
  }

  late AnimationController _animationController;
  late AnimationController _retryController;
  late AnimationController _iconPulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _iconPulseAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _retryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _iconPulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.141592653589793,
    ).animate(CurvedAnimation(parent: _retryController, curve: Curves.linear));

    _iconPulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconPulseController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _retryController.dispose();
    _iconPulseController.dispose();
    super.dispose();
  }

  // Accent color per failure type — falls back to AppTheme.primary for general
  Color get _iconColor {
    switch (getType) {
      case FailureType.network:
        return const Color(0xFF3B82F6); // blue-500
      case FailureType.server:
        return AppTheme.error;
      case FailureType.timeout:
        return AppTheme.warning;
      case FailureType.general:
        return AppTheme.primary;
    }
  }

  // Icon background uses theme surface/card tones instead of light hex tints
  Color get _iconBackgroundColor {
    return _iconColor.withAOpacity(0.15);
  }

  IconData get _iconData {
    switch (getType) {
      case FailureType.network:
        return Icons.wifi_off_rounded;
      case FailureType.server:
        return Icons.dns_rounded;
      case FailureType.timeout:
        return Icons.schedule_rounded;
      case FailureType.general:
        return Icons.warning_rounded;
    }
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);
    _retryController.repeat();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      _retryController.stop();
      _retryController.reset();
      setState(() => _isRetrying = false);
      widget.onRetry();
    }
  }

  bool get _loginRequired => widget.failure is ForceLoginFailure;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppTheme.background,
      padding: 24.w.horizontal,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon Section with pulse effect
                    AnimatedBuilder(
                      animation: _iconPulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 96.w,
                          height: 96.w,
                          decoration: BoxDecoration(
                            color: _iconBackgroundColor,
                            borderRadius: 48.w.borderRadius,
                            boxShadow: [
                              BoxShadow(
                                color: _iconColor.withAOpacity(0.12),
                                blurRadius: 24 + (12 * _iconPulseAnimation.value),
                                offset: const Offset(0, 4),
                                spreadRadius: 2 * _iconPulseAnimation.value,
                              ),
                            ],
                          ),
                          child: Icon(
                            _loginRequired
                                ? FlaticonRoundedIcons.srEntrance
                                : _iconData,
                            size: 46.w,
                            color: _iconColor,
                          ),
                        );
                      },
                    ),

                    28.h.height,

                    // Title
                    Text(
                      widget.failure.title,
                      style: FontConstant.oxygenLargeBold.copyWith(
                        color: widget.textColor ?? AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    12.h.height,

                    // Message
                    Text(
                      widget.failure.message,
                      style: FontConstant.oxygenMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    36.h.height,

                    // Retry / Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 52.h,
                      child: AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          final buttonColor = widget.primaryColor ?? _iconColor;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  buttonColor,
                                  buttonColor.withAOpacity(0.85),
                                ],
                              ),
                              borderRadius: 14.w.borderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: buttonColor.withAOpacity(0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: _loginRequired
                                ? _loginButton()
                                : TextButton(
                                    onPressed: _isRetrying ? null : _handleRetry,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: 14.w.borderRadius,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Transform.rotate(
                                          angle: _isRetrying
                                              ? _rotationAnimation.value
                                              : 0,
                                          child: Icon(
                                            Icons.refresh_rounded,
                                            color: Colors.white,
                                            size: 18.w,
                                          ),
                                        ),
                                        12.w.width,
                                        Text(
                                          _isRetrying ? 'Retrying...' : 'Try Again',
                                          style: FontConstant.oxygenMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _loginButton() {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: 14.w.borderRadius),
      ),
      child: TextWidget(
        'Login',
        style: FontConstant.oxygenMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onPressed: () =>
          context.go('${Routes.login}?from=${context.router.state.uri.path}'),
    );
  }
}