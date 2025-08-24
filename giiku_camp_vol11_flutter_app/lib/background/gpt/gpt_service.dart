import 'dart:convert';
import 'package:giiku_camp_vol11_flutter_app/background/gpt/gpt_environment.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class GPTTerminal {
  final GptEnvironment environment = GptEnvironment();
  // 安全のためホワイトリストを作る
    final allowed = [
    "ls", "pwd", "cat", "less", "head", "tail", "stat",
    "grep", "find", "wc", "sort", "uniq",
    "whoami", "id", "date", "uptime", "df", "du", "free", "top", "ps",
    "uname", "hostname",
    "ping", "curl", "wget", "ifconfig", "netstat"
  ];

  Future<Map<String, dynamic>> sendMessage(String message) async{
    const endpoint = "https://api.openai.com/v1/chat/completions";

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${environment.key}",
      },
      body: jsonEncode({
        "model": environment.model,
        "messages": [
          {"role": "system", "content": "あなたはずんだもんという名前なのだ。口調はこんな感じなのだ。ユーザーのアシスタントをよろしく頼むのだ！"},
          {"role": "system", "content": "一人称はボクなのだ！！ボクの語尾は絶対「なのだ」なのだ！！"},
          {"role": "system", "content": "出力は必ず以下のようなJSON形式で行うこと。"},
          {"role": "system", "content": "{\"command\": \"ls -la\",\"res\": \"ずんだもん口調で返答をお願いするのだ！\"}"},
          {"role": "system", "content": "ユーザーのプロンプトに対して適切なファイル操作コマンドを考え、、commandに$allowed内のコマンドを含む柔軟なコマンド、resにはずんだもん口調で説明を。"},
          {"role": "system", "content": "客観的に考え、、ユーザーに危険が及ぶと判断した場合、さらに、$allowed以外のコマンドが必要な場合はコマンドを生成せず、resにセキュリティ上できない旨を返答のこと。"},
          {"role": "system", "content": "ユーザーが対話を求めた際はコマンドを生成せず、JSON形式でresにずんだもんらしく質問の趣旨に合わせて柔軟に返答のこと。"},
          {"role": "system", "content": "使えるコマンドはresで説明しないで。"},
          {"role": "user", "content": message},
        ],        // nucleus sampling。1.0なら無効、0.9なら上位90%まで
      }),
    );

    if(response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dataDart = data["choices"][0]["message"]["content"] as String;
      final dataDartMap = jsonDecode(dataDart);
      return dataDartMap;
    } else {
      throw Exception("Failed to load response: ${response.body}");
    }
  }

  Future<void> runCommand(String jsonResponse) async {
    final data = jsonDecode(jsonResponse);
    final cmd = data["command"];

    final executable = cmd.split(" ")[0];

    if (!allowed.contains(executable)) {
      print("⚠️ このコマンドは許可されていません: $executable");
      return;
    }

    // 実行
    final result = await Process.run("bash", ["-c", cmd]);
    print(result.stdout);
    if (result.stderr.isNotEmpty) {
      print("エラー: ${result.stderr}");
    }
  }
}

/*
void main() async {
  final gpt = GPTTerminal();

  final reply = await gpt.askGPT("カレントディレクトリを一覧表示して");
  print("GPTの返答: $reply");

  await gpt.runCommand(reply);
}
*/