
import 'package:cloudstream/bookmark.dart';
import 'package:cloudstream/home.dart';
import 'package:cloudstream/search.dart';
import 'package:cloudstream/widgets.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await MovieProvider.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CloudStream',
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF3e51ef),
          secondary: Colors.grey.shade700,
        ),
        primaryColor: const Color(0xFF3e51ef),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xFF121212))
      ),
      home: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {

  int selected = 0;
  GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: WillPopScope(
        onWillPop: () async {
          var state = mainNavKey.currentState;
          state?.pop();
          if(state == null) {
            return true;
          }
          return false;
        },
        child: Navigator(
          key: mainNavKey,
          onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => const Home()),
        ),
      ),
    
      bottomNavigationBar: BottomNavBar(
        selected: selected,
        items: [
          BottomNavBarItem(PictureIcon('assets/home.png'), onTap: () {setState(() => selected = 0); mainNavKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const Home()));}),
          BottomNavBarItem(PictureIcon('assets/search.png'), onTap: () {setState(() => selected = 1); mainNavKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const Search()));}),
          BottomNavBarItem(PictureIcon('assets/bookmark.png'), onTap: () {setState(() => selected = 2); mainNavKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const BookmarkWidget()));}),
          BottomNavBarItem(PictureIcon('assets/download.png'), onTap: () {setState(() => selected = 3); mainNavKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const Home()));}),
          BottomNavBarItem(PictureIcon('assets/settings.png'), onTap: () {setState(() => selected = 4); mainNavKey.currentState?.pushReplacement(MaterialPageRoute(builder: (context) => const Home()));}),
          // BottomNavigationBarItem(label: 'home', icon: PictureIcon('assets/home.png')),
        ],
      ),

    );
  }
}