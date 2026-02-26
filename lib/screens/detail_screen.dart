import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/weather_model.dart';
import '../widgets/sky_atmosphere.dart';

class DetailScreen extends StatefulWidget {
  final WeatherModel weather;
  const DetailScreen({super.key, required this.weather});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 750),
      vsync: this,
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _openMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.weather.lat},${widget.weather.lon}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    // SkyAtmosphere reçoit l'icône météo de la VILLE → jour/nuit exact
    return Scaffold(
      body: SkyAtmosphere(
        weatherIcon: widget.weather.icon,
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Bouton retour ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter:
                                ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      Colors.white.withValues(alpha: 0.22),
                                ),
                              ),
                              child: const Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Hero météo (style Apple Weather) ──────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom de la ville
                          Text(
                            widget.weather.city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Condition météo
                          Text(
                            widget.weather.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.68),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Énorme température (style Apple — ultra fine)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.weather.temperature
                                    .toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 100,
                                  fontWeight: FontWeight.w100,
                                  letterSpacing: -5,
                                  height: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 18),
                                child: Text(
                                  '°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Icône + feeling
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Image.network(
                                'https://openweathermap.org/img/wn/${widget.weather.icon}@2x.png',
                                width: 48,
                                height: 48,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.wb_sunny_rounded,
                                    color: Colors.white,
                                    size: 34),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _tempFeeling(widget.weather.temperature),
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.60),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Séparateur ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 26),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.16),
                    thickness: 0.5,
                  ),
                ),
              ),

              // ── Grille d'infos (style tuiles Apple Weather) ────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _InfoTile(
                      icon: Icons.water_drop_rounded,
                      label: 'Humidité',
                      value: '${widget.weather.humidity}%',
                      iconColor: const Color(0xFF64B5F6),
                    ),
                    _InfoTile(
                      icon: Icons.air_rounded,
                      label: 'Vent',
                      value: '${widget.weather.windSpeed} m/s',
                      iconColor: const Color(0xFF80CBC4),
                    ),
                    _InfoTile(
                      icon: Icons.my_location_rounded,
                      label: 'Latitude',
                      value: widget.weather.lat.toStringAsFixed(3),
                      iconColor: const Color(0xFFFFCC80),
                    ),
                    _InfoTile(
                      icon: Icons.explore_rounded,
                      label: 'Longitude',
                      value: widget.weather.lon.toStringAsFixed(3),
                      iconColor: const Color(0xFFFFCC80),
                    ),
                  ]),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                ),
              ),

              // ── Bouton Google Maps ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 38),
                  child: _MapsButton(onTap: _openMaps),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _tempFeeling(double t) {
    if (t < 0) return 'Conditions glaciales';
    if (t < 12) return 'Temps froid';
    if (t < 22) return 'Temps agréable';
    if (t < 30) return 'Temps chaud';
    return 'Très forte chaleur';
  }
}

// ─── Tuile d'info ─────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.18),
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Label + icône
              Row(
                children: [
                  Icon(icon, size: 13, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.52),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              // Valeur
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bouton Google Maps ───────────────────────────────────────────────────────

class _MapsButton extends StatefulWidget {
  final VoidCallback onTap;
  const _MapsButton({required this.onTap});

  @override
  State<_MapsButton> createState() => _MapsButtonState();
}

class _MapsButtonState extends State<_MapsButton> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.26),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Voir sur Google Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
