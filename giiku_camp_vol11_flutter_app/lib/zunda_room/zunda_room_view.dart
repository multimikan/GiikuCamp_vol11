/*
動的なviewの作り方については適宜学習か質問をお願いします。
ファイル名: ○○_view
クラス名: ClassNameViewのようなキャメルケースの命名をお願いします。
*/

import 'package:flutter/material.dart';

class ZundaRoomView extends StatelessWidget{
  const ZundaRoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
      ),
      body: Center(
          child: Container()
      ),
    );
  }
}