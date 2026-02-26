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
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _entranceAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _entranceAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  List<Color> _getTempGradient(double temp) {
    if (temp < 0) return [const Color(0xFF4FC3F7), const Color(0xFF9C27B0)];
    if (temp < 10) return [const Color(0xFF29B6F6), const Color(0xFF0288D1)];
    if (temp < 20) return [const Color(0xFF26C6DA), const Color(0xFF00897B)];
    if (temp < 28) return [const Color(0xFFFFB74D), const Color(0xFFFF7043)];
    return [const Color(0xFFEF5350), const Color(0xFFB71C1C)];
  }

  void openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.weather.lat},${widget.weather.lon}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getTempGradient(widget.weather.temperature);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1B2A),
              const Color(0xFF1B2838),
              gradient[0].withOpacity(0.4),
              gradient[1].withOpacity(0.5),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              _buildAppBar(context),

              // Contenu scrollable
              Expanded(
                child: FadeTransition(
                  opacity: _entranceAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildWeatherHero(gradient),
                        const SizedBox(height: 24),
                        _buildInfoGrid(gradient),
                        const SizedBox(height: 24),
                        _buildCoordinates(gradient),
                        const SizedBox(height: 28),
                        _buildMapsButton(),
                        const SizedBox(height: 28),
                      ],
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

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
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
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.weather.city,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Détails météorologiques',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherHero(List<Color> gradient) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradient[0].withOpacity(0.20),
                gradient[1].withOpacity(0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: gradient[0].withOpacity(0.35),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // Icône météo
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      gradient[0].withOpacity(0.25),
                      gradient[1].withOpacity(0.10),
                    ],
                  ),
                  border: Border.all(
                    color: gradient[0].withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Image.network(
                  'https://openweathermap.org/img/wn/${widget.weather.icon}@4x.png',
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.wb_sunny_rounded,
                      size: 70,
                      color: gradient[0],
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Température
              ShaderMask(
                shaderCallback: (bounds) =>
                    LinearGradient(colors: gradient).createShader(bounds),
                child: Text(
                  '${widget.weather.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Description
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Text(
                  widget.weather.description.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(List<Color> gradient) {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            icon: Icons.water_drop_rounded,
            label: 'Humidité',
            value: '${widget.weather.humidity}%',
            iconColor: const Color(0xFF29B6F6),
            gradient: [const Color(0xFF29B6F6), const Color(0xFF0288D1)],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _InfoCard(
            icon: Icons.air_rounded,
            label: 'Vent',
            value: '${widget.weather.windSpeed} m/s',
            iconColor: const Color(0xFF26C6DA),
            gradient: [const Color(0xFF26C6DA), const Color(0xFF00897B)],
          ),
        ),
      ],
    );
  }

  Widget _buildCoordinates(List<Color> gradient) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      color: Color(0xFFFF6B6B),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Coordonnées GPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _CoordItem(
                      label: 'Latitude',
                      value: widget.weather.lat.toStringAsFixed(4),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.1),
                  ),
                  Expanded(
                    child: _CoordItem(
                      label: 'Longitude',
                      value: widget.weather.lon.toStringAsFixed(4),
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

  Widget _buildMapsButton() {
    return GestureDetector(
      onTap: openGoogleMaps,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF34C759), Color(0xFF30D158)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF34C759).withOpacity(0.45),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Text(
              'Voir sur Google Maps',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final List<Color> gradient;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                gradient[0].withOpacity(0.18),
                gradient[1].withOpacity(0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: gradient[0].withOpacity(0.30),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 16),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoordItem extends StatelessWidget {
  final String label;
  final String value;

  const _CoordItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.45),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
