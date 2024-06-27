
import 'package:cloudstream/view/primary/bookmark.dart';
import 'package:cloudstream/view/primary/downloads.dart';
import 'package:cloudstream/view/primary/home.dart';
import 'package:cloudstream/view/primary/search.dart';
import 'package:cloudstream/view/primary/settings.dart';
import 'package:cloudstream/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Hive.initFlutter();
  await Hive.openBox('config');
  await Hive.openBox('downloadPosters');
  await MovieProvider.init(Hive.box('config').get('include_adult') ?? false);
  await Permission.storage.isGranted == false ? await Permission.storage.request():null;
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
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF121212)),
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF3e51ef), //TODO: change to bottomnavbar color
          secondary: Color(0xFF616161),
        ),
        primaryColor: const Color(0xFF3e51ef),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xFF121212))
      ),
      home: const Main(),
    );
  }
}

int selected = 0;
GlobalKey<NavigatorState> mainNavKey = GlobalKey<NavigatorState>();

class Main extends StatefulWidget {
  const Main({super.key});

  static Future<void> pushHome() async {while(mainNavKey.currentState?.canPop() ?? false) {mainNavKey.currentState?.pop();} selected = 0; await mainNavKey.currentState?.pushReplacementNamed('home');}
  static Future<void> pushSearch() async {while(mainNavKey.currentState?.canPop() ?? false) {mainNavKey.currentState?.pop();} selected = 1; await mainNavKey.currentState?.pushReplacementNamed('search');}
  static Future<void> pushBookmarks() async {while(mainNavKey.currentState?.canPop() ?? false) {mainNavKey.currentState?.pop();} selected = 2; await mainNavKey.currentState?.pushReplacementNamed('bookmarks');}
  static Future<void> pushDownloads() async {while(mainNavKey.currentState?.canPop() ?? false) {mainNavKey.currentState?.pop();} selected = 3; await mainNavKey.currentState?.pushReplacementNamed('downloads');}
  static Future<void> pushSettings() async {while(mainNavKey.currentState?.canPop() ?? false) {mainNavKey.currentState?.pop();} selected = 4; await mainNavKey.currentState?.pushReplacementNamed('settings');}

  @override
  State<Main> createState() => _MainState();
}

GlobalKey mainStateKey = GlobalKey<_MainState>();
class _MainState extends State<Main> {

  Future<void> test() async {}

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
            return MaterialPageRoute(
              builder: (context) => (settings.name == 'home' ? const Home(key: PageStorageKey(0)):
                settings.name == 'search' ? const Search(key: PageStorageKey(1)):
                settings.name == 'bookmarks' ? const BookmarkWidget(key: PageStorageKey(2)):
                settings.name == 'downloads' ? const Downloads(key: PageStorageKey(3)):
                settings.name == 'settings' ? const Settings(key: PageStorageKey(4)):
                Scaffold(body: Center(child: Text('"${settings.name}" route not found'),),))
            );
          }
        ),
      ),
    
      bottomNavigationBar: BottomNavBar(
        selected: selected,
        items: [
          BottomNavBarItem(PictureIcon('assets/home.png'), onTap: () async {await Main.pushHome(); setState((){});}),
          BottomNavBarItem(PictureIcon('assets/search.png'), onTap: () async {await Main.pushSearch(); setState((){});}),
          BottomNavBarItem(PictureIcon('assets/bookmark.png'), onTap: () async {await Main.pushBookmarks(); setState((){});}),
          BottomNavBarItem(PictureIcon('assets/download.png'), onTap: () async {await Main.pushDownloads(); setState((){});}),
          BottomNavBarItem(PictureIcon('assets/settings.png'), onTap: () async {await Main.pushSettings(); setState((){});}),
          // BottomNavigationBarItem(label: 'home', icon: PictureIcon('assets/home.png')),
        ],
      ),

    );
  }
}