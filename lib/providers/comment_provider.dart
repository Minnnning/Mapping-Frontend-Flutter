import 'package:flutter/material.dart';

class CommentProvider with ChangeNotifier {
  bool _refreshRequested = false;
  bool get refreshRequested => _refreshRequested;

  /// 외부에서 호출: 댓글 새로고침이 필요함을 알린다
  void requestRefresh() {
    _refreshRequested = true;
    notifyListeners();
  }

  /// CommentView가 새로고침을 완료했음을 알린다
  void completeRefresh() {
    _refreshRequested = false;
  }
}
