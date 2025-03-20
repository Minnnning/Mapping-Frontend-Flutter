import 'package:flutter/material.dart';
import './profile_button.dart';
import './custom_search_bar.dart';
import 'category_bar.dart';

class ResizableSearchBar extends StatelessWidget {
  const ResizableSearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.15, // 처음 크기 (15%)
      minChildSize: 0.15, // 최소 크기 (15%)
      maxChildSize: 0.9, // 최대 크기 (85%)
      snap: true,
      snapSizes: [0.15, 0.5, 0.85], // 15%, 50%, 85%에서 멈춤
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            // 박스 UI
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: ListView(
            controller: scrollController, // 스크롤 가능하도록 설정
            padding: EdgeInsets.zero,
            children: [
              // Drag Handle 영역 추가
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40, // 핸들의 가로 크기를 제한
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    CustomSearchBar(),
                    const SizedBox(width: 8),
                    ProfileButton(),
                  ],
                ),
              ),
              // const SizedBox(height: 10),
              CategoryBar(),
            ],
          ),
        );
      },
    );
  }
}
