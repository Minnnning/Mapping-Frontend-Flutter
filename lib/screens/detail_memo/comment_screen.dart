import 'package:flutter/material.dart';
import '../../services/comment_service.dart';
import 'package:provider/provider.dart';
import 'report_dialog.dart';
import '../user_block_dialog.dart';
import '../../providers/user_provider.dart';
import '../../services/like_service.dart';
import '../../theme/colors.dart';
import '../../providers/marker_provider.dart';
import '../../providers/comment_provider.dart';

class CommentView extends StatefulWidget {
  final int memoId;

  const CommentView({Key? key, required this.memoId}) : super(key: key);

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  late CommentProvider _commentProv;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // context 가 안전한 시점(didChangeDependencies) 에 Provider 를 읽어서 저장
    _commentProv = Provider.of<CommentProvider>(context, listen: false);
    // 그리고 리스너 등록
    _commentProv.removeListener(_onCommentRefreshRequested);
    _commentProv.addListener(_onCommentRefreshRequested);
  }

  void _onCommentRefreshRequested() {
    if (!mounted) return;
    final commentProv = context.read<CommentProvider>();
    if (commentProv.refreshRequested) {
      _loadComments().then((_) {
        if (!mounted) return;
        commentProv.completeRefresh();
      });
    }
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

              // Provider 편집 중인 ID와 같으면 “수정 중…” UI
              final editingId =
                  context.watch<CommentProvider>().editingCommentId;
              if (editingId == id) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    children: [
                      Text("수정 중 ...",
                          style: TextStyle(fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              }

              // 일반 표시 UI
              return ListTile(
                dense: true,
                horizontalTitleGap: 10,
                minVerticalPadding: 1,
                //tileColor: Colors.yellow.withOpacity(0.2), // ListTile 영역
                contentPadding: EdgeInsets.zero, // ✅ 기본 좌우 패딩 제거
                leading: Container(
                  //color: Colors.blue.withOpacity(0.3), // Avatar 영역 확인
                  child: CircleAvatar(
                    backgroundImage: comment['profileImageUrl'] != null
                        ? NetworkImage(comment['profileImageUrl'])
                        : null,
                    child: comment['profileImageUrl'] == null
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                ),
                title: Container(
                  //color: Colors.green.withOpacity(0.3), // title 영역
                  child: Row(
                    children: [
                      Text(
                        comment['nickname'] ?? '익명',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ), // 줄 간격 최소화),
                      ),
                      const Spacer(),
                      if (isLoggedIn)
                        PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'edit':
                                // Provider 에 편집 시작 알림 (입력바로 처리)
                                Provider.of<CommentProvider>(context,
                                        listen: false)
                                    .startEditing(id, comment['comment'] ?? '');
                                break;
                              case 'delete':
                                final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('댓글 삭제'),
                                        content:
                                            const Text('정말 이 댓글을 삭제하시겠습니까?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('취소'),
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(false),
                                          ),
                                          TextButton(
                                            child: const Text('삭제'),
                                            onPressed: () async {
                                              final success =
                                                  await CommentService
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
                                    const SnackBar(
                                        content: Text('댓글이 삭제되었습니다.')),
                                  );
                                  _loadComments();
                                }
                                break;
                              case 'report':
                                debugPrint("신고 선택됨");
                                final success = await showReportDialog(
                                  context,
                                  comment['id'],
                                );
                                // 다이얼로그가 닫힌 후, 이 context는 여전히 유효하므로 안전합니다.
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success ? '신고가 접수되었습니다.' : '신고에 실패했습니다.',
                                    ),
                                  ),
                                );
                                break;
                              case 'block':
                                // TODO: 차단 로직
                                final update = await showUserBlockDialog(
                                    context, comment['writerId']);
                                if (update) {
                                  Provider.of<MarkerProvider>(context,
                                          listen: false)
                                      .selectMarker(0); // 마커 선택 해제

                                  Provider.of<MarkerProvider>(context,
                                          listen: false)
                                      .requestRefresh(); // 새로고침
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('사용자가 차단되었습니다.')),
                                  );
                                }
                                break;
                            }
                          },
                          itemBuilder: (_) {
                            if (isMine) {
                              return const [
                                PopupMenuItem(value: 'edit', child: Text('수정')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('삭제')),
                              ];
                            } else {
                              return const [
                                PopupMenuItem(
                                    value: 'report', child: Text('신고')),
                                PopupMenuItem(
                                    value: 'block', child: Text('차단')),
                              ];
                            }
                          },
                        ),
                    ],
                  ),
                ),
                subtitle: Container(
                  //color: Colors.purple.withOpacity(0.2), // subtitle 전체 배경
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment['comment'] ?? ''),
                      Row(
                        children: [
                          Text(
                            (comment['updatedAt']?.split(' ')[0] ?? '') +
                                (isModified ? ' (수정됨)' : ''),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
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
                ),
              );
            },
            separatorBuilder: (_, __) => const Divider(
              color: Colors.grey,
              thickness: 1,
              height: 1,
            ),
          ),
        const SizedBox(height: 30),
      ],
    );
  }
}
