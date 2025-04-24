import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/marker_detail_service.dart';
import '../detail_memo/comment_screen.dart';
import '../../services/like_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../detail_memo/memo_delete_dialog.dart';
import '../detail_memo/report_dialog.dart';
import '../edit_memo_screen.dart';
import '../user_block_dialog.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.user != null;
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
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            memoDetail!['title'] ?? "제목 없음",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Text(
                                memoDetail!['category'] ?? "카테고리",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (memoDetail!['date'] ?? "날짜")
                                    .split(':')
                                    .first, // ':' 기준으로 자르고 첫 번째 요소만 사용
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 4),
                              if (memoDetail!['certified'] == true)
                                const Icon(Icons.verified,
                                    color: Colors.grey, size: 11),
                            ],
                          )
                        ],
                      )),
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
                  //지도출력
                  if (memoDetail!['lat'] != null && memoDetail!['lng'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  memoDetail!['lat'],
                                  memoDetail!['lng'],
                                ),
                                zoom: 18,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('memo_location'),
                                  position: LatLng(
                                    memoDetail!['lat'],
                                    memoDetail!['lng'],
                                  ),
                                )
                              },
                              zoomControlsEnabled: false,
                              liteModeEnabled: true, // 성능 이슈 있으면 lite 모드 사용
                              myLocationButtonEnabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),

                  // 좋아요 & 싫어요 표시
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact, // 여백 축소
                        //padding: EdgeInsets.zero, // 내부 여백
                        onPressed: isLoggedIn
                            ? () async {
                                final success =
                                    await LikeService.likeMemo(widget.memoId);
                                if (success) {
                                  _fetchMemoDetail(widget.memoId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('좋아요!')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('좋아요 실패')),
                                  );
                                }
                              }
                            : null, // 로그인 안 되어 있으면 비활성화
                        icon: Icon(
                          Icons.thumb_up,
                          color: isLoggedIn ? Colors.yellow : Colors.grey,
                        ),
                      ),
                      Text('${memoDetail!['likeCnt'] ?? 0}'),
                      const SizedBox(width: 8),
                      IconButton(
                        visualDensity: VisualDensity.compact, // 여백 축소
                        //padding: EdgeInsets.zero, // 내부 여백
                        onPressed: isLoggedIn
                            ? () async {
                                final success =
                                    await LikeService.hateMemo(widget.memoId);
                                if (success) {
                                  _fetchMemoDetail(widget.memoId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('싫어요')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('싫어요 실패')),
                                  );
                                }
                              }
                            : null,
                        icon: Icon(
                          Icons.thumb_down,
                          color: isLoggedIn ? Colors.yellow : Colors.grey,
                        ),
                      ),
                      Text('${memoDetail!['hateCnt'] ?? 0}'),
                      const Spacer(),
                      if (isLoggedIn)
                        PopupMenuButton(
                          icon: const Icon(Icons.more_horiz),
                          color: Colors.white,
                          itemBuilder: (BuildContext context) {
                            if (memoDetail!['myMemo'] == true) {
                              // myMemo가 true일 때 수정/삭제 메뉴 표시
                              return [
                                PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('수정'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('삭제'),
                                ),
                              ];
                            } else {
                              // myMemo가 false일 때 신고/차단 메뉴 표시
                              return [
                                PopupMenuItem<String>(
                                  value: 'report',
                                  child: Text('신고'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'block',
                                  child: Text('차단'),
                                ),
                              ];
                            }
                          },
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              debugPrint("수정 선택됨");

                              final bool? updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditMemoScreen(
                                    memoId: memoDetail!['id'],
                                    initialTitle: memoDetail!['title'],
                                    initialContent: memoDetail!['content'],
                                    initialCategory: memoDetail!['category'],
                                    initialImageUrls: (memoDetail!['images']
                                                as List<dynamic>?)
                                            ?.map((e) => e.toString())
                                            .toList() ??
                                        <String>[],
                                  ),
                                ),
                              );

                              if (updated == true) {
                                _fetchMemoDetail(widget.memoId);
                              }
                            } else if (value == 'delete') {
                              debugPrint("삭제 선택됨");
                              final deleted = await showMemoDeleteDialog(
                                  context, memoDetail!['id']);

                              if (deleted) {
                                Navigator.of(context).pop(true);
                              }
                            } else if (value == 'report') {
                              debugPrint("신고 선택됨");
                              final success = await showReportDialog(
                                context,
                                memoDetail!['id'],
                              );
                              // 다이얼로그가 닫힌 후, 이 context는 여전히 유효하므로 안전합니다.
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success ? '신고가 접수되었습니다.' : '신고에 실패했습니다.',
                                  ),
                                ),
                              );
                            } else if (value == 'block') {
                              debugPrint("차단 선택됨");
                              final update = await showUserBlockDialog(
                                  context, memoDetail!['authorId']);

                              if (update) {
                                Navigator.of(context).pop(true);
                              }
                            }
                          },
                        ),
                    ],
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
