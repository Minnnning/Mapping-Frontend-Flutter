// memo_delete_dialog.dart

import 'package:flutter/material.dart';
import '../../services/memo_delete_service.dart';

Future<bool> showMemoDeleteDialog(BuildContext context, int memoId) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('메모 삭제'),
        content: Text('정말 이 메모를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            child: Text('취소'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('삭제'),
            onPressed: () async {
              final success = await MemoDeleteService.deleteMemo(memoId);
              Navigator.of(context).pop(success);
            },
          ),
        ],
      );
    },
  );

  return result ?? false;
}
