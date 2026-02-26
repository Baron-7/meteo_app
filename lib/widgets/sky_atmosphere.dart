import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─── Période de la journée ────────────────────────────────────────────────────

enum DayPeriod { dawn, morning, midday, afternoon, sunset, dusk, night }

// ─── Widget principal ─────────────────────────────────────────────────────────

/// Fond atmosphérique animé : ciel + soleil/lune + nuages + étoiles.
/// [weatherIcon] : icône OpenWeather (ex. "01d", "02n") — détecte jour/nuit
///                 de la VILLE. Null = heure locale de l'appareil.
class SkyAtmosphere extends StatefulWidget {
  final Widget child;
  final String? weatherIcon;

  const SkyAtmosphere({
    super.key,
    required this.child,
    this.weatherIcon,
  });

  @override
  State<SkyAtmosphere> createState() => _SkyAtmosphereState();
}

class _SkyAtmosphereState extends State<SkyAtmosphere>
    with TickerProviderStateMixin {
  // Controllers d'animation
  late final AnimationController _cloud1;
  late final AnimationController _cloud2;
  late final AnimationController _cloud3;
  late final AnimationController _glow;
  late final AnimationController _twinkle;

  late DayPeriod _period;
  late int _hour;

  // Positions des étoiles (générées une seule fois)
  late final List<List<double>> _starPositions;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _hour = now.hour;

    // Si une icône météo est fournie (ex: "01n"), on force nuit/jour
    _period = _resolvePeriod();

    // Génère les étoiles une seule fois avec une graine fixe
    final rng = math.Random(42);
    _starPositions = List.generate(
      30,
      (_) => [
        rng.nextDouble(),        // x (fraction de l'écran)
        rng.nextDouble() * 0.60, // y (fraction — uniquement la moitié haute)
        rng.nextDouble() * 1.5 + 0.8, // taille (1 à 2.3 px)
        rng.nextDouble(),        // phase de scintillement
      ],
    );

    // Nuages : durées différentes → vitesses différentes
    _cloud1 = AnimationController(
      duration: const Duration(seconds: 42),
      vsync: this,
    )..repeat();

    _cloud2 = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _cloud2.value = 0.38;
    _cloud2.repeat();

    _cloud3 = AnimationController(
      duration: const Duration(seconds: 50),
      vsync: this,
    );
    _cloud3.value = 0.70;
    _cloud3.repeat();

    // Halo du soleil / pulsation
    _glow = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Scintillement des étoiles
    _twinkle = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  /// Détermine la période selon l'heure locale et l'icône météo.
  DayPeriod _resolvePeriod() {
    // Si l'icône indique nuit (ex: "02n"), on force la nuit
    if (widget.weatherIcon != null &&
        widget.weatherIcon!.endsWith('n')) {
      return DayPeriod.night;
    }
    return _periodFromHour(_hour);
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

  @override
  void dispose() {
    _cloud1.dispose();
    _cloud2.dispose();
    _cloud3.dispose();
    _glow.dispose();
    _twinkle.dispose();
    super.dispose();
  }

  // ── Getters utiles ──────────────────────────────────────────────────────────

  bool get _isNight =>
      _period == DayPeriod.night || _period == DayPeriod.dusk;

  bool get _showSun => !_isNight && _period != DayPeriod.dawn;

  bool get _showClouds => !_isNight;

  // Combien de nuages selon la condition météo
  int get _cloudCount {
    if (widget.weatherIcon == null) {
      return _period == DayPeriod.midday ? 2 : 3;
    }
    final code = widget.weatherIcon!.replaceAll(RegExp(r'[dn]'), '');
    if (code == '01') return 0; // Ciel dégagé
    if (code == '02') return 1; // Quelques nuages
    if (code == '03') return 2; // Nuages épars
    return 3; // Couvert / pluie
  }

  // ── Couleurs du ciel selon la période ──────────────────────────────────────

  List<Color> get _skyGradient {
    switch (_period) {
      case DayPeriod.dawn:
        return [
          const Color(0xFF1A1038),
          const Color(0xFFB05070),
          const Color(0xFFE88050),
        ];
      case DayPeriod.morning:
        return [
          const Color(0xFF4DA8DA),
          const Color(0xFF72C8F0),
          const Color(0xFFFFD080),
        ];
      case DayPeriod.midday:
        return [
          const Color(0xFF1976D2),
          const Color(0xFF2196F3),
          const Color(0xFF64B5F6),
        ];
      case DayPeriod.afternoon:
        return [
          const Color(0xFF1565C0),
          const Color(0xFF42A5F5),
          const Color(0xFFFFB74D),
        ];
      case DayPeriod.sunset:
        return [
          const Color(0xFF7B1FA2),
          const Color(0xFFE53935),
          const Color(0xFFFF9800),
        ];
      case DayPeriod.dusk:
        return [
          const Color(0xFF1A0A2E),
          const Color(0xFF3D1C6E),
          const Color(0xFF5E3090),
        ];
      case DayPeriod.night:
        return [
          const Color(0xFF050C1A),
          const Color(0xFF0A1628),
          const Color(0xFF0D2040),
        ];
    }
  }

  // Teinte des nuages selon la période
  Color get _cloudTint {
    switch (_period) {
      case DayPeriod.sunset:
        return const Color(0xFFFFCCBB);
      case DayPeriod.morning:
      case DayPeriod.dawn:
        return const Color(0xFFFFF0E0);
      default:
        return Colors.white;
    }
  }

  double get _cloudOpacityBase {
    switch (_period) {
      case DayPeriod.midday:
        return 0.42;
      case DayPeriod.morning:
        return 0.58;
      case DayPeriod.sunset:
        return 0.50;
      default:
        return 0.38;
    }
  }

  // ── Position du soleil ──────────────────────────────────────────────────────

  // Arc est-ouest selon l'heure (5h = gauche/bas, 12h = centre/haut, 20h = droite/bas)
  double _sunXFraction() {
    final t = ((_hour - 5) / 15.0).clamp(0.0, 1.0);
    return 0.08 + t * 0.84;
  }

  double _sunYFraction() {
    final t = ((_hour - 5) / 15.0).clamp(0.0, 1.0);
    final arc = math.sin(t * math.pi); // 0 → 1 → 0
    return 0.52 - arc * 0.40; // Horizon (0.52) → Zénith (0.12)
  }

  // Taille du soleil : plus grand près de l'horizon (matin/soir)
  double get _sunSize {
    switch (_period) {
      case DayPeriod.dawn:
      case DayPeriod.sunset:
        return 88;
      case DayPeriod.midday:
        return 60;
      default:
        return 72;
    }
  }

  Color get _sunColor {
    switch (_period) {
      case DayPeriod.dawn:
        return const Color(0xFFFF7043);
      case DayPeriod.morning:
        return const Color(0xFFFFCA28);
      case DayPeriod.midday:
        return const Color(0xFFFFEE58);
      case DayPeriod.afternoon:
        return const Color(0xFFFFB300);
      case DayPeriod.sunset:
        return const Color(0xFFFF6D00);
      default:
        return const Color(0xFFFFD740);
    }
  }

  // ── build ───────────────────────────────────────────────────────────────────

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
          // ── Étoiles (nuit / dusk / aube) ──────────────────────────────────
          if (_isNight || _period == DayPeriod.dawn)
            _StarField(
              controller: _twinkle,
              stars: _starPositions,
              opacity: _period == DayPeriod.dawn ? 0.35 : 1.0,
            ),

          // ── Lune (nuit) ────────────────────────────────────────────────────
          if (_isNight)
            const Positioned(
              right: 55,
              top: 55,
              child: _Moon(),
            ),

          // ── Soleil ─────────────────────────────────────────────────────────
          if (_showSun)
            AnimatedBuilder(
              animation: _glow,
              builder: (context, child) {
                return Positioned(
                  left: _sunXFraction() * size.width - _sunSize / 2 - 10,
                  top: _sunYFraction() * size.height - _sunSize / 2 - 10,
                  child: child!,
                );
              },
              child: _Sun(
                glowCtrl: _glow,
                size: _sunSize,
                color: _sunColor,
              ),
            ),

          // ── Nuages ─────────────────────────────────────────────────────────
          if (_showClouds && _cloudCount >= 1)
            _Cloud(
              controller: _cloud1,
              initialPhase: 0.05,
              top: size.height * 0.09,
              width: 180,
              color: _cloudTint,
              opacity: _cloudOpacityBase,
            ),
          if (_showClouds && _cloudCount >= 2)
            _Cloud(
              controller: _cloud2,
              initialPhase: 0.0,
              top: size.height * 0.18,
              width: 240,
              color: _cloudTint,
              opacity: _cloudOpacityBase - 0.08,
            ),
          if (_showClouds && _cloudCount >= 3)
            _Cloud(
              controller: _cloud3,
              initialPhase: 0.0,
              top: size.height * 0.06,
              width: 140,
              color: _cloudTint,
              opacity: _cloudOpacityBase - 0.12,
            ),

          // ── Contenu de l'écran ─────────────────────────────────────────────
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

  const _Sun({
    required this.glowCtrl,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final haloSize = size + 44;

    return AnimatedBuilder(
      animation: glowCtrl,
      builder: (context, child) {
        final pulse = 0.25 + glowCtrl.value * 0.18;

        return SizedBox(
          width: haloSize,
          height: haloSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Halo externe doux
              Container(
                width: haloSize,
                height: haloSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      color.withValues(alpha: pulse),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Corps du soleil
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
          // Halo lunaire
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Corps de la lune
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
          // Ombre qui crée le croissant
          Positioned(
            left: 14,
            top: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A2A4A).withValues(alpha: 0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Étoiles ─────────────────────────────────────────────────────────────────

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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          children: stars.map((s) {
            final phase = (s[3] + controller.value) % 1.0;
            // Scintillement : valeur entre 0.25 et 1.0
            final alpha =
                opacity * (0.25 + 0.75 * math.sin(phase * math.pi).abs());

            return Positioned(
              left: s[0] * w,
              top: s[1] * h,
              child: Container(
                width: s[2],
                height: s[2],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0)),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Nuage ────────────────────────────────────────────────────────────────────

class _Cloud extends StatelessWidget {
  final AnimationController controller;
  final double initialPhase; // 0.0 → 1.0
  final double top;
  final double width;
  final Color color;
  final double opacity;

  const _Cloud({
    required this.controller,
    required this.initialPhase,
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
      builder: (context, child) {
        // Phase combinée : décalage initial + progression
        final phase = (controller.value + initialPhase) % 1.0;
        // x : commence hors-écran à droite, finit hors-écran à gauche
        final totalTravel = screenW + width + 40;
        final x = (1 - phase) * totalTravel - width - 20;

        return Positioned(
          left: x,
          top: top,
          child: child!,
        );
      },
      child: Opacity(
        opacity: opacity,
        child: _CloudShape(width: width, color: color),
      ),
    );
  }
}

/// Forme de nuage réaliste (corps + 3 boursouflures)
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
          // Base plate
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
            bottom: h * 0.28,
            left: width * 0.06,
            child: Container(
              width: width * 0.36,
              height: width * 0.36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Boursouflure centre (la plus haute)
          Positioned(
            bottom: h * 0.36,
            left: width * 0.30,
            child: Container(
              width: width * 0.40,
              height: width * 0.40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Boursouflure droite
          Positioned(
            bottom: h * 0.22,
            right: width * 0.06,
            child: Container(
              width: width * 0.32,
              height: width * 0.32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
