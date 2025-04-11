import 'package:flutter/material.dart';
import '../../services/marker_detail_service.dart';
import '../detail_memo/comment_screen.dart';
import '../../services/like_service.dart';

class MemoDetailScreen extends StatefulWidget {
  final int memoId;

  const MemoDetailScreen({Key? key, required this.memoId}) : super(key: key);

  @override
  _MemoDetailScreenState createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  Map<String, dynamic>? memoDetail;

  @override
  void initState() {
    super.initState();
    _fetchMemoDetail(widget.memoId);
  }

  Future<void> _fetchMemoDetail(int memoId) async {
    final data = await MarkerDetailService.fetchMemoDetail(memoId);
    setState(() {
      memoDetail = data;
    });
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("메모 상세"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: memoDetail == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목과 유저 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          memoDetail!['title'] ?? "제목 없음",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (memoDetail!['profileImage'] != null)
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(memoDetail!['profileImage']),
                              radius: 20,
                            )
                          else
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 20,
                              child: memoDetail!['nickname'] != null
                                  ? Text(
                                      memoDetail!['nickname'][0],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                            ),
                          const SizedBox(width: 10),
                          Text(
                            memoDetail!['nickname'] ?? '익명',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(),
                  Text(memoDetail!['content'] ?? '내용 없음'),
                  const SizedBox(height: 5),
                  if (memoDetail!['images'] != null &&
                      memoDetail!['images'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 150,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  memoDetail!['images'].map<Widget>((imageUrl) {
                                return GestureDetector(
                                  onTap: () => _showFullImage(imageUrl),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 5),
                  Text(
                    "좋아요: ${memoDetail!['likeCnt'] ?? 0}  싫어요: ${memoDetail!['hateCnt'] ?? 0}",
                  ),
                  const Divider(),
                  CommentView(
                    key: ValueKey(widget.memoId),
                    memoId: widget.memoId,
                  ),
                ],
              ),
            ),
    );
  }
}
