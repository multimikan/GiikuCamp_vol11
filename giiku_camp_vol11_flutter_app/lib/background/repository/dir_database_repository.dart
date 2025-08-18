import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io'; /* ディレクトリ検索モジュール */
import 'package:path/path.dart' as p; 
import 'package:path_provider/path_provider.dart';


class DirDatabaseRepository extends ChangeNotifier{
  late String? selectTarget; //オプショナルtarget(指定する場合に初期化)
  late Directory target; //表示対象dir
  late List<FileSystemEntity> dirList; //対象dirの子階層を格納

  DirDatabaseRepository._(this.target,this.dirList,this.selectTarget); // private constructor
  /*

  ！！！このクラスをインスタンス化する際はawait DirDatabaseRepository.init();としてください！！！

  */
  static Future<DirDatabaseRepository> init([target]) async {
    var t = await getApplicationDocumentsDirectory();
    if(target != null) t = Directory(target);
    
    return DirDatabaseRepository._(t, [],null);
  }

  void fetchDirectory([Directory? t]){ /* ディレクトリ情報を同期 */
    if(t!=null) target = t;
    try{
    dirList.clear();
    target.listSync().forEach((entity) {
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