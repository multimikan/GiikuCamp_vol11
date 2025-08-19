import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/dir_handler.dart';

OverlayEntry? entry;
DirHandler handler = DirHandler();
void showRenameOverlay(BuildContext context, Offset position, FileSystemEntity file) {
  final TextEditingController controller = TextEditingController();
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
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    )
                  ],
                ),
                width: 250,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: "新しい名前を入力",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      controller: controller,
                    ),
                    const SizedBox(height: 8),
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
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            await handler.rename(file, controller.text);
                            entry!.remove();
                            entry = null;
                          },
                          child: const Text("実行"),
                        ),
                      ],
                    )
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