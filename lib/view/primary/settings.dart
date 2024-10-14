
// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:cloudstream/main.dart';
import 'package:cloudstream/view/primary/bookmark.dart';
import 'package:cloudstream/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pull_down_button/pull_down_button.dart';
// import 'package:pull_down_button/pull_down_button.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Button(text: 'General', icon: const Icon(Icons.arrow_forward_ios_rounded), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const GeneralSettings()));},),
          Button(text: 'Player', icon: const Icon(Icons.arrow_forward_ios_rounded), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerSettings()));},),
          Button(text: 'Updates and Backup', icon: const Icon(Icons.arrow_forward_ios_rounded), onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const BackupSettings()));},),
          FutureBuilder(
            future: PackageInfo.fromPlatform().then((value) => value.version),
            builder: (context, snapshot) {
              return Text('v${snapshot.data ?? 'x.x.x'}');
            }
          ),
        ],
      )

    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({required this.text, required this.icon, this.switchValue, this.dropdown, this.subtitle, this.onTap, super.key}):assert(!(switchValue != null && dropdown != null));
  final String text;
  final Widget? subtitle;
  final void Function()? onTap;
  final Widget icon;
  final bool? switchValue;
  final Widget? dropdown;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  icon,
                  const SizedBox(width: 25),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text, style: const TextStyle(fontSize: 16),),
                      if(subtitle != null) subtitle!,//style = TextStyle(fontSize: 12, color: Colors.white54),
                    ],
                  ),
                ],
              ),
              if(switchValue != null) Switch.adaptive(
                value: switchValue!,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) async {
                  onTap?.call();
                }
              ),
              if(dropdown != null) dropdown!,
            ],
          )
        ),
      ),
    );
  }
}

class GeneralSettings extends StatefulWidget {
  const GeneralSettings({super.key});

  @override
  State<GeneralSettings> createState() => _GeneralSettingsState();
}

class _GeneralSettingsState extends State<GeneralSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: CupertinoNavigationBar(
        // flexibleSpace: ClipRect(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //     child: Container(
        //       color: Colors.transparent,
        //     ),
        //   ),
        // ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        middle: Text('General', style: TextStyle(fontSize: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
        // title: const Text('General'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + (Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight)),
            // on ios the path to downloads is "on my iphone > cloudstream > downloads"
            if(!Platform.isIOS) SettingsButton(
              text: 'Download path',
              icon: PictureIcon('assets/download.png'),
              subtitle: Text(getDownloadsDirectory().toString(), style: const TextStyle(fontSize: 12, color: Colors.white54)),
              onTap: () async {
                await setDownloadPath();
                setState(() {});
              },
            ),
            SettingsButton(
              text: 'Include adult content',
              icon: const Icon(CupertinoIcons.exclamationmark_triangle),
              switchValue: Hive.box('config').get('include_adult', defaultValue: false),
              onTap: () async {
                await Hive.box('config').put('include_adult', !(Hive.box('config').get('include_adult') ?? false));
                MovieProvider.includeAdult = Hive.box('config').get('include_adult') ?? false;
                setState(() {});
              },
            ),
            SettingsButton(
              text: 'Clear search history',
              icon: const Icon(Icons.delete_outline_rounded),
              onTap: () async {
                await Hive.box('config').put('searchHistory', <String>[]);
                showHistoryClearedSnackBar(context);
              },
            ),
            ListenableBuilder(
              listenable: Hive.box('config').listenable(keys: ['ItemsInRowCount']),
              builder: (context, child) {
                return SettingsButton(
                  text: 'No. of items in row',
                  dropdown: PullDownButton(
                    buttonBuilder: (context, showFunc) => CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: showFunc,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(Hive.box('config').get('ItemsInRowCount', defaultValue: 3).toString().split('.')[0], style: TextStyle(color: Colors.grey.shade400)),
                          Transform.scale(scaleX: 1.2, scaleY: .6, child: Transform.rotate(angle: math.pi/2, child: Text('< >', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700))))
                        ],
                      )
                    ),
                    itemBuilder: (context) => List.generate(
                      3,
                      (index) => PullDownMenuItem(
                        title: [3, 4, 5][index].toString(),
                        onTap: () async {
                          await Hive.box('config').put('ItemsInRowCount', [3, 4, 5][index]);
                        }
                      )
                    ),
                  ),
                  icon: const Icon(Icons.numbers_rounded),
                  onTap: () {},
                );
              }
            ),
            SettingsButton(
              text: 'Bookmarks sorting',
              icon: const Icon(CupertinoIcons.arrow_up_arrow_down, size: 20,),
              dropdown: PullDownButton(
                buttonBuilder: (context, showFunc) => CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: showFunc,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(scale: .75, child: Icon(Hive.box('config').get('sortDirIsAsc', defaultValue: true) ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down, color: Colors.grey.shade400)),
                      Text(['Name', 'Date added', 'Average rating', 'User rating', 'Release year', 'custom'][Hive.box('config').get('sortType', defaultValue: SortType.dateAdded.index)].toString(), style: TextStyle(color: Colors.grey.shade400)),
                      Transform.scale(scaleX: 1.2, scaleY: .6, child: Transform.rotate(angle: math.pi/2, child: Text('< >', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700))))
                    ],
                  )
                ),
                itemBuilder: (context) => [
                  PullDownMenuItem.selectable(selected: Hive.box('config').get('sortDirIsAsc', defaultValue: true), onTap: () async {await Hive.box('config').put('sortDirIsAsc', true);}, title: 'Ascending', icon: CupertinoIcons.arrow_up,),
                  PullDownMenuItem.selectable(selected: !Hive.box('config').get('sortDirIsAsc', defaultValue: false), onTap: () async {await Hive.box('config').put('sortDirIsAsc', false);}, title: 'Descending', icon: CupertinoIcons.arrow_down,),
                  const PullDownMenuDivider.large(),
                  ...List.generate(
                    SortType.values.length,
                    (i) => PullDownMenuItem.selectable(
                      onTap: () async {
                        await Hive.box('config').put('sortType', [SortType.name, SortType.dateAdded, SortType.averageRating, SortType.userRating, SortType.releaseYear, SortType.custom][i].index);
                      },
                      selected: Hive.box('config').get('sortType', defaultValue: SortType.dateAdded.index) == i,
                      title: ['Name', 'Date added', 'Average rating', 'User rating', 'Release year', 'custom'][i],
                      icon: [CupertinoIcons.textformat_alt, CupertinoIcons.calendar, CupertinoIcons.star_fill, CupertinoIcons.star, CupertinoIcons.textformat_123, CupertinoIcons.pencil][i]
                    )
                  ),
                ],
              ),
            ),
            SettingsButton(
              text: 'automatic watching bookmark',
              // subtitle: const Text('automatically set as watching when you start watching a movie/tv show', style: TextStyle(fontSize: 10, color: Colors.grey),),
              icon: PictureIcon('assets/bookmark.png'),
              switchValue: Bookmarks.getAutomaticBookmarksWatching(),
              onTap: () async => await Bookmarks.setAutomaticBookmarks(!Bookmarks.getAutomaticBookmarksWatching()),
            ),
            SettingsButton(
              text: 'automatic cmpleted bookmark',
              // subtitle: const Text('automatically set as watching when you start watching a movie/tv show', style: TextStyle(fontSize: 10, color: Colors.grey),),
              icon: PictureIcon('assets/bookmark.png'),
              switchValue: Bookmarks.getAutomaticBookmarksCompleted(),
              onTap: () async => await Bookmarks.setAutomaticBookmarks(null, !Bookmarks.getAutomaticBookmarksCompleted()),
            )
          ],
        ),
      ),

    );
  }
}

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: CupertinoNavigationBar(
        // flexibleSpace: ClipRect(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //     child: Container(
        //       color: Colors.transparent,
        //     ),
        //   ),
        // ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        // title: const Text('Player'),
        middle: Text('Player', style: TextStyle(fontSize: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + (Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight)),
          ],
        ),
      ),

    );
  }
}

class BackupSettings extends StatefulWidget {
  const BackupSettings({super.key});

  @override
  State<BackupSettings> createState() => _BackupSettingsState();
}

class _BackupSettingsState extends State<BackupSettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: CupertinoNavigationBar(
        // flexibleSpace: ClipRect(
        //   child: BackdropFilter(
        //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        //     child: Container(
        //       color: Colors.transparent,
        //     ),
        //   ),
        // ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        // title: const Text('updates and Backup'),
        middle: Text('Updates and Backup', style: TextStyle(fontSize: 24, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + (Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight)),
            Container(margin: const EdgeInsets.only(left: 64, top: 16), child: Text('Updates', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)),
            SettingsButton(
              text: 'Auto update',
              subtitle: const Text('Automatically checks for updates', style: TextStyle(fontSize: 12, color: Colors.white54)),
              icon: const Icon(Icons.phone_android_rounded),
              switchValue: Hive.box('config').get('checkForUpdates') ?? true,
              onTap: () async {
                await Hive.box('config').put('checkForUpdates', !(Hive.box('config').get('checkForUpdates') ?? true));
                setState(() {});
              },
            ),
            SettingsButton(
              text: 'Check for update',
              subtitle: FutureBuilder(future: PackageInfo.fromPlatform().then((value) => value.version), builder: (context, snapshot) {return Text('v${snapshot.data ?? '0.0.0'}', style: const TextStyle(fontSize: 12, color: Colors.white54));}),
              icon: const Icon(Icons.phone_android_rounded),
              onTap: () {},//TODO
            ),
            Container(margin: const EdgeInsets.only(left: 64, top: 16), child: Text('Backup', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),)),
            SettingsButton(
              text: 'Restore data from backup',
              icon: Transform.rotate(angle: math.pi/2, child: const Icon(FontAwesomeIcons.arrowRightToBracket)),
              onTap: () async {
                //!/FIXME: ios not working
                if(await showRestoreBackupDialog(context) == false) return;
                var res = await FilePicker.platform.pickFiles(allowMultiple: false, initialDirectory: getDownloadsDirectory().path, type: FileType.custom, allowedExtensions: ['json']);
                late File file;
                if(res?.paths.first != null) {
                  file = File(res!.paths.first!);
                } else {return showDataRestoredSnackBar(context, false);}
                String fileString = await file.readAsString();
                final fileData = jsonDecode(fileString);
                /// search_history
                Hive.box('config').put('searchHistory', (fileData['search_history'] as List).cast<String>());
                /// bookmaks
                List<MapEntry<DateTime, MovieInfo>> watching = (fileData['bookmarks']['watching'] as List).cast<Map>().map((e) => MapEntry(DateTime.parse(e['dateTime']), MovieInfo(title: e['title'], id: e['id'], year: e['year'], poster: e['poster'], desc: e['desc'], genres: (e['genres'] as List).cast<int>(), cast: e['cast'], rating: e['rating'], banner: e['banner']))).toList();
                List<MapEntry<DateTime, MovieInfo>> planned = (fileData['bookmarks']['planned'] as List).cast<Map>().map((e) => MapEntry(DateTime.parse(e['dateTime']), MovieInfo(title: e['title'], id: e['id'], year: e['year'], poster: e['poster'], desc: e['desc'], genres: (e['genres'] as List).cast<int>(), cast: e['cast'], rating: e['rating'], banner: e['banner']))).toList();
                List<MapEntry<DateTime, MovieInfo>> completed = (fileData['bookmarks']['completed'] as List).cast<Map>().map((e) => MapEntry(DateTime.parse(e['dateTime']), MovieInfo(title: e['title'], id: e['id'], year: e['year'], poster: e['poster'], desc: e['desc'], genres: (e['genres'] as List).cast<int>(), cast: e['cast'], rating: e['rating'], banner: e['banner']))).toList();
                List<MapEntry<DateTime, MovieInfo>> onHold = (fileData['bookmarks']['onHold'] as List).cast<Map>().map((e) => MapEntry(DateTime.parse(e['dateTime']), MovieInfo(title: e['title'], id: e['id'], year: e['year'], poster: e['poster'], desc: e['desc'], genres: (e['genres'] as List).cast<int>(), cast: e['cast'], rating: e['rating'], banner: e['banner']))).toList();
                List<MapEntry<DateTime, MovieInfo>> dropped = (fileData['bookmarks']['dropped'] as List).cast<Map>().map((e) => MapEntry(DateTime.parse(e['dateTime']), MovieInfo(title: e['title'], id: e['id'], year: e['year'], poster: e['poster'], desc: e['desc'], genres: (e['genres'] as List).cast<int>(), cast: e['cast'], rating: e['rating'], banner: e['banner']))).toList();
                await Bookmarks.set(watching: watching, planned: planned, completed: completed, onHold: onHold, dropped: dropped);
                /// downloads
                List<MapEntry<DateTime, MovieInfo>> entries = (fileData['downloads'] as Map).entries.toList().cast<MapEntry<DateTime, MovieInfo>>();
                for (var el = 0; el < entries.length; el++) {
                  await Hive.box('downloadPosters').put(entries[el].key, entries[el].value);
                }
                /// settings
                await Hive.box('config').put('downloadPath', fileData['settings']['download_path'] as String);
                await Hive.box('config').put('sortType', fileData['settings']['sortType'] as int);
                await Hive.box('config').put('sortDirIsAsc', fileData['settings']['sortDirIsAsc'] as bool);
                await Hive.box('config').put('include_adult', fileData['settings']['include_adult'] as bool);
                await Hive.box('config').put('checkForUpdates', fileData['settings']['auto_update'] as bool);
                setState(() {});
                showDataRestoredSnackBar(context, true);
              },
            ),
            SettingsButton(
              text: 'Back up data',
              icon: Transform.rotate(angle: math.pi*1.5, child: const Icon(FontAwesomeIcons.arrowRightFromBracket)),
              onTap: () async {
                Directory dir = getDownloadsDirectory();
                DateTime time = DateTime.now();
                String fileName = '${dir.path}/cloudstream_backup_${time.year}_${time.month}_${time.day}_${time.hour}:${time.minute}:${time.second}.${time.toString().split('.').last}.json';
                File file = File(fileName);
                Bookmarks bm = Bookmarks.get();
                Map downloadedPosters = Hive.box('downloadPosters').toMap();
                String fileData = 
'''{
  "search_history": ${(Hive.box('config').get('searchHistory', defaultValue: <String>[]) as List<String>).map((e) => '"$e"').toList()},
  "bookmarks": {
    "watching": ${bm.watching.map((e) => """{
      "dateTime": "${e.key.toString()}",
      "movie": ${e.value.movie},
      "title": "${e.value.title}",
      "id": ${e.value.id},
      "year": "${e.value.year}",
      "poster": "${e.value.poster}",
      "desc": "${e.value.desc?.replaceAll('"', r'\"')}",
      "genres": ${e.value.genres},
      "cast": ${e.value.cast},
      "rating": ${e.value.rating},
      "banner": "${e.value.banner}"
    }""").toList()},
    "planned": ${bm.planned.map((e) => """{
      "dateTime": "${e.key.toString()}",
      "movie": ${e.value.movie},
      "title": "${e.value.title}",
      "id": ${e.value.id},
      "year": "${e.value.year}",
      "poster": "${e.value.poster}",
      "desc": "${e.value.desc?.replaceAll('"', r'\"')}",
      "genres": ${e.value.genres},
      "cast": ${e.value.cast},
      "rating": ${e.value.rating},
      "banner": "${e.value.banner}"
    }""").toList()},
    "completed": ${bm.completed.map((e) => """{
      "dateTime": "${e.key.toString()}",
      "movie": ${e.value.movie},
      "title": "${e.value.title}",
      "id": ${e.value.id},
      "year": "${e.value.year}",
      "poster": "${e.value.poster}",
      "desc": "${e.value.desc?.replaceAll('"', r'\"')}",
      "genres": ${e.value.genres},
      "cast": ${e.value.cast},
      "rating": ${e.value.rating},
      "banner": "${e.value.banner}"
    }""").toList()},
    "onHold": ${bm.onHold.map((e) => """{
      "dateTime": "${e.key.toString()}",
      "movie": ${e.value.movie},
      "title": "${e.value.title}",
      "id": ${e.value.id},
      "year": "${e.value.year}",
      "poster": "${e.value.poster}",
      "desc": "${e.value.desc?.replaceAll('"', r'\"')}",
      "genres": ${e.value.genres},
      "cast": ${e.value.cast},
      "rating": ${e.value.rating},
      "banner": "${e.value.banner}"
    }""").toList()},
    "dropped": ${bm.dropped.map((e) => """{
      "dateTime": "${e.key.toString()}",
      "movie": ${e.value.movie},
      "title": "${e.value.title}",
      "id": ${e.value.id},
      "year": "${e.value.year}",
      "poster": "${e.value.poster}",
      "desc": "${e.value.desc?.replaceAll('"', r'\"')}",
      "genres": ${e.value.genres},
      "cast": ${e.value.cast},
      "rating": ${e.value.rating},
      "banner": "${e.value.banner}"
    }""").toList()}
  },
  "downloads": {
    ${downloadedPosters.entries.mapIndexed((e, index) => '"${e.key}": ${e.value}${index == downloadedPosters.length - 1?'':','}\n    ').toList().join('')}},
  "settings": {
    "download_path": "${Hive.box('config').get('downloadPath',) ?? defaultDownloadsPath}",
    "include_adult": ${Hive.box('config').get('include_adult') ?? false},
    "sortType": ${Hive.box('config').get('sortType') ?? 1},
    "sortDirIsAsc": ${Hive.box('config').get('sortDirIsAsc') ?? true},
    "auto_update": ${Hive.box('config').get('checkForUpdates') ?? true}
  }
}''';
                if(!await file.exists()) file = await file.create();
                IOSink ioSink = file.openWrite();
                ioSink.write(fileData);
                await ioSink.flush();
                await ioSink.close();
                showBackedUpSnackBar(context);
              },
            ),
          ],
        ),
      ),

    );
  }
}

Future<void> setDownloadPath() async => await Hive.box('config').put('downloadPath', (await FilePicker.platform.getDirectoryPath())/* ?? defaultDownloadsPath */);
Directory getDownloadsDirectory() {
  Directory dir = Directory(Hive.box('config').get('downloadPath', defaultValue: defaultDownloadsPath));
  return dir;
  // if(Platform.isIOS) {
  //   dir = await getApplicationDocumentsDirectory();
  // } else {
  //   // dir = Directory(defaultDownloadsPath);
  //   dir = Directory.current;
  // }
  // if(!await dir.exists()) {
  //   String? pickedDir = await FilePicker.platform.getDirectoryPath(dialogTitle: 'Choose where to store the backup file', initialDirectory: null);
  //   if(pickedDir != null && await Directory(pickedDir).exists()) {
  //     dir = Directory(pickedDir);
  //   } else {
  //     throw ErrorDescription('could not get download directory');
  //   }
  // }
}
Future<bool?> showRestoreBackupDialog(BuildContext context) async => await showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      surfaceTintColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will override any existing data', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Button(
                  text: 'Cancel',
                  textColor: Theme.of(context).primaryColor,
                  buttonColor: const Color(0xFF242424),
                  borderRadius: BorderRadius.circular(6),
                  centerTitle: true,
                  onTap: () => Navigator.pop(context, false),
                ),
                Button(
                  text: 'Continue',
                  textColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                  buttonColor: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(6),
                  centerTitle: true,
                  onTap: () => Navigator.pop(context, true),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
);

void showHistoryClearedSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text('Search history cleared', style: TextStyle(color: Colors.white),),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(12),
    width: textToSize('Search history cleared', const TextStyle()).width + 24 + 6,
    backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
  ));
}

void showBackedUpSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text('Data Backed Up', style: TextStyle(color: Colors.white),),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(12),
    width: textToSize('Data Backed Up', const TextStyle()).width + 24 + 4,
    backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
  ));
}

void showDataRestoredSnackBar(BuildContext context, bool success) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(success ? 'Data Restored':'Canceled', style: const TextStyle(color: Colors.white),),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.all(12),
    width: textToSize(success ? 'Data Restored':'Canceled', const TextStyle()).width + 24,
    backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
  ));
}

String get defaultDownloadsPath => Platform.isIOS ? defaultIosDownloadPath : 'storage/emulated/0/Download';