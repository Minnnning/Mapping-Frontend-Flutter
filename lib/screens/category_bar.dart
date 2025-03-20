import 'package:flutter/material.dart';
import 'package:mapping_flutter/theme/colors.dart';
import 'package:provider/provider.dart';
import '../providers/marker_provider.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({Key? key}) : super(key: key);

  // 표시할 카테고리와 실제 카테고리를 매핑
  final Map<String, String> categoryMapping = const {
    "전체": "전체",
    "화장실": "공용 화장실",
    "주차장": "주차장",
    "흡연장": "흡연장",
    "쓰레기통": "쓰레기통",
    "기타": "기타",
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkerProvider>(
      builder: (context, markerProvider, child) {
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categoryMapping.keys.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              String displayCategory = categoryMapping.keys.elementAt(index);
              String actualCategory = categoryMapping[displayCategory]!;
              bool isSelected =
                  markerProvider.selectedCategory == actualCategory;

              return ChoiceChip(
                label: Text(
                  displayCategory,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    markerProvider.setCategory(actualCategory);
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
