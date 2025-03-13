import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'login_screen.dart';

class ResizableSearchBar extends StatefulWidget {
  const ResizableSearchBar({Key? key}) : super(key: key);

  @override
  _ResizableSearchBarState createState() => _ResizableSearchBarState();
}

class _ResizableSearchBarState extends State<ResizableSearchBar> {
  double _heightFactor = 0.15; // 기본 높이 (최소)
  final double _minHeight = 0.15;
  final double _midHeight = 0.5;
  final double _maxHeight = 0.85;

  void _onDragUpdate(DragUpdateDetails details, double screenHeight) {
    setState(() {
      _heightFactor -= details.primaryDelta! / screenHeight;
      _heightFactor = _heightFactor.clamp(_minHeight, _maxHeight);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      if ((_heightFactor - _minHeight).abs() < 0.1) {
        _heightFactor = _minHeight;
      } else if ((_heightFactor - _midHeight).abs() < 0.1) {
        _heightFactor = _midHeight;
      } else {
        _heightFactor = _maxHeight;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) => _onDragUpdate(details, screenHeight),
        onVerticalDragEnd: _onDragEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _heightFactor * screenHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 검색바 + 로그인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '검색어 입력',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final user = userProvider.user;
                        final bool isLoggedIn = user != null;
                        final bool hasProfileImage =
                            isLoggedIn && user.profileImageUrl.isNotEmpty;

                        return isLoggedIn
                            ? TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero, // 모든 패딩 제거
                                  minimumSize: Size.zero,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: hasProfileImage
                                    ? CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(user.profileImageUrl),
                                        radius: 20,
                                      )
                                    : const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        radius: 20,
                                        child: Icon(Icons.person,
                                            size: 24, color: Colors.white),
                                      ),
                              )
                            : TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero, // 불필요한 패딩 제거
                                  minimumSize: Size(45, 45), // 버튼 크기 지정
                                  shape: const CircleBorder(
                                    side: BorderSide(color: Colors.grey),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen()),
                                  );
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "로그인",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                      },
                    ),
                  ],
                ),
              ),

              // 중간/최대 높이에서만 추가 내용 표시
              if (_heightFactor > _minHeight + 0.01)
                const Expanded(
                  child: Center(
                    child: Text('추가 내용이 여기에 표시됩니다.'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
