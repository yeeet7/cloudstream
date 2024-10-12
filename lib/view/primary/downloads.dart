
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cloudstream/main.dart';
import 'package:cloudstream/view/primary/settings.dart';
import 'package:cloudstream/view/secondary/player.dart';
import 'package:cloudstream/widgets.dart';
import 'package:disk_space/disk_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';

class Downloads extends StatefulWidget {
  const Downloads({super.key});

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).padding.top + 67),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
              padding: EdgeInsets.only(left: 15, right: 15, top: MediaQuery.of(context).padding.top + 15, bottom: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Internal Storage', style: TextStyle(fontWeight: FontWeight.bold),),
                  //*total space bar
                  Container(
                    width: MediaQuery.of(context).size.width - 30,
                    height: 15,
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      // color: const Color(0xFF515151),
                      color: const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        //* used space bar
                        FutureBuilder(
                          future: Future.wait([DiskSpace.getTotalDiskSpace, DiskSpace.getFreeDiskSpace]),
                          builder: (context, snapshot) {
                            return Container(
                              width: snapshot.data == null ? 0 : remap((snapshot.data![0]! - snapshot.data![1]!).toInt(), 0, snapshot.data![0]!.toInt(), 0, (MediaQuery.of(context).size.width - 30).toInt()),
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2)
                              ),
                            );
                          }
                        ),
                        //* app space bar
                        FutureBuilder(
                          future: Future.wait([DiskSpace.getTotalDiskSpace, DiskSpace.getFreeDiskSpace]),
                          builder: (context, snapshot) {
                            List sizelist = [];
                            Directory(Hive.box('config').get('downloadPath') ?? defaultDownloadsPath).listSync(recursive: true).where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|ogg|webm').matchAsPrefix(element.path.split('.').last) != null).forEach((element) => sizelist.add(element.statSync().size));
                            num size = 0;
                            for (var el in sizelist) {
                              size += el;
                            }
                            return Container(
                              width: snapshot.data?[0] == null ? 0 : remap((size / 1024 / 1024 / 1024).ceil(), 0, snapshot.data![0]!.toInt(), 0, (MediaQuery.of(context).size.width - 30).toInt()),
                              height: 15,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2)
                              ),
                            );
                          }
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12.5,
                            height: 12.5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FutureBuilder(
                            future: (() async => (await DiskSpace.getTotalDiskSpace)! - (await DiskSpace.getFreeDiskSpace)!).call(),
                            builder: (context, snapshot) {
                              return Text('Used•${((snapshot.data ?? 0) / 1024).withDecimals(1)} GB ');
                            }
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12.5,
                            height: 12.5,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Builder(
                            builder: (context) {
                              List sizelist = [];
                              Directory(Hive.box('config').get('downloadPath') ?? defaultDownloadsPath).listSync(recursive: true).where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|webm|ogg').matchAsPrefix(element.path.split('.').last) != null).forEach((element) => sizelist.add(element.statSync().size));
                              num size = 0;
                              for (var el in sizelist) {
                                size += el;
                              }
                              return Text('App•${(size / 1024 / 1024 / 1024).withDecimals(1)} GB ');
                            }
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12.5,
                            height: 12.5,
                            decoration: BoxDecoration(
                              // color: const Color(0xFF515151),
                              color: const Color(0xFF424242),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FutureBuilder(
                            future: DiskSpace.getFreeDiskSpace,
                            builder: (context, snapshot) {
                              return Text('Free•${((snapshot.data ?? 0) / 1024).withDecimals(1)} GB ');
                            }
                          ),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),

      body: FutureBuilder(
        future: Permission.storage.status,
        builder: (context, snapshot) {
          switch (snapshot.data?.isGranted) {
            case null:
              return ContainerShimmer(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                borderRadius: BorderRadius.zero,
                backgroundColor: Colors.black,
                foregroundColor: const Color(0xFF101010),
              );
            case true:
              final List<FileSystemEntity> snap = Directory(Hive.box('config').get('downloadPath') ?? defaultDownloadsPath).listSync(recursive: true);
              int itemsRowCount = int.parse(Hive.box('config').get('ItemsInRowCount', defaultValue: 3).toString().split('.')[0]);
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  primary: true,
                  padding: const EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        children: snap.where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|webm|ogg').matchAsPrefix(element.path.split('.').last.toLowerCase()) != null)
                          .where((e) => Platform.isIOS ? !e.path.startsWith('$defaultIosDownloadPath/.Trash') : true).map<Widget>(
                          (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.path)));//!/FIXME
                            return DownloadedMovie(
                              File(e.path),
                              itemsRowCount
                            );
                          }
                        ).toList()
                      ),
                    ],
                  ),
                ),
              );
            case false:
              return Center(
                child: CupertinoButton(child: const Text('Grant storage permission'), onPressed: () async {await Permission.storage.request(); setState(() {});}),
              );
          }
          // return Center(
          //   child: Column(
          //     mainAxisSize: MainAxisSize.min,
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Text('The selected download path was not found'),
          //       Button(text: 'change download path', centerTitle: true, textColor: Theme.of(context).primaryColor, hasIcon: false, onTap: () async {await setDownloadPath(); setState(() {});}),
          //     ],
          //   ),
          // );
        }
      ),

    );
  }
}

class DownloadedMovie extends StatelessWidget {
  const DownloadedMovie(this.movie, this.itemsRowCount, {super.key});
  final File movie;
  final int itemsRowCount;

  @override
  Widget build(BuildContext context) {
    //width = (total_width - total_padding) / items
    double width = ((MediaQuery.of(context).size.width - 5*(itemsRowCount+1)) / itemsRowCount);
    return StatefulBuilder(
      builder: (context, setstate) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: width,
              height: width / 9 * 12.5 + 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212),
                          image: Hive.box('downloadPosters').get(movie.absolute.path) != null ? DecorationImage(image: Image.memory(Uint8List.fromList((Hive.box('downloadPosters').get(movie.absolute.path) as List).cast<int>())).image, fit: BoxFit.cover):null,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => Player(true, file: movie)));},
                        onLongPress: () async {await Hive.box('downloadPosters').put(movie.absolute.path, await ImagePicker().pickImage(source: ImageSource.gallery).then((val) async => await val?.readAsBytes())); setstate(() {});},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: width,
              height: 45,
              child: Center(
                child: Text(
                  movie.path.split('.').first.split('/').last,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ],
        
        );
      }
    );
  }
}

extension Decimal on double {
  double withDecimals(int decimals) {
    String th = toString();
    String dec = th.split('.')[1].padRight(decimals, '0').substring(0, decimals);
    return double.parse('${th.split('.')[0]}.$dec');
  }
}