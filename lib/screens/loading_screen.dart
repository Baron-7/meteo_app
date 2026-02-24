import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import 'detail_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final List<String> cities = ['Paris', 'New York', 'Tokyo', 'London', 'Dakar'];

  final List<String> messages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes avant d\'avoir le résultat...',
  ];

  final WeatherService _weatherService = WeatherService();

  List<WeatherModel> weatherList = [];
  double progress = 0.0;
  int messageIndex = 0;
  int cityIndex = 0;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startLoading();
  }

  void startLoading() {
    _timer?.cancel();

    setState(() {
      weatherList = [];
      progress = 0.0;
      messageIndex = 0;
      cityIndex = 0;
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    bool isFetching = false;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (isFetching) return;
      isFetching = true;

      if (cityIndex < cities.length) {
        try {
          final weather = await _weatherService.fetchWeather(cities[cityIndex]);
          setState(() {
            weatherList.add(weather);
            cityIndex++;
            progress = cityIndex / cities.length;
            messageIndex = (messageIndex + 1) % messages.length;
          });
        } catch (e) {
          timer.cancel();
          setState(() {
            hasError = true;
            isLoading = false;
            errorMessage = 'Erreur de chargement. Vérifiez votre connexion internet ou votre clé API.';
          });
        }
      }

      isFetching = false;

      if (cityIndex >= cities.length) {
        timer.cancel();
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Données Météo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: hasError ? _buildError() : (isLoading ? _buildLoading() : _buildResults()),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 14,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Text(
          messages[messageIndex],
          style: const TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        if (cityIndex > 0)
          Text(
            '$cityIndex / ${cities.length} villes chargées',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 90, color: Colors.red),
        const SizedBox(height: 20),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: startLoading,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildResults() {
    return Column(
      children: [
        const Text(
          'Résultats Météo 🌍',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: weatherList.length,
            itemBuilder: (context, index) {
              return WeatherCard(
                weather: weatherList[index],
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(weather: weatherList[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: startLoading,
            icon: const Icon(Icons.refresh),
            label: const Text('Recommencer', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
