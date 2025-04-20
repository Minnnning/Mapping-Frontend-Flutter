// lib/widgets/user_block_dialog.dart

import 'package:flutter/material.dart';
import '../services/user_block_service.dart';

/// 사용자 차단 다이얼로그.
/// 다이얼로그에서 최종적으로 성공 여부(true/false)를 반환합니다.
Future<bool> showUserBlockDialog(BuildContext context, int userId) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('사용자 차단'),
        content: const Text('정말 이 사용자를 차단하시겠습니까?'),
        actions: [
          TextButton(
            child: const Text('취소'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: const Text('차단'),
            onPressed: () async {
              final success = await UserBlockService.blockUser(userId);
              Navigator.of(context).pop(success);
            },
          ),
        ],
      );
    },
  );
  return result ?? false;
}
