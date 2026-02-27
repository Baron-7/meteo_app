import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Période de la journée ────────────────────────────────────────────────────

enum DayPeriod { dawn, morning, midday, afternoon, sunset, dusk, night }

// ─── Widget principal ─────────────────────────────────────────────────────────

/// Fond atmosphérique animé : ciel + soleil/lune + nuages + étoiles.
///
/// [cityLocalHour]  : heure locale RÉELLE de la ville (calculée via timezone).
///                    Si null → heure locale de l'appareil.
/// [cityIsDaytime]  : true si l'API indique qu'il fait jour dans la ville.
///                    Garantit qu'on ne montre pas la nuit quand c'est le jour.
/// [weatherIconCode]: code météo OpenWeather (01, 02, 03…) pour le nombre de nuages.
class SkyAtmosphere extends StatefulWidget {
  final Widget child;
  final int? cityLocalHour;
  final bool? cityIsDaytime;
  final String? weatherIconCode;

  const SkyAtmosphere({
    super.key,
    required this.child,
    this.cityLocalHour,
    this.cityIsDaytime,
    this.weatherIconCode,
  });

  @override
  State<SkyAtmosphere> createState() => _SkyAtmosphereState();
}

class _SkyAtmosphereState extends State<SkyAtmosphere>
    with TickerProviderStateMixin {
  late final AnimationController _cloud1;
  late final AnimationController _cloud2;
  late final AnimationController _cloud3;
  late final AnimationController _glow;
  late final AnimationController _twinkle;

  late DayPeriod _period;
  late int _hour;

  // Positions des étoiles (générées une seule fois avec graine fixe)
  late final List<List<double>> _stars;

  @override
  void initState() {
    super.initState();

    // ── Heure utilisée pour les effets ──
    // Priorité : heure locale de la ville (API) > heure locale appareil
    _hour = widget.cityLocalHour ?? DateTime.now().hour;
    _period = _buildPeriod();

    // Étoiles fixes (graine 42 → positions stables entre les rebuilds)
    final rng = math.Random(42);
    _stars = List.generate(
      24, // 24 étoiles (au lieu de 32) → moins de charge GPU
      (_) => [
        rng.nextDouble(),
        rng.nextDouble() * 0.62,
        rng.nextDouble() * 1.6 + 0.7,
        rng.nextDouble(), // phase initiale
      ],
    );

    // Nuages – durées longues → peu de frames de mise à jour
    _cloud1 = AnimationController(
        duration: const Duration(seconds: 45), vsync: this)
      ..repeat();

    _cloud2 = AnimationController(
        duration: const Duration(seconds: 65), vsync: this);
    _cloud2.value = 0.38;
    _cloud2.repeat();

    _cloud3 = AnimationController(
        duration: const Duration(seconds: 55), vsync: this);
    _cloud3.value = 0.72;
    _cloud3.repeat();

    // Halo solaire (plus lent = moins de repaints)
    _glow = AnimationController(
        duration: const Duration(seconds: 3), vsync: this)
      ..repeat(reverse: true);

    // Scintillement des étoiles
    _twinkle = AnimationController(
        duration: const Duration(seconds: 6), vsync: this)
      ..repeat();
  }

  /// Détermine la période du jour à partir de l'heure locale de la VILLE.
  DayPeriod _buildPeriod() {
    final period = _periodFromHour(_hour);

    // Si l'API dit "il fait jour" mais la période calculée est nuit/crépuscule
    // → forcer "milieu de journée"
    if (widget.cityIsDaytime == true && _isNightPeriod(period)) {
      return DayPeriod.midday;
    }

    // Si l'API dit "c'est la nuit" mais la période locale est jour → forcer nuit
    if (widget.cityIsDaytime == false && !_isNightPeriod(period)) {
      return DayPeriod.night;
    }

    return period;
  }

  DayPeriod _periodFromHour(int h) {
    if (h >= 5 && h < 7) return DayPeriod.dawn;
    if (h >= 7 && h < 11) return DayPeriod.morning;
    if (h >= 11 && h < 15) return DayPeriod.midday;
    if (h >= 15 && h < 18) return DayPeriod.afternoon;
    if (h >= 18 && h < 20) return DayPeriod.sunset;
    if (h >= 20 && h < 22) return DayPeriod.dusk;
    return DayPeriod.night;
  }

  bool _isNightPeriod(DayPeriod p) =>
      p == DayPeriod.night || p == DayPeriod.dusk;

  @override
  void dispose() {
    _cloud1.dispose();
    _cloud2.dispose();
    _cloud3.dispose();
    _glow.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  bool get _isNight => _isNightPeriod(_period);
  bool get _showSun => !_isNight && _period != DayPeriod.dawn;
  bool get _showClouds => !_isNight;

  /// Nombre de nuages selon le code météo OpenWeather
  int get _cloudCount {
    final code = widget.weatherIconCode ?? '';
    if (code == '01') return 0;
    if (code == '02') return 1;
    if (code == '03') return 2;
    if (code.isEmpty) return 2;
    return 3; // 04, 09, 10, 11, 13, 50
  }

  List<Color> get _skyGradient {
    switch (_period) {
      case DayPeriod.dawn:
        return [const Color(0xFF1A1038), const Color(0xFFB05070), const Color(0xFFE88050)];
      case DayPeriod.morning:
        return [const Color(0xFF4DA8DA), const Color(0xFF72C8F0), const Color(0xFFFFD080)];
      case DayPeriod.midday:
        return [const Color(0xFF1976D2), const Color(0xFF2196F3), const Color(0xFF64B5F6)];
      case DayPeriod.afternoon:
        return [const Color(0xFF1565C0), const Color(0xFF42A5F5), const Color(0xFFFFB74D)];
      case DayPeriod.sunset:
        return [const Color(0xFF7B1FA2), const Color(0xFFE53935), const Color(0xFFFF9800)];
      case DayPeriod.dusk:
        return [const Color(0xFF1A0A2E), const Color(0xFF3D1C6E), const Color(0xFF5E3090)];
      case DayPeriod.night:
        return [const Color(0xFF050C1A), const Color(0xFF0A1628), const Color(0xFF0D2040)];
    }
  }

  Color get _cloudTint {
    switch (_period) {
      case DayPeriod.sunset:  return const Color(0xFFFFCCBB);
      case DayPeriod.morning:
      case DayPeriod.dawn:    return const Color(0xFFFFF0E0);
      default:                return Colors.white;
    }
  }

  double get _cloudOpacity {
    switch (_period) {
      case DayPeriod.morning:  return 0.58;
      case DayPeriod.midday:   return 0.42;
      case DayPeriod.sunset:   return 0.50;
      default:                 return 0.38;
    }
  }

  // Arc solaire : heure 5 → gauche/bas, heure 12 → centre/haut, heure 20 → droite/bas
  double _sunX(double w) {
    final t = ((_hour - 5) / 15.0).clamp(0.0, 1.0);
    return (0.08 + t * 0.84) * w;
  }

  double _sunY(double h) {
    final t = ((_hour - 5) / 15.0).clamp(0.0, 1.0);
    return (0.52 - math.sin(t * math.pi) * 0.40) * h;
  }

  double get _sunSize {
    switch (_period) {
      case DayPeriod.dawn:
      case DayPeriod.sunset:  return 88;
      case DayPeriod.midday:  return 60;
      default:                return 72;
    }
  }

  Color get _sunColor {
    switch (_period) {
      case DayPeriod.dawn:      return const Color(0xFFFF7043);
      case DayPeriod.morning:   return const Color(0xFFFFCA28);
      case DayPeriod.midday:    return const Color(0xFFFFEE58);
      case DayPeriod.afternoon: return const Color(0xFFFFB300);
      case DayPeriod.sunset:    return const Color(0xFFFF6D00);
      default:                  return const Color(0xFFFFD740);
    }
  }

  // ── build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _skyGradient,
        ),
      ),
      child: Stack(
        children: [
          // ── Éléments atmosphériques ─────────────────────────────────────────
          // RepaintBoundary : isole les repaints animés du contenu UI.
          // IgnorePointer   : les éléments décoratifs ne bloquent JAMAIS les touches.
          RepaintBoundary(
            child: IgnorePointer(
              child: Stack(
                children: [
                  // Étoiles — dessinées via CustomPainter (0 widget par étoile)
                  if (_isNight ||
                      _period == DayPeriod.dusk ||
                      _period == DayPeriod.dawn)
                    _StarField(
                      controller: _twinkle,
                      stars: _stars,
                      opacity: _period == DayPeriod.dawn ? 0.30 : 1.0,
                    ),

                  // Lune
                  if (_isNight)
                    const Positioned(right: 55, top: 55, child: _Moon()),

                  // Soleil — position fixe basée sur _hour (pas besoin d'AnimatedBuilder)
                  if (_showSun)
                    Positioned(
                      left: _sunX(size.width) - _sunSize / 2 - 10,
                      top: _sunY(size.height) - _sunSize / 2 - 10,
                      child: _Sun(
                        glowCtrl: _glow,
                        size: _sunSize,
                        color: _sunColor,
                      ),
                    ),

                  // Nuages
                  if (_showClouds && _cloudCount >= 1)
                    _Cloud(
                      controller: _cloud1,
                      top: size.height * 0.09,
                      width: 180,
                      color: _cloudTint,
                      opacity: _cloudOpacity,
                    ),
                  if (_showClouds && _cloudCount >= 2)
                    _Cloud(
                      controller: _cloud2,
                      top: size.height * 0.18,
                      width: 240,
                      color: _cloudTint,
                      opacity: _cloudOpacity - 0.08,
                    ),
                  if (_showClouds && _cloudCount >= 3)
                    _Cloud(
                      controller: _cloud3,
                      top: size.height * 0.06,
                      width: 140,
                      color: _cloudTint,
                      opacity: _cloudOpacity - 0.13,
                    ),
                ],
              ),
            ),
          ),

          // ── Contenu de l'écran (reçoit tous les touches) ────────────────────
          widget.child,
        ],
      ),
    );
  }
}

// ─── Soleil ───────────────────────────────────────────────────────────────────

class _Sun extends StatelessWidget {
  final AnimationController glowCtrl;
  final double size;
  final Color color;

  const _Sun({required this.glowCtrl, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final halo = size + 44;
    return AnimatedBuilder(
      animation: glowCtrl,
      builder: (_, child) {
        final pulse = 0.22 + glowCtrl.value * 0.18;
        return SizedBox(
          width: halo,
          height: halo,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo
              Container(
                width: halo,
                height: halo,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    color.withValues(alpha: pulse),
                    Colors.transparent,
                  ]),
                ),
              ),
              // Disque
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.55),
                      blurRadius: 28,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Lune ─────────────────────────────────────────────────────────────────────

class _Moon extends StatelessWidget {
  const _Moon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                Colors.white.withValues(alpha: 0.12),
                Colors.transparent,
              ]),
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8EAF6),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.35),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          // Ombre pour simuler le croissant
          Positioned(
            left: 14,
            top: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0D1B3E).withValues(alpha: 0.70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Étoiles (CustomPainter — zéro widget par étoile) ────────────────────────

class _StarField extends StatelessWidget {
  final AnimationController controller;
  final List<List<double>> stars;
  final double opacity;

  const _StarField({
    required this.controller,
    required this.stars,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => CustomPaint(
        painter: _StarsPainter(
          stars: stars,
          progress: controller.value,
          opacity: opacity,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Dessine toutes les étoiles sur le canvas en une seule passe.
/// Beaucoup plus rapide que 24 Container widgets recréés à chaque frame.
class _StarsPainter extends CustomPainter {
  final List<List<double>> stars;
  final double progress;
  final double opacity;

  _StarsPainter({
    required this.stars,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final phase = (s[3] + progress) % 1.0;
      final alpha =
          (opacity * (0.25 + 0.75 * math.sin(phase * math.pi).abs()))
              .clamp(0.0, 1.0);
      paint.color = Colors.white.withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s[0] * size.width, s[1] * size.height),
        s[2] / 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarsPainter old) => old.progress != progress;
}

// ─── Nuage ────────────────────────────────────────────────────────────────────

class _Cloud extends StatelessWidget {
  final AnimationController controller;
  final double top;
  final double width;
  final Color color;
  final double opacity;

  const _Cloud({
    required this.controller,
    required this.top,
    required this.width,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final total = screenW + width + 40;
        final x = (1 - controller.value) * total - width - 20;
        return Positioned(left: x, top: top, child: child!);
      },
      // child est construit une seule fois (pas de rebuild inutile)
      child: Opacity(
        opacity: opacity,
        child: _CloudShape(width: width, color: color),
      ),
    );
  }
}

class _CloudShape extends StatelessWidget {
  final double width;
  final Color color;

  const _CloudShape({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    final h = width * 0.55;
    return SizedBox(
      width: width,
      height: h,
      child: Stack(
        children: [
          // Base
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: h * 0.50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(h * 0.25),
              ),
            ),
          ),
          // Boursouflure gauche
          Positioned(
            bottom: h * 0.28, left: width * 0.06,
            child: Container(
              width: width * 0.36, height: width * 0.36,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          // Boursouflure centre (la plus haute)
          Positioned(
            bottom: h * 0.36, left: width * 0.30,
            child: Container(
              width: width * 0.40, height: width * 0.40,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
          // Boursouflure droite
          Positioned(
            bottom: h * 0.22, right: width * 0.06,
            child: Container(
              width: width * 0.32, height: width * 0.32,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );
  }
}
