import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/main_dev.dart';
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
enum Axis{
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

class ImageHelper{
  Image image;
  int door_Y;
  Map<String,int> floor_x; //[min:OO,maxOO]
  Map<String,int> floor_y;
  ImageHelper(this.image,this.door_Y,this.floor_x,this.floor_y);
}

class HomeImages{
  final home1 = {
    RoomDirection.left: ImageHelper(Image.asset("images/home1(L).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":0,"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),

    RoomDirection.right: ImageHelper(Image.asset("images/home1(R).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth*0.2).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),

  RoomDirection.center: ImageHelper(Image.asset("images/home1(C).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),
  };

  final home2 = {
    RoomDirection.left: ImageHelper(Image.asset("images/home2(L).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":0,"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),

    RoomDirection.right: ImageHelper(Image.asset("images/home2(R).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth*0.2).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),

  RoomDirection.center: ImageHelper(Image.asset("images/home2(C).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),
  };
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
  Axis axis;
  Status status;

  Zundamon(this.location,this.skin,this.axis,this.status);
}

class ZundaRoomViewModel extends ChangeNotifier{
  bool _showFirst = true;
  bool get showFirst => _showFirst; //getter
  final homeImages = HomeImages();
  static var home = HomeImages().home1[RoomDirection.left];
  late final ZundaMoveController controller;
  static Zundamon zundamon = Zundamon(Location(AppConfig.windowWidth.toInt(),AppConfig.windowHeight.toInt()), Image.asset("images/ZUNDA/zundamon1.png"), Axis.left, Status.stop);

  ZundaRoomViewModel(){
    Iterable<Widget> imageIte = ImageIte();
    final image =imageIte.iterator;
    image.moveNext();
    controller = ZundaMoveController(zundamon);
    print("windowWidth:${AppConfig.windowWidth})");

    Timer.periodic(Duration(milliseconds: 500), (_) {
      _showFirst = !_showFirst; //0.5sごとにshowFirstが切り替わる
      image.moveNext(); //ジェネレータ.next()
      zundamon.skin = image.current;
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

  Widget resize(Widget w, int percent){
    final Image img;
    if(w is Image){
      img = w;
      return Image(
        image: img.image,
        width: (img.width??256)*percent/100,
        height: (img.height??256)*percent/100,
      );
    }
    else {
      return SizedBox(
        width: (256)*percent/100,
        height: (256)*percent/100,
        child: w,
      );
    }
  }

  Widget _changeImageWidgetWithNowAxis(Image img){
    final transeformedImg;
    if (zundamon.axis==Axis.left){
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