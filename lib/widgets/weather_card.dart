import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onTap;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.onTap,
  });

  // Temperature accent color
  Color _getTempColor() {
    final t = weather.temperature;
    if (t <= 0) return const Color(0xFF82B1FF);
    if (t <= 15) return const Color(0xFF40C4FF);
    if (t <= 25) return const Color(0xFF69F0AE);
    if (t <= 35) return const Color(0xFFFFD740);
    return const Color(0xFFFF6E40);
  }

  // City emoji flag
  String _getCityEmoji() {
    final city = weather.city.toLowerCase();
    if (city.contains('paris')) return '🇫🇷';
    if (city.contains('new york')) return '🇺🇸';
    if (city.contains('tokyo')) return '🇯🇵';
    if (city.contains('london')) return '🇬🇧';
    if (city.contains('dakar')) return '🇸🇳';
    return '🌍';
  }

  @override
  Widget build(BuildContext context) {
    final tempColor = _getTempColor();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Row(
                children: [
                  // Weather icon box
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.cloud_rounded,
                          size: 38,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // City info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // City name + flag
                        Row(
                          children: [
                            Text(
                              _getCityEmoji(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              weather.city,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        // Description
                        Text(
                          weather.description,
                          style: GoogleFonts.poppins(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Humidity row
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4FC3F7)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.water_drop_rounded,
                                      size: 11,
                                      color: Color(0xFF4FC3F7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${weather.humidity}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF4FC3F7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Temperature + arrow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weather.temperature.toStringAsFixed(1)}°',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: tempColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.white38,
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
    );
  }
}
