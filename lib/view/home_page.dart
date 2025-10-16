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

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      var data = await weatherService.getWeather('Sao Paulo');
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

  String getBackgroundImage(condition) {
    if (weatherData == null) return 'assets/images/background/telaSol.png';


    if (condition.contains('clear')) {
      return 'assets/images/background/telaSol.png';
    } else if (condition.contains('clouds')) {
      return 'assets/images/background/telaNublado.png';
    } else if (condition.contains('rain')) {
      return 'assets/images/background/telaChuva.png';
    } else if (condition.contains('thunderstorm')) {
      return 'assets/images/background/telaTempestade.png';
    } else {
      return 'assets/images/background/telaSol.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),

      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(getBackgroundImage(
                weatherData != null ? weatherData!['weather'][0]['main'].toString().toLowerCase() : 'clear')),
            fit: BoxFit.cover,
          ),
        ),

        child: Center(
          child: errorMessage != null ? Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 18),
                ): weatherData == null ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${weatherData!['main']['temp']}°C',
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          weatherData!['weather'][0]['description'],
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        Text('Umidade: ${weatherData!['main']['humidity']}%',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
