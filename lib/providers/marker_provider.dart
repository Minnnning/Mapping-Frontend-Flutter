import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerProvider with ChangeNotifier {
  Set<Marker> _markers = {};

  Set<Marker> get markers => _markers;

  void setMarkers(Set<Marker> markers) {
    _markers = markers;
    notifyListeners();
  }
}
