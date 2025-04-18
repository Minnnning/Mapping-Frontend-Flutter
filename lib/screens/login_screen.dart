import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'activity_memo/commented_memo_screen.dart';
import 'activity_memo/liked_memo_screen.dart';
import 'activity_memo/my_memos_screen.dart';
import 'change_info_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final UserModel? user = userProvider.user;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text('내 정보'),
            actions: [
              if (user != null)
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => _handleLogout(context),
                  tooltip: '로그아웃',
                ),
            ],
          ),
          body: Column(
            children: [
              buildProfileSection(context, user),
              buildDivider(),
              user == null
                  ? buildLoginButton(context)
                  : buildUserActions(context, user),
              if (user != null) buildBlockedUsersButton(context),
              const Spacer(),
              buildLicenseButton(context),
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('문의하기 이메일: team.mapping.app@gmail.com'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildProfileSection(BuildContext context, UserModel? user) {
    return Container(
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              user != null && user.profileImageUrl.isNotEmpty
                  ? CircleAvatar(
                      backgroundImage: NetworkImage(user.profileImageUrl),
                      radius: 25,
                    )
                  : CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 25,
                      child: user != null
                          ? Text(
                              user.nickname[0],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ), // 로그인 안 된 경우 기본 아이콘
                    ),
              const SizedBox(width: 10),
              Text(
                user?.nickname ?? '로그인이 필요합니다.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(child: SizedBox()),
              if (user != null) // 로그인한 경우에만 프로필 변경 버튼 표시
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChangeInfoScreen()),
                  ),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: mainColor // 버튼 색상 설정
                      ),
                  child: const Text('프로필 변경'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 구분선
  Widget buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        color: boxGray,
        thickness: 1,
        indent: 16,
        endIndent: 16,
      ),
    );
  }

  /// 로그인 버튼 섹션 (로그인하지 않은 경우)
  Widget buildLoginButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: boxGray,
        borderRadius: BorderRadius.circular(9),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      width: double.infinity,
      child: GestureDetector(
        onTap: () => _handleLogin(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Image.asset(
            'assets/images/kakao_login_large_wide.png',
            height: 40,
          ),
        ),
      ),
    );
  }

  /// 사용자 활동 섹션 (로그인한 경우)
  Widget buildUserActions(BuildContext context, UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: boxGray,
        borderRadius: BorderRadius.circular(9),
      ),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 5),
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 활동',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyMemoScreen()),
            ),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: Colors.black,
            ),
            child: const Text('📝 내 메모'),
          ),
          const Divider(height: 1, thickness: 1),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LikedMemoScreen()),
            ),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: Colors.black,
            ),
            child: const Text('👍 좋아요 누른 메모'),
          ),
          const Divider(height: 1, thickness: 1),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CommentedMemoScreen()),
            ),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: Colors.black,
            ),
            child: const Text('💬 댓글 단 메모'),
          ),
        ],
      ),
    );
  }

  /// 차단한 사용자 버튼 섹션 (로그인한 경우)
  Widget buildBlockedUsersButton(BuildContext context) {
    return Column(
      children: [
        buildDivider(),
        Container(
          decoration: BoxDecoration(
            color: boxGray,
            borderRadius: BorderRadius.circular(9),
          ),
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          width: double.infinity,
          child: TextButton(
            onPressed: () => print('🚫 차단한 사용자 클릭됨'),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              foregroundColor: Colors.black,
            ),
            child: const Text('🚫 차단한 사용자'),
          ),
        )
      ],
    );
  }
}

Widget buildLicenseButton(BuildContext context) {
  return Column(
    children: [
      Container(
        // decoration: BoxDecoration(
        //   color: boxGray,
        //   borderRadius: BorderRadius.circular(9),
        // ),
        padding: const EdgeInsets.only(left: 16, right: 16),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        width: double.infinity,
        child: TextButton(
          onPressed: () async {
            final info = await PackageInfo.fromPlatform();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LicensePage(
                  applicationName: info.appName,
                  applicationVersion: info.version,
                  applicationIcon: const FlutterLogo(),
                ),
              ),
            );
          },
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            foregroundColor: Colors.black,
          ),
          child: const Text('📄 오픈소스 라이선스 보기'),
        ),
      ),
    ],
  );
}
