import 'dart:io';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/sub_menu/open_menu_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/sub_menu/rename_menu_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/sub_menu/move_menu_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/sub_menu/delete_menu_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu_viewmodel.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:path/path.dart' as p;

void showFileItemMenu(BuildContext context, Obj obj) {
    final overlay = Overlay.of(context); // ボタン用オーバーレイ
    OverlayEntry? entry;
    entry = OverlayEntry(
        builder: (context) {
            return Stack(
                children: [
                    Positioned.fill( // 別の場所クリック時
                        child: Listener(
                            behavior: HitTestBehavior.translucent, // 検知用に透明なオーバーレイで覆っているため、下ウィジェットに操作を伝達
                            onPointerDown: (_) {
                                entry!.remove();
                            },
                        ),
                    ),
                    Positioned( // メニュー表示
                        left: (obj.location.x).toDouble(),
                        top: (obj.location.y).toDouble() - 50,
                        child: FractionalTranslation(
                            translation: const Offset(-0.5, -0.5),
                            child: ContextMenuOverlay(
                                obj: obj, 
                                onClose: () {
                                    entry!.remove();
                                },
                            ),
                        ),
                    ),
                ],
            );
        },
    );
    overlay.insert(entry);
}

class ContextMenuOverlay extends StatelessWidget { // メニュー内容
    final Obj obj;
    final VoidCallback onClose;
    const ContextMenuOverlay({
      super.key,
      required this.onClose,
      required this.obj,
    });
    @override
    Widget build(BuildContext context) {
        return Material(
            color: Colors.transparent, // 透明なウィジェット
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    if (obj.extention != "") ...[
                      _buildButton(context, Icons.open_in_new, '開く', obj),
                      const SizedBox(width: 8),
                    ],
                    _buildButton(context, Icons.edit, '名前変更', obj),
                    const SizedBox(width: 8),
                    _buildButton(context, Icons.drive_file_move, '移動', obj),
                    const SizedBox(width: 8),
                    _buildButton(context, Icons.delete, '削除', obj),
                ],
            ),
        );
    }

    Widget _buildButton(BuildContext context, IconData icon, String tooltip, Obj obj) {
        return GestureDetector(
            onTap: () {
                onClose(); // クリックしたらメニューを閉じる
                debugPrint('$tooltip tapped');
                switch (tooltip) {
                    case '開く':
                        showOpenOverlay(context, obj);
                        break;
                    case '名前変更':
                        showRenameOverlay(context, obj);
                        break;
                    case '移動':
                        showMoveOverlay(context, obj);
                        break;
                    case '削除':
                        showDeleteOverlay(context, obj);
                        break;
                }
            },
            child: Container( // 操作アイコン見た目
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                ),
                child: Icon(icon, size: 24),
            ),
        );
    }
}

class TestFileIcon extends StatelessWidget { // 表示テスト用
    final IconData icon;
    final Obj obj;
    const TestFileIcon({
        super.key,
        required this.icon,
        required this.obj,
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                showFileItemMenu(context, obj);
            },
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(icon, size: 48),
                ],
            ),
        );
    }
}