import 'package:flutter/material.dart';
import 'package:weather/service/weather_service.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherService weatherService = WeatherService();
  Map<String, dynamic>? weatherData;
  Map<String, dynamic>? fiveDayForecast;
  String? errorMessage;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null).then((_) {
      loadWeather('guarapuava');
    });
  }

  Future<void> loadWeather(String city) async {
    setState(() {
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        weatherService.getWeather(city),
        weatherService.getFiveDayForecast(city),
      ]);

      setState(() {
        weatherData = results[0] as Map<String, dynamic>?;
        fiveDayForecast = results[1] as Map<String, dynamic>?;
        errorMessage = null;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao carregar dados do tempo.';
      });

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Por favor, escreva uma cidade válida.',
            style: TextStyle(
            fontSize: 18,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK',
                style: TextStyle(
                fontSize: 18,
              ),
            ),
            ),
          ],
        ),
      );
    }
  }

  String _getIcon(bool isCurrent, [int index = 0]) {
    String condition = '';

    try {
      if (isCurrent) {
        condition = weatherData?['weather']?[0]?['main']?.toString().toLowerCase() ?? '';
      } else {
        final list = fiveDayForecast?['list'] as List<dynamic>?;
        if (list != null && index >= 0 && index < list.length) {
          condition = list[index]['weather'][0]['main'].toString().toLowerCase();
        }
      }
    } catch (_) {
      condition = '';
    }

    if (condition.contains('clear')) return 'assets/images/icons/sol.png';
    if (condition.contains('cloud')) return 'assets/images/icons/nublado.png';
    if (condition.contains('rain')) return 'assets/images/icons/chuva.png';
    if (condition.contains('thunder')) return 'assets/images/icons/tempestade.png';

    return 'assets/images/icons/sol.png';
  }

  String _getBackground() {
    final condition = weatherData?['weather']?[0]?['main']?.toString().toLowerCase() ?? '';
    if (condition.contains('clear')) return 'assets/images/background/telaSol.png';
    if (condition.contains('cloud')) return 'assets/images/background/telaNublado.png';
    if (condition.contains('rain')) return 'assets/images/background/telaChuva.png';
    if (condition.contains('thunder')) return 'assets/images/background/telaTempestade.png';
    return 'assets/images/background/telaSol.png';
  }

  String _formatDate(String dtTxt) {
      final dt = DateTime.parse(dtTxt);
      return DateFormat('dd/MM', 'pt_BR').format(dt);
  }

  @override
  Widget build(BuildContext context) {

    if (weatherData == null || fiveDayForecast == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    final iconPath = _getIcon(true);
    final backgroundPath = _getBackground();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: TextField(
          controller: _search,
          decoration: InputDecoration(
            hintText: 'Digite a cidade...',
            hintStyle: const TextStyle(color: Colors.black54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                final value = _search.text.trim();
                if (value.isNotEmpty) {
                  loadWeather(value);
                }
              },
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: (value) {
            final v = value.trim();
            if (v.isNotEmpty) loadWeather(v);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundPath),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // CLIMA ATUAL
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ÍCONE E DESCRIÇÃO
                        Column(
                          children: [
                            Image.asset(iconPath, width: 110, height: 110),
                            const SizedBox(height: 20),
                            Text(
                              (() {
                                final desc = weatherData!['weather'][0]['description'].toString();
                                if (desc.isEmpty) return '';
                                return desc.replaceFirst(desc[0], desc[0].toUpperCase());
                              })(),
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 80),

                        // TEMPERATURA E CIDADE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '${weatherData!['main']['temp'].toInt()}°',
                              style: const TextStyle(
                                fontSize: 90,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              weatherData!['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // PREVISÃO DE 5 DIAS
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      final dayIndex = (index + 1) * 8;
                      final list = fiveDayForecast!['list'] as List<dynamic>;
                      final safeIndex = (dayIndex < list.length) ? dayIndex : (list.length - 1);
                      final item = list[safeIndex];
                      final dateTxt = item['dt_txt'].toString();
                      final formatted = _formatDate(dateTxt);
                      final cond = item['weather'][0]['main'].toString().toLowerCase();

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _fiveDays(cond, formatted, safeIndex),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // INFORMAÇÕES ATUAIS
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: [
                    _infoCard('Sensação', '${weatherData!['main']['feels_like'].toInt()}°', Icons.thermostat),
                    _infoCard('Umidade', '${weatherData!['main']['humidity']}%', Icons.water_drop),
                    _infoCard('Vento', '${weatherData!['wind']['speed']} m/s', Icons.air),
                    _infoCard('Pressão', '${weatherData!['main']['pressure']} hPa', Icons.speed),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
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
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fiveDays(String condition, String date, int index) {
    final iconPath = _getIcon(false, index);

    return Container(
      width: 90,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(date, style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Image.asset(iconPath, width: 50, height: 50),
          ],
        ),
      ),
    );
  }

}
