
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
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

PageController pageController = PageController();

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  State<Main> createState() => _MainState();
}

GlobalKey mainStateKey = GlobalKey<_MainState>();
class _MainState extends State<Main> {

  Future<void> test() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: PageView(
        controller: pageController,
        allowImplicitScrolling: false,
        onPageChanged: (index) async => await Future.delayed(const Duration(milliseconds: 100), () => setState(() {})),
        physics: const NeverScrollableScrollPhysics(),
        children: const [Home(), Search(), BookmarkWidget(), Downloads(), Settings()],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: pageController.positions.isNotEmpty ? pageController.page?.toInt() ?? 0 : 0,
        showSelectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        items: List.generate(5, (index) => BottomNavigationBarItem(
            label: ['Home', 'Search', 'Bookmarks', 'Downloads', 'Settings'][index],
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            icon: Container(
              width: 60,
              height: 32.5,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
              decoration: BoxDecoration(
                // color: selected ? iconColor.withAlpha(40) : iconColor.withAlpha(0),
                color: (pageController.positions.isNotEmpty ? pageController.page?.toInt() ?? 0 : 0) == index ? Theme.of(context).primaryColor.withAlpha(40) : Theme.of(context).primaryColor.withAlpha(0),
                borderRadius: BorderRadius.circular(16)
              ),
              child: PictureIcon('assets/${['home', 'search', 'bookmark', 'download', 'settings'][index]}.png')
            ),
          ),
        ),
        onTap: (index) {
          switch (index) {
            case 0:
              pageController.animateToPage(0, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              break;
            case 1:
              pageController.animateToPage(1, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              searchNode.requestFocus();
              break;
            case 2:
              pageController.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              break;
            case 3:
              pageController.animateToPage(3, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              break;
            case 4:
              pageController.animateToPage(4, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
              break;
            default:
              return;
          }
        },
      ),

    );
  }
}