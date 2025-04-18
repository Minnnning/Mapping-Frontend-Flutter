import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapping_flutter/screens/detail_memo/marker_detail.dart';
import '../services/location_service.dart';
import '../services/marker_service.dart';
import '../services/auth_service.dart';
import 'resizable_search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/marker_provider.dart';
import '../providers/user_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622);
  LatLng? _lastFetchedLocation;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkAndFetchUser();
    await _fetchCurrentLocation();
  }

  Future<void> _checkAndFetchUser() async {
    String? accessToken = await _secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      debugPrint('액세스 토큰 존재, 유저 정보 가져오기 실행');
      await AuthService()
          .fetchUser(Provider.of<UserProvider>(context, listen: false));
    } else {
      debugPrint('액세스 토큰 없음, 유저 정보 가져오기 건너뜀');
    }
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

    final result = await MarkerService.fetchMarkers(center, (memo) {
      debugPrint('마커 클릭');
      Provider.of<MarkerProvider>(context, listen: false)
          .selectMarker(memo['id']);
    });

    final Set<Marker> newMarkers = result['markers'];
    final Map<String, bool> secretMap = result['secretMap'];

    _lastFetchedLocation = center;
    Provider.of<MarkerProvider>(context, listen: false)
        .setMarkers(newMarkers, secretMap);
  }

  void _forceFetchMarkers() {
    _lastFetchedLocation = null; // 2km 거리 제한 무시
    _fetchMarkers(); // 마커 다시 불러오기
    debugPrint("사용자 재검색");
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
          Positioned(
            top: 170,
            right: 5,
            child: FloatingActionButton(
              heroTag: 'refreshMarkersButton',
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _forceFetchMarkers,
              child: const Icon(Icons.refresh, color: Colors.black),
            ),
          ),
          if (_controller != null)
            ResizableSearchBar(mapController: _controller!),
          ResizableDetailBar()
        ],
      ),
    );
  }
}
