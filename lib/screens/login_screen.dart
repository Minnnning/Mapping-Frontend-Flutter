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
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0), // 마진 추가
                          child: Image.asset(
                            'assets/images/kakao_login_large_wide.png',
                            height: 40,
                          ),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                        children: [
                          Text(
                            '내 활동',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16), // 강조 (선택)
                          ),
                          SizedBox(height: 1), // 텍스트와 버튼 간격 줄이기
                          TextButton(
                            onPressed: () {
                              print('TextButton 클릭됨');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero, // 기본 패딩 제거
                              alignment: Alignment.centerLeft, // 왼쪽 정렬
                              foregroundColor: Colors.black,
                            ),
                            child: Text('📝 내 메모'),
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          TextButton(
                            onPressed: () {
                              print('TextButton 클릭됨');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('👍 좋아요 누른 메모'),
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          TextButton(
                            onPressed: () {
                              print('TextButton 클릭됨');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('💬 댓글 단 메모'),
                          ),
                        ],
                      );
              },
            ),
          ),
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              UserModel? user = userProvider.user;
              return user != null // 로그인한 경우만 Column 표시
                  ? Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Divider(
                            color: boxGray,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: boxGray,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(horizontal: 16.0),
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              print('TextButton 클릭됨');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('🚫 차단한 사용자'),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(); // 로그인하지 않은 경우 빈 공간 반환
            },
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
