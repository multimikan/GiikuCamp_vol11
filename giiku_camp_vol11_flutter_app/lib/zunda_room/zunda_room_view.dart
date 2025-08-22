/*
動的なviewの作り方については適宜学習か質問をお願いします。
ファイル名: ○○_view
クラス名: ClassNameViewのようなキャメルケースの命名をお願いします。
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/image_helper.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu.dart';

late ObjDatabaseStore store;

class ZundaRoomView extends StatefulWidget {
  const ZundaRoomView({super.key});

  @override
  _ZundaRoomViewState createState() => _ZundaRoomViewState();
}

class _ZundaRoomViewState extends State<ZundaRoomView> {
  bool loaded = false;
  int currentRoomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadObjects();
  }

  Future<void> _loadObjects() async {
    store = await ObjDatabaseStore.init();
    await store.fetchObjects();
    context.read<ZundaRoomViewModel>().fetchRoomDirs();
    setState(() {
      loaded = true;
    });
  }
  void nextRoom(List<RoomDirs> rooms) {
    setState(() {
      if (currentRoomIndex < rooms.length - 1) {
        currentRoomIndex++;
      }
    });
  }
  void _prevRoom() {
    setState(() {
      if (currentRoomIndex > 0) {
        currentRoomIndex--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  final vm = context.watch<ZundaRoomViewModel>();
  final home = ZundaRoomViewModel.home!.image;
  final location = vm.controller.location??Location(0,0);

  if(ZundaMoveController.jobList.isNotEmpty) vm.controller.move(ZundaRoomViewModel.zundamon.have!);

  if (ZundaRoomViewModel.rooms.isEmpty) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("部屋がありません"),
            IconButton(
              icon: const Icon(Icons.arrow_downward, size: 32),
              onPressed: () async {
                await store.changeTarget(p.dirname(DirDatabaseRepository.target.path));
                currentRoomIndex = 0;
                vm.fetchRoomDirs();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  final currentRoom = ZundaRoomViewModel.rooms[currentRoomIndex];

    if (!loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          SizedBox.expand(
            child: home, 
          ),
      // もともとこの位置に書いてあったもの、一応残しておきます。
      // appBar: AppBar(
      //     backgroundColor: Colors.black,
      // ),
      // body: Center(
      //     child: Container()
      // ),
          for(var o in currentRoom.directories) // ディレクトリ配置
            Positioned(
              left: (o.location.x).toDouble(),
              top: (o.location.y).toDouble(),
              child: ObjIcon(
                obj: o,
                onTap: () async {
                  showFileItemMenu(context, o);
                },
                onDoubleTap: () async {
                  await store.changeTarget(o.path);
                  currentRoomIndex = 0;
                  vm.fetchRoomDirs();
                  print("変更完了");
                  setState(() {});
                },
              ),
            ),
          for(var o in currentRoom.files) // ファイル配置
            Positioned(
              left: (o.location.x).toDouble(),
              top: (o.location.y).toDouble(),
              child: ObjIcon(
                obj: o,
                onTap: () async {
                  showFileItemMenu(context, o);
                },
                onDoubleTap: () {},
              ),
            ),
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            left: location.x.toDouble() - ZUNDAMON_IMAGE_PADDING,
            top: location.y.toDouble() - ZUNDAMON_IMAGE_PADDING,
            child: Stack(
              clipBehavior: Clip.none, // はみ出しを許可
              children: [
                ZundamonWidget(),      // 位置基準はここ
                Positioned(
                  top: -40, 
                  left: -60,
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 0),
                    child: ObjIcon(
                      key: ValueKey(ZundaRoomViewModel.zundamon.have), // 変更を判定するキー
                      obj: ZundaRoomViewModel.zundamon.have,
                    ),
                  ) ,
                ),
              ],
            ),
            onEnd: () {
              vm.controller.completer!.complete();
            },
          ),

          LayoutBuilder(builder: (context,constraints){
            print({"constraints.maxWidth:${constraints.maxWidth}"});
            print("constraints.maxHeight:${constraints.maxHeight}");
            print("LWidth:${location.x}");
            print("LHidth:${location.y}");
            return Container();
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: _prevRoom,
              icon: const Icon(Icons.chevron_left, size: 48),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: (){nextRoom(ZundaRoomViewModel.rooms);},
              icon: const Icon(Icons.chevron_right, size: 48),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_downward, size: 32),
                  onPressed: () async {
                    await store.changeTarget(p.dirname(DirDatabaseRepository.target.path));
                    currentRoomIndex = 0;
                    vm.fetchRoomDirs();
                    setState(() {});
                  },
                ),
                const Text(
                  "親ディレクトリに戻る",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ObjIcon extends StatefulWidget {
  final Obj? obj;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  const ObjIcon({super.key, this.obj, this.onTap, this.onDoubleTap});

  @override
  _ObjIconState createState() => _ObjIconState();
}

class _ObjIconState extends State<ObjIcon> {
  late Obj obj;
  late VoidCallback onTap;
  late VoidCallback onDoubleTap;

  @override
  void initState() {
    super.initState();
    obj = widget.obj ?? Obj("", "", SizedBox(), "", Location(0, 0), Directory(""));
    onTap = widget.onTap ?? () {};
    onDoubleTap = widget.onDoubleTap ?? () {};
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print("クリック");
        onTap();
      },
      onDoubleTap: () {
        print("ダブルクリック");
        onDoubleTap();
      },
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: SizedBox(
          width: 60,
          child: Center(
            child: Column(
              children: [
                Text(
                  widget.obj!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                widget.obj!.image,
              ],
            ),
          ),
        ),
      ),
    );
  }
}



class ZundamonWidget extends StatefulWidget{
  const ZundamonWidget({super.key});

  @override
  State<ZundamonWidget> createState()=>_ZundamonWidgetState();
}

class _ZundamonWidgetState extends State<ZundamonWidget> {

  @override
  void didChangeDependencies(){ /* キャッシュで先読み込み */
    super.didChangeDependencies();
    for(var i=1; i<33; i++) {
      precacheImage(AssetImage("images/ZUNDA/zundamon$i.png"), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skin = ZundaRoomViewModel.zundamon.skin;

    return Stack(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 0),
          child: ImageHelper.resize(skin,ZUNDAMON_RESIZE_PERCENT),
        ),
      ],
    );
  }
}




/// 画面上に一定間隔のグリッドと座標ラベルを描くデバッグ用オーバーレイ。
class DebugGridOverlay extends StatelessWidget {
  const DebugGridOverlay({
    super.key,
    this.interval = 50,
    this.lineThickness = 0.5,
    this.lineColor,
    this.labelColor,
    this.showLabels = true,
    this.padding = EdgeInsets.zero,
    this.ignoreSafeArea = false,
  });

  /// 縦横ラインの間隔（論理ピクセル）
  final double interval;

  /// ラインの太さ
  final double lineThickness;

  /// ライン色（未指定なら半透明の赤）
  final Color? lineColor;

  /// ラベル色（未指定ならテーマに合わせた黒/白）
  final Color? labelColor;

  /// 座標ラベルを表示するか
  final bool showLabels;

  /// 描画範囲に与えるパディング
  final EdgeInsets padding;

  /// SafeArea を無視して、画面全域に描画するか
  final bool ignoreSafeArea;

  @override
  Widget build(BuildContext context) {
    final grid = CustomPaint(
      painter: _GridPainter(
        interval: interval,
        lineThickness: lineThickness,
        lineColor: lineColor ?? Colors.red.withOpacity(0.35),
        labelColor: labelColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87),
        showLabels: showLabels,
        padding: padding,
      ),
      size: Size.infinite,
    );

    return IgnorePointer( // タップを透過
      child: ignoreSafeArea ? grid : SafeArea(child: grid),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({
    required this.interval,
    required this.lineThickness,
    required this.lineColor,
    required this.labelColor,
    required this.showLabels,
    required this.padding,
  });

  final double interval;
  final double lineThickness;
  final Color lineColor;
  final Color labelColor;
  final bool showLabels;
  final EdgeInsets padding;

  @override
  void paint(Canvas canvas, Size size) {
    // パディングを考慮した描画領域
    final left = padding.left;
    final top = padding.top;
    final right = size.width - padding.right;
    final bottom = size.height - padding.bottom;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineThickness;

    // 縦線
    for (double x = left; x <= right; x += interval) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), paint);
    }
    // 横線
    for (double y = top; y <= bottom; y += interval) {
      canvas.drawLine(Offset(left, y), Offset(right, y), paint);
    }

    if (!showLabels) return;

    // ラベル描画（x軸上端、y軸左端）
    final textStyle = TextStyle(
      color: labelColor,
      fontSize: 10,
      height: 1.0,
    );

    // x座標ラベル（上）
    for (double x = left; x <= right; x += interval) {
      final tp = _layoutText(x.toStringAsFixed(0), textStyle);
      // 少し右下にオフセット
      tp.paint(canvas, Offset(x + 2, top + 2));
    }

    // y座標ラベル（左）
    for (double y = top; y <= bottom; y += interval) {
      final tp = _layoutText(y.toStringAsFixed(0), textStyle);
      tp.paint(canvas, Offset(left + 2, y + 2));
    }

    // 外枠（視認性のため）
    final border = Paint()
      ..color = lineColor.withOpacity(0.6)
      ..strokeWidth = lineThickness + 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawRect(Rect.fromLTRB(left, top, right, bottom), border);
  }

  TextPainter _layoutText(String text, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return tp;
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) {
    return interval != old.interval ||
        lineThickness != old.lineThickness ||
        lineColor != old.lineColor ||
        labelColor != old.labelColor ||
        showLabels != old.showLabels ||
        padding != old.padding;
  }
}