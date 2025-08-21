import 'dart:io'; 
import 'dart:ui' as ui;  
import 'package:flutter/material.dart';                                  
import 'package:flutter/services.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_view.dart';
import 'package:giiku_camp_vol11_flutter_app/zunda_room/zunda_room_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

class AppConfig {
  static late double windowWidth;
  static late double windowHeight;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final ByteData data = await rootBundle.load('images/home1(R).png');
  final ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final ui.FrameInfo frame = await codec.getNextFrame();
  double windowWidth = frame.image.width.toDouble()*0.4;
  double windowHeight = frame.image.height.toDouble()*0.4;

  if (Platform.isWindows|| Platform.isMacOS || Platform.isLinux){
    setWindowTitle('Image Sized Window');
    setWindowMaxSize(Size(windowWidth, windowHeight));
    setWindowMinSize(Size(windowWidth, windowHeight));
    setWindowFrame(Rect.fromLTWH(100, 100, windowWidth, windowHeight));
  }

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_)=>ZundaRoomViewModel()),
    ],
    child: const MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    AppConfig.windowWidth = screenWidth;
    AppConfig.windowHeight = screenHeight;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ZundaRoomView(),
    );
  }
}
