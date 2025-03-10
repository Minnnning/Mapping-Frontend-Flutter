import 'package:flutter/material.dart';
import 'login_screen.dart';

class ResizableSearchBar extends StatefulWidget {
  const ResizableSearchBar({Key? key}) : super(key: key);

  @override
  _ResizableSearchBarState createState() => _ResizableSearchBarState();
}

class _ResizableSearchBarState extends State<ResizableSearchBar>
    with SingleTickerProviderStateMixin {
  double _currentHeightFactor = 0.15; // 최소 상태: 화면 높이의 15%
  double _dragStartHeightFactor = 0.15;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  // 세 가지 스냅 포지션: 최소, 중간, 최대
  final double minHeightFactor = 0.15;
  final double midHeightFactor = 0.5;
  final double maxHeightFactor = 0.85;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// 현재 높이와 가장 가까운 스냅 위치를 결정합니다.
  double _getClosestSnap(double value) {
    double diffMin = (value - minHeightFactor).abs();
    double diffMid = (value - midHeightFactor).abs();
    double diffMax = (value - maxHeightFactor).abs();
    if (diffMin <= diffMid && diffMin <= diffMax) return minHeightFactor;
    if (diffMid <= diffMin && diffMid <= diffMax) return midHeightFactor;
    return maxHeightFactor;
  }

  /// 지정한 스냅 위치로 애니메이션을 통해 이동합니다.
  void _animateToSnap(double snapValue) {
    _heightAnimation = Tween<double>(begin: _currentHeightFactor, end: snapValue)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut))
      ..addListener(() {
        setState(() {
          _currentHeightFactor = _heightAnimation.value;
        });
      });
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onVerticalDragStart: (details) {
          _dragStartHeightFactor = _currentHeightFactor;
        },
        onVerticalDragUpdate: (details) {
          setState(() {
            double delta = details.primaryDelta! / screenHeight;
            // 드래그 방향에 따라 높이 조절
            _currentHeightFactor =
                (_dragStartHeightFactor - delta).clamp(minHeightFactor, maxHeightFactor);
          });
        },
        onVerticalDragEnd: (details) {
          double snapValue = _getClosestSnap(_currentHeightFactor);
          _animateToSnap(snapValue);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _currentHeightFactor * screenHeight,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Colors.black26,
              )
            ],
          ),
          child: Column(
            children: [
              // 드래그 핸들: 사용자가 드래그할 수 있음을 암시
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 검색바: 텍스트 필드와 로그인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // 텍스트 입력창
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: '검색어 입력',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 로그인 버튼
                    ElevatedButton(
                      onPressed: () {
                        // 로그인 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      child: const Text('로그인'),
                    ),
                  ],
                ),
              ),
              // 최소 상태일 때는 검색바와 로그인 버튼만 보여줌.
              // 중간, 최대 상태일 때 추가 내용(예시로 텍스트)을 표시합니다.
              if (_currentHeightFactor > minHeightFactor + 0.01)
                Expanded(
                  child: Center(
                    child: Text(
                      '추가 내용이 여기에 표시됩니다.\n현재 높이: ${_currentHeightFactor.toStringAsFixed(2)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
