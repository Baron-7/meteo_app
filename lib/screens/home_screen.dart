import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import '../widgets/sky_atmosphere.dart';
import 'loading_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _launch() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, _) => const LoadingScreen(),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SkyAtmosphere(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Stack(
              children: [
                // Bouton thème (haut droite)
                Positioned(
                  top: 10,
                  right: 16,
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, _) {
                      return _GlassBtn(
                        onTap: () {
                          themeNotifier.value = mode == ThemeMode.light
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                        child: Icon(
                          mode == ThemeMode.light
                              ? Icons.nights_stay_rounded
                              : Icons.wb_sunny_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),

                // Contenu centré
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(flex: 3),

                      // Titre
                      const Text(
                        'Météo',
                        style: TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Météo en temps réel dans le monde',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withValues(alpha: 0.68),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(flex: 2),

                      // Carte frosted : 5 villes
                      _FrostedCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: const [
                            _CityPill(flag: '🗼', city: 'Paris'),
                            _CityPill(flag: '🗽', city: 'New York'),
                            _CityPill(flag: '⛩️', city: 'Tokyo'),
                            _CityPill(flag: '🎡', city: 'London'),
                            _CityPill(flag: '🌍', city: 'Dakar'),
                          ],
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Bouton lancer
                      _LaunchButton(onTap: _launch),

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

// ─── Widgets locaux ───────────────────────────────────────────────────────────

class _FrostedCard extends StatelessWidget {
  final Widget child;
  const _FrostedCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.20),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(flag, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 5),
        Text(
          city,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.65),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _GlassBtn({required this.child, required this.onTap});

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
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.22)),
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
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) {
        setState(() => _down = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.38),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
