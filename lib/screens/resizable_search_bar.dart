import 'package:flutter/material.dart';
import './profile_button.dart';
import './custom_search_bar.dart';
import 'category_bar.dart';
import 'search_result_list.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResizableSearchBar extends StatefulWidget {
  final GoogleMapController mapController;

  const ResizableSearchBar({Key? key, required this.mapController})
      : super(key: key);

  @override
  State<ResizableSearchBar> createState() => _ResizableSearchBarState();
}

class _ResizableSearchBarState extends State<ResizableSearchBar> {
  final DraggableScrollableController _controller =
      DraggableScrollableController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller, // 추가된 부분
      initialChildSize: 0.15,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      snap: true,
      snapSizes: const [0.15, 0.4, 0.90],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomSearchBar(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const ProfileButton(),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              const CategoryBar(),
              SearchResultList(
                searchQuery: _searchQuery,
                mapController: widget.mapController,
                sheetController: _controller, // 전달
              ),
            ],
          ),
        );
      },
    );
  }
}
