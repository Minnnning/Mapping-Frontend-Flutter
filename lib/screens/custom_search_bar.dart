import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final DraggableScrollableController sheetController;
  final ValueChanged<String>? onChanged;

  const CustomSearchBar(
      {Key? key, required this.sheetController, this.onChanged})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTap: () {
        // 드래그 시트 크기 키우기
        sheetController.animateTo(
          0.9,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: '검색어 입력',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
