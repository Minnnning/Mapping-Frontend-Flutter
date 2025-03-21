import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marker_provider.dart';
import '../../services/marker_detail_service.dart';

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

    // DraggableScrollableController 크기 변경 감지
    _controller.addListener(() {
      if (_controller.size == 0.0) {
        // 크기가 0이면 selectedMarkerId 초기화
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
                        Text(
                          markerProvider.selectedMarkerId != 0
                              ? "메모 ID: ${markerProvider.selectedMarkerId}"
                              : "선택된 메모 없음",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        memoDetail == null
                            ? const Center(
                                child: CircularProgressIndicator()) // 로딩 중
                            : Text(
                                "내용: ${memoDetail!['content']}",
                                style: const TextStyle(fontSize: 14),
                              ),
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
