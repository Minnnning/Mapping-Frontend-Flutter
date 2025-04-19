// memo_delete_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/marker_provider.dart';
import '../../services/memo_delete_service.dart';

Future<void> showMemoDeleteDialog(BuildContext context, int memoId) async {
  final markerProvider = Provider.of<MarkerProvider>(context, listen: false);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('메모 삭제'),
        content: const Text('정말 이 메모를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // 다이얼로그 닫기

              final success = await MemoDeleteService.deleteMemo(memoId);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메모가 삭제되었습니다.')),
                );

                markerProvider.selectMarker(0); // 선택된 마커 초기화
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('메모 삭제에 실패했습니다.')),
                );
              }
            },
            child: const Text('삭제'),
          ),
        ],
      );
    },
  );
}
