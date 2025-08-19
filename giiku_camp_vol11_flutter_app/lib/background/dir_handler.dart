import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io';
import 'package:path/path.dart' as p; 

class DirHandler extends ChangeNotifier{
  Future<void> rename(FileSystemEntity f, String name) async{
    final store = await ObjDatabaseStore.init();
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
    await store.fetchObjects();
    notifyListeners();
  }

  Future<void> move(FileSystemEntity f, String newPath) async {
    final store = await ObjDatabaseStore.init();
    store.fetchObjects();

    await f.rename(newPath);

    await store.fetchObjects();
    notifyListeners();
  }

  Future<void> del(FileSystemEntity f) async {
    final store = await ObjDatabaseStore.init();
    store.fetchObjects();
    
    await f.delete();

    await store.fetchObjects();
    notifyListeners();
  }
}