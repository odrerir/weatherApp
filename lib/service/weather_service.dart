import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '20dcf846ff69c694b0668986fdc061b4';
  final String baseUrl = 'https://pro.openweathermap.org/data/2.5/weather';

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse('$baseUrl?q=$city&units=metric&lang=pt_br&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar dados do clima: ${response.statusCode}');
    }
  }
}
