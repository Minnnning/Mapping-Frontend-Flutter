import 'package:flutter/material.dart';

class CommentProvider with ChangeNotifier {
  bool _refreshRequested = false;
  bool get refreshRequested => _refreshRequested;
  bool _isEditing = false;
  bool get isEditing => _isEditing;

  /// 외부에서 호출: 댓글 새로고침이 필요함을 알린다
  void requestRefresh() {
    _refreshRequested = true;
    notifyListeners();
  }

  /// CommentView가 새로고침을 완료했음을 알린다
  void completeRefresh() {
    _refreshRequested = false;
  }

  /// 댓글 편집 모드 시작
  void startEditing() {
    if (_isEditing) return;
    _isEditing = true;
    notifyListeners();
  }

  /// 댓글 편집 모드 종료
  void stopEditing() {
    if (!_isEditing) return;
    _isEditing = false;
    notifyListeners();
  }
}
