import 'package:flutter/material.dart';
import 'package:mapping_flutter/screens/add_memo/memo_input_screen_1.dart';
import 'package:provider/provider.dart';
import 'package:mapping_flutter/theme/colors.dart';
import '../providers/marker_provider.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({Key? key}) : super(key: key);

  // 표시할 카테고리와 실제 카테고리를 매핑
  final Map<String, String> categoryMapping = const {
    "전체": "전체",
    "흡연장": "흡연장",
    "주차장": "주차장",
    "쓰레기통": "쓰레기통",
    "화장실": "공용 화장실",
    "기타": "기타",
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<MarkerProvider>(
      builder: (context, markerProvider, child) {
        // 총 아이템 수: 카테고리 개수 + 지도보기 버튼 1개
        int itemCount = categoryMapping.keys.length + 1;
        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // 마지막 아이템은 지도 보기 버튼
              if (index == categoryMapping.keys.length) {
                return ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemoInputScreen1()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    //primary: mainColor,
                    //onPrimary: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text("메모 추가"),
                );
              }

              // 나머지 아이템은 기존 ChoiceChip
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
