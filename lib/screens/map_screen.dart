import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'resizable_search_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622); // 기본 위치

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // 현재 위치 가져오는 함수
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 꺼져 있으면 오류 출력
      print("위치 서비스가 비활성화되었습니다.");
      return;
    }

    // 위치 권한 요청
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

    // 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // 위치 업데이트
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    // 카메라 위치 이동
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLocation, zoom: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
              _determinePosition(); // 지도가 로드되면 현재 위치를 가져옴
            },
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          const ResizableSearchBar(),
          Positioned(
            top: 120,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _determinePosition(); // 버튼 클릭 시 현재 위치로 이동
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
