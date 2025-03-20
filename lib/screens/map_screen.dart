import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';
import '../services/marker_service.dart';
import 'detail_memo/marker_detail.dart';
import 'resizable_search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/marker_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622);
  LatLng? _lastFetchedLocation;

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

    if (_lastFetchedLocation != null) {
      double distanceInMeters = await Geolocator.distanceBetween(
        _lastFetchedLocation!.latitude,
        _lastFetchedLocation!.longitude,
        center.latitude,
        center.longitude,
      );

      if (distanceInMeters < 2000) {
        debugPrint('2km 이내, 새 요청 안 함');
        return;
      }
    }

    Set<Marker> newMarkers = await MarkerService.fetchMarkers(center, (memo) {
      debugPrint('마커 클릭');
      showMarkerDetail(context, memo);
    });

    _lastFetchedLocation = center;
    Provider.of<MarkerProvider>(context, listen: false).setMarkers(newMarkers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
              if (_controller != null) {
                _fetchMarkers();
              }
            },
            onCameraIdle: () {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _fetchMarkers();
              });
            },
            initialCameraPosition:
                CameraPosition(target: _currentLocation, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: Provider.of<MarkerProvider>(context).markers,
          ),
          Positioned(
            top: 120,
            right: 5,
            child: FloatingActionButton(
              heroTag: 'locationButton',
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
