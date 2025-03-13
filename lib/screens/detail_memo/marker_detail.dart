import 'package:flutter/material.dart';
import '../../services/marker_detail_service.dart'; // ✅ 서비스 파일 import

void showMarkerDetail(BuildContext context, Map<String, dynamic> memo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // ✅ 높이 조정 가능하게 설정
    builder: (context) {
      return FutureBuilder<Map<String, dynamic>?>(
        future: MarkerDetailService.fetchMemoDetail(memo['id']), // API 요청
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()), // 로딩 표시
            );
          }
          if (!snapshot.hasData) {
            return const SizedBox(
              height: 300,
              child: Center(child: Text("데이터를 불러오지 못했습니다.")),
            );
          }

          final memo = snapshot.data!;

          return Container(
            padding: const EdgeInsets.all(16),
            height: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(memo['title'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("카테고리: ${memo['category']}"),
                Text("내용: ${memo['content']}"),
                Text("작성자: ${memo['nickname']}"),
                Text("좋아요: ${memo['likeCnt']}  싫어요: ${memo['hateCnt']}"),
                const SizedBox(height: 10),
                if (memo['profileImage'] != null) // 프로필 이미지 표시
                  Align(
                    alignment: Alignment.centerLeft,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(memo['profileImage']),
                      radius: 20,
                    ),
                  ),
                const Spacer(),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("닫기"),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
