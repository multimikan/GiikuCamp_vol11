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

late ObjDatabaseStore store;

class ZundaRoomView extends StatefulWidget {
  const ZundaRoomView({super.key});

  @override
  _ZundaRoomViewState createState() => _ZundaRoomViewState();
}

class _ZundaRoomViewState extends State<ZundaRoomView> {
  bool loaded = false;
  Image home = Image.asset("images/brick(R)1.png",fit: BoxFit.fill,);

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

  @override
  Widget build(BuildContext context) {
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
            child: home
          ),
      // もともとこの位置に書いてあったもの、一応残しておきます。
      // appBar: AppBar(
      //     backgroundColor: Colors.black,
      // ),
      // body: Center(
      //     child: Container()
      // ),
          for(var o in ObjDatabaseStore.objects)
            Positioned(
              left: (o.location.x).toDouble(),
              top: (o.location.y).toDouble(),
              child: ObjIcon(
                obj: o,
                onTap: () async {
                  await store.changeTarget(o.path);
                  print("変更完了");
                  setState(() {});
                }
              ),
            ),
            Positioned(
              left:AppConfig.windowWidth-10,
              top: AppConfig.windowHeight-10,
              child: ZundamonWidget()
            ),
        ],
      ),
    );
  }
}

class ObjIcon extends StatefulWidget {
  final Obj obj;
  final VoidCallback onTap;
  const ObjIcon({super.key, required this.obj, required this.onTap});

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
        print("変更開始");
        widget.onTap();
        //showFileItemMenu
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
