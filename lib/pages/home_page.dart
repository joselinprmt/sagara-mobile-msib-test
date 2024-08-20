import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sagara_mobile_msib_test/models/weather.dart';
import 'package:sagara_mobile_msib_test/api/api.dart';

import '../styles/styles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<WeatherForecast>> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = fetchDailyWeatherForecast();
  }

  Future<void> _refreshWeather() async {
    setState(() {
      futureWeather = fetchDailyWeatherForecast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0x001f271b),
        body: SafeArea(
          child: FutureBuilder<List<WeatherForecast>>(
            future: futureWeather,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Terjadi kesalahan. Silahkan coba lagi",
                        style: currentDateStyle,
                      ), // Add some space between the error message and the refresh button
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.refresh),
                        iconSize: 30,
                        onPressed: _refreshWeather,
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasData) {
                final weathers = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: _refreshWeather,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _currentWeather(context, weathers[0]),
                        _temperatureDetail(context, weathers[0]),
                        _dailyForecast(context, weathers),
                        IconButton(
                          color: Colors.white,
                          icon: const Icon(Icons.refresh),
                          iconSize: 30,
                          onPressed: _refreshWeather,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        "Tidak ada data. Silahkan coba lagi",
                        style: currentDateStyle,
                      ),
                      IconButton(
                        color: Colors.white,
                        icon: const Icon(Icons.refresh),
                        iconSize: 30,
                        onPressed: _refreshWeather,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ));
  }
}

Widget _currentWeather(BuildContext context, WeatherForecast weather) {
  final date = weather.dateTime.toLocal();
  return Column(children: [
    const SizedBox(height: 16),
    Text(
      weather.description,
      style: currentWeatherDescriptionStyle,
    ),
    Image.network(
      getWeatherIconUrl(weather.icon),
      width: 150,
      height: 150,
    ),
    Text(
      '${weather.temperature}°C',
      style: currentTemperatureStyle,
    ),
    const SizedBox(height: 8),
    Text(
      "${DateFormat("EEEE").format(date)}, ${DateFormat("d MMMM y").format(date)}",
      style: currentDateStyle,
    ),
    const SizedBox(height: 8),
  ]);
}

Widget _temperatureDetail(BuildContext context, WeatherForecast weather) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  "${weather.humidity.toString()}°",
                  style: detailTitleStyle,
                  textAlign: TextAlign.center,
                ),
                const Text(
                  "Humidity",
                  style: detailSubtitleStyle,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  "${weather.tempMin.toInt()}°C",
                  style: detailTitleStyle,
                ),
                const Text(
                  "Minimum\nTemperature",
                  style: detailSubtitleStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  "${weather.tempMax.toInt()}°C",
                  style: detailTitleStyle,
                ),
                const Text(
                  "Maximum\nTemperature",
                  style: detailSubtitleStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _dailyForecast(BuildContext context, List<WeatherForecast> weathers) {
  return SizedBox(
    child: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            "3 Days Forecasts",
            style: forecastTitleStyle,
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 1; i <= 3; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: _weatherCard(context, weathers[i]),
                ),
              ),
          ],
        ),
      ],
    ),
  );
}

Widget _weatherCard(BuildContext context, WeatherForecast weather) {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    color: Colors.white.withOpacity(0.2),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        height: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd-MM').format(weather.dateTime),
              style: weatherCardDateStyle,
              textAlign: TextAlign.center,
            ),
            Image.network(
              getWeatherIconUrl(weather.icon),
              width: 80,
              height: 80,
            ),
            Text(
              "${weather.tempMax.toInt()}°C",
              style: weatherCardTemperatureStyle,
            ),
            const SizedBox(height: 8),
            Text(
              weather.description,
              style: weatherCardDescriptionStyle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
