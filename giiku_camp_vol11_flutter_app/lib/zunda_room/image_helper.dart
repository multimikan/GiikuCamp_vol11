import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';

class ImageHelper{
  Image image;
  int door_Y;
  Map<String,int> floor_x; //[min:OO,maxOO]
  Map<String,int> floor_y;
  ImageHelper(this.image,this.door_Y,this.floor_x,this.floor_y);

  static Widget resize(Widget w, int percent){
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
}

class HomeImages{
  final home1 = {
    RoomDirection.left: ImageHelper(Image.asset("images/home1(L).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth*0.2).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.5).toInt(),"max":(AppConfig.windowHeight*0.9).toInt()}),

    RoomDirection.right: ImageHelper(Image.asset("images/home1(R).png",fit: BoxFit.fill,),
  (AppConfig.windowHeight*0.4).toInt(),
  {"min":0,"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),

  RoomDirection.center: ImageHelper(Image.asset("images/home1(C).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),
  };

  final home2 = {
    RoomDirection.left: ImageHelper(Image.asset("images/home2(L).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth*0.2).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),
  
    RoomDirection.right: ImageHelper(Image.asset("images/home2(R).png",fit: BoxFit.fill,),
  (AppConfig.windowHeight*0.4).toInt(),
  {"min":0,"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),

  RoomDirection.center: ImageHelper(Image.asset("images/home2(C).png",fit: BoxFit.fill,),
    (AppConfig.windowHeight*0.4).toInt(),
  {"min":(AppConfig.windowWidth).toInt(),"max":(AppConfig.windowWidth*0.8).toInt()},
  {"min":(AppConfig.windowHeight*0.4).toInt(),"max":AppConfig.windowHeight.toInt()}),
  };
}