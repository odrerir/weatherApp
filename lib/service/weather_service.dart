import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = '20dcf846ff69c694b0668986fdc061b4';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5'; //

  Future<Map<String, dynamic>> getWeather(String city) async {
    final url = Uri.parse('$baseUrl/weather?q=$city&units=metric&lang=pt_br&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar dados atuais doclima: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getFiveDayForecast(String city) async {
    final url = Uri.parse('$baseUrl/forecast?q=$city&units=metric&lang=pt_br&appid=$apiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao buscar previsão de 5 dias: ${response.statusCode}');
    }
  }
}
