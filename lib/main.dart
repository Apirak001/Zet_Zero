import 'package:flutter/foundation.dart'; // เพิ่มสำหรับ kIsWeb
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:device_frame/device_frame.dart'; // เพิ่มสำหรับกรอบมือถือ
import 'firebase_options.dart';
import 'controllers/game_controller.dart';

import 'views/loading_view.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => GameController())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zet Zero',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // ใส่ builder หุ้มเฉพาะตอนรันบน Web (เครื่องคุณ)
      // ถ้าเพื่อนนำไปรันบน Android จะเป็นหน้าจอปกติทันทีครับ
      builder: (context, child) {
        if (kIsWeb) {
          return DeviceFrame(
            device: Devices
                .ios
                .iPhone16ProMax, // เปลี่ยนเป็น 16 Pro Max ตามคำขอ
            isFrameVisible: true,
            orientation: Orientation.portrait,
            screen: child!,
          );
        }
        return child!;
      },
      home: const LoadingView(),
    );
  }
}
