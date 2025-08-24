import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu_viewmodel.dart';

OverlayEntry? entry;
FileHandlingMenuViewmodel handler = FileHandlingMenuViewmodel();
void showRenameOverlay(BuildContext context, Obj obj, void Function() upd) {
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
            left: (obj.location.x).toDouble(),
            top: (obj.location.y).toDouble() - 50,
            child: FractionalTranslation(
              translation: const Offset(-0.5, -0.5),
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
                          hintText: "新しい名前を入力するのだ",
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
                              await handler.renameObj(obj, controller.text);
                              entry!.remove();
                              entry = null;
                              upd();
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
          ),
        ],
      );
    },
  );
  overlay.insert(entry!);
}