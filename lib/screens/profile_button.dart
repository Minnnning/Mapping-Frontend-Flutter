import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/login_screen.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final bool isLoggedIn = user != null;
        final bool hasProfileImage =
            isLoggedIn && user.profileImageUrl.isNotEmpty;

        return TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: isLoggedIn
              ? CircleAvatar(
                  backgroundImage: hasProfileImage
                      ? NetworkImage(user.profileImageUrl)
                      : null,
                  backgroundColor: hasProfileImage ? null : Colors.grey,
                  radius: 20,
                  child: !hasProfileImage
                      ? Text(
                          user.nickname[0],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                )
              : const CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
