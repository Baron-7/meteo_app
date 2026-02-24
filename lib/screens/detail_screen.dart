import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/weather_model.dart';

class DetailScreen extends StatelessWidget {
  final WeatherModel weather;

  const DetailScreen({super.key, required this.weather});

  void openGoogleMaps() async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${weather.lat},${weather.lon}';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(weather.city),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Image.network(
                      'https://openweathermap.org/img/wn/${weather.icon}@4x.png',
                      width: 110,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.cloud, size: 80, color: Colors.grey);
                      },
                    ),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      weather.description,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.water_drop, 'Humidité', '${weather.humidity}%', Colors.blue),
                    const Divider(),
                    _buildInfoRow(Icons.air, 'Vitesse du vent', '${weather.windSpeed} m/s', Colors.teal),
                    const Divider(),
                    _buildInfoRow(Icons.location_on, 'Latitude', weather.lat.toStringAsFixed(4), Colors.red),
                    const Divider(),
                    _buildInfoRow(Icons.location_on, 'Longitude', weather.lon.toStringAsFixed(4), Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: openGoogleMaps,
                icon: const Icon(Icons.map),
                label: const Text('Voir sur Google Maps', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 26, color: iconColor),
          const SizedBox(width: 14),
          Text(label, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
