import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

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
        title: const Text('내 정보'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              UserModel? user = userProvider.user;
              return user != null
                  ? IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _handleLogout(context),
                      tooltip: '로그아웃',
                    )
                  : const SizedBox.shrink(); // 로그인하지 않았을 때 숨김
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 프로필 정보
          Container(
            decoration: BoxDecoration(
              color: boxGray,
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                Row(
                  children: const [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text(
                      "프로필",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    UserModel? user = userProvider.user;
                    return Row(
                      children: <Widget>[
                        user?.profileImageUrl.isNotEmpty == true
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(user!.profileImageUrl),
                                radius: 25,
                              )
                            : const Icon(Icons.account_circle, size: 50),
                        const SizedBox(width: 10),
                        Text(
                          user?.nickname ?? '로그인이 필요합니다.',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // 구분선
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(
              color: boxGray,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
          ),
          // 로그인 버튼
          Container(
            decoration: BoxDecoration(
              color: boxGray,
              borderRadius: BorderRadius.circular(9),
            ),
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            width: double.infinity,
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                UserModel? user = userProvider.user;
                return user == null
                    ? GestureDetector(
                        onTap: () => _handleLogin(context),
                        child: Image.asset(
                          'assets/images/kakao_login_large_wide.png',
                          height: 40,
                        ),
                      )
                    : const SizedBox.shrink(); // 로그인 상태에서는 숨김
              },
            ),
          ),
          Expanded(child: Center()),
          // 문의 이메일
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text('문의하기 이메일: mapping@google.com'),
          ),
        ],
      ),
    );
  }
}
