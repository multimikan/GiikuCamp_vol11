import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/dir_handler.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class FileHandlingMenuViewmodel extends DirHandler{
  final repo = DirDatabaseRepository.init();

  Future<void> openObj(Obj obj) async {
    await OpenFile.open(obj.path);
  }
  Future<void> renameObj(Obj obj, String newPath) async {
    final repository = await repo;
    FileSystemEntity f = await repository.convertFileSystemEntityFromObj(obj);
    await super.rename(f, newPath);
  }
  Future<void> moveObj(Obj obj, String newPath) async {
    final repository = await repo;
    FileSystemEntity f = await repository.convertFileSystemEntityFromObj(obj);
    await super.move(f, newPath);
  }
  Future<void> delObj(Obj obj) async {
    final repository = await repo;
    FileSystemEntity f = await repository.convertFileSystemEntityFromObj(obj);
    await super.del(f);
  }
}