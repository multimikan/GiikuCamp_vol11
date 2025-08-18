import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/rename_menu_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/move_menu_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/delete_menu_view.dart';

void showFileItemMenu(BuildContext context, Offset position) {
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
                        left: position.dx,
                        top: position.dy - 50,
                        child: ContextMenuOverlay(
                            position: position,
                            onClose: () {
                                entry!.remove();
                            },
                        ),
                    ),
                ],
            );
        },
    );
    overlay.insert(entry);
}

class ContextMenuOverlay extends StatelessWidget { // メニュー内容
    final Offset position;
    final VoidCallback onClose;
    const ContextMenuOverlay({super.key, required this.onClose, required this.position});
    @override
    Widget build(BuildContext context) {
        return Material(
            color: Colors.transparent, // 透明なウィジェット
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    _buildButton(context, Icons.edit, '名前変更', position),
                    const SizedBox(width: 8),
                    _buildButton(context, Icons.drive_file_move, '移動', position),
                    const SizedBox(width: 8),
                    _buildButton(context, Icons.delete, '削除', position),
                ],
            ),
        );
    }

    Widget _buildButton(BuildContext context, IconData icon, String tooltip, Offset position) {
        return GestureDetector(
            onTap: () {
                onClose(); // クリックしたらメニューを閉じる
                debugPrint('$tooltip tapped');
                switch (tooltip) {
                    case '名前変更':
                        showRenameOverlay(context, position);
                        break;
                    case '移動':
                        showMoveOverlay(context, position);
                        break;
                    case '削除':
                        showDeleteOverlay(context, position);
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
    final String name;
    final IconData icon;
    const TestFileIcon({
        super.key,
        required this.name,
        required this.icon,
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: () {
                final renderBox = context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                showFileItemMenu(context, position);
            },
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(icon, size: 48),
                    Text(name),
                ],
            ),
        );
    }
}