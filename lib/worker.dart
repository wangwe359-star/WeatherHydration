import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String kWeatherApiKey = String.fromEnvironment('WEATHER_API_KEY', defaultValue: 'REPLACE_WITH_YOUR_OPENWEATHERMAP_KEY');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> checkWeatherAndNotify(double lat, double lon) async {
  final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$kWeatherApiKey&units=metric&lang=zh_cn');

  final resp = await http.get(url);
  if (resp.statusCode != 200) return;

  final data = json.decode(resp.body);
  final hourly = data['hourly'] as List<dynamic>;

  // 简单判断未来12小时是否有降雨（weather id 表示）
  bool willRain = false;
  for (int i = 0; i < hourly.length && i < 12; i++) {
    final hour = hourly[i];
    final weather = hour['weather'][0];
    final id = weather['id'];
    if (id < 700) {
      willRain = true;
      break;
    }
  }

  if (willRain) {
    await flutterLocalNotificationsPlugin.show(
      1,
      '降雨提醒',
      '未来 12 小时内可能下雨，请带好雨具。',
      const NotificationDetails(
        android: AndroidNotificationDetails('weather_channel', '天气提醒',
            importance: Importance.high),
      ),
    );
  }
}
