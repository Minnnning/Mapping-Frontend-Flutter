import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/user_provider.dart';
import '../../services/marker_detail_service.dart';
import '../../services/like_service.dart';
import '../detail_memo/memo_delete_dialog.dart';
import '../detail_memo/report_dialog.dart';
import '../detail_memo/comment_screen.dart';
import '../detail_memo/comment_input_bar.dart';
import '../edit_memo_screen.dart';
import '../user_block_dialog.dart';
import '../../theme/colors.dart';

class MemoDetailScreen extends StatefulWidget {
  final int memoId;
  const MemoDetailScreen({Key? key, required this.memoId}) : super(key: key);

  @override
  _MemoDetailScreenState createState() => _MemoDetailScreenState();
}

class _MemoDetailScreenState extends State<MemoDetailScreen> {
  Map<String, dynamic>? memo;

  @override
  void initState() {
    super.initState();
    _loadMemo();
  }

  Future<void> _loadMemo() async {
    final data = await MarkerDetailService.fetchMemoDetail(widget.memoId);
    setState(() => memo = data);
  }

  Future<void> launchGoogleMaps(double lat, double lng, String destName) async {
    // 1) Android Google Maps 앱용 인텐트 URI
    final googleMapsUri = Uri.parse('google.navigation:q=$lat,$lng&mode=w');
    // 2) fallback) 웹 브라우저용 구글맵 방향 URL
    final webUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');

    // 앱이 해당 인텐트를 처리할 수 있는지 확인
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map for $lat,$lng';
    }
  }

  Future<void> launchKakaoMap(double lat, double lng, String destName) async {
    // 이름에 공백, 한글 등이 들어갈 수 있으니 인코딩
    final encodedName = Uri.encodeComponent(destName);

    final appUri = Uri.parse('kakaomap://look?p=$lat,$lng');
    final webUri =
        Uri.parse('https://map.kakao.com/link/map/$encodedName,$lat,$lng');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch map for $lat,$lng';
    }
  }

  void openMapNavigation(
      BuildContext context, double lat, double lng, String destName) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext ctx) {
        return SafeArea(
          bottom: true, // 제스처 영역 고려
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('구글 지도'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchGoogleMaps(lat, lng, destName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('카카오 지도'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await launchKakaoMap(lat, lng, destName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<UserProvider>().user != null;

    return Scaffold(
      appBar: AppBar(title: const Text("메모 상세"), backgroundColor: Colors.white),
      backgroundColor: Colors.white,
      body: memo == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const Divider(),
                        Text(memo!['content'] ?? ''),
                        const SizedBox(height: 8),
                        if (_hasImages) _buildImageList(),
                        if (_hasLocation) ...[
                          const SizedBox(height: 16),
                          _buildMap(),
                        ],
                        const SizedBox(height: 8),
                        _buildReactions(isLoggedIn),
                        const Divider(),
                        CommentView(
                          key: ValueKey(widget.memoId),
                          memoId: widget.memoId,
                        ),
                      ],
                    ),
                  ),
                ),

                // 화면 맨 아래에 고정된 입력창
                if (isLoggedIn)
                  Container(
                    color: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SafeArea(
                      top: false,
                      bottom: true,
                      child: CommentInputBar(memoId: widget.memoId),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    final m = memo!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                m['title'] ?? '',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(m['category'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  const SizedBox(width: 4),
                  Text((m['date'] ?? '').split(':').first,
                      style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  if (m['certified'] == true)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.verified, size: 11, color: Colors.grey),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundImage: m['profileImage'] != null
              ? NetworkImage(m['profileImage'])
              : null,
          child: m['profileImage'] == null ? const Icon(Icons.person) : null,
        ),
        const SizedBox(width: 8),
        Text(m['nickname'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  bool get _hasImages =>
      memo!['images'] != null && (memo!['images'] as List).isNotEmpty;
  bool get _hasLocation => memo!['lat'] != null && memo!['lng'] != null;

  Widget _buildImageList() {
    final imgs = (memo!['images'] as List).cast<String>();
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: imgs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
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
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.network(url, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(memo!['lat'], memo!['lng']),
            zoom: 18,
          ),
          markers: {
            Marker(
                markerId: const MarkerId('loc'),
                position: LatLng(memo!['lat'], memo!['lng']))
          },
          zoomControlsEnabled: true,
          //liteModeEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }

  Widget _buildReactions(bool isLoggedIn) {
    final id = widget.memoId;
    final m = memo!;
    return Row(
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: isLoggedIn ? () => _toggleLike(id) : null,
          icon: Icon(Icons.thumb_up,
              color: isLoggedIn ? Colors.yellow : Colors.grey),
        ),
        Text('${m['likeCnt'] ?? 0}'),
        const SizedBox(width: 16),
        IconButton(
          visualDensity: VisualDensity.compact,
          onPressed: isLoggedIn ? () => _toggleHate(id) : null,
          icon: Icon(Icons.thumb_down,
              color: isLoggedIn ? Colors.yellow : Colors.grey),
        ),
        Text('${m['hateCnt'] ?? 0}'),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.navigation_rounded, color: mainColor),
          onPressed: () {
            openMapNavigation(context, m['lat'], m['lng'], m['title']);
          },
        ),
        if (isLoggedIn) ...[
          const SizedBox(
            width: 1,
          ),
          _buildPopupMenu()
        ],
      ],
    );
  }

  Future<void> _toggleLike(int id) async {
    if (await LikeService.likeMemo(id)) {
      await _loadMemo();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('좋아요!')));
    }
  }

  Future<void> _toggleHate(int id) async {
    if (await LikeService.hateMemo(id)) {
      await _loadMemo();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('싫어요')));
    }
  }

  Widget _buildPopupMenu() {
    final m = memo!;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_horiz),
      onSelected: (v) => _onMenuSelected(v),
      itemBuilder: (_) {
        if (m['myMemo'] == true) {
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
    );
  }

  Future<void> _onMenuSelected(String v) async {
    final id = widget.memoId;
    if (v == 'edit') {
      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => EditMemoScreen(
                  memoId: id,
                  initialTitle: memo!['title'],
                  initialContent: memo!['content'],
                  initialCategory: memo!['category'],
                  initialImageUrls:
                      (memo!['images'] as List<dynamic>?)?.cast<String>() ?? [],
                )),
      );
      if (updated == true) _loadMemo();
    }
    if (v == 'delete') {
      if (await showMemoDeleteDialog(context, id))
        Navigator.of(context).pop(true);
    }
    if (v == 'report') {
      final ok = await reportDialogAndRefresh(id);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ok ? '신고 되었습니다.' : '이미 신고 되었습니다.')));
    }
    if (v == 'block') {
      if (await showUserBlockDialog(context, memo!['authorId']))
        Navigator.of(context).pop(true);
    }
  }

  Future<bool> reportDialogAndRefresh(int id) async {
    return await showReportDialog(context, id);
  }
}
