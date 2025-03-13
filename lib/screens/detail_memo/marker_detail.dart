import 'package:flutter/material.dart';

void showMarkerDetail(BuildContext context, Map<String, dynamic> memo) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(16),
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(memo['title'],
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("카테고리: ${memo['category']}"),
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
