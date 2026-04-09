import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_screen.dart';
import '../l10n/app_strings.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;

  late Animation<double> _logoFade;
  late Animation<double> _logoSlide;
  late Animation<double> _dividerFade;
  late Animation<double> _textFade;
  late Animation<double> _textScale;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))..repeat(reverse: true);
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
    _particleController = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.35, curve: Curves.easeIn)));
    _logoSlide = Tween<double>(begin: -40.0, end: 0.0).animate(
        CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _dividerFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _mainController, curve: const Interval(0.3, 0.6, curve: Curves.easeIn)));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)));
    _textScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _mainController, curve: const Interval(0.5, 1.0, curve: Curves.elasticOut)));
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    _mainController.forward();
    Future.delayed(const Duration(seconds: 5), _goToHome);
  }

  void _goToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else {
      // iOS tidak benarkan force close
      // Minimize ke home screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: GestureDetector(
        onTap: _goToHome,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF030E1F),
                Color(0xFF0A2342),
                Color(0xFF0D3B6E),
                Color(0xFF0A2342),
                Color(0xFF030E1F),
              ],
              stops: [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                // Floating particles
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(size.width, size.height),
                      painter: _ParticlePainter(_particleController.value),
                    );
                  },
                ),

                // Main content
                Center(
                  child: AnimatedBuilder(
                    animation: _mainController,
                    builder: (context, child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo
                            FadeTransition(
                              opacity: _logoFade,
                              child: Transform.translate(
                                offset: Offset(0, _logoSlide.value),
                                child: Container(
                                  width: 190,
                                  height: 85,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.4),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10)),
                                      BoxShadow(
                                          color: const Color(0xFF1565C0).withOpacity(0.6),
                                          blurRadius: 40,
                                          spreadRadius: 5),
                                    ],
                                  ),
                                  child: Image.asset(
                                      'assets/images/Pi7_Tool_splash.png',
                                      fit: BoxFit.contain),
                                ),
                              ),
                            ),
                            const SizedBox(height: 56),

                            // Top divider with anchor
                            FadeTransition(
                              opacity: _dividerFade,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 0.8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.4)
                                        ]),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Icon(Icons.anchor,
                                        color: Colors.white.withOpacity(0.6), size: 18),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 0.8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.white.withOpacity(0.4),
                                          Colors.transparent
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // DEFINING EXCELLENCE text
                            FadeTransition(
                              opacity: _textFade,
                              child: ScaleTransition(
                                scale: _textScale,
                                child: Column(
                                  children: [
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) => Text(
                                        '— LUMUT NAVAL SHIPYARD —',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(
                                              0.35 + _pulseAnimation.value * 0.2),
                                          fontSize: 9,
                                          letterSpacing: 3.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    AnimatedBuilder(
                                      animation: _shimmerAnimation,
                                      builder: (context, child) {
                                        return ShaderMask(
                                          shaderCallback: (bounds) {
                                            return LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: const [
                                                Color(0xFFE3F2FD),
                                                Color(0xFFFFFFFF),
                                                Color(0xFFB3E5FC),
                                                Color(0xFFFFFFFF),
                                                Color(0xFFE3F2FD),
                                              ],
                                              stops: [
                                                0.0,
                                                (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                                                _shimmerAnimation.value.clamp(0.0, 1.0),
                                                (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                                                1.0,
                                              ],
                                            ).createShader(bounds);
                                          },
                                          child: AnimatedBuilder(
                                            animation: _pulseAnimation,
                                            builder: (context, child) => Text(
                                              'DEFINING\nEXCELLENCE',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 34,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 5,
                                                height: 1.3,
                                                shadows: [
                                                  Shadow(
                                                      color: Colors.white.withOpacity(
                                                          _pulseAnimation.value * 0.6),
                                                      blurRadius: 30),
                                                  Shadow(
                                                      color: const Color(0xFF64B5F6)
                                                          .withOpacity(_pulseAnimation.value),
                                                      blurRadius: 60),
                                                  Shadow(
                                                      color: const Color(0xFF1565C0)
                                                          .withOpacity(0.8),
                                                      blurRadius: 80),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    AnimatedBuilder(
                                      animation: _pulseAnimation,
                                      builder: (context, child) => Container(
                                        width: 120,
                                        height: 1.5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(
                                                  0.3 + _pulseAnimation.value * 0.4),
                                              Colors.white.withOpacity(
                                                  0.6 + _pulseAnimation.value * 0.4),
                                              Colors.white.withOpacity(
                                                  0.3 + _pulseAnimation.value * 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.white.withOpacity(
                                                    _pulseAnimation.value * 0.5),
                                                blurRadius: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Bottom divider with anchor
                            FadeTransition(
                              opacity: _textFade,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 0.8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.4)
                                        ]),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Icon(Icons.anchor,
                                        color: Colors.white.withOpacity(0.6), size: 18),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 0.8,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(colors: [
                                          Colors.white.withOpacity(0.4),
                                          Colors.transparent
                                        ]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Exit button — top left
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _exitApp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.exit_to_app, color: Colors.white, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.get('quote_exit'),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Skip button — top right
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _goToHome,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Text(
                        AppStrings.get('quote_skip'),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ),
                ),

                // Progress bar — bottom
                Positioned(
                  bottom: 32,
                  left: 32,
                  right: 32,
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 5),
                        builder: (context, value, child) => ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.get('quote_tap'),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.35), fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    super.dispose();
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> _particles = List.generate(25, (i) => _Particle(i));

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (var p in _particles) {
      final t = (progress + p.offset) % 1.0;
      final x = p.x * size.width;
      final y = size.height - (t * size.height * 1.2);
      final opacity = (sin(t * pi) * 0.4).clamp(0.0, 0.4);
      final radius = p.size * (1 - t * 0.5);
      final paint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _Particle {
  late double x;
  late double offset;
  late double size;

  _Particle(int seed) {
    final rng = Random(seed * 137);
    x = rng.nextDouble();
    offset = rng.nextDouble();
    size = 1.0 + rng.nextDouble() * 2.5;
  }
}
