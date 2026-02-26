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
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _goToLoading() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const LoadingScreen(),
        transitionsBuilder: (context, animation, _, child) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B2838),
              Color(0xFF1A3A5C),
              Color(0xFF2D1B69),
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Cercles décoratifs en arrière-plan
              Positioned(
                top: -80,
                right: -80,
                child: AnimatedBuilder(
                  animation: _rotateAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateAnimation.value * 2 * 3.14159,
                      child: child,
                    );
                  },
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.06),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF667EEA).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                left: -100,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF764BA2).withOpacity(0.07),
                  ),
                ),
              ),
              // Étoiles décoratives
              ..._buildStars(),

              // Bouton thème
              Positioned(
                top: 12,
                right: 16,
                child: ValueListenableBuilder(
                  valueListenable: themeNotifier,
                  builder: (context, themeMode, child) {
                    return _GlassButton(
                      onTap: () {
                        themeNotifier.value = themeNotifier.value == ThemeMode.light
                            ? ThemeMode.dark
                            : ThemeMode.light;
                      },
                      child: Icon(
                        themeMode == ThemeMode.light
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    );
                  },
                ),
              ),

              // Contenu principal
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône soleil animée
                      AnimatedBuilder(
                        animation: Listenable.merge([_pulseAnimation, _floatAnimation]),
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            ),
                          );
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Halo externe
                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFD700).withOpacity(0.25),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            // Corps du soleil
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFFFE066), Color(0xFFFF9500)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.5),
                                    blurRadius: 50,
                                    spreadRadius: 5,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFFFF9500).withOpacity(0.3),
                                    blurRadius: 80,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.wb_sunny_rounded,
                                size: 75,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Titre
                      const Text(
                        'MÉTÉO MONDE',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Votre fenêtre sur le monde',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.55),
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // Carte glassmorphique
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 28,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.18),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Villes avec emojis
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _CityBadge(flag: '🗼', city: 'Paris'),
                                    _CityBadge(flag: '🗽', city: 'New York'),
                                    _CityBadge(flag: '🗾', city: 'Tokyo'),
                                    _CityBadge(flag: '🇬🇧', city: 'London'),
                                    _CityBadge(flag: '🌍', city: 'Dakar'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Températures, humidité et vent\npour 5 villes du globe en temps réel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.70),
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Bouton principal
                      GestureDetector(
                        onTap: _goToLoading,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667EEA).withOpacity(0.55),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rocket_launch_rounded,
                                  color: Colors.white, size: 22),
                              SizedBox(width: 12),
                              Text(
                                'Lancer l\'expérience',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStars() {
    final starPositions = [
      [40.0, 80.0], [120.0, 40.0], [200.0, 150.0], [300.0, 60.0],
      [80.0, 300.0], [350.0, 200.0], [30.0, 500.0], [250.0, 450.0],
      [380.0, 120.0], [15.0, 180.0],
    ];
    return starPositions.map((pos) {
      return Positioned(
        left: pos[0],
        top: pos[1],
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.4),
          ),
        ),
      );
    }).toList();
  }
}

class _CityBadge extends StatelessWidget {
  final String flag;
  final String city;

  const _CityBadge({required this.flag, required this.city});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(flag, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 4),
        Text(
          city,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _GlassButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
