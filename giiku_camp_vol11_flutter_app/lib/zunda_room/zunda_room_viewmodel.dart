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

class ZundaRoomViewModel extends ChangeNotifier{
  bool _showFirst = true;
  bool get showFirst => _showFirst; //getter
  Status nowStatus = Status.walk;
  Image nowImage = Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1));

  ZundaRoomViewModel(){
    Iterable<Image> imageIte = ImageIte();
    final image =imageIte.iterator;

    Timer.periodic(Duration(milliseconds: 300), (_) {
      _showFirst = !_showFirst; //0.5sごとにshowFirstが切り替わる
      image.moveNext();
      nowImage = image.current;
      notifyListeners();
    });
  }

  List<Image> getAnimationImages(){
    switch(nowStatus){
      case (Status.stop):
        return [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(2))];
      case (Status.walk):
        return [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon2.png",key: const ValueKey(2))];
      case (Status.cry):
        return [Image.asset("images/ZUNDA/zundamon23.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon24.png",key: const ValueKey(2))];
      case (Status.bad):
        return [Image.asset("images/ZUNDA/zundamon27.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon30.png",key: const ValueKey(2))];
      case (Status.surprize1):
        return [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon.png",key: const ValueKey(2))];
      case (Status.surprize2):
        return [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon12.png",key: const ValueKey(2))];
      case (Status.surprize3):
        return [Image.asset("images/ZUNDA/zundamon1.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon21.png",key: const ValueKey(2))];
      case (Status.look):
        return [Image.asset("images/ZUNDA/zundamon17.png",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon18.png",key: const ValueKey(2))];
    }
  }

  Iterable<Image> ImageIte([bool? i]) sync*{
    i = i??true;
    yield getAnimationImages()[i?1:0];
    yield* ImageIte(!i);
  }

  Image resize(Image img, int percent){
    return Image(
      image: img.image,
      width: (img.width??256)*percent/100,
      height: (img.height??256)*percent/100,
    );
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
      child: vm.resize(nowImage,40),
    );
  }
}