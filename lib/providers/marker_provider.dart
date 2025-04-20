import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/custom_marker.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  List<CustomMarker> _allMarkers = [];
  String _selectedCategory = "전체";
  int _selectedMarkerId = 0;

  bool _refreshRequested = false;
  bool get refreshRequested => _refreshRequested;

  Set<Marker> get markers => _markers;
  String get selectedCategory => _selectedCategory;
  int get selectedMarkerId => _selectedMarkerId;

  void setMarkers(Set<Marker> markers, Map<String, bool> secretMap) {
    _allMarkers = markers.map((marker) {
      final id = marker.markerId.value;
      return CustomMarker(marker: marker, secret: secretMap[id] ?? false);
    }).toList();
    _updateMarkers();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _updateMarkers();
    notifyListeners();
  }

  void _updateMarkers() {
    if (_selectedCategory == "전체") {
      _markers = _allMarkers.map((e) => e.marker).toSet();
    } else if (_selectedCategory == "개인") {
      _markers = _allMarkers
          .where((e) => e.secret == true)
          .map((e) => e.marker)
          .toSet();
    } else {
      _markers = _allMarkers
          .where((e) => e.marker.infoWindow.snippet == _selectedCategory)
          .map((e) => e.marker)
          .toSet();
    }
    notifyListeners();
  }

  void selectMarker(int markerId) {
    _selectedMarkerId = markerId;
    notifyListeners();
  }

  /// 🔄 외부에서 강제로 새로고침 요청
  void requestRefresh() {
    _refreshRequested = true;
    notifyListeners();
  }

  /// ✅ 새로고침이 끝났다고 처리
  void completeRefresh() {
    _refreshRequested = false;
  }
}
