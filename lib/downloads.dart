
import 'dart:io';
import 'package:cloudstream/player.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Downloads extends StatelessWidget {
  const Downloads({super.key});

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
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(4)
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 12.5,
                    height: 12.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(' Used • 0 GB'),
                  const SizedBox(width: 10),
                  Container(
                    width: 12.5,
                    height: 12.5,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(' App • 0 GB'),
                  const SizedBox(width: 10),
                  Container(
                    width: 12.5,
                    height: 12.5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Text(' Free • 0 GB'),
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
            final snap =  Directory(Hive.box('config').get('downloadPath', defaultValue: 'storage/emulated/0/Download')).listSync(recursive: true);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: Wrap(
                spacing: 5,
                runSpacing: 10,
                children: snap.where((element) => RegExp('mp4|m4v|m4p|amv|mov|avi|ogg|webm').matchAsPrefix(element.path.split('.').last) != null).map((e) => DownloadedMovie(File(e.path))).toList(),
              ),
            );
          }
          return const CircularProgressIndicator();
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
                  child: Container(color: Colors.grey,)//TODOmovie.image,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => Player(true, file: movie)));},//TODO
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
              movie.path.split('.')[0].split('/').last,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: const TextStyle(overflow: TextOverflow.ellipsis),
            ),
          ),
        ),
      ],
    
    );
  }
}