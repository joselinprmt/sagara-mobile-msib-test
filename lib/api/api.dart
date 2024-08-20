import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

Future<List<WeatherForecast>> fetchDailyWeatherForecast() async {
  final String apiKey = dotenv.env['API_KEY'] ?? 'no_api_key';
  const String baseUrl = 'https://api.openweathermap.org/data/2.5/forecast';
  const String city = 'Jakarta';
  const String units = 'metric'; // Using celcius

  final response = await http.get(
    Uri.parse('$baseUrl?q=$city&appid=$apiKey&units=$units'),
  );

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body)['list'];
    List<WeatherForecast> allForecasts =
        data.map((item) => WeatherForecast.fromJson(item)).toList();

    // Filter forecast for each day
    List<WeatherForecast> dailyForecast = allForecasts.where((forecast) {
      return forecast.dateTime.hour == 12;
    }).toList();

    return dailyForecast;
  } else {
    throw Exception('Failed to load weather forecast');
  }
}

String getWeatherIconUrl(String iconCode) {
  const String iconBaseUrl = 'http://openweathermap.org/img/wn/';
  return '$iconBaseUrl$iconCode@2x.png';
}
