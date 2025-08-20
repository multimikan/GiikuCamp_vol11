import 'dart:io';

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/dir_handler.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
import 'package:giiku_camp_vol11_flutter_app/background/store/obj_database_store.dart';
import 'dart:io';

class FileHandlingMenuViewmodel extends DirHandler{
  final repo = DirDatabaseRepository.init();

  Future<void> moveObj(Obj obj, String newPath) async {
    final repository = await repo;
    FileSystemEntity f = await repository.convertFileSystemEntityFromObj(obj);
    await super.move(f, newPath);
  }
}