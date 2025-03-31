import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MemoInputScreen1 extends StatefulWidget {
  const MemoInputScreen1({Key? key}) : super(key: key);
  
  @override
  _MemoInputScreen1State createState() => _MemoInputScreen1State();
}

class _MemoInputScreen1State extends State<MemoInputScreen1> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622);
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // 현재 위치를 가져오는 함수 (Geolocator 사용)
  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('위치 서비스 비활성화');
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('위치 권한 거부됨');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      debugPrint('위치 권한 영구 거부됨');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16),
      ),
    );
  }

  // 지도에서 길게 누르면 호출되어 마커를 추가하고 좌표를 표시하는 함수
  void _onMapLongPress(LatLng position) {
    setState(() {
      _markers.clear(); // 기존 마커 제거 (필요시 제거하지 않고 추가 가능)
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: InfoWindow(
            title: "Selected Location",
            snippet: "Lat: ${position.latitude}, Lng: ${position.longitude}",
          ),
        ),
      );
    });
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selected Location"),
        content: Text("Latitude: ${position.latitude}\nLongitude: ${position.longitude}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("메모 추가하기")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 16),
        onMapCreated: (controller) {
          _mapController = controller;
          _fetchCurrentLocation(); // 지도 생성 후 최신 위치 반영
        },
        markers: _markers,
        myLocationEnabled: true,
        onLongPress: _onMapLongPress,
      ),
    );
  }
}
