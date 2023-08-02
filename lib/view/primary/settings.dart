
import 'dart:math' as math;
import 'package:cloudstream/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
              return Text('v${snapshot.data ?? '0.0.0'}');
            }
          ),
        ],
      )

    );
  }
}

class SettingsButton extends StatelessWidget {
  const SettingsButton({required this.text, required this.icon, this.switchValue, this.subtitle, this.onTap, super.key});
  final String text;
  final Widget? subtitle;
  final void Function()? onTap;
  final Widget icon;
  final bool? switchValue;

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
              if(switchValue != null) Switch(
                value: switchValue!,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (value) async {
                  onTap?.call();
                }
              )
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
              subtitle: Text('${Hive.box('config').get('downloadPath',) ?? '/storage/emulated/0/Download'}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
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

      body: const SingleChildScrollView(
        child: Column(
          children: [
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

      appBar: AppBar(
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        title: const Text('updates and Backup'),
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              onTap: () {},//TODO
            ),
            SettingsButton(
              text: 'Back up data',
              icon: Transform.rotate(angle: math.pi*1.5, child: const Icon(FontAwesomeIcons.arrowRightFromBracket)),
              onTap: () {},//TODO
            ),
          ],
        ),
      ),

    );
  }
}

Future<void> setDownloadPath() async => await Hive.box('config').put('downloadPath', (await FilePicker.platform.getDirectoryPath()) ?? '/storage/emulated/0/Download');