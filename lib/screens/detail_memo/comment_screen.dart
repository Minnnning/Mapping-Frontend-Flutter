import 'package:flutter/material.dart';
import '../../services/comment_service.dart'; // 🔥 서비스 파일 임포트
import 'package:provider/provider.dart';
import 'comment_input_bar.dart';
import '../../providers/user_provider.dart';

class CommentView extends StatefulWidget {
  final int memoId;

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
    _loadComments();
  }

  /// 🔹 댓글 불러오기
  Future<void> _loadComments() async {
    List<int>? commentIds = await CommentService.fetchCommentIds(widget.memoId);
    if (commentIds != null) {
      List<Map<String, dynamic>> fetchedComments =
          await CommentService.fetchCommentDetails(commentIds);
      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  /// 🔹 댓글이 추가되었을 때 새로고침
  void _onCommentAdded() {
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.user != null;
    return Column(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : comments.isEmpty
                ? Column(
                    children: [
                      const Center(child: Text("댓글이 없습니다.")),
                    ],
                  )
                : Column(
                    children: [
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 0),
                            leading: CircleAvatar(
                              backgroundImage:
                                  comment['profileImageUrl'] != null
                                      ? NetworkImage(comment['profileImageUrl'])
                                      : null,
                              child: comment['profileImageUrl'] == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                            title: Text(
                              comment['nickname'] ?? '익명',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                            height: 1,
                          );
                        },
                      ),
                    ],
                  ),
        if (isLoggedIn && !isLoading)
          CommentInputBar(
            memoId: widget.memoId,
            onCommentAdded: _onCommentAdded,
          ),
      ],
    );
  }
}
