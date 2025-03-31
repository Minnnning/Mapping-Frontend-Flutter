import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'screens/map_screen.dart';
import 'providers/user_provider.dart';
import 'providers/marker_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  final kakaoNativeAppKey = dotenv.env['KAKAO_NATIVE_APP_KEY'];

  if (kakaoNativeAppKey == null) {
    throw Exception('KAKAO_NATIVE_APP_KEY is not set in the .env file');
  }
  KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  var key = await KakaoSdk.origin;
  debugPrint("key : "+key);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MarkerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Kakao Map App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapScreen(), // MapScreen을 초기 화면으로 설정
    );
  }
}
