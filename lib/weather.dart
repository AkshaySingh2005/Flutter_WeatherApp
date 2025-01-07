import 'dart:convert';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'additional_info.dart';
import 'weather_forecastcard.dart';
import 'package:http/http.dart' as http;
import 'api.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getWeather() async {
    try {
      String cityName = 'Pune';
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,in&APPID=$openWeatherMapAPI'),
      );
      final data = jsonDecode(res.body);

      if (data['cod'] != '200') {
        throw data['message'];
      }
      //
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Weather App',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {},
            ),
          ],
        ),
        body: FutureBuilder(
          future: getWeather(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            final data = snapshot.data!;

            final currentTemp = data['list'][0]['main']['temp'] - 273.15;
            final currentSky = data['list'][0]['weather'][0]['main'];
            final currentHumidity = data['list'][0]['main']['humidity'];
            final currentWindSpeed = data['list'][0]['wind']['speed'];
            final currentPressure = data['list'][0]['main']['pressure'];

            return Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              '${currentTemp.toStringAsFixed(2)} °C',
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 15),
                            BoxedIcon(
                              currentSky == 'Clear'
                                  ? WeatherIcons.day_sunny
                                  : currentSky == 'Clouds'
                                      ? WeatherIcons.day_cloudy
                                      : currentSky == 'Rain'
                                          ? WeatherIcons.rain
                                          : currentSky == 'Snow'
                                              ? WeatherIcons.snow
                                              : Icons
                                                  .error, // Default icon if none match
                              size: 64,
                            ),
                            SizedBox(height: 15),
                            Text('$currentSky', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Today\'s Forecast',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      itemCount: 5,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final hourlyForecast = data['list'][index + 1];
                        final hourlySky =
                            data['list'][index + 1]['weather'][0]['main'];
                        final hourlyTemp = double.parse(
                                hourlyForecast['main']['temp'].toString()) -
                            273.15;
                        final time = DateTime.parse(hourlyForecast['dt_txt']);
                        return HourlyForecastItem(
                          time: DateFormat.j().format(time),
                          temperature: hourlyTemp.toStringAsFixed(2),
                          icon: hourlySky == 'Clear'
                              ? WeatherIcons.day_sunny
                              : hourlySky == 'Clouds'
                                  ? WeatherIcons.day_cloudy
                                  : hourlySky == 'Rain'
                                      ? WeatherIcons.rain
                                      : hourlySky == 'Snow'
                                          ? WeatherIcons.snow
                                          : Icons
                                              .error, // Default icon if none match
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Additional Information',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      AdditionalInfoCard(
                        icon: Icons.water_drop,
                        label: 'Humidity',
                        value: '$currentHumidity',
                      ),
                      SizedBox(width: 10),
                      AdditionalInfoCard(
                        icon: Icons.air,
                        label: 'Wind Speed',
                        value: '$currentWindSpeed',
                      ),
                      SizedBox(width: 10),
                      AdditionalInfoCard(
                        icon: Icons.beach_access,
                        label: 'Pressure',
                        value: '$currentPressure',
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        ));
  }
}
