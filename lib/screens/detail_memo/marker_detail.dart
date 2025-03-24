import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marker_provider.dart';
import '../../services/marker_detail_service.dart';
import 'comment_screen.dart';

class ResizableDetailBar extends StatefulWidget {
  const ResizableDetailBar({Key? key}) : super(key: key);

  @override
  _ResizableDetailBarState createState() => _ResizableDetailBarState();
}

class _ResizableDetailBarState extends State<ResizableDetailBar> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  Map<String, dynamic>? memoDetail;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.size == 0.0) {
        Provider.of<MarkerProvider>(context, listen: false).selectMarker(0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final markerProvider = Provider.of<MarkerProvider>(context, listen: false);

    markerProvider.addListener(() {
      if (markerProvider.selectedMarkerId != 0) {
        _controller.animateTo(
          0.4,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _fetchMemoDetail(markerProvider.selectedMarkerId);
      }
    });
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
              boundaryMargin: EdgeInsets.all(20),
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
    return Consumer<MarkerProvider>(
      builder: (context, markerProvider, child) {
        return DraggableScrollableSheet(
          controller: _controller,
          initialChildSize: 0,
          minChildSize: 0,
          maxChildSize: 0.9,
          snap: true,
          snapSizes: [0, 0.4, 0.90],
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (memoDetail == null)
                          const Center(child: CircularProgressIndicator())
                        else ...[
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
                                      backgroundImage: NetworkImage(
                                          memoDetail!['profileImage']),
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
                                      children: memoDetail!['images']
                                          .map<Widget>((imageUrl) {
                                        return GestureDetector(
                                          onTap: () => _showFullImage(imageUrl),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(right: 8),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                          // 좋아요 & 싫어요 표시
                          Text(
                              "좋아요: ${memoDetail!['likeCnt'] ?? 0}  싫어요: ${memoDetail!['hateCnt'] ?? 0}"),
                          const Divider(),
                          CommentView(
                              key: ValueKey(markerProvider.selectedMarkerId),
                              memoId: markerProvider.selectedMarkerId)
                        ],
                      ],
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
}
