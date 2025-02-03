import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;

  Future<void> _handleLogin() async {
    UserModel? user = await _authService.login();
    if (user != null) {
      setState(() => _user = user);
    }
  }

  Future<void> _handleLogout() async {
    await _authService.logout();
    setState(() => _user = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakao Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _user?.profileImageUrl.isNotEmpty == true
                ? CircleAvatar(
                    backgroundImage: NetworkImage(_user!.profileImageUrl),
                    radius: 40,
                  )
                : const Icon(Icons.account_circle, size: 80),
            const SizedBox(height: 10),
            Text(
              _user?.nickname ?? '로그인 해주세요',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _user == null ? _handleLogin : _handleLogout,
              child: Text(_user == null ? '카카오 로그인' : '로그아웃'),
            ),
          ],
        ),
      ),
    );
  }
}
