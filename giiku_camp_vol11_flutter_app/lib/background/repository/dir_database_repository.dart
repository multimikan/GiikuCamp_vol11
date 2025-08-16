import 'package:flutter/material.dart';
import 'dart:io'; /* ディレクトリ検索モジュール */


class DirDatabaseRepository extends ChangeNotifier{
  late Directory dir;
  late List<FileSystemEntity> dirList;
  late final String home; 

  DirDatabaseRepository(){
    home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
    dir  = Directory(home);
    fetchDirectory();
  }

  void fetchDirectory(/* target: String */){ /* ディレクトリ情報を同期 */
    try{
    dirList.clear();
    dir.listSync().forEach((entity) {
      dirList.add(entity);
    });
     }catch(e){
      print("エラー：$e");
     }
    notifyListeners(); /* 変更を通知 */
  }
}