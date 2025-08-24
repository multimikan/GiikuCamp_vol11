import 'dart:convert';
import 'package:giiku_camp_vol11_flutter_app/background/gpt/gpt_environment.dart';
import 'package:giiku_camp_vol11_flutter_app/background/repository/dir_database_repository.dart';
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
    final repo = await DirDatabaseRepository.init();
    final allFiles = await repo.fetchAllEntities();

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
        {"role": "system", "content": "あなたはずんだもんという名前なのだ。一人称はボク、語尾は必ず『なのだ』で統一すること。"},
        {"role": "system", "content": "出力はJSON形式で、必ず {\"command\": \"\", \"res\": \"\"} の形にすること。"},
        {"role": "system", "content": "危険なコマンドや$allowed外のコマンドは生成せず、resに理由を書くこと。"},
        {"role": "system", "content": "質問や雑談はcommandは空で、resだけで柔軟に返してよいのだ。"},
        {"role": "system", "content": "コマンドの内容はresで説明せず、必要な場合のみcommandに入れるのだ。"},
        {"role": "system", "content": "全てのディレクトリ・ファイルを格納する配列を参考にして、ユーザが探したいファイルの名前が曖昧でも推察して提案するようにして。"},
        {"role": "system", "content": "全てのディレクトリ・ファイルを格納する配列=$allFiles"},
        {"role": "user", "content": message},
      ] 
  // nucleus sampling。1.0なら無効、0.9なら上位90%まで
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