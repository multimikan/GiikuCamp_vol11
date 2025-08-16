import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io'; /* ディレクトリ検索モジュール */
import 'package:path/path.dart' as p; 


class DirDatabaseRepository extends ChangeNotifier{
  late String? target;
  late Directory dir;
  late List<FileSystemEntity> dirList;
  late final String home; 

  DirDatabaseRepository([target]){ //オプションでターゲットのディレクトリを指定できる
    home = Platform.environment['HOME'] ?? Platform.environment['USERPROFILE']!;
    target = target ?? home;
    dir  = Directory(target);
    fetchDirectory();
  }

  void fetchDirectory(){ /* ディレクトリ情報を同期 */
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

  /*
  ディレクトリ名を変更した瞬間全てのデータが吹き飛びます。(Fileなら大丈夫)
  妥協して実装しています。
  改善すべきかどうかは後で相談します。
  */

  void rename(FileSystemEntity f, String name) async{
    final store = ObjDatabaseStore();
    final dirName = p.dirname(f.path);
    final extension = p.extension(f.path);
    if(p.extension(f.path)!='') {
      try{
        final newPath = '$dirName/$name/$extension';
        await f.rename(newPath);
      }catch(e){
        print("エラー：$e");
      }
    }
    else{
      try{
        final newPath = '$dirName/$name';
        await f.rename(newPath);
      }catch(e){
        print("エラー：$e");
      }
    }
    store.fetchObjects();
    notifyListeners();
  }

  void move(FileSystemEntity f, String newPath)async{
    final store = ObjDatabaseStore();
    store.fetchObjects();
    await f.rename(newPath);
  }

}