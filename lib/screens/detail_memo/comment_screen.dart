import 'package:flutter/material.dart';
import '../../services/comment_service.dart';
import 'package:provider/provider.dart';
import 'comment_input_bar.dart';
import '../../providers/user_provider.dart';
import '../../services/like_service.dart';

class CommentView extends StatefulWidget {
  final int memoId;

  const CommentView({Key? key, required this.memoId}) : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;

  // 수정 중인 댓글 ID, 그리고 수정용 컨트롤러
  int? _editingCommentId;
  late TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _editController = TextEditingController();
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    List<int>? commentIds = await CommentService.fetchCommentIds(widget.memoId);
    if (!mounted) return;
    if (commentIds != null) {
      List<Map<String, dynamic>> fetchedComments =
          await CommentService.fetchCommentDetails(commentIds);
      if (!mounted) return;
      setState(() {
        comments = fetchedComments;
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _onCommentAdded() => _loadComments();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.user != null;
    final String? myNickname = userProvider.user?.nickname;

    return Column(
      children: [
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (comments.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text("댓글이 없습니다.")),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: comments.length,
            itemBuilder: (context, index) {
              final comment = comments[index];
              final id = comment['id'] as int;
              final bool isModified = comment['modify'] == true;
              final bool isMine = comment['nickname'] == myNickname;

              // “수정 중” UI
              if (_editingCommentId == id) {
                return ListTile(
                  title: TextField(
                    controller: _editController,
                    decoration: const InputDecoration(
                      hintText: "댓글을 수정하세요",
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          final newText = _editController.text.trim();
                          if (newText.isEmpty) return;
                          final ok = await CommentService.updateComment(
                            commentId: id,
                            comment: newText,
                          );
                          if (ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('댓글이 수정되었습니다.')),
                            );
                            setState(() => _editingCommentId = null);
                            _loadComments();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('댓글 수정에 실패했습니다.')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          setState(() => _editingCommentId = null);
                        },
                      ),
                    ],
                  ),
                );
              }

              // 일반 표시 UI
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
                title: Row(
                  children: [
                    Text(
                      comment['nickname'] ?? '익명',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    if (isLoggedIn)
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              // 수정 모드로 전환
                              _editController.text = comment['comment'] ?? '';
                              setState(() => _editingCommentId = id);
                              break;
                            case 'delete':
                              final ok = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('댓글 삭제'),
                                      content: const Text('정말 이 댓글을 삭제하시겠습니까?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('취소'),
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                        ),
                                        TextButton(
                                          child: const Text('삭제'),
                                          onPressed: () async {
                                            final success = await CommentService
                                                .deleteComment(id);
                                            Navigator.of(ctx).pop(success);
                                          },
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('댓글이 삭제되었습니다.')),
                                );
                                _loadComments();
                              }
                              break;
                            case 'report':
                              // TODO: 신고 로직
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('신고가 접수되었습니다.')),
                              );
                              break;
                            case 'block':
                              // TODO: 차단 로직
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('사용자가 차단되었습니다.')),
                              );
                              break;
                          }
                        },
                        itemBuilder: (_) {
                          if (isMine) {
                            return const [
                              PopupMenuItem(value: 'edit', child: Text('수정')),
                              PopupMenuItem(value: 'delete', child: Text('삭제')),
                            ];
                          } else {
                            return const [
                              PopupMenuItem(value: 'report', child: Text('신고')),
                              PopupMenuItem(value: 'block', child: Text('차단')),
                            ];
                          }
                        },
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comment['comment'] ?? ''),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          (comment['updatedAt']?.split(' ')[0] ?? '') +
                              (isModified ? ' (수정됨)' : ''),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: isLoggedIn
                              ? () async {
                                  final success =
                                      await LikeService.likeComment(id);
                                  if (success) _loadComments();
                                }
                              : null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: comment['myLike'] == true
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (comment['likeCnt'] ?? 0).toString(),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10,
              endIndent: 10,
              height: 1,
            ),
          ),
// 수정 후
        if (isLoggedIn && !isLoading && _editingCommentId == null)
          CommentInputBar(
            memoId: widget.memoId,
            onCommentAdded: _onCommentAdded,
          ),
      ],
    );
  }
}
