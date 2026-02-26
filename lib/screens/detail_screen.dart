import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/weather_model.dart';

class DetailScreen extends StatelessWidget {
  final WeatherModel weather;

  const DetailScreen({super.key, required this.weather});

  // Dynamic gradient based on weather icon code
  List<Color> _getGradientColors() {
    final icon = weather.icon;
    if (icon.startsWith('01')) {
      // Clear sky – warm blue sky
      return const [Color(0xFF1565C0), Color(0xFF1E88E5), Color(0xFF42A5F5)];
    } else if (icon.startsWith('02') || icon.startsWith('03') || icon.startsWith('04')) {
      // Cloudy – steel blue-gray
      return const [Color(0xFF263238), Color(0xFF37474F), Color(0xFF546E7A)];
    } else if (icon.startsWith('09') || icon.startsWith('10')) {
      // Rain – deep navy
      return const [Color(0xFF0D1B2A), Color(0xFF1B2A3B), Color(0xFF2C3E50)];
    } else if (icon.startsWith('11')) {
      // Thunderstorm – dark purple
      return const [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)];
    } else if (icon.startsWith('13')) {
      // Snow – indigo-violet
      return const [Color(0xFF1A237E), Color(0xFF3949AB), Color(0xFF5C6BC0)];
    } else {
      // Mist / fog / default
      return const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];
    }
  }

  // Temperature-based accent color
  Color _getTempColor() {
    final t = weather.temperature;
    if (t <= 0) return const Color(0xFF82B1FF);
    if (t <= 15) return const Color(0xFF40C4FF);
    if (t <= 25) return const Color(0xFF69F0AE);
    if (t <= 35) return const Color(0xFFFFD740);
    return const Color(0xFFFF6E40);
  }

  void openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${weather.lat},${weather.lon}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradientColors();
    final tempColor = _getTempColor();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom AppBar ─────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.18)),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        weather.city,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Weather icon mini badge
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.icon}.png',
                      width: 42,
                      height: 42,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              // ── Scrollable body ───────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                  child: Column(
                    children: [
                      // Hero temperature card
                      _buildHeroCard(tempColor),

                      const SizedBox(height: 16),

                      // Humidity & Wind row
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.water_drop_rounded,
                              label: 'Humidité',
                              value: '${weather.humidity}%',
                              iconColor: const Color(0xFF4FC3F7),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.air_rounded,
                              label: 'Vent',
                              value: '${weather.windSpeed} m/s',
                              iconColor: const Color(0xFF80DEEA),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Coordinates card
                      _buildCoordCard(),

                      const SizedBox(height: 28),

                      // Google Maps button
                      GestureDetector(
                        onTap: openGoogleMaps,
                        child: Container(
                          width: double.infinity,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                            ),
                            borderRadius: BorderRadius.circular(29),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    const Color(0xFF00B894).withOpacity(0.4),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Voir sur Google Maps',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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

  // ── Hero temperature card ─────────────────────────────────
  Widget _buildHeroCard(Color tempColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Weather icon
              Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                width: 120,
                height: 120,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.cloud_rounded,
                  size: 80,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 4),
              // Temperature
              Text(
                '${weather.temperature.toStringAsFixed(1)}°',
                style: GoogleFonts.poppins(
                  fontSize: 86,
                  fontWeight: FontWeight.w800,
                  color: tempColor,
                  height: 1.0,
                ),
              ),
              Text(
                'CELSIUS',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: tempColor.withOpacity(0.6),
                  letterSpacing: 4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              // Description pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                ),
                child: Text(
                  weather.description.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 2.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stat card (humidity / wind) ───────────────────────────
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 14),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white38,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Coordinates card ──────────────────────────────────────
  Widget _buildCoordCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFEF9A9A),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordonnées GPS',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.white38,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.lat.toStringAsFixed(4)}° N',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${weather.lon.toStringAsFixed(4)}° E',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
