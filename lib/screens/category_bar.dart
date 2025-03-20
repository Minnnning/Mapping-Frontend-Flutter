import 'package:flutter/material.dart';
import 'package:mapping_flutter/theme/colors.dart';
import 'package:provider/provider.dart';
import '../providers/marker_provider.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({Key? key}) : super(key: key);

  final List<String> categories = const [
    "전체",
    "화장실",
    "주차장",
    "흡연장",
    "쓰레기통",
    "기타"
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkerProvider>(
      builder: (context, markerProvider, child) {
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              String category = categories[index];
              bool isSelected = markerProvider.selectedCategory == category;

              return ChoiceChip(
                label: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    markerProvider.setCategory(category);
                  }
                },
                selectedColor: mainColor,
                backgroundColor: Colors.grey[300],
                labelPadding: const EdgeInsets.symmetric(horizontal: 12),
              );
            },
          ),
        );
      },
    );
  }
}
