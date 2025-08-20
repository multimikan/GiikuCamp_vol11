import 'dart:async';

import 'package:flutter/material.dart';

enum Status{
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

  ZundaRoomViewModel(){
    Timer.periodic(Duration(microseconds: 500), (_) {
      _showFirst = !_showFirst; //0.5sごとにshowFirstが切り替わる
      notifyListeners();
    });
  }

  List<Image> getAnimationImages(Status status){
    switch(status){
      case (Status.walk):
        return [Image.asset("images/ZUNDA/zundamon1",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon2",key: const ValueKey(2))];
      case (Status.cry):
        return [Image.asset("images/ZUNDA/zundamon23",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon24",key: const ValueKey(2))];
      case (Status.bad):
        return [Image.asset("images/ZUNDA/zundamon27",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon30",key: const ValueKey(2))];
      case (Status.surprize1):
        return [Image.asset("images/ZUNDA/zundamon1",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon4",key: const ValueKey(2))];
      case (Status.surprize2):
        return [Image.asset("images/ZUNDA/zundamon1",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon12",key: const ValueKey(2))];
      case (Status.surprize3):
        return [Image.asset("images/ZUNDA/zundamon1",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon21",key: const ValueKey(2))];
      case (Status.look):
        return [Image.asset("images/ZUNDA/zundamon17",key: const ValueKey(1)),Image.asset("images/ZUNDA/zundamon18",key: const ValueKey(2))];
    }
  }
}

/*viewで実装
class _MyAnimatedImageState extends State<MyAnimatedImage> {
  final vm = ZundaRoomView

  @override
  Widget build(BuildContext context) {
    final animevm = context.watch<ZundaRoomViewmodel>();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: animevm.showFirst
          ? Image.asset('assets/image1.png', key: const ValueKey(1))
          : Image.asset('assets/image2.png', key: const ValueKey(2)),
      ),
    );
  }
}
*/