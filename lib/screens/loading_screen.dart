import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';
import 'detail_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  final List<String> cities = [
    'Paris',
    'New York',
    'Tokyo',
    'London',
    'Dakar',
  ];

  final List<String> messages = [
    'Nous téléchargeons les données...',
    'C\'est presque fini...',
    'Plus que quelques secondes...',
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

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
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
          final weather =
              await _weatherService.fetchWeather(cities[cityIndex]);
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
            errorMessage =
                'Erreur de chargement. Vérifiez votre connexion internet ou votre clé API.';
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
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
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
                    Text(
                      'Données Météo',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ───────────────────────────────────
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: hasError
                        ? _buildError()
                        : (isLoading ? _buildLoading() : _buildResults()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Loading state ──────────────────────────────────────────
  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Circular progress
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 186,
              height: 186,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            SizedBox(
              width: 170,
              height: 170,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 10,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF8E54E9),
                ),
                strokeCap: StrokeCap.round,
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(progress * 100).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                Text(
                  'chargé',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white38,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 44),

        // Message
        Text(
          messages[messageIndex],
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // City count badge
        if (cityIndex > 0)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border:
                  Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_city_rounded,
                    color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Text(
                  '$cityIndex / ${cities.length} villes chargées',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 44),

        // Dot progress
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cities.length, (i) {
            final done = i < cityIndex;
            final current = i == cityIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: done ? 32 : (current ? 14 : 8),
              height: 8,
              decoration: BoxDecoration(
                gradient: done
                    ? const LinearGradient(
                        colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
                      )
                    : null,
                color: done
                    ? null
                    : (current
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.18)),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Error state ────────────────────────────────────────────
  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.redAccent.withOpacity(0.12),
            border: Border.all(
                color: Colors.redAccent.withOpacity(0.3), width: 1),
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Oops !',
          style: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white54,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: startLoading,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4776E6).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Réessayer',
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
    );
  }

  // ── Results state ──────────────────────────────────────────
  Widget _buildResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Résultats Météo',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Text('🌍', style: TextStyle(fontSize: 22)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${weatherList.length} villes analysées',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: weatherList.length,
            itemBuilder: (context, index) {
              return WeatherCard(
                weather: weatherList[index],
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              DetailScreen(weather: weatherList[index]),
                      transitionsBuilder: (context, animation,
                          secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: startLoading,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.refresh_rounded,
                    color: Colors.white60, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Recommencer',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
