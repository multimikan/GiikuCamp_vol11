import 'dart:async';

import 'package:flutter/material.dart';
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

class ZundaRoomViewModel extends ChangeNotifier{
  bool _showFirst = true;
  bool get showFirst => _showFirst; //getter
  Status nowStatus = Status.walk;
  Axis nowAxis = Axis.left;
  
  Widget nowImage = Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1));

  ZundaRoomViewModel(){
    Iterable<Widget> imageIte = ImageIte();
    final image =imageIte.iterator;

    Timer.periodic(Duration(milliseconds: 500), (_) {
      _showFirst = !_showFirst; //0.5sごとにshowFirstが切り替わる
      image.moveNext();
      nowImage = image.current;
      notifyListeners();
    });
  }

  List<Image> getAnimationImages(){
    final List<Image>tmp;

    switch(nowStatus){
      case (Status.stop):
        tmp = [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(2))];
      case (Status.walk):
        tmp = [Image.asset("images/ZUNDA/zundamon18.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon2.png",key: const ValueKey(2))];
      case (Status.cry):
        tmp = [Image.asset("images/ZUNDA/zundamon23.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon24.png",key: const ValueKey(2))];
      case (Status.bad):
        tmp = [Image.asset("images/ZUNDA/zundamon27.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon30.png",key: const ValueKey(2))];
      case (Status.surprize1):
        tmp = [Image.asset("images/ZUNDA/zundamon18.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon4.png",key: const ValueKey(2))];
      case (Status.surprize2):
        tmp = [Image.asset("images/ZUNDA/zundamon18.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon12.png",key: const ValueKey(2))];
      case (Status.surprize3):
        tmp = [Image.asset("images/ZUNDA/zundamon18.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon21.png",key: const ValueKey(2))];
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
    if (nowAxis==Axis.left){
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

class MyAnimatedImage extends StatefulWidget{
  const MyAnimatedImage({super.key});

  @override
  State<MyAnimatedImage> createState()=>_MyAnimatedImageState();
}

class _MyAnimatedImageState extends State<MyAnimatedImage> {

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    for(var i=1; i<33; i++) {
      precacheImage(AssetImage("images/ZUNDA/zundamon$i.png"), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ZundaRoomViewModel>();
    final nowImage = vm.nowImage;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 0),
      child: vm.resize(nowImage,45),
    );
  }
}