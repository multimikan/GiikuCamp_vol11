import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/dir_handler.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu_viewmodel.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';

OverlayEntry? entry;
FileHandlingMenuViewmodel handler = FileHandlingMenuViewmodel();
void showMoveOverlay(BuildContext context, Obj obj) {
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
                        await handler.moveObj(obj, DirDatabaseRepository.target.path);
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