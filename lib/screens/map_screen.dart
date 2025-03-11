import 'dart:convert';
import 'dart:convert' as convert; // 추가
import 'dart:math';
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
  LatLng _currentLocation = const LatLng(36.629014, 127.456622);
  LatLng? _lastFetchedLocation; // ✅ 이전 검색 위치 저장
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// ✅ 현재 위치 가져오기 (초기 로드 시)
  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("위치 서비스가 비활성화되었습니다.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
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

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: _currentLocation, zoom: 16)),
    );

    _fetchMarkersFromCameraCenter();
  }

  /// ✅ 두 좌표 간 거리 계산 (Haversine 공식 사용)
  double _calculateDistance(LatLng pos1, LatLng pos2) {
    const double R = 6371; // 지구 반경 (km)
    double dLat = _degToRad(pos2.latitude - pos1.latitude);
    double dLng = _degToRad(pos2.longitude - pos1.longitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(pos1.latitude)) * cos(_degToRad(pos2.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _degToRad(double deg) {
    return deg * pi / 180;
  }

  /// ✅ 카메라 중심 기준으로 마커 불러오기 (2km 이상 이동 시 요청)
  Future<void> _fetchMarkersFromCameraCenter() async {
    if (_controller == null) return;

    LatLngBounds visibleRegion = await _controller!.getVisibleRegion();
    LatLng center = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );

    // ✅ 이전 검색 위치와 비교하여 2km 이내면 요청 안 함
    if (_lastFetchedLocation != null &&
        _calculateDistance(_lastFetchedLocation!, center) < 2.0) {
      print("2km 이내 이동 - API 요청 생략");
      return;
    }

    _lastFetchedLocation = center; // ✅ 검색 위치 업데이트

    final String url = 'https://api.mapping.kro.kr/api/v2/memo/total?lat=${center.latitude}&lng=${center.longitude}&km=5';

    try {
      final response = await http.get(Uri.parse(url), headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        // ✅ UTF-8 디코딩
        final String decodedBody = convert.utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);

        if (data['success'] == true) {
          List<dynamic> memoData = data['data'];

          Set<Marker> newMarkers = memoData.map((memo) {
            return Marker(
              markerId: MarkerId(memo['id'].toString()),
              position: LatLng(memo['lat'], memo['lng']),
              infoWindow: InfoWindow(title: memo['title'], snippet: memo['category']),
              icon: _getCategoryIcon(memo['category']),
              onTap: () {
                _showMarkerDetail(memo);
              },
            );
          }).toSet();

          setState(() {
            _markers = newMarkers;
          });
          print("📌 새 마커 불러옴 (중심: ${center.latitude}, ${center.longitude})");
        }
      } else {
        print("API 요청 실패: ${response.statusCode}");
      }
    } catch (e) {
      print("API 요청 오류: $e");
    }
  }

  /// ✅ 카테고리별 아이콘 반환
  BitmapDescriptor _getCategoryIcon(String category) {
    switch (category) {
      case '공용 화장실':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case '쓰레기통':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta);
      case '흡연장':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case '주차장':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }

  /// ✅ 마커 클릭 시 상세 정보 표시
  void _showMarkerDetail(Map<String, dynamic> memo) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                memo['title'],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text("카테고리: ${memo['category']}"),
              const SizedBox(height: 8),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// ✅ 지도 위젯
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
              _fetchMarkersFromCameraCenter(); // 초기 마커 불러오기
            },
            onCameraIdle: () {
              _fetchMarkersFromCameraCenter(); // 지도 이동 후 마커 갱신 (1km 이상일 때만)
            },
            initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
          ),

          /// ✅ 현재 위치 버튼
          Positioned(
            top: 120,
            right: 5,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              mini: true,
              onPressed: _determinePosition,
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          /// ✅ 검색 바 (별도 위젯)
          const ResizableSearchBar(),
        ],
      ),
    );
  }
}
