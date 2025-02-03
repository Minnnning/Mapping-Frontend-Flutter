import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> _handleLogin(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await AuthService().login(userProvider);
  }

  Future<void> _handleLogout(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await AuthService().logout(userProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakao Login'),
      ),
      body: Center(
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            UserModel? user = userProvider.user;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                user?.profileImageUrl.isNotEmpty == true
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(user!.profileImageUrl),
                        radius: 40,
                      )
                    : const Icon(Icons.account_circle, size: 80),
                const SizedBox(height: 10),
                Text(
                  user?.nickname ?? '로그인 해주세요',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: user == null
                      ? () => _handleLogin(context)
                      : () => _handleLogout(context),
                  child: Text(user == null ? '카카오 로그인' : '로그아웃'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
