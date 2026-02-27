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
      begin: const Offset(0, 0.08),
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
    final w = widget.weather;

    // Code de l'icône sans le suffixe d/n (ex: "02d" → "02")
    final iconCode = w.icon.replaceAll(RegExp(r'[dn]'), '');

    return Scaffold(
      body: SkyAtmosphere(
        // ── Heure locale RÉELLE de la ville (calculée via le timezone de l'API)
        cityLocalHour: w.localHour,
        // ── Jour/nuit selon l'API (pas l'heure du téléphone)
        cityIsDaytime: w.isDaytime,
        // ── Code météo pour le nombre de nuages
        weatherIconCode: iconCode,
        child: SafeArea(
          child: Column(
            children: [
              // ── Header FIXE (ne défile jamais) ────────────────────────────
              _FixedHeader(cityName: w.city),

              // ── Contenu scrollable ─────────────────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // ── Nom + condition ──────────────────────────────
                            Text(
                              w.city,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w300,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              w.description,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // ── Température (Apple-style : ultra-fine, immense) ──
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  w.temperature.toStringAsFixed(0),
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

                            // ── Icône + feeling ──────────────────────────────
                            Row(
                              children: [
                                Image.network(
                                  'https://openweathermap.org/img/wn/${w.icon}@2x.png',
                                  width: 48,
                                  height: 48,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.wb_sunny_rounded,
                                    color: Colors.white,
                                    size: 34,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _tempFeeling(w.temperature),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.58),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),

                            // ── Heure locale de la ville ─────────────────────
                            const SizedBox(height: 8),
                            _LocalTimeBadge(localHour: w.localHour),

                            // ── Séparateur ───────────────────────────────────
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Divider(
                                color: Colors.white.withValues(alpha: 0.15),
                                thickness: 0.5,
                              ),
                            ),

                            // ── Grille infos 2×2 ─────────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.water_drop_rounded,
                                    label: 'Humidité',
                                    value: '${w.humidity}%',
                                    iconColor: const Color(0xFF64B5F6),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.air_rounded,
                                    label: 'Vent',
                                    value: '${w.windSpeed} m/s',
                                    iconColor: const Color(0xFF80CBC4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.my_location_rounded,
                                    label: 'Latitude',
                                    value: w.lat.toStringAsFixed(3),
                                    iconColor: const Color(0xFFFFCC80),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _InfoTile(
                                    icon: Icons.explore_rounded,
                                    label: 'Longitude',
                                    value: w.lon.toStringAsFixed(3),
                                    iconColor: const Color(0xFFFFCC80),
                                  ),
                                ),
                              ],
                            ),

                            // ── Bouton Google Maps ───────────────────────────
                            const SizedBox(height: 24),
                            _MapsButton(onTap: _openMaps),
                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ),
                  ),
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

// ─── Header fixe (toujours visible, même quand on scroll) ────────────────────

class _FixedHeader extends StatelessWidget {
  final String cityName;
  const _FixedHeader({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Bouton retour — toujours accessible
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
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
    );
  }
}

// ─── Badge heure locale ───────────────────────────────────────────────────────

class _LocalTimeBadge extends StatelessWidget {
  final int localHour;
  const _LocalTimeBadge({required this.localHour});

  @override
  Widget build(BuildContext context) {
    final h = localHour;
    final period = h >= 5 && h < 12
        ? 'Matin'
        : h < 18
            ? 'Après-midi'
            : h < 22
                ? 'Soir'
                : 'Nuit';
    final display =
        '${h.toString().padLeft(2, '0')}h locales · $period';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        display,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.70),
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// ─── Tuile info ───────────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
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
            children: [
              Row(
                children: [
                  Icon(icon, size: 13, color: iconColor),
                  const SizedBox(width: 6),
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.50),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
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
              width: double.infinity,
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
