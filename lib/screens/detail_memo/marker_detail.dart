import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marker_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/comment_provider.dart';
import '../../services/marker_detail_service.dart';
import '../../services/like_service.dart';
import 'memo_delete_dialog.dart';
import 'report_dialog.dart';
import '../edit_memo_screen.dart';
import '../user_block_dialog.dart';
import 'comment_screen.dart';
import 'comment_input_bar.dart';

class ResizableDetailBar extends StatefulWidget {
  const ResizableDetailBar({Key? key}) : super(key: key);

  @override
  _ResizableDetailBarState createState() => _ResizableDetailBarState();
}

class _ResizableDetailBarState extends State<ResizableDetailBar> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  Map<String, dynamic>? memoDetail;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSheetScroll);
  }

  void _onSheetScroll() {
    if (_controller.isAttached) {
      final now = _controller.size >= 0.6;
      if (now != isExpanded) setState(() => isExpanded = now);
    }
    if (_controller.size == 0.0) {
      context.read<MarkerProvider>().selectMarker(0);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final prov = context.read<MarkerProvider>();
    prov
      ..removeListener(_onMarkerChanged)
      ..addListener(_onMarkerChanged);
  }

  void _onMarkerChanged() {
    final prov = context.read<MarkerProvider>();
    if (prov.selectedMarkerId != 0 && _controller.isAttached) {
      _controller.animateTo(0.4,
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      _fetchDetail(prov.selectedMarkerId);
    }
  }

  Future<void> _fetchDetail(int id) async {
    final data = await MarkerDetailService.fetchMemoDetail(id);
    setState(() => memoDetail = data);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSheetScroll);
    context.read<MarkerProvider>().removeListener(_onMarkerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserProvider>().user != null;
    final screenHeight = MediaQuery.of(context).size.height;
    final id = context.read<MarkerProvider>().selectedMarkerId;

    // 내용 높이 대략 계산
    final contentLength = memoDetail?['content']?.length ?? 0;
    final contentHeightEstimate = contentLength * 0.5;
    final hasImages = memoDetail?['images'] != null &&
        (memoDetail!['images'] as List).isNotEmpty;
    final imageHeight = hasImages ? 180.0 : 0.0;
    final totalContentHeightEstimate = contentHeightEstimate + imageHeight;
    final targetSheetHeight = screenHeight * 0.21;
    final dynamicSpace = (targetSheetHeight - totalContentHeightEstimate)
        .clamp(0, 200)
        .toDouble();

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0,
      minChildSize: 0,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0, 0.4, 0.9],
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Stack(
            children: [
              // 스크롤 가능한 메모 & 댓글 영역
              Padding(
                padding: EdgeInsets.only(
                  bottom: isExpanded && isLoggedIn ? 70 : 0, // 입력바 높이만큼 패딩
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                    boxShadow: [
                      BoxShadow(blurRadius: 10, color: Colors.black26)
                    ],
                  ),
                  child: ListView(
                    controller: scrollCtrl,
                    padding: EdgeInsets.zero,
                    children: [
                      // drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.grey[400],
                              borderRadius: BorderRadius.circular(2)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: memoDetail == null
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildHeader(isLoggedIn),
                                  const Divider(),
                                  Text(memoDetail!['content'] ?? ''),
                                  const SizedBox(height: 8),
                                  if (memoDetail!['images'] != null &&
                                      memoDetail!['images'].isNotEmpty)
                                    _buildImageRow(),
                                  const SizedBox(height: 8),
                                  SizedBox(height: dynamicSpace),
                                  _buildReactions(isLoggedIn),
                                  const Divider(),
                                  if (isExpanded)
                                    CommentView(
                                      key: ValueKey(id),
                                      memoId: id,
                                    ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              // 고정된 댓글 입력바
              if (isExpanded &&
                  isLoggedIn &&
                  !context.watch<CommentProvider>().isEditing)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CommentInputBar(
                      memoId: context.read<MarkerProvider>().selectedMarkerId,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isLoggedIn) {
    final d = memoDetail!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(d['title'] ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
            Row(children: [
              Text(d['category'] ?? '',
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(width: 4),
              Text((d['date'] ?? '').split(':').first,
                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
              if (d['certified'] == true)
                const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.verified, size: 11, color: Colors.grey)),
            ]),
          ],
        )),
        Row(children: [
          if (d['profileImage'] != null)
            CircleAvatar(
                backgroundImage: NetworkImage(d['profileImage']), radius: 20)
          else
            const CircleAvatar(radius: 20, child: Icon(Icons.person)),
          const SizedBox(width: 8),
          Text(d['nickname'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ],
    );
  }

  Widget _buildImageRow() {
    final imgs = (memoDetail!['images'] as List).cast<String>();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imgs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => GestureDetector(
          onTap: () => _showFullImage(imgs[i]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(imgs[i],
                width: 150, height: 150, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  void _showFullImage(String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildReactions(bool isLoggedIn) {
    final id = context.read<MarkerProvider>().selectedMarkerId;
    final d = memoDetail!;
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: isLoggedIn
              ? () async {
                  final ok = await LikeService.likeMemo(id);
                  if (ok) {
                    await _fetchDetail(id);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('좋아요!')));
                  }
                }
              : null,
          icon: Icon(Icons.thumb_up,
              color: isLoggedIn ? Colors.yellow : Colors.grey),
        ),
        Text('${d['likeCnt'] ?? 0}'),
        const SizedBox(width: 16),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: isLoggedIn
              ? () async {
                  final ok = await LikeService.hateMemo(id);
                  if (ok) {
                    await _fetchDetail(id);
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('싫어요')));
                  }
                }
              : null,
          icon: Icon(Icons.thumb_down,
              color: isLoggedIn ? Colors.yellow : Colors.grey),
        ),
        Text('${d['hateCnt'] ?? 0}'),
        if (isLoggedIn) ...[const Spacer(), _buildPopupMenu(d)],
      ],
    );
  }

  Widget _buildPopupMenu(Map<String, dynamic> d) {
    final id = context.read<MarkerProvider>().selectedMarkerId;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (v) async {
        if (v == 'edit') {
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (_) => EditMemoScreen(
                      memoId: id,
                      initialTitle: d['title'],
                      initialContent: d['content'],
                      initialCategory: d['category'],
                      initialImageUrls:
                          (d['images'] as List?)?.cast<String>() ?? [],
                    )),
          );
          if (updated == true) {
            context.read<MarkerProvider>().requestRefresh();
            await _fetchDetail(id);
          }
        }
        if (v == 'delete') {
          final ok = await showMemoDeleteDialog(context, id);
          if (ok) {
            context.read<MarkerProvider>().selectMarker(0);
            setState(() => memoDetail = null);
            _controller.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
            context.read<MarkerProvider>().requestRefresh();
          }
        }
        if (v == 'report') {
          final res = await showReportDialog(context, id);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(res ? '신고됨' : '실패')));
        }
        if (v == 'block') {
          final res = await showUserBlockDialog(context, d['authorId']);
          if (res) {
            context.read<MarkerProvider>().selectMarker(0);
            setState(() => memoDetail = null);
            _controller.animateTo(0.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
            context.read<MarkerProvider>().requestRefresh();
          }
        }
      },
      itemBuilder: (_) => d['myMemo'] == true
          ? [
              const PopupMenuItem(value: 'edit', child: Text('수정')),
              const PopupMenuItem(value: 'delete', child: Text('삭제'))
            ]
          : [
              const PopupMenuItem(value: 'report', child: Text('신고')),
              const PopupMenuItem(value: 'block', child: Text('차단'))
            ],
    );
  }
}
