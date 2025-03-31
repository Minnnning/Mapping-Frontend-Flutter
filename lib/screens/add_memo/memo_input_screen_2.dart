import 'package:flutter/material.dart';

class MemoInputScreen2 extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MemoInputScreen2({Key? key, required this.latitude, required this.longitude}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("다음 화면")),
      body: Center(
        child: Text("위도: $latitude\n경도: $longitude"),
      ),
    );
  }
}
