/*
動的なviewの作り方については適宜学習か質問をお願いします。
ファイル名: ○○_view
クラス名: ClassNameViewのようなキャメルケースの命名をお願いします。
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/gpt/gpt_service.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/Menu/file_handling_menu.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/image_helper.dart';
import 'dart:math';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';

late ObjDatabaseStore store;
int currentRoomIndex = 0;
Map<String, dynamic> reply = {};

class ZundaRoomView extends StatefulWidget {
  const ZundaRoomView({super.key});

  @override
  _ZundaRoomViewState createState() => _ZundaRoomViewState();
}
class _ZundaRoomViewState extends State<ZundaRoomView> {
  bool loaded = false;
  final vm = ZundaRoomViewModel();

  Obj? selectedObj;
  final gpt = GPTTerminal();
  final TextEditingController controller = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadObjects();
  }

  void upd() {
    setState(() {
      zundamonNeutral();
      currentRoomIndex = 0;
      ZundaRoomViewModel.currentHomeDirection = RoomDirection.left;
      vm.fetchRoomDirs();
    });
  }

  void zundamonNeutral(){
    setState(() {
      selectedObj = null;
      vm.controller.zundamon.status = Status.look;
    });
    
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
      zundamonNeutral();
      if (currentRoomIndex < rooms.length - 1) {
        currentRoomIndex++;
        if(currentRoomIndex==rooms.length-1) {
          ZundaRoomViewModel.currentHomeDirection = RoomDirection.right;
          vm.fetchRoomDirs();
        }
        else{
          ZundaRoomViewModel.currentHomeDirection = RoomDirection.center;
          vm.fetchRoomDirs();
        }
      }
    });
  }
  void _prevRoom() {
    setState(() {
      zundamonNeutral();
      if (currentRoomIndex > 0) {
        currentRoomIndex--;
        if(currentRoomIndex==0) {
          ZundaRoomViewModel.currentHomeDirection = RoomDirection.left;
          vm.fetchRoomDirs();
          }
        else{
          ZundaRoomViewModel.currentHomeDirection = RoomDirection.center;
          vm.fetchRoomDirs();
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
  final vm = context.watch<ZundaRoomViewModel>();
  final home = ZundaRoomViewModel.home!.image;

  if(context.watch<ZundaMoveController>().localJobList.isNotEmpty) {
    
  }

  if (ZundaRoomViewModel.rooms.isEmpty) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            SizedBox.expand(child: home,),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("からっぽの部屋なのだ..."),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward, size: 32),
                    onPressed: () async {
                      await store.changeTarget(p.dirname(DirDatabaseRepository.target.path));
                      upd();
                    },
                  ),
                ],
              ),
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
                key: ValueKey(o.path),
                obj: o,
                onTap: () async {
                  showFileItemMenu(context, o, upd);
                  print(o.path);
                },
                onDoubleTap: () async {
                  await store.changeTarget(o.path);
                  ZundaRoomViewModel.currentHome = store.getCurrentHomeType(o.path);

                  upd();
                  print(o.path);
                },
              ),
            ),

          for(var o in currentRoom.files) // ファイル配置
            Positioned(
              left: (o.location.x).toDouble(),
              top: (o.location.y).toDouble(),
              child: ObjIcon(
                key: ValueKey(o.path),
                obj: o,
                onTap: () async {
                  ZundaMoveController.jobList.add(Job(Location(0,0),o.location,o));
                  vm.controller.fetch();
                  selectedObj = o;
                  showFileItemMenu(context, o, upd);
                  print(o.path);
                },
                onDoubleTap: () {},
              ),
            ),

            AnimatedPositioned(
            duration: const Duration(seconds: 3),
            curve: Curves.easeInOut,
            left: vm.controller.zundamon.location.x.toDouble() - ZUNDAMON_IMAGE_PADDING,
            top:  vm.controller.zundamon.location.y.toDouble() - ZUNDAMON_IMAGE_PADDING,
            child: Stack(
              clipBehavior: Clip.none, // はみ出しを許可
              children: [
                ZundamonWidget(),
              ],
            ),
            onEnd: () {
              vm.controller.completeIfNeeded(Status.values.byName("surprize${Random().nextInt(3)+1}"));
            },
          ),

          if(selectedObj!=null)
            Positioned(
              left: (selectedObj!.location.x).toDouble(),
              top: (selectedObj!.location.y).toDouble(),
              child: ObjIcon(
                key: ValueKey(selectedObj!.path),
                obj: selectedObj,
                onTap: () async {
                  ZundaMoveController.jobList.add(Job(Location(0,0),selectedObj!.location,selectedObj!));
                  vm.controller.fetch();
                  showFileItemMenu(context, selectedObj!, upd);
                  print(selectedObj!.path);
                },
                onDoubleTap: () {},
              ),
            ),

          LayoutBuilder(builder: (context,constraints){
            /*print({"constraints.maxWidth:${constraints.maxWidth}"});
            print("constraints.maxHeight:${constraints.maxHeight}");
            print("LWidth:${location.x}");
            print("LHidth:${location.y}");*/
            return Container();
          }),
          Align(
            alignment: Alignment.centerLeft,/* 部屋を左に移動 */
            child: IconButton(
              onPressed: (_prevRoom),
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
                    selectedObj = null;
                    final currentPath = p.dirname(DirDatabaseRepository.target.path);
                    await store.changeTarget(currentPath);
                    ZundaRoomViewModel.currentHome = store.getCurrentHomeType(currentPath);
                    vm.controller.zundamon.status = Status.look;

                    upd();
                  },
                ),
                Text(
                  p.basename(DirDatabaseRepository.target.path),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft, // 左下
            child: Image.asset(
              "images/ITEM/trash.png",
              width: 40,
              height: 40,
            ),
          ),
          Align(
            alignment: Alignment.topLeft, // 左上
            child: SizedBox(
              width: 400,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "やってほしいことを教えてほしいのだ",
                        border: OutlineInputBorder(),
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {

                      final tmp = controller.text;
                      controller.text = "";
                      final reply = gpt.sendMessage(tmp);
                      /*if(reply["command"]!=""){
                        runCmdAlart(context, reply["command"]);
                      }*/
                      print(controller.text);
                      print(reply);
                      upd();
                      showGPTResultDialog(context, reply);
                    },
                    child: const Text("実行"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


Future<void> showGPTResultDialog(BuildContext context, Future<Map<String, dynamic>> futureResponse) async {

  return showDialog(
    context: context,
    barrierDismissible: false, // タップで閉じられないようにする
    builder: (BuildContext context) {
      return _CharacterDialog(futureResponse: futureResponse, position: ZundaRoomViewModel.zundamon.location);
    },
  );
}

class _CharacterDialog extends StatefulWidget {
  final Future<Map<String, dynamic>> futureResponse;
  final Location position;

  const _CharacterDialog({Key? key, required this.futureResponse, required this.position}) : super(key: key);

  @override
  State<_CharacterDialog> createState() => _CharacterDialogState();
}

class _CharacterDialogState extends State<_CharacterDialog> {
  String displayText = "";
  Timer? _timer;
  int dotCount = 0;

  @override
  void initState() {
    super.initState();

    // 読み込み中のアニメーション
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4;
        displayText = "考え中なのだ" + "." * dotCount;
      });
    });

    // API 呼び出し開始
    widget.futureResponse.then((res) {
      if (mounted) {
        _timer?.cancel();
        setState(() {
          displayText = res["res"] ?? "応答がなかったのだ…";
        });
      }
    }).catchError((err) {
      if (mounted) {
        _timer?.cancel();
        setState(() {
          displayText = "エラーが出たのだ: $err";
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: widget.position.x.toDouble()-AppConfig.windowWidth*0.1,
          top: widget.position.y.toDouble()-AppConfig.windowWidth*0.1,
          child: FractionalTranslation(
          translation: const Offset(-1, -1),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // 吹き出し
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                  ),
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: Text(
                    displayText,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                // 閉じるボタン
                Positioned(
                  right: 0,
                  top: 0,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


Future<void> runCmdAlart(BuildContext context, String cmd) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, // 左寄せ
            children: [
              Text(
                "実行確認",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // 中身（例: コマンド表示）
              Text("実行コマンド: $cmd"),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("キャンセル"),
                  ),TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("実行"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
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
    return FractionalTranslation(
      translation: const Offset(-0.5, -0.5),
      child: GestureDetector(
        onTap: () {
          print("クリック");
          onTap();
        },
        onDoubleTap: () {
          print("ダブルクリック");
          onDoubleTap();
        },
        child: SizedBox(
          width: 100,
          child: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: Text(
                    obj?.name ?? "",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
                obj?.image ?? const SizedBox(),
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
          child: ImageUtils.resize(skin,ZUNDAMON_RESIZE_PERCENT),
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