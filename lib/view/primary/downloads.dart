
import 'dart:io';
import 'dart:typed_data';
import 'package:cloudstream/view/secondary/player.dart';
import 'package:cloudstream/widgets.dart';
import 'package:disk_space/disk_space.dart';
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

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(67),
        child: Container(
          color: Theme.of(context).appBarTheme.backgroundColor,
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Internal Storage', style: TextStyle(fontWeight: FontWeight.bold),),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                height: 15,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4)
                ),
                child: FutureBuilder(
                  future: Future.wait([DiskSpace.getTotalDiskSpace, DiskSpace.getFreeDiskSpace]),
                  builder: (context, snapshot) {
                    return Container(
                      width: snapshot.data == null ? 0 : remap((snapshot.data![0]! - snapshot.data![1]!).toInt(), 0, snapshot.data![0]!.toInt(), 0, (MediaQuery.of(context).size.width - 30).toInt()),
                      height: 15,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4)
                      ),
                      child: Builder(
                        builder: (context) {
                          List sizelist = [];
                          Directory(Hive.box('config').get('downloadPath') ?? '/storage/emulated/0/Download/').listSync(recursive: true).where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|ogg|webm').matchAsPrefix(element.path.split('.').last) != null).forEach((element) => sizelist.add(element.statSync().size));
                          num size = 0;
                          for (var el in sizelist) {
                            size += el;
                          }
                          return Container(
                            width: snapshot.data?[0] == null ? 0 : remap((size / 1024 / 1024 / 1024).ceil(), 0, snapshot.data![0]!.toInt(), 0, (MediaQuery.of(context).size.width - 30).toInt()),
                            height: 15,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4)
                            ),
                          );
                        }
                      )
                    );
                  }
                ),
              ),
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
                          return Text(' Used•${((snapshot.data ?? 0) / 1024).withDecimals(1)} GB');
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
                          Directory(Hive.box('config').get('downloadPath') ?? '/storage/emulated/0/Download/').listSync(recursive: true).where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|webm|ogg').matchAsPrefix(element.path.split('.').last) != null).forEach((element) => sizelist.add(element.statSync().size));
                          num size = 0;
                          for (var el in sizelist) {
                            size += el;
                          }
                          return Text(' App•${(size / 1024 / 1024 / 1024).withDecimals(1)} GB');
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
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FutureBuilder(
                        future: DiskSpace.getFreeDiskSpace,
                        builder: (context, snapshot) {
                          return Text(' Free•${((snapshot.data ?? 0) / 1024).withDecimals(1)} GB');
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

      body: FutureBuilder(
        future: Permission.storage.request(),
        builder: (context, snapshot) {
          if(snapshot.hasData && snapshot.data!.isGranted) {
            final List<FileSystemEntity> snap = Directory(Hive.box('config').get('downloadPath') ?? '/storage/emulated/0/Download/').listSync(recursive: true);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Wrap(
                spacing: 5,
                runSpacing: 10,
                children: snap.where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|webm|ogg').matchAsPrefix(element.path.split('.').last) != null).map((e) => DownloadedMovie(File(e.path))).toList(),
              ),
            );
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
          return ContainerShimmer(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            borderRadius: BorderRadius.zero,
            backgroundColor: Colors.black,
            foregroundColor: const Color(0xFF101010),
          );
        }
      ),

    );
  }
}

class DownloadedMovie extends StatelessWidget {
  const DownloadedMovie(this.movie, {super.key});
  final File movie;

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setstate) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: (MediaQuery.of(context).size.width - 20) / 3,
              height: (MediaQuery.of(context).size.width - 20) / 3 / 9 * 12.5 + 1,
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
              width: (MediaQuery.of(context).size.width - 20) / 3,
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