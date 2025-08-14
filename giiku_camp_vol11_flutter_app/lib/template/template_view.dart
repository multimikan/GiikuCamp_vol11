/*
静的viewのテンプレートを作っときました🦔
適宜コピペして新しいファイルを作ってください！
動的なviewの作り方については適宜学習か質問をお願いします。
ファイル名: ○○_view
クラス名: ClassNameViewのようなキャメルケースの命名をお願いします。
*/

import 'package:flutter/material.dart';

class TemplateView extends StatelessWidget{
    const TemplateView({super.key});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.black,
            ),
            body: Center(
                child: Column(
                    children: [
                        Text("テンプレートビュー")
                    ],
                ),
            ),
        );
    }
}