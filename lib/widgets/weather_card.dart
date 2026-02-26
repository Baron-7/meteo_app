import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final VoidCallback onTap;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.onTap,
  });

  List<Color> _getTempGradient(double temp) {
    if (temp < 0) {
      return [const Color(0xFF4FC3F7), const Color(0xFF9C27B0)];
    } else if (temp < 10) {
      return [const Color(0xFF29B6F6), const Color(0xFF0288D1)];
    } else if (temp < 20) {
      return [const Color(0xFF26C6DA), const Color(0xFF00897B)];
    } else if (temp < 28) {
      return [const Color(0xFFFFB74D), const Color(0xFFFF7043)];
    } else {
      return [const Color(0xFFEF5350), const Color(0xFFB71C1C)];
    }
  }

  String _getTempLabel(double temp) {
    if (temp < 0) return 'Glacial';
    if (temp < 10) return 'Froid';
    if (temp < 20) return 'Frais';
    if (temp < 28) return 'Agréable';
    return 'Chaud';
  }

  IconData _getTempIcon(double temp) {
    if (temp < 0) return Icons.ac_unit_rounded;
    if (temp < 10) return Icons.thermostat_rounded;
    if (temp < 20) return Icons.wb_cloudy_rounded;
    if (temp < 28) return Icons.wb_sunny_rounded;
    return Icons.local_fire_department_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getTempGradient(weather.temperature);
    final tempLabel = _getTempLabel(weather.temperature);
    final tempIcon = _getTempIcon(weather.temperature);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradient[0].withOpacity(0.22),
                    gradient[1].withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: gradient[0].withOpacity(0.35),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icône météo dans un cercle coloré
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradient[0].withOpacity(0.35),
                          gradient[1].withOpacity(0.25),
                        ],
                      ),
                      border: Border.all(
                        color: gradient[0].withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Image.network(
                      'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(tempIcon, size: 32, color: gradient[0]);
                      },
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Infos ville
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weather.city,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weather.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 13,
                              color: Colors.blue.shade300,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${weather.humidity}%',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.air_rounded,
                              size: 13,
                              color: Colors.teal.shade300,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${weather.windSpeed} m/s',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.55),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Température + label
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: gradient,
                        ).createShader(bounds),
                        child: Text(
                          '${weather.temperature.toStringAsFixed(1)}°',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tempLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 13,
                        color: Colors.white.withOpacity(0.35),
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
