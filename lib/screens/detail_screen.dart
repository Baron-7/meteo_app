import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/weather_model.dart';

class DetailScreen extends StatefulWidget {
  final WeatherModel weather;
  const DetailScreen({super.key, required this.weather});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Couleurs du ciel selon la température
  List<Color> _skyColors(double temp) {
    if (temp < 0) {
      return [const Color(0xFF1A237E), const Color(0xFF283593), const Color(0xFF3949AB)];
    }
    if (temp < 12) {
      return [const Color(0xFF0D2137), const Color(0xFF1565C0), const Color(0xFF1976D2)];
    }
    if (temp < 22) {
      return [const Color(0xFF0D47A1), const Color(0xFF1565C0), const Color(0xFF42A5F5)];
    }
    if (temp < 30) {
      return [const Color(0xFF1565C0), const Color(0xFFE65100), const Color(0xFFFF8F00)];
    }
    return [const Color(0xFFB71C1C), const Color(0xFFE53935), const Color(0xFFFF7043)];
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
    final sky = _skyColors(widget.weather.temperature);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: sky,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header fixe ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Hero météo (comme Apple Weather) ──────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 32, 28, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom de la ville
                          Text(
                            widget.weather.city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w300,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Condition météo
                          Text(
                            widget.weather.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.70),
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Énorme température (style Apple)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.weather.temperature
                                    .toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 96,
                                  fontWeight: FontWeight.w100,
                                  letterSpacing: -4,
                                  height: 1,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 16),
                                child: Text(
                                  '°C',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w200,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Icône météo + ressentie
                          Row(
                            children: [
                              Image.network(
                                'https://openweathermap.org/img/wn/${widget.weather.icon}@2x.png',
                                width: 50,
                                height: 50,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.wb_sunny_rounded,
                                    color: Colors.white,
                                    size: 36),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _tempLabel(widget.weather.temperature),
                                style: TextStyle(
                                  color:
                                      Colors.white.withValues(alpha: 0.65),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.18),
                    thickness: 0.5,
                  ),
                ),
              ),

              // ── Tuiles d'infos (style Apple Weather widget grid) ──────────
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
                      icon: Icons.explore_rounded,
                      label: 'Latitude',
                      value: widget.weather.lat.toStringAsFixed(3),
                      iconColor: const Color(0xFFFFCC80),
                    ),
                    _InfoTile(
                      icon: Icons.explore_outlined,
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
                    childAspectRatio: 1.45,
                  ),
                ),
              ),

              // ── Bouton Google Maps ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 36),
                  child: _MapsButton(onTap: _openMaps),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _tempLabel(double t) {
    if (t < 0) return 'Conditions glaciales';
    if (t < 12) return 'Temps froid';
    if (t < 22) return 'Temps agréable';
    if (t < 30) return 'Temps chaud';
    return 'Très forte chaleur';
  }
}

// ─── Tuile d'information ──────────────────────────────────────────────────────

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
              Row(
                children: [
                  Icon(icon, size: 14, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
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
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.28),
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
