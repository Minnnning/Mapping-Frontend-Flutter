import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentView extends StatefulWidget {
  final int memoId; // 외부에서 전달받은 memoId

  const CommentView({Key? key, required this.memoId}) : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage(); // Secure Storage 인스턴스 생성
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  String? _accessToken; // 토큰 저장 변수

  @override
  void initState() {
    super.initState();
    _loadAccessToken(); // 토큰 먼저 로드
  }

  /// 🔹 SecureStorage에서 AccessToken 가져오기
  Future<void> _loadAccessToken() async {
    String? token = await _secureStorage.read(key: 'accessToken');
    setState(() {
      _accessToken = token;
    });
    _fetchCommentIds(); // 토큰 로드 후 API 호출
  }

  /// 🔹 댓글 ID 목록 가져오기
  Future<void> _fetchCommentIds() async {
    final url = Uri.parse(
        'https://api.mapping.kro.kr/api/v2/comment/ids?memoId=${widget.memoId}');

    // 🔥 헤더 동적 설정 (토큰이 없으면 Authorization 제외)
    Map<String, String> headers = {'accept': '*/*'};
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    } else {
      print("⚠️ 엑세스 토큰 없음. 토큰 없이 요청을 보냅니다.");
    }

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<int> commentIds = List<int>.from(data['data']);
      _fetchCommentDetails(commentIds);
    } else {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 댓글 상세 정보 가져오기
  Future<void> _fetchCommentDetails(List<int> commentIds) async {
    List<Map<String, dynamic>> fetchedComments = [];

    for (int id in commentIds) {
      final url = Uri.parse('https://api.mapping.kro.kr/api/v2/comment/$id');

      // 🔥 헤더 동적 설정
      Map<String, String> headers = {'accept': '*/*'};
      if (_accessToken != null) {
        headers['Authorization'] = 'Bearer $_accessToken';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        fetchedComments.add(data['data']);
      }
    }

    setState(() {
      comments = fetchedComments;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : comments.isEmpty
            ? const Center(child: Text("댓글이 없습니다."))
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero, // ListView의 기본 패딩 제거
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                    leading: CircleAvatar(
                      backgroundImage: comment['profileImageUrl'] != null
                          ? NetworkImage(comment['profileImageUrl'])
                          : null,
                      child: comment['profileImageUrl'] == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(
                      comment['nickname'] ?? '익명',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(comment['comment'] ?? ''),
                    trailing: Text(
                      comment['updatedAt']?.split(' ')[0] ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 10,
                    endIndent: 10,
                    height: 1, // Divider 상하 패딩 제거
                  );
                },
              );
  }
}
