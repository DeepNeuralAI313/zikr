import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize pulse animation for logo
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Initialize fade animation for tagline
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Initialize glow animation
    _glowController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _pulseController.repeat(reverse: true);
    _fadeController.forward();
    _glowController.repeat(reverse: true);

    // Navigate to home after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo with Arabic Calligraphy
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppGradients.logoGradient,
                      boxShadow: [
                        BoxShadow(
                          color: accentYellow.withOpacity(_glowAnimation.value * 0.6),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                        BoxShadow(
                          color: accentPink.withOpacity(_glowAnimation.value * 0.4),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                        BoxShadow(
                          color: accentCyan.withOpacity(_glowAnimation.value * 0.3),
                          blurRadius: 80,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Center(
                      child: ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.white, Colors.white.withOpacity(0.8)],
                        ).createShader(bounds),
                        child: Text(
                          'ذِكْر',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Amiri',
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            SizedBox(height: 50),
            
            // Animated Tagline
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Text(
                    'Track Your Quran & Zikr Journey',
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            
            SizedBox(height: 80),
            
            // Loading indicator with custom color
            Container(
              width: 45,
              height: 45,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(accentCyan),
                backgroundColor: accentCyan.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}