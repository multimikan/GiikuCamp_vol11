/*

家具のデータベースを扱うファイル

*/

import 'package:flutter/material.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';


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
    final repo = DirDatabaseRepository();

    void fetchObjects(){ /* パソコンのディレクトリ情報と同期して家具リストを更新 */
        repo.fetchDirectory();
        print(repo.dirList);
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