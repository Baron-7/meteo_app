import 'dart:async';
import 'dart:ui';
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

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  final List<String> cities = ['Paris', 'New York', 'Tokyo', 'London', 'Dakar'];

  // Messages exacts du cahier des charges
  final List<String> messages = [
    'Nous téléchargeons les données…',
    'C\'est presque fini…',
    'Plus que quelques secondes avant d\'avoir le résultat…',
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
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    startLoading();
  }

  void startLoading() {
    _timer?.cancel();
    _fadeController.reset();

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
          if (!mounted) return;
          setState(() {
            weatherList.add(weather);
            cityIndex++;
            progress = cityIndex / cities.length;
            messageIndex = (messageIndex + 1) % messages.length;
          });
        } catch (e) {
          timer.cancel();
          if (!mounted) return;
          setState(() {
            hasError = true;
            isLoading = false;
            errorMessage =
                'Erreur de chargement.\nVérifiez votre connexion internet ou votre clé API.';
          });
        }
      }

      isFetching = false;

      if (cityIndex >= cities.length) {
        timer.cancel();
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF0D1B3E),
                    const Color(0xFF1A3461),
                    const Color(0xFF1F4287),
                  ]
                : [
                    const Color(0xFF48B5E8),
                    const Color(0xFF2183C4),
                    const Color(0xFF1565C0),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: hasError
                      ? _buildError()
                      : (isLoading ? _buildLoading() : _buildResults()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.22)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            isLoading
                ? 'Chargement…'
                : (hasError ? 'Erreur' : 'Météo Mondiale'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── État : chargement ──────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Jauge circulaire
        SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cercle de fond
              SizedBox(
                width: 190,
                height: 190,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  color: Colors.white.withValues(alpha: 0.10),
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Cercle de progression
              SizedBox(
                width: 190,
                height: 190,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  color: Colors.white,
                  backgroundColor: Colors.transparent,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Pourcentage au centre
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w200,
                      color: Colors.white,
                      letterSpacing: -2,
                    ),
                  ),
                  Text(
                    '$cityIndex / ${cities.length} villes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Message d'attente (du cahier des charges)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(
            messages[messageIndex],
            key: ValueKey(messageIndex),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 40),

        // Villes chargées
        if (weatherList.isNotEmpty) ...[
          Text(
            'Déjà chargé :',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.50),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: weatherList.map((w) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          w.city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ── État : erreur ──────────────────────────────────────────────────────────

  Widget _buildError() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.12),
          ),
          child:
              const Icon(Icons.cloud_off_rounded, size: 44, color: Colors.white),
        ),
        const SizedBox(height: 28),
        const Text(
          'Oups…',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w300,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.70),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 40),
        _PillButton(
          label: 'Réessayer',
          icon: Icons.refresh_rounded,
          onTap: startLoading,
        ),
      ],
    );
  }

  // ── État : résultats ───────────────────────────────────────────────────────

  Widget _buildResults() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Résultats',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            '${weatherList.length} villes · mis à jour maintenant',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: weatherList.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration:
                      Duration(milliseconds: 250 + index * 80),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - value)),
                        child: child,
                      ),
                    );
                  },
                  child: WeatherCard(
                    weather: weatherList[index],
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (_, animation, __) =>
                              DetailScreen(weather: weatherList[index]),
                          transitionsBuilder: (_, animation, __, child) {
                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(1, 0),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            );
                          },
                          transitionDuration:
                              const Duration(milliseconds: 380),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Bouton Recommencer (exigence du cahier)
          _PillButton(
            label: 'Recommencer',
            icon: Icons.refresh_rounded,
            onTap: startLoading,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Bouton pill partagé ─────────────────────────────────────────────────────

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
