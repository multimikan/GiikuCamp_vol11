import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu_viewmodel.dart';

OverlayEntry? entry;
FileHandlingMenuViewmodel handler = FileHandlingMenuViewmodel();
void showDeleteOverlay(BuildContext context, Obj obj, void Function() upd) {
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
                        "本当に削除しますか？\n復元できません",
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
                              await handler.delObj(obj);
                              entry!.remove();
                              entry = null;
                              upd();
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
          ),
        ],
      );
    },
  );
  overlay.insert(entry!);
}