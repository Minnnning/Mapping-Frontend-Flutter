import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const CustomSearchBar({Key? key, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: '검색어 입력',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
