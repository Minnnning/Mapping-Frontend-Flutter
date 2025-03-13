import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/marker_service.dart';
import 'detail_memo/marker_detail.dart';
import 'resizable_search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622);
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    LatLng? position = await LocationService.getCurrentPosition();
    if (position != null) {
      setState(() => _currentLocation = position);
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: position, zoom: 16)),
      );
      _fetchMarkers();
    }
  }

  Future<void> _fetchMarkers() async {
    if (_controller == null) return;
    LatLngBounds visibleRegion = await _controller!.getVisibleRegion();
    LatLng center = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );

    Set<Marker> newMarkers = await MarkerService.fetchMarkers(center, (memo) {
      showMarkerDetail(context, memo); // ✅ 마커 클릭 시 상세보기 호출
    });

    setState(() => _markers = newMarkers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
              _fetchMarkers();
            },
            onCameraIdle: _fetchMarkers,
            initialCameraPosition:
                CameraPosition(target: _currentLocation, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),
          Positioned(
            top: 120,
            right: 5,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _fetchCurrentLocation,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
          const ResizableSearchBar(),
        ],
      ),
    );
  }
}
