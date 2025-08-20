import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io';
import 'package:path/path.dart' as p; 
import 'package:win32/win32.dart';

class DirHandler extends ChangeNotifier{
  Future<void> rename(FileSystemEntity f, String name) async{
    final store = await ObjDatabaseStore.init();
    final dirName = p.dirname(f.path);
    final extension = p.extension(f.path);
    final sr = Platform.isWindows ? "\\" : "/";

    if(p.extension(f.path)!='') {
      try{
        final newPath = '$dirName$sr$name$extension';
        print("リネームpath:$newPath");
        await f.rename(newPath);
      }catch(e){
        print("エラー：$e");
      }
    }
    else{
      try{
        final newPath = '$dirName$sr$name';
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
    final String trushPath;
    store.fetchObjects();
    
    if(Platform.isWindows) {trushPath = _getWinTrush();}
    else {trushPath = "${Platform.environment["HOME"]}/.Trush";}

    await move(f, trushPath);

    await store.fetchObjects();
    notifyListeners();
  }

  String _getWinTrush(){
    final buffer = wsalloc(MAX_PATH);
    SHGetFolderPath(0, CSIDL_BITBUCKET, 0, 0, buffer);
    final path = buffer.toDartString();
    free(buffer);
    return path;
  }
}