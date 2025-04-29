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

  Future<void> _submitComment() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    bool success = await CommentService.createComment(
      comment: _controller.text.trim(),
      memoId: widget.memoId,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      _controller.clear();
      // 댓글 새로고침 요청
      context.read<CommentProvider>().requestRefresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("댓글이 생성되었습니다!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("댓글 생성에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48, // 전송 버튼과 동일한 높이 설정
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "댓글을 입력하세요...",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8), // 텍스트필드와 버튼 사이 간격
          _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton(
                  onPressed: _submitComment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
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
    );
  }
}
