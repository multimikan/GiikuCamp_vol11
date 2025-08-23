import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io';
import 'package:path/path.dart' as p; 
import 'package:win32/win32.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';

class DirHandler extends ChangeNotifier{
  final sr = Platform.isWindows ? "\\" : "/";
  Future<void> rename(FileSystemEntity f, String name) async{
    String path = DirDatabaseRepository.target.path;
    Directory dir = Directory(path);
    final store = await ObjDatabaseStore.init();
    final dirName = p.dirname(f.path);
    final extension = p.extension(f.path);

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
    await store.fetchObjects(dir);
    notifyListeners();
  }

  Future<void> move(FileSystemEntity f, String newPath) async {
    String path = DirDatabaseRepository.target.path;
    Directory dir = Directory(path);
    final store = await ObjDatabaseStore.init();
    store.fetchObjects(dir);

    await f.rename("$newPath$sr${p.basename(f.path)}");

    await store.fetchObjects(dir);
    notifyListeners();
  }

  Future<void> del(FileSystemEntity f) async {
    String path = DirDatabaseRepository.target.path;
    Directory dir = Directory(path);
    final store = await ObjDatabaseStore.init();
    store.fetchObjects(dir);
    
    try {
      if (f is Directory) {
        await f.delete(recursive: true);
      } else if (f is File) {
        await f.delete();
      }
      print("削除成功: ${f.path}");
    } catch (e) {
      print("削除失敗: $e");
    }

    await store.fetchObjects(dir);
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