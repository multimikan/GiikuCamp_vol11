import 'package:flutter/material.dart';

enum Walk{
  walk,
  cry,
  bad,
  surprize1,
  surprize2,
  surprize3,
  look,
}

class ZundaRoomViewModel extends ChangeNotifier{
  List<Image> _getAnimationImages(Walk walk){
    switch(walk){
      case (Walk.walk):
        return [Image.asset("images/ZUNDA/zundamon1"),Image.asset("images/ZUNDA/zundamon2")];
      case (Walk.cry):
        return [Image.asset("images/ZUNDA/zundamon23"),Image.asset("images/ZUNDA/zundamon24")];
      case (Walk.bad):
        return [Image.asset("images/ZUNDA/zundamon27"),Image.asset("images/ZUNDA/zundamon30")];
      case (Walk.surprize1):
        return [Image.asset("images/ZUNDA/zundamon1"),Image.asset("images/ZUNDA/zundamon4")];
      case (Walk.surprize2):
        return [Image.asset("images/ZUNDA/zundamon1"),Image.asset("images/ZUNDA/zundamon12")];
      case (Walk.surprize3):
        return [Image.asset("images/ZUNDA/zundamon1"),Image.asset("images/ZUNDA/zundamon21")];
      case (Walk.look):
        return [Image.asset("images/ZUNDA/zundamon17"),Image.asset("images/ZUNDA/zundamon18")];
    }
  }
}