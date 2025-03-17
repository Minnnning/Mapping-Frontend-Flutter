import 'package:flutter/material.dart';
import '../../services/marker_detail_service.dart'; // ✅ 서비스 파일 import

void showMarkerDetail(BuildContext context, Map<String, dynamic> memo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // ✅ 높이 조정 가능하게 설정
    enableDrag: true,
    showDragHandle: true,
    builder: (BuildContext context) {
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
                memo['profileImage'] != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(memo['profileImage']),
                        radius: 25,
                      )
                    : CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 25,
                        child: memo['title'] != null
                            ? Text(
                                memo['nickname'][0],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ), // 로그인 안 된 경우 기본 아이콘
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
