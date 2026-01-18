import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'screens/vibration_table_screen.dart';
import 'screens/board_screen.dart';
import 'screens/settings_screen.dart';
import 'package:provider/provider.dart'; // import 추가
import 'services/vibration_service.dart'; // import 추가
import 'services/auth_service.dart';
import 'services/board_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(
      MultiProvider(
        providers : [
          ChangeNotifierProvider(create: (_) => VibrationService()),
          ChangeNotifierProvider(create: (_) => BoardService()),
          ChangeNotifierProvider(create: (_) => AuthService()..signInAnonymously()),
        ],
        child: const DoDream(),
      ),
  );
}

class DoDream extends StatelessWidget {
  const DoDream({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DoDream',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // [토스 스타일 핵심 1] 배경색은 완전 흰색이 아닌 연한 회색 (#F2F4F6)
        scaffoldBackgroundColor: const Color(0xFFF2F4F6),

        // [색상 팔레트] 계획서의 민트색을 메인으로 하되, 채도를 조절하여 세련되게
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00C7D1),
          primary: const Color(0xFF00C7D1),
          surface: Colors.white,
        ),

        useMaterial3: true,
        fontFamily: 'Pretendard', // 폰트가 없으면 기본 폰트가 적용됨

        // [앱바 스타일] 그림자 없이 깔끔하게
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F4F6), // 배경색과 통일
          scrolledUnderElevation: 0,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    VibrationTableScreen(),
    BoardScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),

      // [토스 스타일 핵심 2] 하단 탭바는 깔끔하고 심플하게
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: '진동표'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: '게시판'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: '설정'), // 설정은 마이페이지 느낌으로
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFF00C7D1),
          unselectedItemColor: const Color(0xFFB0B8C1), // 비활성 아이콘은 연한 회색
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}