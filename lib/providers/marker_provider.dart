import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Marker> _allMarkers = {}; // 원본 데이터 유지
  String _selectedCategory = "전체";

  Set<Marker> get markers => _markers;
  String get selectedCategory => _selectedCategory;

  void setMarkers(Set<Marker> markers) {
    _allMarkers = markers; // 원본 데이터 유지
    _updateMarkers();
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return; // 이미 선택된 카테고리는 업데이트 안 함
    _selectedCategory = category;
    _updateMarkers();
    notifyListeners();
  }

  void _updateMarkers() {
    if (_selectedCategory == "전체") {
      _markers = Set.from(_allMarkers);
    } else {
      _markers = _allMarkers.where((marker) {
        return marker.infoWindow.snippet == _selectedCategory;
      }).toSet();
    }
    notifyListeners();
  }
}
