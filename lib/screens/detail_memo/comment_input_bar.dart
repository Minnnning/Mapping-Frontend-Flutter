import 'package:flutter/material.dart';
import '../../services/comment_service.dart';

class CommentInputBar extends StatefulWidget {
  final int memoId;
  final VoidCallback onCommentAdded;

  const CommentInputBar(
      {Key? key, required this.memoId, required this.onCommentAdded})
      : super(key: key);

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
      widget.onCommentAdded();
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
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "댓글을 입력하세요...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ),
          _isLoading
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: _submitComment,
                ),
        ],
      ),
    );
  }
}
