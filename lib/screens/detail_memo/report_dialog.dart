import 'package:flutter/material.dart';
import '../../services/memo_report_service.dart';

const _reportReasons = {
  'SPAM': '스팸홍보/도배글입니다.',
  'OBSCENE': '음란물입니다.',
  'ILLEGAL_INFORMATION': '불법정보를 포함하고 있습니다.',
  'HARMFUL_TO_MINORS': '청소년에게 유해한 내용입니다.',
  'OFFENSIVE_EXPRESSION': '욕설/생명경시/혐오/차별적 표현입니다.',
  'PRIVACY_EXPOSURE': '개인정보 노출 게시물입니다.',
  'UNPLEASANT_EXPRESSION': '불쾌한 표현이 있습니다.',
  'OTHER': '기타',
};

/// 다이얼로그에서는 단순히 사용자가 '신고' 버튼을 눌렀는지,
/// 그리고 실제 API 호출이 성공했는지만 반환합니다.
Future<bool> showReportDialog(BuildContext context, int memoId) async {
  String? _selectedReason = _reportReasons.keys.first;

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('신고'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('사유를 선택하세요.'),
              const SizedBox(height: 12),
              ..._reportReasons.entries.map((e) {
                return RadioListTile<String>(
                  title: Text(e.value),
                  value: e.key,
                  groupValue: _selectedReason,
                  onChanged: (v) => setState(() => _selectedReason = v),
                );
              }).toList(),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('신고'),
              onPressed: () async {
                // API 호출
                final success = await MemoReportService.reportMemo(
                  memoId: memoId,
                  reportReason: _selectedReason!,
                );
                // 결과만 팝과 동시에 반환
                Navigator.of(context).pop(success);
              },
            ),
          ],
        );
      },
    ),
  );

  return result ?? false;
}
