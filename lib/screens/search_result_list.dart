import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/marker_provider.dart';

class SearchResultList extends StatelessWidget {
  final String searchQuery;
  final GoogleMapController mapController;
  final DraggableScrollableController sheetController;

  const SearchResultList({
    Key? key,
    required this.searchQuery,
    required this.mapController,
    required this.sheetController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final markerProvider = Provider.of<MarkerProvider>(context);
    final allMarkers = markerProvider.markers.toList();

    final filteredMarkers = searchQuery.isEmpty
        ? allMarkers
        : allMarkers.where((marker) {
            final title = marker.infoWindow.title ?? '';
            return title.contains(searchQuery);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredMarkers.map((marker) {
        final markerId = int.tryParse(marker.markerId.value) ?? 0;
        final title = marker.infoWindow.title ?? '제목 없음';
        final category = marker.infoWindow.snippet ?? '카테고리 없음';
        final position = marker.position;

        return InkWell(
          onTap: () {
            // 마커 선택
            Provider.of<MarkerProvider>(context, listen: false)
                .selectMarker(markerId);

            // 카메라 이동
            mapController.animateCamera(
              CameraUpdate.newLatLng(position),
            );

            // 드래그 시트 크기 줄이기
            sheetController.animateTo(
              0.4,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(category,
                    style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const Divider(),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
