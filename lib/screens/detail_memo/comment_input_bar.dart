import 'package:flutter/material.dart';
import '../../services/comment_service.dart';
import '../../theme/colors.dart';
import '../../providers/comment_provider.dart';
import 'package:provider/provider.dart';

class CommentInputBar extends StatefulWidget {
  final int memoId;

  const CommentInputBar({Key? key, required this.memoId}) : super(key: key);

  @override
  _CommentInputBarState createState() => _CommentInputBarState();
}

class _CommentInputBarState extends State<CommentInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = context.watch<CommentProvider>();
    // 편집 모드 시작 시 provider.editingText 로 컨트롤러 초기화
    if (prov.editingCommentId != null) {
      _controller.text = prov.editingText;
    }
  }

  Future<void> _submit() async {
    final prov = context.read<CommentProvider>();
    final editingId = prov.editingCommentId;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);

    bool ok;
    if (editingId != null) {
      ok = await CommentService.updateComment(
          commentId: editingId, comment: text);
    } else {
      ok = await CommentService.createComment(
          comment: text, memoId: widget.memoId);
    }

    setState(() => _isLoading = false);

    if (ok) {
      _controller.clear();
      if (editingId != null) {
        prov.stopEditing();
      }
      prov.requestRefresh();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(editingId != null ? "댓글이 수정되었습니다!" : "댓글이 생성되었습니다!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommentProvider>();
    final isEditing = prov.editingCommentId != null;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(isEditing), // 모드 바뀔 때 애니메이션
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: isEditing ? "댓글을 수정하세요..." : "댓글을 입력하세요...",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (_isLoading)
              SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
            else if (isEditing) ...[
              TextButton(
                onPressed: _submit,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // TextButton 자체 패딩 제거
                  minimumSize: Size.zero, // 최소 크기 제거
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: mainColor,
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: const Text(
                    "수정",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              TextButton(
                onPressed: () {
                  context.read<CommentProvider>().stopEditing();
                  _controller.clear();
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // TextButton 자체 패딩 제거
                  minimumSize: Size.zero, // 최소 크기 제거
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: boxGray,
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: const Text(
                    "취소",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ] else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                  backgroundColor: mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                ),
                child: const Text(
                  "전송",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
