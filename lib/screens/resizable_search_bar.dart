import 'package:flutter/material.dart';
import './profile_button.dart';
import './custom_search_bar.dart';

class ResizableSearchBar extends StatefulWidget {
  const ResizableSearchBar({Key? key}) : super(key: key);

  @override
  _ResizableSearchBarState createState() => _ResizableSearchBarState();
}

class _ResizableSearchBarState extends State<ResizableSearchBar> {
  double _heightFactor = 0.15;
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
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CustomSearchBar(),
                    SizedBox(width: 8),
                    ProfileButton(),
                  ],
                ),
              ),
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
