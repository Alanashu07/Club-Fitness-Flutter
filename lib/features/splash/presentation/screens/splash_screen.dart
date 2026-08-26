import 'package:club_fitness/config/local/app_data.dart';
import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/constants/constants.dart';
import 'package:club_fitness/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────────────────────────────
  late final AnimationController _logoCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _barCtrl;
  late final AnimationController _pulseCtrl;

  // ── Logo animations ────────────────────────────────────────────────────────
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _logoSlide;

  // ── Text animations ────────────────────────────────────────────────────────
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _taglineOpacity;

  // ── Loading bar ────────────────────────────────────────────────────────────
  late final Animation<double> _barProgress;
  late final Animation<double> _barOpacity;

  // ── Pulse glow on logo ─────────────────────────────────────────────────────
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();

    // Force dark status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Controllers
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Logo
    _logoScale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    // Text
    _titleOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // Bar
    _barProgress = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut));
    _barOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _barCtrl,
        curve: const Interval(0.0, 0.15, curve: Curves.easeIn),
      ),
    );

    // Pulse
    _pulse = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Sequence
    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _textCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _barCtrl.forward();

    // Navigate after bar completes + small pause
    await Future.delayed(const Duration(milliseconds: 1800));
    _navigate();
  }

  void _navigate() async {
    if (!mounted) return;
    if (AppData.accessTokenValue.isNotEmpty) {
      context.read<AuthBloc>().add(const GetMyProfileEvent());
      return;
    }
    context.go(Routes.login);
  }

  void _navigateToHome(String role) {
    if (!mounted) return;
    switch (role.toLowerCase()) {
      case 'admin':
        context.go(Routes.adminHome);
      case 'trainer':
      case 'staff':
        context.go(Routes.trainerHome);
      default:
        context.go(Routes.home);
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _barCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _navigateToHome(state.user.role);
          } else if (state is AuthFailure) {
            context.go(Routes.login);
          }
        },
        child: Stack(
          children: [
            // ── Background radial glow ─────────────────────────────────────────
            Positioned(
              top: size.height * 0.18,
              left: size.width * 0.5 - 180,
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 360,
                    height: 360,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primary.withAOpacity(0.18),
                          AppTheme.primary.withAOpacity(0.06),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Subtle grid lines (decorative) ─────────────────────────────────
            Positioned.fill(child: CustomPaint(painter: _GridPainter())),

            // ── Top accent line ────────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _logoOpacity,
                builder: (_, __) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primary,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Main content ───────────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, child) => FadeTransition(
                      opacity: _logoOpacity,
                      child: SlideTransition(
                        position: _logoSlide,
                        child: ScaleTransition(scale: _logoScale, child: child),
                      ),
                    ),
                    child: _LogoContainer(),
                  ),

                  const SizedBox(height: 32),

                  // Club Fitness name
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => FadeTransition(
                      opacity: _titleOpacity,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            // "CLUB" — outlined/light
                            Text(
                              'CLUB',
                              style: TextStyle(
                                color: Colors.white.withAOpacity(0.55),
                                fontSize: 22,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 14,
                              ),
                            ),
                            // "FITNESS" — bold red
                            const Text(
                              'FITNESS',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 10,
                                height: 0.95,
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Tagline
                            FadeTransition(
                              opacity: _taglineOpacity,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _dividerDot(),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'YOUR GYM. YOUR WAY.',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 4,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  _dividerDot(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Loading bar (bottom) ───────────────────────────────────────────
            Positioned(
              bottom: 60,
              left: 48,
              right: 48,
              child: AnimatedBuilder(
                animation: _barCtrl,
                builder: (_, __) => FadeTransition(
                  opacity: _barOpacity,
                  child: Column(
                    children: [
                      // Progress track
                      Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withAOpacity(0.08),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _barProgress.value,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF8B0000),
                                  AppTheme.primary,
                                  Color(0xFFFF6B6B),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withAOpacity(0.6),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Powered by Club Fitness',
                        style: TextStyle(
                          color: Colors.white.withAOpacity(0.2),
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dividerDot() => Container(
    width: 4,
    height: 4,
    decoration: const BoxDecoration(
      color: AppTheme.primary,
      shape: BoxShape.circle,
    ),
  );
}

// ─── Logo container widget ────────────────────────────────────────────────────
class _LogoContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withAOpacity(0.15),
              width: 1,
            ),
          ),
        ),
        // Middle ring
        Container(
          width: 124,
          height: 124,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withAOpacity(0.25),
              width: 1,
            ),
          ),
        ),
        // Logo card
        Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            color: AppTheme.card,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.primary.withAOpacity(0.5),
              width: 2,
            ),
            image: const DecorationImage(
              image: AssetImage(AssetConstants.logoTransparent),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAOpacity(0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withAOpacity(0.5),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          // child: ClipOval(
          //   child: Padding(
          //     padding: const EdgeInsets.all(20),
          //     child: Image.asset(AssetConstants.logo, fit: BoxFit.cover),
          //   ),
          // ),
        ),
      ],
    );
  }
}

// ─── Subtle background grid painter ──────────────────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAOpacity(0.025)
      ..strokeWidth = 0.5;

    const spacing = 44.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
