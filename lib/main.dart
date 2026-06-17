import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String kWeatherApiKey =
    String.fromEnvironment('WEATHER_API_KEY',
        defaultValue: 'REPLACE_WITH_YOUR_OPENWEATHERMAP_KEY');

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '天气与喝水提醒',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _status = '等待获取位置信息';
  String _weather = '暂无天气信息';

  @override
  void initState() {
    super.initState();
    _requestLocationAndWeather();
  }

  Future<void> _requestLocationAndWeather() async {
    setState(() {
      _status = '请求定位权限...';
    });

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _status = '定位权限被拒绝';
      });
      return;
    }

    setState(() {
      _status = '获取当前位置...';
    });

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );

    setState(() {
      _status =
          '当前位置: ${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    });

    await _fetchWeather(pos.latitude, pos.longitude);
  }

  Future<void> _fetchWeather(double lat, double lon) async {
    setState(() {
      _weather = '正在获取天气...';
    });

    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/onecall?lat=$lat&lon=$lon&exclude=minutely,alerts&appid=$kWeatherApiKey&units=metric&lang=zh_cn');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final current = data['current'];
        final weatherDesc = current['weather'][0]['description'];
        final temp = current['temp'];
        setState(() {
          _weather = '$temp°C, $weatherDesc';
        });
        if (data['hourly'] != null) {
          final hourly = data['hourly'] as List<dynamic>;
          bool willRain = false;
          for (int i = 0; i < hourly.length && i < 12; i++) {
            final weatherId = hourly[i]['weather'][0]['id'] as int;
            if (weatherId < 700) {
              willRain = true;
              break;
            }
          }
          if (willRain) {
            await _showNotification('降雨提醒', '未来 12 小时可能下雨，请准备雨具');
          }
        }
      } else {
        setState(() {
          _weather = '天气信息获取失败: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _weather = '天气获取异常';
      });
    }
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'weather_channel',
      '天气提醒',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('天气与喝水提醒')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('状态：$_status'),
            const SizedBox(height: 8),
            Text('当前天气：$_weather'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _requestLocationAndWeather,
              child: const Text('手动刷新天气'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _showNotification('喝水提醒', '请喝一杯水，保持健康。'),
              child: const Text('测试喝水提醒'),
            ),
          ],
        ),
      ),
    );
  }
}
