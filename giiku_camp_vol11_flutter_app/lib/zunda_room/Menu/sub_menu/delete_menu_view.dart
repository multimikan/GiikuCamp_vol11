import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/dir_handler.dart';

OverlayEntry? entry;
DirHandler handler = DirHandler();
void showDeleteOverlay(BuildContext context, Offset position, FileSystemEntity file) {
  final overlay = Overlay.of(context);
  entry?.remove();
  entry = null;
  entry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          Positioned.fill( // 別の場所クリック時
            child: Listener(
              behavior: HitTestBehavior.translucent, // 検知用オーバーレイ
              onPointerDown: (_) {
                entry!.remove();
                entry = null;
              },
            ), 
          ),
          Positioned(
            left: position.dx,
            top: position.dy - 50,
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
                      "本当に削除しますか？",
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
                            await handler.del(file);
                            entry!.remove();
                            entry = null;
                          },
                          child: const Text("実行"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  overlay.insert(entry!);
}