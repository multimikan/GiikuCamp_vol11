import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io'; /* ディレクトリ検索モジュール */
import 'package:path_provider/path_provider.dart';


class DirDatabaseRepository extends ChangeNotifier{
  late String? selectTarget; //オプショナルtarget(指定する場合に初期化)
  static late Directory target; //表示対象dir
  late List<FileSystemEntity> dirList; //対象dirの子階層を格納
  
  /*
  dirListは[Directory:OO,File:OO.extention]のように辞書形式のような形
  */

  DirDatabaseRepository._(target,this.dirList,this.selectTarget); // private constructor
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
    print(dirList);
  }

  Future<FileSystemEntity> convertFileSystemEntityFromObj(Obj obj) async {
    final type = await FileSystemEntity.type(obj.path);
    if(type == FileSystemEntityType.file) return File(obj.path);
    return Directory(obj.path);
  }

  /*
  ディレクトリ名を変更した瞬間全てのデータが吹き飛びます。(Fileなら大丈夫)
  妥協して実装しています。
  改善すべきかどうかは後で相談します。
  */

}