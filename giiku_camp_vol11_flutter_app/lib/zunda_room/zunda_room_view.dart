/*
動的なviewの作り方については適宜学習か質問をお願いします。
ファイル名: ○○_view
クラス名: ClassNameViewのようなキャメルケースの命名をお願いします。
*/

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';

class ZundaRoomView extends StatefulWidget {
  const ZundaRoomView({super.key});

  @override
  _ZundaRoomViewState createState() => _ZundaRoomViewState();
}

class _ZundaRoomViewState extends State<ZundaRoomView> {
  late ObjDatabaseStore store;
  bool loaded = false;

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
            child: Image.asset(
              'images/zundamonnoie2.png',
            fit: BoxFit.fill,
            ),
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
              left: (o.x).toDouble(),
              top: (o.y).toDouble(),
              child: ObjIcon(obj: o),
            ),
          Positioned(
            left: 30,
            top: 30,
            child: ElevatedButton(
              onPressed: () async {
                await store.fetchObjects();
                setState(() {});
              },
              child: const Text("fetch"),
            ),
          ),
        ],
      ),
    );
  }
}

class ObjIcon extends StatefulWidget {
  final Obj obj;
  const ObjIcon({super.key, required this.obj});

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
      onTap: () {
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
