import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'resizable_search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622); // 기본 위치
  Set<Marker> _markers = {}; // 지도에 표시할 마커 리스트

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _listenToLocationChanges(); // 위치 변경 감지 시작
  }

  // 현재 위치 가져오는 함수
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("위치 서비스가 비활성화되었습니다.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("위치 권한이 거부되었습니다.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("위치 권한이 영구적으로 거부되었습니다.");
      return;
    }

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10m 이상 이동 시 업데이트
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    _updateLocation(position);
  }

  // 위치 변경을 감지하는 스트림
  void _listenToLocationChanges() {
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10m 이동마다 업데이트
      ),
    ).listen((Position position) {
      _updateLocation(position);
    });
  }

  // 위치 업데이트 및 API 호출
  Future<void> _updateLocation(Position position) async {
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // 카메라 이동
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16),
      ),
    );

    // API 요청 후 마커 업데이트
    await _fetchMarkers(position.latitude, position.longitude);
  }

  // API 요청 및 마커 추가
  Future<void> _fetchMarkers(double lat, double lng) async {
    final String url =
        'https://api.mapping.kro.kr/api/v2/memo/total?lat=$lat&lng=$lng&km=5';
    
    try {
      final response = await http.get(Uri.parse(url), headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['success'] == true) {
          List<dynamic> memoData = data['data'];

          // 새로운 마커 리스트 생성
          Set<Marker> newMarkers = memoData.map((memo) {
            return Marker(
              markerId: MarkerId(memo['id'].toString()),
              position: LatLng(memo['lat'], memo['lng']),
              infoWindow: InfoWindow(title: memo['title'], snippet: memo['category']),
              icon: _getCategoryIcon(memo['category']),
            );
          }).toSet();

          setState(() {
            _markers = newMarkers;
          });
        }
      } else {
        print("API 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("API 요청 오류: $e");
    }
  }

  // 카테고리별 아이콘을 반환하는 함수
  BitmapDescriptor _getCategoryIcon(String category) {
    switch (category) {
      case '공용 화장실':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); 
      case '쓰레기통':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); 
      case '흡연장':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case '주차장':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); 
      default:
        return BitmapDescriptor.defaultMarker; // 기본 아이콘
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
              _determinePosition();
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers, // ✅ 마커 추가
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
          const ResizableSearchBar(),
        ],
      ),
    );
  }
}
