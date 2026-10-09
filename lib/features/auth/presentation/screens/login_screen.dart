import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/constants/asset_constants.dart';
import 'package:club_fitness/core/exceptions/failure.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/features/auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ─── Login Screen ─────────────────────────────────────────────────────────────

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // Mode: 'password' or 'otp'
  String _mode = 'password';

  // Step: 'input' → 'otp'
  String _step = 'input';

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  // Entrance animations
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Step transition
  late final AnimationController _stepCtrl;
  late final Animation<double> _stepFade;
  late final Animation<Offset> _stepSlide;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    _stepCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _stepFade = CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut);
    _stepSlide = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _stepCtrl, curve: Curves.easeOut));
    _stepCtrl.value = 1.0;

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _stepCtrl.dispose();
    _passwordCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // Switch input mode (phone ↔ email)
  void _switchMode(String mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _step = 'input';
    });
    _stepCtrl.forward(from: 0);
  }

  void _signInWithPassword() {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email and password')),
      );
      return;
    }
    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(
      SignInWithEmailPasswordEvent(email: email, password: password),
    );
  }

  // Send OTP → move to OTP step
  void _sendOtp() {
    setState(() => _isLoading = true);
    context.read<AuthBloc>().add(
      SignInWithEmailRequestEvent(email: _emailCtrl.text.trim()),
    );
  }

  // Back to input step
  void _backToInput() {
    setState(() => _step = 'input');
    _stepCtrl.forward(from: 0);
  }

  String enteredOtp = "";

  // Verify OTP → navigate
  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
      enteredOtp = otp;
    });
    context.read<AuthBloc>().add(
      SignInWithEmailVerifyEvent(email: _emailCtrl.text.trim(), otp: otp),
    );
  }

  void _continueWithGoogle() {
    context.read<AuthBloc>().add(const SignInWithGoogleEvent());
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.background,
      resizeToAvoidBottomInset: false,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            setState(() => _isLoading = false);
            context.showToastFromFailure(state.failure);
          } else if (state is AuthSuccess) {
            setState(() => _isLoading = false);
            String from =
                context.router.state.uri.queryParameters['from'] ?? '';
            if (from.isNotEmpty) return context.go(from);
            switch (state.user.role.toLowerCase()) {
              case 'admin':
                context.go(Routes.adminHome);
              case 'trainer':
              case 'staff':
                context.go(Routes.trainerHome);
              default:
                context.go(Routes.home);
            }
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // ── Glow blobs ──────────────────────────────────────────────────
              Positioned(
                top: -80,
                left: -60,
                child: _GlowBlob(
                  color: AppTheme.primary.withAOpacity(0.18),
                  size: 300,
                ),
              ),
              Positioned(
                bottom: size.height * 0.25,
                right: -80,
                child: _GlowBlob(
                  color: const Color(0xFF1565C0).withAOpacity(0.12),
                  size: 240,
                ),
              ),

              // ── Grid bg ─────────────────────────────────────────────────────
              Positioned.fill(child: CustomPaint(painter: _FadedGridPainter())),

              // ── Content ─────────────────────────────────────────────────────
              SafeArea(
                child: AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: bottom),
                  child: Column(
                    children: [
                      // Logo area
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: _buildLogoArea(),
                        ),
                      ),

                      // Card area — expands to fill
                      Expanded(
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: SlideTransition(
                            position: _slideAnim,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: _buildCard(
                                state is AuthFailure ? state.failure : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Logo Area ───────────────────────────────────────────────────────────────
  Widget _buildLogoArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Column(
        children: [
          // Logo mark
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage(AssetConstants.logo),
              ),
              border: Border.all(
                color: AppTheme.primary.withAOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withAOpacity(0.25),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            // child: const Icon(
            //   Icons.fitness_center_rounded,
            //   color: AppTheme.primary,
            //   size: 32,
            // ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Club Fitness',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your gym, your way.',
            style: TextStyle(
              color: Colors.white.withAOpacity(0.35),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ── Auth Card ───────────────────────────────────────────────────────────────
  Widget _buildCard(Failure? failure) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAOpacity(0.35),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisSize: MainAxisSize.min,
        shrinkWrap: true,
        children: [
          // Step content
          FadeTransition(
            opacity: _stepFade,
            child: SlideTransition(
              position: _stepSlide,
              child: _step == 'input' ? _buildInputStep() : _buildOtpStep(),
            ),
          ),

          const SizedBox(height: 24),

          // ── Divider ────────────────────────────────────────────────────
          if (_step == 'input') ...[
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withAOpacity(0.08),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: Colors.white.withAOpacity(0.3),
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withAOpacity(0.08),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Google button
            _GoogleButton(onTap: _continueWithGoogle),
            const SizedBox(height: 20),

            // Mode switch
            _buildModeSwitch(),

            const SizedBox(height: 20),
            if (failure != null) _buildFailure(failure),
          ],
        ],
      ),
    );
  }

  Widget _buildFailure(Failure failure) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            failure.title,
            style: const TextStyle(
              color: AppTheme.error,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            failure.message,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── Input Step ──────────────────────────────────────────────────────────────
  Widget _buildInputStep() {
    final isPassword = _mode == 'password';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPassword
              ? 'Sign in with\nyour password'
              : 'Enter your\nemail address',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isPassword
              ? 'Enter your email and password to continue.'
              : "We'll send a one-time code to your inbox.",
          style: TextStyle(
            color: Colors.white.withAOpacity(0.38),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),

        _EmailField(controller: _emailCtrl),

        if (isPassword) ...[
          const SizedBox(height: 12),
          _PasswordField(
            controller: _passwordCtrl,
            onSubmitted: _signInWithPassword,
          ),
          const SizedBox(height: 12),
          _buildFirstTimeInfo(),
        ],
        const SizedBox(height: 20),

        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (_step == 'otp') return;
            if (state is AuthOtpSent) {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _step = 'otp';
              });
              _stepCtrl.forward(from: 0);
            }
          },
          child: _PrimaryButton(
            label: isPassword ? 'Sign In' : 'Send OTP',
            isLoading: _isLoading,
            onTap: isPassword ? _signInWithPassword : _sendOtp,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstTimeInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withAOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primary.withAOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AppTheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withAOpacity(0.6),
                  fontSize: 12,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text:
                        'First time logging in? Your password is your date of birth in ',
                  ),
                  TextSpan(
                    text: 'DD/MM/YYYY',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: ' format.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── OTP Step ────────────────────────────────────────────────────────────────
  Widget _buildOtpStep() {
    final destination = _emailCtrl.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back
        GestureDetector(
          onTap: _backToInput,
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withAOpacity(0.08),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),

        // Heading
        const Text(
          'Verify code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white.withAOpacity(0.38),
              fontSize: 13,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'A 6-digit code was sent to '),
              TextSpan(
                text: destination,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // OTP boxes
        _OtpInput(onCompleted: _verifyOtp),
        const SizedBox(height: 20),

        // Verify button
        _PrimaryButton(
          label: 'Verify & Sign In',
          isLoading: _isLoading,
          onTap: () => _verifyOtp('------'),
        ),
        const SizedBox(height: 16),

        // Resend
        const Center(child: _ResendTimer()),
      ],
    );
  }

  // ── Mode Switch (bottom of card) ─────────────────────────────────────────────
  Widget _buildModeSwitch() {
    final isPassword = _mode == 'password';
    return Center(
      child: GestureDetector(
        onTap: () => _switchMode(isPassword ? 'otp' : 'password'),
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.white.withAOpacity(0.35),
              fontSize: 13,
            ),
            children: [
              TextSpan(
                text: isPassword
                    ? 'Use email OTP instead  '
                    : 'Use password instead  ',
              ),
              TextSpan(text: isPassword ? '✉' : '🔒'),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Phone Field ──────────────────────────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSubmitted;
  const _PasswordField({required this.controller, this.onSubmitted});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => widget.onSubmitted?.call(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Password',
          hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          prefixIcon: const Icon(
            Icons.lock_outline_rounded,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
      ),
    );
  }
}
// ─── Email Field ──────────────────────────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  const _EmailField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAOpacity(0.07), width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: const InputDecoration(
          hintText: 'you@example.com',
          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: AppTheme.textSecondary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        ),
      ),
    );
  }
}

// ─── OTP Input (6 boxes) ──────────────────────────────────────────────────────

class _OtpInput extends StatefulWidget {
  final ValueChanged<String> onCompleted;
  const _OtpInput({required this.onCompleted});
  @override
  State<_OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<_OtpInput> {
  final _count = 6;
  late final List<TextEditingController> _ctrls;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(_count, (_) => TextEditingController());
    _nodes = List.generate(_count, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _nodes[0].requestFocus(),
    );
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  void _onChanged(int i, String val) {
    if (val.length > 1) {
      // Handle paste
      final digits = val.replaceAll(RegExp(r'\D'), '');
      for (int j = 0; j < _count && j < digits.length; j++) {
        _ctrls[j].text = digits[j];
      }
      final nextFocus = digits.length < _count ? digits.length : _count - 1;
      _nodes[nextFocus].requestFocus();
      _checkComplete();
      return;
    }
    if (val.isNotEmpty && i < _count - 1) {
      _nodes[i + 1].requestFocus();
    }
    _checkComplete();
  }

  void _onKeyEvent(int i, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrls[i].text.isEmpty &&
        i > 0) {
      _nodes[i - 1].requestFocus();
      _ctrls[i - 1].clear();
    }
  }

  void _checkComplete() {
    final otp = _ctrls.map((c) => c.text).join();
    if (otp.length == _count) {
      widget.onCompleted(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_count, (i) {
        return _OtpBox(
          controller: _ctrls[i],
          focusNode: _nodes[i],
          onChanged: (v) => _onChanged(i, v),
          onKeyEvent: (e) => _onKeyEvent(i, e),
        );
      }),
    );
  }
}

class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });
  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(
      () => setState(() => _focused = widget.focusNode.hasFocus),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.controller.text.isNotEmpty;
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: widget.onKeyEvent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 52,
        decoration: BoxDecoration(
          color: _focused
              ? AppTheme.primary.withAOpacity(0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _focused
                ? AppTheme.primary
                : filled
                ? AppTheme.primary.withAOpacity(0.4)
                : Colors.white.withAOpacity(0.1),
            width: _focused ? 2 : 1,
          ),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: widget.onChanged,
        ),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLoading
              ? AppTheme.primary.withAOpacity(0.6)
              : AppTheme.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withAOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Google Button ────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GoogleButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAOpacity(0.1), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo drawn inline
            _GoogleLogo(size: 20),
            SizedBox(width: 10),
            Text(
              'Continue with Google',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Draw colored arcs (simplified Google G)
    final colors = [
      const Color(0xFF4285F4), // blue
      const Color(0xFFEA4335), // red
      const Color(0xFFFBBC05), // yellow
      const Color(0xFF34A853), // green
    ];

    const sweepAngles = [
      1.67, // blue
      1.57, // red
      0.79, // yellow
      2.36, // green
    ];

    const startAngles = [-0.26, 1.41, 2.98, 3.77];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.18
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r - size.width * 0.09),
        startAngles[i],
        sweepAngles[i],
        false,
        paint,
      );
    }

    // White horizontal bar for the "G" cutout
    final barPaint = Paint()
      ..color = AppTheme.surface
      ..strokeWidth = size.width * 0.19;
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.75, cy), barPaint);
    // Small inner circle mask
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.46,
      Paint()..color = AppTheme.surface,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Resend Timer ─────────────────────────────────────────────────────────────

class _ResendTimer extends StatefulWidget {
  const _ResendTimer();
  @override
  State<_ResendTimer> createState() => _ResendTimerState();
}

class _ResendTimerState extends State<_ResendTimer> {
  int _seconds = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _seconds = 30;
      _canResend = false;
    });
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _seconds--);
      if (_seconds <= 0) {
        setState(() => _canResend = true);
        return false;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_canResend) {
      return GestureDetector(
        onTap: _startTimer,
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 13),
            children: [
              TextSpan(
                text: "Didn't receive it?  ",
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              TextSpan(
                text: 'Resend OTP',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13),
        children: [
          TextSpan(
            text: 'Resend code in  ',
            style: TextStyle(color: Colors.white.withAOpacity(0.3)),
          ),
          TextSpan(
            text: '0:${_seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Background Painters ──────────────────────────────────────────────────────

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, Colors.transparent]),
    ),
  );
}

class _FadedGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAOpacity(0.02)
      ..strokeWidth = 0.5;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
