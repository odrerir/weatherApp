import 'package:flutter/material.dart';
import 'package:weather/service/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  String? errorMessage;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather([String city = 'Guarapuava']) async {
    try {
      var data = await weatherService.getWeather(city);
      setState(() {
        weatherData = data;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar dados do tempo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = weatherData!['weather'][0]['main'].toString().toLowerCase();
    String iconPath;
    String backgroundPath;
    if (condition.contains('clear')) {
      iconPath = 'assets/images/icons/sol.png';
      backgroundPath = 'assets/images/background/telaSol.png';
    }
    else if (condition.contains('clouds')) {
      iconPath = 'assets/images/icons/nublado.png';
      backgroundPath = 'assets/images/background/telaNublado.png';
    }
    else if (condition.contains('rain')) {
      iconPath = 'assets/images/icons/chuva.png';
      backgroundPath = 'assets/images/background/telaChuva.png';
    }
    else if (condition.contains('thunderstorm')) {
      iconPath = 'assets/images/icons/tempestade.png';
      backgroundPath = 'assets/images/background/telaTempestade.png';
    }
    else {
      iconPath = 'assets/images/icons/sol.png';
      backgroundPath = 'assets/images/background/telaSol.png';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Digite a cidade...',
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.search, color: Colors.black),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) => loadWeather(value),
        ),
      ),
      body: weatherData == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(backgroundPath),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          iconPath,
                          width: 110,
                          height: 110,
                        ),
                        const SizedBox(width: 80),
                        Text(
                          '${weatherData!['main']['temp'].toInt()}°',
                          style: TextStyle(
                            fontSize: 90,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Grid com 4 cards
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                        children: [
                          _infoCard(
                            'Sensação',
                            '${weatherData!['main']['feels_like'].toInt()}°',
                            Icons.thermostat,
                          ),
                          _infoCard(
                            'Umidade',
                            '${weatherData!['main']['humidity']}%',
                            Icons.water_drop,
                          ),
                          _infoCard(
                            'Vento',
                            '${weatherData!['wind']['speed']} m/s',
                            Icons.air,
                          ),
                          _infoCard(
                            'Pressão',
                            '${weatherData!['main']['pressure']} hPa',
                            Icons.speed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _infoCard(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: Colors.black87),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
