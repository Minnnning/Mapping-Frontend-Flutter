import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_common.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  KakaoSdk.init(nativeAppKey: dotenv.get('KAKAO_NATIVE_APP_KEY'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kakao Login Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Kakao Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _userNickname;
  String? _userProfileImage;

  Future<void> _loginWithKakao() async {
    try {
      if (await isKakaoTalkInstalled()) {
        await UserApi.instance.loginWithKakaoTalk();
      } else {
        await UserApi.instance.loginWithKakaoAccount();
      }
      _fetchUserInfo();
    } catch (error) {
      print(await KakaoSdk.origin);
      print('Login failed: $error');
    }
  }

  Future<void> _fetchUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      setState(() {
        _userNickname = user.kakaoAccount?.profile?.nickname;
        _userProfileImage = user.kakaoAccount?.profile?.thumbnailImageUrl;
      });
    } catch (error) {
      print('Failed to get user info: $error');
    }
  }

  Future<void> _logout() async {
    try {
      await UserApi.instance.logout();
      setState(() {
        _userNickname = null;
        _userProfileImage = null;
      });
    } catch (error) {
      print('Logout failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _userProfileImage != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(_userProfileImage!),
                    radius: 40,
                  )
                : const Icon(Icons.account_circle, size: 80),
            const SizedBox(height: 10),
            Text(
              _userNickname ?? '로그인 해주세요',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _userNickname == null ? _loginWithKakao : _logout,
              child: Text(_userNickname == null ? '카카오 로그인' : '로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
