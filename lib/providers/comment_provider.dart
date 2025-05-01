import 'package:flutter/material.dart';

class CommentProvider with ChangeNotifier {
  bool _refreshRequested = false;
  bool get refreshRequested => _refreshRequested;

  bool isEditing = false;
  int? _editingCommentId;
  String? _editingText;
  int? get editingCommentId => _editingCommentId;
  String get editingText => _editingText ?? '';

  /// 외부에서 호출: 댓글 새로고침이 필요함을 알린다
  void requestRefresh() {
    _refreshRequested = true;
    notifyListeners();
  }

  /// CommentView가 새로고침을 완료했음을 알린다
  void completeRefresh() {
    _refreshRequested = false;
  }

  /// 편집 모드 시작
  void startEditing(int id, String text) {
    _editingCommentId = id;
    _editingText = text;
    isEditing = true;
    notifyListeners();
  }

  /// 편집 모드 종료
  void stopEditing() {
    _editingCommentId = null;
    _editingText = null;
    isEditing = false;
    notifyListeners();
  }
}
