import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/main_dev.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/image_helper.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_view.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;

enum Status{
  stop,
  walk,
  cry,
  bad,
  surprize1,
  surprize2,
  surprize3,
  look,
}
enum LookAxis{
  //top,
  right,
  left,
  //bottom
}

enum RoomDirection { left, right, center }

class Location{
  int x;
  int y;

  Location(this.x,this.y);
}

class Job{
  Obj target;
  Location goal;
  Location middle;
  Job(this.goal,this.middle,this.target);
}

class Zundamon{
  Location location;
  Widget skin;
  LookAxis axis;
  Status status;
  Obj? have;

  Zundamon(this.location,this.skin,this.axis,this.status);
}

class RoomDirs {
  List<Obj> directories;
  List<Obj> files;

  RoomDirs(this.directories, this.files);
}

class ZundaRoomViewModel extends ChangeNotifier{
  bool _showFirst = true;
  bool get showFirst => _showFirst; //getter
  final homeImages = HomeImages();
  static var currentHomeDirection = RoomDirection.left;
  static var currentHome = HomeType.home1;
  static var home = HomeImages.get(currentHome)[currentHomeDirection];
  late final ZundaMoveController controller;
  static Zundamon zundamon = Zundamon(Location(0,0),Image.asset(""),LookAxis.left,Status.stop);
  static List<RoomDirs> rooms = [];

  ZundaRoomViewModel(){
    fetchRoomDirs();
    Iterable<Widget> imageIte = ImageIte();
    final image =imageIte.iterator;
    image.moveNext();
    var location = Location(AppConfig.windowWidth.toInt(),AppConfig.windowHeight.toInt());
    zundamon  = Zundamon(location, image.current, LookAxis.left, Status.walk);
    controller = ZundaMoveController(zundamon);

    Timer.periodic(Duration(milliseconds: 500), (_) {
      final newLocation = controller.location??Location(AppConfig.windowWidth.toInt(),AppConfig.windowHeight.toInt());
      location = newLocation;
      _showFirst = !_showFirst; //0.5sごとにshowFirstが切り替わる
      image.moveNext(); //ジェネレータ.next()
      zundamon.skin = image.current;
      notifyListeners();
    });
  }

  static setHave(Obj obj){
    zundamon.have = obj;
    final index = ObjDatabaseStore.objects.indexWhere((d)=> d.path == obj.path);
    ObjDatabaseStore.objects[index].image = SizedBox();
    store.fetchObjects();
  }

  static cancelHave(Obj obj){
    zundamon.have = Obj("","",SizedBox(),"",Location(0,0),File(""));
    final index = ObjDatabaseStore.objects.indexWhere((d)=> d.path == obj.path);
    ObjDatabaseStore.objects[index].image = ImageUtils.resize(Image.asset(ImageUtils.fromExtension(p.extension(obj.path))),10);
    store.fetchObjects();  
  }

  List<Image> getAnimationImages(){
    final List<Image>tmp;

    switch(zundamon.status){
      case (Status.stop):
        tmp = [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(2))];
      case (Status.walk):
        tmp = [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon2.png",key: const ValueKey(2))];
      case (Status.cry):
        tmp = [Image.asset("images/ZUNDA/zundamon23.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon24.png",key: const ValueKey(2))];
      case (Status.bad):
        tmp = [Image.asset("images/ZUNDA/zundamon27.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon30.png",key: const ValueKey(2))];
      case (Status.surprize1):
        tmp = [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon16.png",key: const ValueKey(2))];
      case (Status.surprize2):
        tmp = [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon13.png",key: const ValueKey(2))];
      case (Status.surprize3):
        tmp = [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon21.png",key: const ValueKey(2))];
      case (Status.look):
        tmp = [Image.asset("images/ZUNDA/zundamon17.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon18.png",key: const ValueKey(2))];
    }
    return tmp;
  }

  Iterable<Widget> ImageIte([bool? i]) sync*{
    i = i??true;
    final img = getAnimationImages()[i?1:0];
    yield _changeImageWidgetWithNowAxis(img);
    yield* ImageIte(!i);
  }

  void fetchRoomDirs(){
    final needRooms = _getNeedDoorNumbersInObjects();
    final separatedObjects = _getSeparationObjects();
    final files = separatedObjects["Files"]??[];
    final directories = separatedObjects["Directories"]??[];
    const max_door = 4;
    const max_item = 10;
    rooms = [];

    List<Obj> tmpD = [] ,tmpF = [];
    int t = 0;

    for(var i = 0; i<needRooms; i++){
      for(var j=0; j<max_door; j++){
        if(directories.isNotEmpty){
          if(i==0) t = 172;
          else if(i<needRooms-1) t = 112;
          else t = 52;
          directories.last.location.x = j*125 + t;
          tmpD.add(directories.last);
          directories.removeLast();
        }
      }
      for(var j=0; j<max_item; j++){
        if(files.isNotEmpty){
        tmpF.add(files.last);
        files.removeLast();
        }
      }
      rooms.add(RoomDirs(tmpD, tmpF));
      tmpD = [];
      tmpF = [];
    }
    notifyListeners();
  }
  

  int _getNeedDoorNumbersInObjects(){
    var dirNum = 0;
    var need = 0;
    const int max_door=4;
    const int max_item=20;

    for(var o in ObjDatabaseStore.objects) {dirNum += o.extention==""?1:0;}
    need = dirNum%max_door!=0?dirNum~/max_door+1:dirNum~/max_door;
    final fileNum = (ObjDatabaseStore.objects.length-dirNum);
    final fileneed = fileNum%max_item!=0?fileNum~/max_item+1:fileNum~/max_item;

    return need>fileneed? need:fileneed;
  }

  Map<String,List<Obj>> _getSeparationObjects(){
    List<Obj> files = [];
    List<Obj> directories = [];
    for(var o in ObjDatabaseStore.objects){
      if(o.extention!="") {files.add(o);}
      else {directories.add(o);}
    }
    return {"Files":files,"Directories":directories};
  }

  Widget _changeImageWidgetWithNowAxis(Image img){
    final transeformedImg;
    if (zundamon.axis==LookAxis.left){
      transeformedImg = Transform(
        alignment: Alignment.center, // 回転軸を画像の中心に
        transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0), // x軸を反転
        child: img,
        );
    }
    else{
      transeformedImg = Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..scale(1.0, 1.0, 1.0),
        child: img,
        );
    }
    return transeformedImg;
  }
  
}

/* ---------------------------------------------------------------------------- */
enum moveStatus{
  start,
  end
}
class ZundaMoveController extends ChangeNotifier{
  static List<Job> jobList = [];
  Location? location;
  Zundamon zundamon;
  bool isMoveing = false;
  moveStatus status = moveStatus.start;
  bool wait = false;

  Completer<void>? completer;
  
  ZundaMoveController(this.zundamon){
    location = Location(zundamon.location.x, zundamon.location.y);
  }

  Future<void> move(Obj obj) async{
    if(!isMoveing) return;
    if(jobList.isNotEmpty){
      isMoveing = true;
      zundamon.have = obj;
      Job job = _popJobList();
      _setmove(job.middle);
      status = moveStatus.start;
      zundamon.status = Status.stop;
      notifyListeners();
      //middleまで待つ
      await sleep(1);
      zundamon.status = Status.walk;
      _setmove(job.goal);
      status = moveStatus.end;
      notifyListeners();
      await sleep(1);
      move(job.target);
    }
    else{
      print("全ての動作が完了しました");
      isMoveing = false;
    }
  }
  
  void completeIfNeeded() { /* コンプリタが呼ばれたら */
    if (completer != null && !completer!.isCompleted) {
      completer!.complete();
      completer = null;
    }
  }

  Future<void> sleep(int time) async{
    wait = true;
    await Future.delayed(Duration(seconds: time));
    wait = false;
  }

  Job _popJobList(){
    final tmp = jobList.last;
    jobList.removeLast();
    return tmp;
  }

  Future<void> _setmove(Location destination){
    location = destination;
    zundamon.status = Status.walk;
    notifyListeners();
    return completer!.future;
  }
}