import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _fadeController;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0D1B3E),
                    const Color(0xFF1A3461),
                    const Color(0xFF1F4287),
                  ]
                : [
                    const Color(0xFF48B5E8),
                    const Color(0xFF2183C4),
                    const Color(0xFF1565C0),
                  ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Stack(
              children: [
                // Nuages décoratifs subtils
                Positioned(
                  top: 30,
                  left: -30,
                  child: _CloudShape(
                    width: 180,
                    opacity: isDark ? 0.04 : 0.12,
                  ),
                ),
                Positioned(
                  top: 80,
                  right: -20,
                  child: _CloudShape(
                    width: 140,
                    opacity: isDark ? 0.03 : 0.09,
                  ),
                ),

                // Bouton thème en haut à droite
                Positioned(
                  top: 10,
                  right: 16,
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, themeMode, _) {
                      return _TopButton(
                        onTap: () {
                          themeNotifier.value =
                              themeMode == ThemeMode.light
                                  ? ThemeMode.dark
                                  : ThemeMode.light;
                        },
                        child: Icon(
                          themeMode == ThemeMode.light
                              ? Icons.nights_stay_rounded
                              : Icons.wb_sunny_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),

                // Contenu principal
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // Soleil animé
                      AnimatedBuilder(
                        animation: _floatAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          );
                        },
                        child: _SunWidget(isDark: isDark),
                      ),

                      const SizedBox(height: 44),

                      // Titre
                      const Text(
                        'Météo',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Météo en temps réel pour 5 villes du monde',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.75),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Carte d'accueil frosted
                      _FrostedCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _CityPill(flag: '🗼', city: 'Paris'),
                                _CityPill(flag: '🗽', city: 'New York'),
                                _CityPill(flag: '⛩️', city: 'Tokyo'),
                                _CityPill(flag: '🎡', city: 'London'),
                                _CityPill(flag: '🌍', city: 'Dakar'),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Bouton principal
                      _LaunchButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, animation, __) =>
                                  const LoadingScreen(),
                              transitionsBuilder:
                                  (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 36),
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
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _SunWidget extends StatelessWidget {
  final bool isDark;
  const _SunWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Halo doux
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD426).withValues(alpha: isDark ? 0.12 : 0.20),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Corps du soleil
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFE566), Color(0xFFFFAA00)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFCC00).withValues(alpha: 0.35),
                blurRadius: 40,
                spreadRadius: 8,
              ),
            ],
          ),
          child: const Icon(
            Icons.wb_sunny_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _FrostedCard extends StatelessWidget {
  final Widget child;
  const _FrostedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CityPill extends StatelessWidget {
  final String flag;
  final String city;
  const _CityPill({required this.flag, required this.city});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(flag, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(
          city,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.70),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _TopButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TopButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _LaunchButton extends StatefulWidget {
  final VoidCallback onTap;
  const _LaunchButton({required this.onTap});

  @override
  State<_LaunchButton> createState() => _LaunchButtonState();
}

class _LaunchButtonState extends State<_LaunchButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
              width: 1,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Découvrir la météo mondiale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloudShape extends StatelessWidget {
  final double width;
  final double opacity;
  const _CloudShape({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: width,
        height: width * 0.55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(width / 2),
        ),
      ),
    );
  }
}
