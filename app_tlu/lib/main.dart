import 'package:flutter/material.dart';
import 'api/api_client.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/token_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Kiểm tra token đã lưu
  final savedToken = await TokenStorage.getAccessToken();
  if (savedToken != null && savedToken.isNotEmpty) {
    ApiClient.setToken(savedToken);
  }

  runApp(MyApp(initialToken: savedToken));
}

class MyApp extends StatelessWidget {
  final String? initialToken;
  const MyApp({super.key, this.initialToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TLU Mobile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: initialToken != null && initialToken!.isNotEmpty
          ? const MainScreen()
          : const LoginScreen(),
    );
  }
}
