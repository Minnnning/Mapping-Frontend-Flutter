import 'package:flutter/material.dart';
import 'package:mapping_flutter/screens/add_memo/memo_input_screen_1.dart';
import 'package:provider/provider.dart';
import 'package:mapping_flutter/theme/colors.dart';
import '../providers/marker_provider.dart';
import '../providers/user_provider.dart';

class CategoryBar extends StatelessWidget {
  const CategoryBar({Key? key}) : super(key: key);

  // 표시할 카테고리와 실제 카테고리를 매핑
  final Map<String, String> baseCategoryMapping = const {
    "전체": "전체",
    "개인": "개인",
    "흡연장": "흡연장",
    "주차장": "주차장",
    "사진명소": "사진명소",
    "쓰레기통": "쓰레기통",
    "화장실": "공용 화장실",
    "기타": "기타",
  };

  @override
  Widget build(BuildContext context) {
    return Consumer2<MarkerProvider, UserProvider>(
      builder: (context, markerProvider, userProvider, child) {
        bool isLoggedIn = userProvider.user != null; // 로그인 여부 확인
        Map<String, String> categoryMapping = Map.from(baseCategoryMapping);

        // 로그인하지 않은 경우 '개인' 카테고리 제거
        if (!isLoggedIn) {
          categoryMapping.remove("개인");
        }

        // 전체 카테고리 개수 + "메모 추가" 버튼(로그인한 경우만)
        int itemCount = categoryMapping.keys.length + 1;

        return SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // 첫 번째 버튼: "메모 추가" (로그인한 경우만)
              if (index == 0) {
                if (isLoggedIn) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 6), // 원하는 세로 패딩 설정
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MemoInputScreen1()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        backgroundColor: addMakerColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9.0),
                        ),
                      ),
                      child: const Text(
                        "메모 추가", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );

                } else {
                  return const SizedBox.shrink(); // 로그인하지 않은 경우 버튼 제거
                }
              }

              // 나머지 카테고리 버튼
              String displayCategory = categoryMapping.keys.elementAt(index - 1); // index - 1 (메모 추가 버튼 고려)
              String actualCategory = categoryMapping[displayCategory]!;
              bool isSelected = markerProvider.selectedCategory == actualCategory;

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
