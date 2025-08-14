/*

家具のデータベースを扱うファイル

*/

import 'package:flutter/material.dart';


enum ObjType{ /*家具の種類*/
    door,
    clock
}

enum ObjExtention{ /*拡張子*/
    directory,
    file
}

class Obj{
    final int id; /*ディレクトリ固有のidを取得*/
    String name;
    ObjType type;
    ObjExtention extention;
    Obj(this.id, this.name, this.type, this.extention);
}

class ObjDatabaseStore extends ChangeNotifier{
    static List<Obj> objects = [];

    void fetchObjects(){ /* パソコンのディレクトリ情報と同期して家具リストを更新 */

    }
}