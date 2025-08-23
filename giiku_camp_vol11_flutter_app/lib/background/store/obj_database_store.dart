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
  FileSystemEntity original;
  Obj(this.path, this.name, this.image, this.extention, this.location, this.original);

  dynamic field(String key) { /* 構造体の要素を文字列を受け取って変換し返す */
    switch(key){
      case "x":
        return location.x;
      case "y":
        return location.y;
    }
  }
}

class History{
  String path;
  List<Obj> objects;
  HomeType homeType;
  History(this.path,this.objects,this.homeType);
}

class ObjDatabaseStore{
  static List<History> history = [];
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
    final existing = history.indexWhere((h) => h.path == target!.path);
    if(existing!=-1) objects = history[existing].objects;//hitstoryにターゲットパスが存在すればobjectsを置き換え

    _convertDirListToObjList(repo.dirList); // 1 & 2

    if(existing!=-1) {history[existing].objects = objects;} //path:objects
    else {history.add(History(target.path, objects, HomeType.values.byName("home${Random().nextInt(2)+1}")));}

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

    final instance = Obj(obj.path, name, image, extension, Location(x,y),obj.original);
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
    Widget image = Image.asset(ImageUtils.fromExtension(p.extension(f.path))); 
    if(f is File) image = ImageUtils.resize(image,10);
    else if(f is Directory) image = ImageUtils.resize(image,60); //ドアリサイズ
    final extention = p.extension(f.path);

    final notAlreadyAddedPlacesMap = _getPlace(f);
    final x = notAlreadyAddedPlacesMap["x"];
    final y = notAlreadyAddedPlacesMap["y"];

    final instance = Obj(f.path,name,image,extention,Location(x!,y!),f);
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
    double m = AppConfig.windowWidth*0.1;
    int margin = m.toInt();
    const int maxTry = 1000;

    int x, y;
    int tries = 0;

    while (true) {
      final fp = _filePlace();
      if (p.extension(f.path) == "") {
        x = _dirPlace()["x"]!;
        y = _dirPlace()["y"]!;
      } else {
        x = fp["x"]!;
        y = fp["y"]!;
      }

      bool collide = false;
      for (var o in objects) {
        final dx = (o.location.x - x).abs();
        final dy = (o.location.y - y).abs();
        if (dx < margin && dy < margin) {
          collide = true;
          break;
        }
      }

      if (!collide) {
        return {"x": x, "y": y};
      }

      tries++;
      if (tries > maxTry) {
        return {"x": x, "y": y};
      }
    }
  }

  Map<String,int> _dirPlace(){
    final tmp = ZundaRoomViewModel.home!;
    final y = tmp.doorY;
    final maxX = tmp.floorX["max"] ?? 0;
    final minX = tmp.floorX["min"] ?? 0;
    final x = Random().nextInt(maxX-minX)+minX;
    return {"x":x.toInt(),"y":y.toInt()};
  }

  Map<String,int> _filePlace(){
    final tmp = ZundaRoomViewModel.home!;
    final maxY = tmp.floorY["max"] ?? 0;
    final minY = tmp.floorY["min"] ?? 0;
    final maxX = tmp.floorX["max"] ?? 0;
    final minX = tmp.floorX["min"] ?? 0;
    final y = Random().nextInt(maxY-minY)+minY; 
    final x = Random().nextInt(maxX-minX)+minX; 
    return {"x":x.toInt(),"y":y.toInt()};
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