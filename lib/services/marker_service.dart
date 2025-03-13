import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerService {
  static Future<Set<Marker>> fetchMarkers(
      LatLng center, Function(Map<String, dynamic>) onTap) async {
    final String url =
        'https://api.mapping.kro.kr/api/v2/memo/total?lat=${center.latitude}&lng=${center.longitude}&km=5';

    try {
      final response =
          await http.get(Uri.parse(url), headers: {'accept': '*/*'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(utf8.decode(response.bodyBytes));

        if (data['success'] == true) {
          return data['data'].map<Marker>((memo) {
            return Marker(
              markerId: MarkerId(memo['id'].toString()),
              position: LatLng(memo['lat'], memo['lng']),
              infoWindow:
                  InfoWindow(title: memo['title'], snippet: memo['category']),
              icon: _getCategoryIcon(memo['category']),
              onTap: () => onTap(memo), // ✅ 마커 클릭 시 상세보기 호출
            );
          }).toSet();
        }
      }
    } catch (e) {
      print("API 요청 오류: $e");
    }
    return {};
  }

  static BitmapDescriptor _getCategoryIcon(String category) {
    switch (category) {
      case '공용 화장실':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case '쓰레기통':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta);
      case '흡연장':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      case '주차장':
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange);
      default:
        return BitmapDescriptor.defaultMarker;
    }
  }
}
