import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
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

  late Zundamon zundamon;

  ZundaRoomViewModel(){
    Iterable<Widget> imageIte = ImageIte();
    final image =imageIte.iterator;
    image.moveNext();
    zundamon = Zundamon(Location(0,0), image.current, Axis.left, Status.stop);

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
  Job? job;
  bool moveStackIsNotEmpty = false;
  List<Location> moveStack = [];
  Zundamon zundamon;
  
  ZundaMoveController(this.zundamon);

  void fetchJobList(){
    if(jobList.isNotEmpty){
      final job = _popJobList();
      _pushMVStackFromJob(job);
      moveStackIsNotEmpty = true;
    }
    else{
      moveStackIsNotEmpty = false;
    }
  }

  void move(){
    fetchJobList();
    if(moveStackIsNotEmpty){
      Location destination;
      destination = _popMVStack();
      _moveStartToMiddle(destination);
      //time.sleep()
      _moveMiddleToGoal(destination);
      //time.sleep()
      move();
    }
    else{
      print("全ての動作が完了しました");
    }
  }

  void move(){
    if(jobList.isNotEmpty){
      Job job = _popJobList();
      _moveStartToMiddle(job.middle);
      //middleまで待つ
      //time.sleep()
      _moveMiddleToGoal(job.goal);
      //time.sleep()
      move();
    }
  }

  void _pushMVStackFromJob(Job job){
    moveStack.add(job.goal);
    moveStack.add(job.middle);
  }

  Location _popMVStack(){
    final tmp = moveStack.last;
    moveStack.removeLast();
    return tmp;
  }

  Job _popJobList(){
    final tmp = jobList.last;
    jobList.removeLast();
    return tmp;
  }

  void _moveStartToMiddle(Location destination){
    location = destination;
  }

  void _moveMiddleToGoal(Location destination){
    notifyListeners();
    location = destination;
  }
}

class MyAnimatedImage extends StatefulWidget{
  const MyAnimatedImage({super.key});

  @override
  State<MyAnimatedImage> createState()=>_MyAnimatedImageState();
}

class _MyAnimatedImageState extends State<MyAnimatedImage> {

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
    final skin = vm.zundamon.skin;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 0),
      child: vm.resize(skin,45),
    );
  }
}