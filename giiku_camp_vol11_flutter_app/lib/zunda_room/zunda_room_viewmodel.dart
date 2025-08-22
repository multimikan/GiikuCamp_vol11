import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/main_dev.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/image_helper.dart';
import 'package:provider/provider.dart';

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

enum RoomDirection{
  left,
  right,
  center
}

class Location{
  int x;
  int y;

  Location(this.x,this.y);
}

class Job{
  Location goal;
  Location middle;
  Job(this.goal,this.middle);
}

class Zundamon{
  Location location;
  Widget skin;
  LookAxis axis;
  Status status;

  Zundamon(this.location,this.skin,this.axis,this.status);
}

class ZundaRoomViewModel extends ChangeNotifier{
  bool _showFirst = true;
  bool get showFirst => _showFirst; //getter
  final homeImages = HomeImages();
  static var home = HomeImages().home1[RoomDirection.left];
  late final ZundaMoveController controller;
  Zundamon zundamon = Zundamon(Location(0,0),Image.asset(""),LookAxis.left,Status.stop);

  ZundaRoomViewModel() {
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
      zundamon.status = Status.cry;
      notifyListeners();
    });
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

class ZundaMoveController extends ChangeNotifier{
  static List<Job> jobList = [];
  Location? location;
  Zundamon zundamon;
  bool isMoveing = false;

  Completer<void>? completer;
  
  ZundaMoveController(this.zundamon){
    location = Location(zundamon.location.x, zundamon.location.y);
  }

  void move(){
    if(!isMoveing) return;
    if(jobList.isNotEmpty){
      isMoveing = true;
      Job job = _popJobList();
      _setmove(job.middle);
      //middleまで待つ
      //time.sleep()
      _setmove(job.goal);
      //time.sleep()
      move();
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

  Job _popJobList(){
    final tmp = jobList.last;
    jobList.removeLast();
    return tmp;
  }

  Future<void> _setmove(Location destination){
    location = destination;
    notifyListeners();
    return completer!.future;
  }
}