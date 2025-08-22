/*

家具のデータベースを扱うファイル
永続保存の機能はまだない
(ターゲットチェンジでデータが損失する問題あり)

*/
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/main.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/image_helper.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';



class Obj{ /* Model */
  String path; /*ディレクトリの絶対パスを取得*/
  String name;
  Widget image;
  String extention;
  Location location;
  Obj(this.path, this.name, this.image, this.extention, this.location);

  dynamic field(String key) { /* 構造体の要素を文字列を受け取って変換し返す */
    switch(key){
      case "x":
        return location.x;
      case "y":
        return location.y;
    }
  }
}

class ObjDatabaseStore{
  static Map<String,List<Obj>> history = {};
  static List<Obj> objects = [];
  late DirDatabaseRepository repo;

  /*
  methodName() <- viewで使っても良い
  _methodName() <- viewで使ってはいけない
  */

  ObjDatabaseStore._(this.repo);

  static Future<ObjDatabaseStore> init() async{
    var s = await DirDatabaseRepository.init();
    return ObjDatabaseStore._(s);
  }

  /*別クラスでfetchObjectを使うときはasync{await fetchObject}を推奨(特に同期が重要な場面では必須)*/
  Future<void> fetchObjects([Directory? target]) async { /* パソコンのディレクトリ情報と同期して家具リストを更新 */
    target = target?? await getApplicationDocumentsDirectory();
    repo.fetchDirectory(target); //同期関数のためawait必要なし
    /*
    -更新後に必要な判定-
    1.オブジェクトリストにない新規fileをオブジェクトリストに追加
    2.オブジェクトリストにはあるがディレクトリ情報にないものをオブジェクトリストから削除
    */

    if(history.containsKey(target.path)) objects = history[target.path]!; //hitstoryにターゲットパスが存在すればobjectsを置き換え

    _convertDirListToObjList(repo.dirList); // 1 & 2

    history[target.path] = objects; //path:objects

    for(var i = 0; i< objects.length; i++){
      print(objects[i].path);
      print(objects[i].location.x);
      print(objects[i].location.y);
    }
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

  void _convertDirListToObjList(List<FileSystemEntity> dirList){ /* OSから取得したdirリストをobjリストに変換 */
    for(var f in dirList){
      if(!_isAleadyAddedObjectsList(f.path)){
        _appendObj(f);
        } //過去に登録したことがないファイルは登録
      else{
        final index = _findObjectsIndexFromPath(f.path);
        _updateObj(objects[index]);
      }
    }
    final toDelete = <Obj>[]; // 削除対象集め
    for (var obj in objects) {
      final index = dirList.indexWhere((d) => d.path == obj.path);
      if (index == -1) toDelete.add(obj);
    }
    for (var obj in toDelete) {// 削除フェーズ
      _deleteObj(obj);
    }
  }

  void _updateObj(Obj obj, [String? name, Widget? image, String? extension, int? x, int? y]){ /*既存のオブジェクトを更新*/
    final index = _findObjectsIndexFromPath(obj.path);

    name = name ?? obj.name;
    image = image ?? obj.image;
    extension = extension ?? obj.extention;
    x = x ?? obj.location.x;
    y = y ?? obj.location.y;

    final instance = Obj(obj.path, name, image, extension, Location(x,y));
    objects[index] = instance;
  }

  void _appendObj(FileSystemEntity f){ /* 新規オブジェクトを追加 */
    final instance = _convertObjFromFileSystemEntity(f);
    objects.add(instance);
  }

  void _deleteObj(Obj obj){ /* オブジェクトリストからobjを削除 */
    final index = _findObjectsIndexFromPath(obj.path);
    objects.removeAt(index);
  }

  Obj _convertObjFromFileSystemEntity(FileSystemEntity f){ /* システムエンティティをオブジェ型に変換 */
    final name = p.basename(f.path);
    final image = ImageHelper.resize(Image.asset(ImageHelper.convertImageTypeFromExtention(p.extension(f.path))),10);
    final extention = p.extension(f.path);

    final notAlreadyAddedPlacesMap = _getPlace(f);
    final x = notAlreadyAddedPlacesMap["x"];
    final y = notAlreadyAddedPlacesMap["y"];

    final instance = Obj(f.path,name,image,extention,Location(x!,y!));
    return instance;
  }

  int _findObjectsIndexFromPath(String path){ /* pathが既存オブジェクトリストに登録済みならそのインデックスを返す */
    final index = objects.indexWhere((d)=> d.path == path);
    return index; //見つからない場合-1を返す
  }
  
  bool _isAddedPlaceFromObjects(String xyz, int place){ /* objectsにすでにxyzが格納済みかを判定 */
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

  Map<String, int> _getPlace(FileSystemEntity f) {
  const int margin = 5; // 座標の誤差

  int x;
  int y;

  if (p.extension(f.path) == "") {
    x = _dirPlace()["x"]!;
    y = _dirPlace()["y"]!;
  } else {
    x = _filePlace()["x"]!;
    y = _filePlace()["y"]!;
  }

  for (int i = -margin; i <= margin; i++) {
    if (!_isAddedPlaceFromObjects("x", x + i) &&
        !_isAddedPlaceFromObjects("y", y + i)) {
      print("x:${x + i}, y:${y + i}");
      return {"x": x + i, "y": y};
    }
  }

  return {"x": x, "y": y};
}


  Map<String,int> _dirPlace(){
    final y = ZundaRoomViewModel.home!.door_Y; 
    final x = Random().nextInt(100)+10;
    return {"x":x,"y":y};
  }

  Map<String,int> _filePlace(){
    final margin = 100;
    final floorY = ZundaRoomViewModel.home!.floor_y; 
    final floorX = ZundaRoomViewModel.home!.floor_x; 
    final y = Random().nextInt(floorY["max"]!-margin)+floorY["min"]!; 
    final x = Random().nextInt(floorX["max"]!-margin)+floorX["min"]!; 
    return {"x":x,"y":y};
  }
}

class TestView extends StatefulWidget{
  const TestView({super.key});

  @override
  _TestViewState createState()=>_TestViewState();
}

class _TestViewState extends State<TestView>{
  late ObjDatabaseStore store;
  bool loaded = false;
  bool initialized = false;

  @override
  void initState(){
    super.initState();
    _loadObjects();
  }

  Future<void> _loadObjects()async{
    store = await ObjDatabaseStore.init();
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
                    left: (o.location.x).toDouble(),
                    top: (o.location.y).toDouble(),
                    child: Container(
                      decoration: BoxDecoration(),
                      child: Text(o.name),
                    ),
                  ),
                Positioned(
                left: 30,
                top: 30,
                child: Container(
                  width: 100,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.amber
                  ),
                  child: TextButton(onPressed: ()=>{
                    store.fetchObjects(),
                    setState(() {})
                  }, child: Text("fetch")),
                ),
                )
              ],
            ),
        )
    );
  }
}