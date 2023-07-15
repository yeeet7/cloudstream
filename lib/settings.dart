

import 'package:cloudstream/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Button(text: 'General', onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const GeneralSettings()));},),
          Button(text: 'Player', onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const PlayerSettings()));},),
          const Text('0.2.0'),
        ],
      )

    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({required this.text, required this.icon, this.subtitle, this.onTap, super.key});
  final String text;
  final String? subtitle;
  final void Function()? onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 25),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: const TextStyle(fontSize: 16),),
                  if(subtitle != null) Text('$subtitle', style: const TextStyle(fontSize: 12, color: Colors.white54),),
                ],
              ),
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

      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text('General'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingsButton(
              text: 'Download path',
              icon: PictureIcon('assets/download.png'),
              subtitle: '${Hive.box('config').get('downloadPath',) ?? '/storage/emulated/0/Download'}',
              onTap: () async {
                await setDownloadPath();
                setState(() {});
              },
            ),
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

      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text('Player'),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: const [
          ],
        ),
      ),

    );
  }
}

Future<void> setDownloadPath() async => await Hive.box('config').put('downloadPath', (await FilePicker.platform.getDirectoryPath()) ?? '/storage/emulated/0/Download');