/*

家具のデータベースを扱うファイル
永続保存の機能はまだない
(ターゲットチェンジでデータが損失する問題あり)

*/
import 'dart:io';
import 'dart:math';
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
  int x;
  int y;
  Obj(this.path, this.name, this.type, this.extention, this.x, this.y);

  dynamic field(String key) { /* 構造体の要素を文字列を受け取って変換し返す */
    switch(key){
      case "x":
        return x;
      case "y":
        return y;
    }
  }

}


class ObjDatabaseStore extends ChangeNotifier{
  static List<Obj> objects = [];
  late DirDatabaseRepository repo;

  /*
  methodName() <- viewで使っても良い
  _methodName() <- viewで使ってはいけない
  */

  Future<void> init() async{
    repo = await DirDatabaseRepository.init();
  }

  /*別クラスでfetchObjectを使うときはasync{await fetchObject}を推奨(特に同期が重要な場面では必須)*/
  Future<void> fetchObjects([Directory? target]) async { /* パソコンのディレクトリ情報と同期して家具リストを更新 */
    await init(); //イニシャライズ完了まで待機
    repo.fetchDirectory(target); //同期関数のためawait必要なし
    /*
    -更新後に必要な判定-
    1.オブジェクトリストにない新規fileをオブジェクトリストに追加
    2.オブジェクトリストにはあるがディレクトリ情報にないものをオブジェクトリストから削除
    */
    _convertDirListToObjList(repo.dirList); // 1 & 2
    for(var i = 0; i< objects.length; i++){
      print(objects[i].path);
      print(objects[i].x);
      print(objects[i].y);
    }
    notifyListeners();
  }

  Future<void> changeTarget(String targetPass) async { /* 引数の型は扱いやすいように変えて良い */
    await fetchObjects(Directory(targetPass));
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

  void _updateObj(Obj obj, [String? name, ObjType? type, String? extension, int? x, int? y]){ /*既存のオブジェクトを更新*/
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

    final notAlreadyAddedPlacesMap = _getPlace();
    final x = notAlreadyAddedPlacesMap["x"];
    final y = notAlreadyAddedPlacesMap["y"];

    final instance = Obj(f.path,name,type,extention,x!,y!);
    return instance;
  }

  int _findObjectsIndexFromPath(String path){ /* pathが既存オブジェクトリストに登録済みならそのインデックスを返す */
    final index = objects.indexWhere((d)=> d.path == path);
    return index; //見つからない場合-1を返す
  }
  
  bool _isAddedPlaceFromObjects(String xyz, double place){ /* objectsにすでにxyzが格納済みかを判定 */
    var isAdded = false;
    for(var o in objects){ /* objectsを全探索 */
      if (o.field(xyz) == place) isAdded = true;
    }
    return isAdded;
  }



  bool _isAleadyAddedObjectsList(String path){ /* 過去に読み込んだディレクトリ情報かを判定 */
    final index = _findObjectsIndexFromPath(path);
    return index != -1 ? true: false;
  }

  Map<String,int> _getPlace(){ /* 床とか壁の判定はまだ未実装 */
    final double margin = 5.0; /* 座標の誤差 */
    var x = Random().nextInt(721);
    var y = Random().nextInt(721);
    for(var i = -margin; i<margin; i++){ // O(n*margin)のため動作が重いかも
      if(_isAddedPlaceFromObjects("x", x+i) || _isAddedPlaceFromObjects("y", y+i)) continue;
    }
    return {"x":x,"y":y};
  }
}

class TestView extends StatefulWidget{
  const TestView({super.key});

  @override
  _TestViewState createState()=>_TestViewState();
}

class _TestViewState extends State<TestView>{
  final store = ObjDatabaseStore();
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    _loadObjects();
  }

  Future<void> _loadObjects()async{
    await store.fetchObjects();
    setState(() {
      loaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
      // TODO: implement build

    if(!loaded){
    return Scaffold(
      body: Center(child: CircularProgressIndicator(),)
    );
    }
    
    return Scaffold(
        body: Center(
            child: Stack(
              children: [
                for(var o in ObjDatabaseStore.objects)
                  Positioned(
                    left: (o.x).toDouble(),
                    top: (o.y).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Text(o.name),
                    ),
                  ),

                Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.amber
                  ),
                  child: TextButton(onPressed: ()=>{
                    _loadObjects()
                  }, child: Text("fetch")),
                ),
              ],
            ),
        )
    );
  }
}