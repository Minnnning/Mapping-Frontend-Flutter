import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'memo_input_screen_2.dart';
import '../../theme/colors.dart';


class MemoInputScreen1 extends StatefulWidget {
  const MemoInputScreen1({Key? key}) : super(key: key);

  @override
  _MemoInputScreen1State createState() => _MemoInputScreen1State();
}

class _MemoInputScreen1State extends State<MemoInputScreen1> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(36.629014, 127.456622);
  LatLng? _selectedLocation; // 선택된 마커의 위치 저장
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // 현재 위치를 가져오는 함수
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

  // 지도에서 길게 누르면 마커 추가 및 위치 저장
  void _onMapLongPress(LatLng position) {
    setState(() {
      _selectedLocation = position; // 선택된 위치 저장
      _markers.clear(); // 기존 마커 제거
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: const InfoWindow(title: "선택된 위치"),
        ),
      );
    });
  }

  // 다음 화면으로 이동
  void _goToNextScreen() {
    if (_selectedLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MemoInputScreen2(
            latitude: _selectedLocation!.latitude,
            longitude: _selectedLocation!.longitude,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("메모 추가하기"),
        backgroundColor: Colors.white, // ✅ 앱바 배경색을 흰색으로 설정
        //elevation: 1, // 앱바 아래 그림자 효과 추가
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _selectedLocation != null ? _goToNextScreen : null,
            color: _selectedLocation != null ? mainColor : Colors.grey, // ✅ 활성화되면 mainColor, 비활성화되면 회색
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _currentLocation, zoom: 16),
            onMapCreated: (controller) {
              _mapController = controller;
              _fetchCurrentLocation();
            },
            markers: _markers,
            myLocationEnabled: true,
            onLongPress: _onMapLongPress, // 길게 눌러 마커 추가
          ),
          // 안내문 추가
          Positioned(
            bottom: 80, // 화면 하단에서 위로 80px 위치
            left: 50,
            right: 50,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.8), // 반투명 배경
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "지도를 꾹 눌러서 마커 추가",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
