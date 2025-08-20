import 'package:flutter/material.dart';

OverlayEntry? entry;
void showMoveOverlay(BuildContext context, Offset position) {
  final overlay = Overlay.of(context);
  entry?.remove();
  entry = null;
  entry = OverlayEntry(
    builder: (context) {
      return Positioned(
        right: 16,
        bottom: 16,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(16),
            width: 250,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "この場所にしますか？",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        entry!.remove();
                        entry = null;
                      },
                      child: const Text("キャンセル"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // moveメソッド
                        entry!.remove();
                        entry = null;
                      },
                      child: const Text("決定"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  overlay.insert(entry!);
}