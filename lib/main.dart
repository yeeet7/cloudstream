
import 'package:cloudstream/bookmark.dart';
import 'package:cloudstream/downloads.dart';
import 'package:cloudstream/home.dart';
import 'package:cloudstream/search.dart';
import 'package:cloudstream/settings.dart';
import 'package:cloudstream/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await MovieProvider.init();
  await Hive.initFlutter();
  await Hive.openBox('config');
  await Hive.openBox('downloadPosters');
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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212)),
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
          var state = mainNavKey.currentState?.canPop();
          if(state == true) {
            mainNavKey.currentState?.pop(context);
            return false;
          } else if(state == false && selected != 0) {
            setState(() {
              selected = 0;
              mainNavKey.currentState?.pushReplacementNamed('home');
            });
            return false;
          }
          return true;
        },
        child: Navigator(
          key: mainNavKey,
          initialRoute: 'home',
          onGenerateRoute: (settings) {
            if(settings.name == 'home') {return MaterialPageRoute(builder: (context) => const Home(key: ValueKey(0)));}
            else if(settings.name == 'search') {return MaterialPageRoute(builder: (context) => const Search(key: ValueKey(1)));}
            else if(settings.name == 'bookmarks') {return MaterialPageRoute(builder: (context) => const BookmarkWidget(key: ValueKey(2)));}
            else if(settings.name == 'downloads') {return MaterialPageRoute(builder: (context) => const Downloads(key: ValueKey(3)));}
            else if(settings.name == 'settings') {return MaterialPageRoute(builder: (context) => const Settings(key: ValueKey(4)));}
            else {return MaterialPageRoute(builder: (context) => Scaffold(body: Center(child: Text('"${settings.name}" route not found'),),));}
          }
        ),
      ),
    
      bottomNavigationBar: BottomNavBar(
        selected: selected,
        items: [
          BottomNavBarItem(PictureIcon('assets/home.png'), onTap: () {if(selected != 0) {mainNavKey.currentState?.pushReplacementNamed('home'); setState(() => selected = 0);}}),
          BottomNavBarItem(PictureIcon('assets/search.png'), onTap: () {if(selected != 1) {mainNavKey.currentState?.pushReplacementNamed('search'); setState(() => selected = 1);}}),
          BottomNavBarItem(PictureIcon('assets/bookmark.png'), onTap: () {if(selected != 2) {mainNavKey.currentState?.pushReplacementNamed('bookmarks'); setState(() => selected = 2);}}, onLongTap: () async {await Hive.box<List<MovieInfo>>('bookmarks').deleteFromDisk();},),
          BottomNavBarItem(PictureIcon('assets/download.png'), onTap: () {if(selected != 3) {mainNavKey.currentState?.pushReplacementNamed('downloads'); setState(() => selected = 3);}}),
          BottomNavBarItem(PictureIcon('assets/settings.png'), onTap: () {if(selected != 4) {mainNavKey.currentState?.pushReplacementNamed('settings'); setState(() => selected = 4);}}),
          // BottomNavigationBarItem(label: 'home', icon: PictureIcon('assets/home.png')),
        ],
      ),

    );
  }
}