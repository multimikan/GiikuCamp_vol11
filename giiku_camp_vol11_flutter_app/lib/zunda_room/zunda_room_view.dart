/*
動的なviewの作り方については適宜学習か質問をお願いします。
ファイル名: ○○_view
クラス名: ClassNameViewのようなキャメルケースの命名をお願いします。
*/

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';

//仮置き
class RoomDirs {
  List<Obj> directories;
  List<Obj> files;

  RoomDirs({this.directories = const [], this.files = const []});
}
List<RoomDirs> Rooms = [
  RoomDirs(directories: [], files: []),
  RoomDirs(directories: [], files: []),
  RoomDirs(directories: [], files: []),
];

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
    setState(() {
      loaded = true;
    });
  }
  void _nextRoom() {
    setState(() {
      if (currentRoomIndex < Rooms.length - 1) {
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
  final currentRoom = Rooms[currentRoomIndex];

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
                  //showmenu
                },
                onDoubleTap: () async {
                  await store.changeTarget(o.path);
                  currentRoomIndex = 0;
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
                  //showmenu
                },
                onDoubleTap: () {},
              ),
            ),
          AnimatedPositioned(
            duration: Duration(seconds: 2),
            left:location.x.toDouble(),
            top: location.y.toDouble(),
            child: SizedBox(child: ZundamonWidget(),),
            onEnd:(){ vm.controller.completer!.complete();},
          ),
          LayoutBuilder(builder: (context,constraints){
            print({"constraints.maxWidth:${constraints.maxWidth}"});
            print("constraints.maxHeight:${constraints.maxHeight}");
            print("windowsWidth:${AppConfig.windowWidth}");
            print("windowsHidth:${AppConfig.windowHeight}");
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
              onPressed: _nextRoom,
              icon: const Icon(Icons.chevron_right, size: 48),
            ),
          ),
        ],
      ),
    );
  }
}

class ObjIcon extends StatefulWidget {
  final Obj obj;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  const ObjIcon({super.key, required this.obj, required this.onTap, required this.onDoubleTap});

  @override
  _ObjIconState createState() => _ObjIconState();
}

class _ObjIconState extends State<ObjIcon> {
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        print("クリック");
        widget.onTap();
      },
      onDoubleTap: () async {
        print("ダブルクリック");
        widget.onDoubleTap();
      },
      child: Column(
        children: [
          Icon(size: 20, widget.obj.type == ObjType.door ? Icons.folder : Icons.insert_drive_file, ),
          Text(widget.obj.name),
        ],
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
    final vm = context.watch<ZundaRoomViewModel>();
    final skin = ZundaRoomViewModel.zundamon.skin;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 0),
      child: vm.resize(skin,45),
    );
  }
}
