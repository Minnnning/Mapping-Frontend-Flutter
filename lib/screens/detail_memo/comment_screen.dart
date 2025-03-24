import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CommentView extends StatefulWidget {
  final int memoId; // 외부에서 전달받은 memoId

  const CommentView({Key? key, required this.memoId}) : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCommentIds();
  }

  Future<void> _fetchCommentIds() async {
    final url = Uri.parse(
        'https://api.mapping.kro.kr/api/v2/comment/ids?memoId=${widget.memoId}');

    final response = await http.get(url, headers: {'accept': '*/*'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<int> commentIds = List<int>.from(data['data']);

      _fetchCommentDetails(commentIds);
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchCommentDetails(List<int> commentIds) async {
    List<Map<String, dynamic>> fetchedComments = [];

    for (int id in commentIds) {
      final url = Uri.parse('https://api.mapping.kro.kr/api/v2/comment/$id');
      final response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer YOUR_ACCESS_TOKEN'
      });

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
