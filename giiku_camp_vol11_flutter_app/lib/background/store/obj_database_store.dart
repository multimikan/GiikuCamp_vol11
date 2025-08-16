/*

家具のデータベースを扱うファイル
永続保存の機能はまだない
(ターゲットチェンジでデータが損失する問題あり)

*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:path/path.dart' as p;


enum ObjType{ /*家具の種類*/
  door,
  clock
}

class Obj{ /* Model */
  String path; /*ディレクトリの絶対パスを取得*/
  String name;
  ObjType type;
  String extention;
  double x;
  double y;
  Obj(this.path, this.name, this.type, this.extention, this.x, this.y);
}

class ObjDatabaseStore extends ChangeNotifier{
  static List<Obj> objects = [];
  late final repo = DirDatabaseRepository();

  /*
  methodName() <- viewで使っても良い
  _methodName() <- viewで使ってはいけない
  */

  void fetchObjects(){ /* パソコンのディレクトリ情報と同期して家具リストを更新 */
    repo.fetchDirectory();
    /*
    -更新後に必要な判定-
    1.オブジェクトリストにない新規fileをオブジェクトリストに追加
    2.オブジェクトリストにはあるがディレクトリ情報にないものをオブジェクトリストから削除
    */
    _convertDirListToObjList(repo.dirList); // 1 & 2
    notifyListeners();
  }

  void changeTarget(String targetPass){
    repo.dir = Directory(targetPass);
    repo.fetchDirectory();
  }

  /*
  このアプリの外でリネームされた場合にファイルの追跡ができなくなります。
  現在、FileSystemEntity型の変数でディレクトリ情報を取得していますが、この型にはidが存在しません。
  対処法として考えたのはハッシュ値とパスの両方で判定をすることです。
  これにより、アプリ外でリネームした際にはハッシュ値による検索が可能になります。
  しかし、アプリ外でリネーム&内容を変更された際には追跡ができません。
  dartの標準モジュールでは完全自動追跡ができないそうなので、最終スプリントで改善or妥協を決めましょう。
  *現状ではパスのみでの判定です
  */

  void _updateObj(Obj obj, [String? name, ObjType? type, String? extension, double? x, double? y]){ /*既存のオブジェクトを更新*/
    final index = _findObjectsIndexFromPath(obj.path);

    name = name ?? obj.name;
    type = type ?? obj.type;
    extension = extension ?? obj.extention;
    x = x ?? obj.x;
    y = y ?? obj.y;

    final instance = Obj(obj.path, name, type, extension, x, y);
    objects[index] = instance;
    notifyListeners();
  }

  void _appendObj(FileSystemEntity f){ /* 新規オブジェクトを追加 */
    final instance = _convertObjFromFileSystemEntity(f);
    objects.add(instance);
    notifyListeners();
  }

  void _deleteObj(Obj obj){ /* オブジェクトリストからobjを削除 */
    final index = _findObjectsIndexFromPath(obj.path);
    objects.removeAt(index);
    notifyListeners();
  }

  void _convertDirListToObjList(List<FileSystemEntity> dirList){ /* OSから取得したdirリストをobjリストに変換 */
    for(var f in dirList){
      if(!_isAleadyAddedObjectsList(f.path)){
        _appendObj(f);
        } //過去に登録したことがないファイルは登録
      else{
        final instance = _convertObjFromFileSystemEntity(f);
        _updateObj(instance);
      }
    }
    for(var obj in objects){//objectリストを全探索
      final index = dirList.indexWhere((d) => d.path == obj.path); //dirリストにobjパスがあるか確認
      if(index == -1) _deleteObj(obj); //見つからなかったら削除
    }
  }

  Obj _convertObjFromFileSystemEntity(FileSystemEntity f){ /* システムエンティティをオブジェ型に変換 */
    final name = p.basename(f.path);
    final type = ObjType.clock; //判定は後で実装
    final extention = p.extension(f.path);
    final x = 0.0; //ここも後で実装
    final y = 0.0; //ここも後で実装

    final instance = Obj(f.path,name,type,extention,x,y);
    return instance;
  }

  int _findObjectsIndexFromPath(String path){ /* pathが既存オブジェクトリストに登録済みならそのインデックスを返す */
    final index = objects.indexWhere((d)=> d.path == path);
    return index; //見つからない場合-1を返す
  }

  bool _isAleadyAddedObjectsList(String path){ /* 過去に読み込んだディレクトリ情報かを判定 */
    final index = _findObjectsIndexFromPath(path);
    return index != -1 ? true: false;
  }
}

class TestView extends StatelessWidget{
  final store = ObjDatabaseStore();

  TestView({super.key});
    @override
    Widget build(BuildContext context) {
        // TODO: implement build
        return Scaffold(
            body: Center(
                child: Column(
                  children: [
                    IconButton(onPressed: ()=>{store.fetchObjects()}, icon: Icon(Icons.access_alarm_outlined)),
                  ],
                ),
            )
        );
    }
}