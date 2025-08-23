import 'dart:math';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';


/// 部屋の一枚の画像情報
class RoomImage {
  final Image image;
  final int doorY;
  final Map<String, int> floorX; // {min: OO, max: OO}
  final Map<String, int> floorY;

  const RoomImage({
    required this.image,
    required this.doorY,
    required this.floorX,
    required this.floorY,
  });
}

/// 画像関連ユーティリティ
class ImageUtils {
  /// リサイズ
  static Widget resize(Widget widget, int percent) {
    if (widget is Image) {
      return Image(
        image: widget.image,
        width: (widget.width ?? 256) * percent / 100,
        height: (widget.height ?? 256) * percent / 100,
      );
    } else {
      return SizedBox(
        width: 256 * percent / 100,
        height: 256 * percent / 100,
        child: widget,
      );
    }
  }

  /// 拡張子からアイコン画像のパスに変換
  static String fromExtension(String extension) {
    final e = extension.replaceAll(".", "").toLowerCase();
    final random = Random();

    const imageExtensions = ["png", "jpg", "jpeg", "bmp", "heic"];
    const otherExtensions = ["docx", "mp3", "mp4", "pptx", "txt", "xlsx"];
    const dirImages = [
      "images/DOOR/door1.png",
      "images/DOOR/door2.png",
      "images/DOOR/door3.png",
      "images/DOOR/door4.png",
    ];

    if (e.isEmpty) {
      return dirImages[random.nextInt(dirImages.length)];
    } else if (imageExtensions.contains(e)) {
      return "images/ITEM/image.png";
    } else if (otherExtensions.contains(e)) {
      return "images/ITEM/$e.png";
    } else {
      return "images/ITEM/txt.png";
    }
  }
}

/// 家の種類
enum HomeType { home1, home2 }
/// 家ごとの画像セットを管理
class HomeImages {
  static Map<RoomDirection, RoomImage> get(HomeType type) {
    switch (type) {
      case HomeType.home1:
        return {
          RoomDirection.left: RoomImage(
            image: Image.asset("images/home1(L).png", fit: BoxFit.fill),
            doorY: (AppConfig.windowHeight * 0.35).toInt(),
            floorX: {
              "min": (AppConfig.windowWidth * 0.2).toInt(),
              "max": (AppConfig.windowWidth * 0.8).toInt(),
            },
            floorY: {
              "min": (AppConfig.windowHeight * 0.5).toInt(),
              "max": (AppConfig.windowHeight * 0.9).toInt(),
            },
          ),
          RoomDirection.right: RoomImage(
            image: Image.asset("images/home1(R).png", fit: BoxFit.fill),
            doorY: (AppConfig.windowHeight * 0.35).toInt(),
            floorX: {
              "min": (AppConfig.windowWidth * 0.2).toInt(),
              "max": (AppConfig.windowWidth * 0.8).toInt(),
            },
            floorY: {
              "min": (AppConfig.windowHeight * 0.5).toInt(),
              "max": (AppConfig.windowHeight * 0.9).toInt(),
            },
          ),
          RoomDirection.center: RoomImage(
            image: Image.asset("images/home1(C).png", fit: BoxFit.fill),
            doorY: (AppConfig.windowHeight * 0.35).toInt(),
            floorX: {
              "min": (AppConfig.windowWidth * 0.2).toInt(),
              "max": (AppConfig.windowWidth * 0.8).toInt(),
            },
            floorY: {
              "min": (AppConfig.windowHeight * 0.5).toInt(),
              "max": (AppConfig.windowHeight * 0.9).toInt(),
            },
          ),
        };

      case HomeType.home2:
        return {
          RoomDirection.left: RoomImage(
            image: Image.asset("images/home2(L).png", fit: BoxFit.fill),
            doorY: (AppConfig.windowHeight * 0.35).toInt(),
            floorX: {
              "min": (AppConfig.windowWidth * 0.2).toInt(),
              "max": (AppConfig.windowWidth * 0.8).toInt(),
            },
            floorY: {
              "min": (AppConfig.windowHeight * 0.5).toInt(),
              "max": (AppConfig.windowHeight * 0.9).toInt(),
            },
          ),
          RoomDirection.right: RoomImage(
            image: Image.asset("images/home2(R).png", fit: BoxFit.fill),
            doorY: (AppConfig.windowHeight * 0.35).toInt(),
            floorX: {
              "min": (AppConfig.windowWidth * 0.2).toInt(),
              "max": (AppConfig.windowWidth * 0.8).toInt(),
            },
            floorY: {
              "min": (AppConfig.windowHeight * 0.5).toInt(),
              "max": (AppConfig.windowHeight * 0.9).toInt(),
            },
          ),
          RoomDirection.center: RoomImage(
            image: Image.asset("images/home2(C).png", fit: BoxFit.fill),
            doorY: (AppConfig.windowHeight * 0.35).toInt(),
            floorX: {
              "min": (AppConfig.windowWidth * 0.2).toInt(),
              "max": (AppConfig.windowWidth * 0.8).toInt(),
            },
            floorY: {
              "min": (AppConfig.windowHeight * 0.5).toInt(),
              "max": (AppConfig.windowHeight * 0.9).toInt(),
            },
          ),
        };
    }
  }
}
