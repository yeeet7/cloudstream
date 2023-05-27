
import 'dart:async';
import 'dart:io';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
// import 'package:wakelock/wakelock.dart';
import 'package:flutter_screen_wake/flutter_screen_wake.dart';

class Player extends StatefulWidget {
  const Player(this.isFile, {this.file, this.url, super.key}) : assert(isFile ? (file != null) : (url != null));
  final bool isFile;
  final File? file;
  final String? url;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {

  late VideoPlayerController ctrl;
  late AnimationController animation;
  late AnimationController sliderAnim;
  bool controlsShown = true;
  DragStartDetails? dragStart;
  double? currentBrightness;
  double? currentVolume;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    PerfectVolumeControl.hideUI = true;
    // Future.delayed(Duration.zero, () => Wakelock.enable());
    Future.delayed(Duration.zero, () => FlutterScreenWake.keepOn(true));
    animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    sliderAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    if(widget.isFile && widget.file != null) {
      ctrl = VideoPlayerController.file(widget.file!);
      Future.delayed(Duration.zero, () => ctrl.initialize());
      ctrl.addListener(() {if(mounted) setState(() {});});
      ctrl.play();
    }
    Timer(const Duration(seconds: 5), () {
      controlsShown = true;
      try {
        animation.forward();
      } catch(e) {null;}
    });
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    PerfectVolumeControl.hideUI = false;
    // Future.delayed(Duration.zero, () => Wakelock.disable());
    Future.delayed(Duration.zero, () => FlutterScreenWake.keepOn(false));
    Future.delayed(Duration.zero, () => ctrl.pause());
    Future.delayed(Duration.zero, () => ctrl.removeListener(() {}));
    ctrl.dispose();
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Stack(
          children: [
            VideoPlayer(ctrl),
            GestureDetector(
              onTap: () {
                Timer? timer;
                setState(() => controlsShown = !controlsShown);
                if(controlsShown) {
                  animation.forward();
                  if(timer != null) timer.cancel();
                } else {
                  timer = Timer(const Duration(seconds: 5), () {
                    if(ctrl.value.isPlaying) {
                      controlsShown = true;
                      animation.forward();
                    }
                  });
                  animation.reverse();
                }
              },
              onDoubleTapDown: (details) async {
                if(!controlsShown) return;
                double size = MediaQuery.of(context).size.width / 2;
                Duration? pos = await ctrl.position;
                /// right forward
                if(details.globalPosition.dx > size) {
                  if(pos != null) await ctrl.seekTo(Duration(seconds: pos.inSeconds + 10));
                } else {
                  /// left backward
                  if(pos != null) await ctrl.seekTo(Duration(seconds: pos.inSeconds - 10));
                }
                posKey.currentState?.setState(() {});
              },
              onVerticalDragStart: (details) async {dragStart = details; currentBrightness = await ScreenBrightness().current; currentVolume = await PerfectVolumeControl.getVolume(); sliderAnim.forward(); controlsShown = true; animation.forward();},
              onVerticalDragDown: (details) {sliderAnim.forward();},
              onVerticalDragEnd: (details) {dragStart = null; currentBrightness = null; currentVolume = null; sliderAnim.reverse();},
              onVerticalDragCancel: () {dragStart = null; currentBrightness = null; currentVolume = null; sliderAnim.reverse();},
              onVerticalDragUpdate: (details) async {
                if(dragStart!.globalPosition.dx > MediaQuery.of(context).size.width / 2) {
                  if(dragStart == null || currentVolume == null) return;
                  double volumeOffset = remap((dragStart!.globalPosition.dy - details.globalPosition.dy).clamp(-(MediaQuery.of(context).size.height / 4), (MediaQuery.of(context).size.height / 4)).toInt(), -MediaQuery.of(context).size.height ~/ 4, MediaQuery.of(context).size.height ~/ 4, 0, 2) - 1;
                  await PerfectVolumeControl.setVolume((currentBrightness! + volumeOffset).clamp(0, 1));
                  setState(() {});
                } else {
                  ScreenBrightness brightnessCtrl = ScreenBrightness();
                  if(dragStart == null || currentBrightness == null) return;
                  double brightnessOffset = remap((dragStart!.globalPosition.dy - details.globalPosition.dy).clamp(-(MediaQuery.of(context).size.height / 4), (MediaQuery.of(context).size.height / 4)).toInt(), -MediaQuery.of(context).size.height ~/ 4, MediaQuery.of(context).size.height ~/ 4, 0, 2) - 1;
                  await brightnessCtrl.setScreenBrightness((currentBrightness! + brightnessOffset).clamp(0, 1));
                  setState(() {});
                }
              },
              child: Container(
                color: ColorTween(begin: Colors.black38, end: Colors.transparent).animate(animation).value,
              ),
            ),

            AnimatedBuilder(
              animation: sliderAnim,
              builder: (context, child) {
                return Opacity(
                  opacity: Tween(begin: 0.0, end: 1.0).animate(sliderAnim).value,
                  child: child,
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// volume left / right slide
                  if(dragStart != null && dragStart!.globalPosition.dx > MediaQuery.of(context).size.width / 2) Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.volume_up_rounded, size: 30,),
                        const SizedBox(height: 15),
                        Container(
                          width: 5,
                          height: MediaQuery.of(context).size.height / 2,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: StreamBuilder(
                            stream: PerfectVolumeControl.stream,
                            builder: (context, snapshot) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)
                                ),
                                height: MediaQuery.of(context).size.height / 2 * (snapshot.data ?? 0),
                                width: 5,
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ) else const SizedBox(),
                  /// brightness right / left slide
                  if(dragStart != null && dragStart!.globalPosition.dx < MediaQuery.of(context).size.width / 2) Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wb_sunny_outlined, size: 30,),
                        const SizedBox(height: 15),
                        Container(
                          width: 5,
                          height: MediaQuery.of(context).size.height / 2,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(6)
                          ),
                          alignment: Alignment.bottomCenter,
                          child: FutureBuilder(
                            future: ScreenBrightness().current,
                            builder: (context, snapshot) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6)
                                ),
                                height: MediaQuery.of(context).size.height / 2 * (snapshot.data ?? 0),
                                width: 5,
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                  ) else const SizedBox()
                ],
              ),
            ),
            
            /// back button
            if(Tween(begin: 1.0, end: 0.0).animate(animation).value != 0) Positioned(
              left: 10,
              top: 10,
              child: Opacity(
                opacity: Tween(begin: 1.0, end: 0.0).animate(animation).value,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {Navigator.pop(context);},
                ),
              ),
            ),
            
            /// video title
            Positioned(
              top: Tween(begin: 20.0, end: -100.0).animate(animation).value,
              left: MediaQuery.of(context).size.width / 2 - textToSize('${widget.file?.path.split('/').last}', const TextStyle()).width / 2,
              child: Text('${widget.file?.path.split('/').last}'),
            ),
      
            /// slider, options
            Positioned(
              bottom: Tween(begin: 0.0, end: -100.0).animate(animation).value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width - 40,
                child: Row(
                  children: [
                    PosWidget('${ctrl.value.position}'.split('.')[0]),
                    Expanded(
                      child: Slider(
                        min: 0,
                        max: ctrl.value.duration.inSeconds.toDouble(),
                        value: ctrl.value.position.inSeconds.toDouble(),
                        // divisions: ctrl.value.duration.inSeconds + 1,
                        onChanged: (pos) async {await ctrl.seekTo(Duration(seconds: pos.toInt()));setState(() {});}
                      ),
                    ),
                    Text('${ctrl.value.duration}'.split('.')[0]),
                  ],
                ),
              ),
            ),
      
            /// pause, resume... controls
            if(Tween(begin: 1.0, end: 0.0).animate(animation).value != 0) Center(
              child: Opacity(
                opacity: Tween(begin: 1.0, end: 0.0).animate(animation).value,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: PictureIcon('assets/backward.png', padding: const EdgeInsets.all(5), size: 60),
                      onPressed: () async {
                        Duration? pos = await ctrl.position;
                        if(pos != null) await ctrl.seekTo(Duration(seconds: pos.inSeconds - 10));
                        // setState(() {});
                        posKey.currentState?.setState(() {});
                      },
                    ),
                    IconButton(
                      icon: ctrl.value.isPlaying ? const Icon(Icons.pause_outlined, size: 60,) : const Icon(Icons.play_arrow_rounded, size: 65),
                      onPressed: () async {ctrl.value.isPlaying ? await ctrl.pause() : await ctrl.play(); setState(() {});},
                    ),
                    IconButton(
                      icon: PictureIcon('assets/forward.png', padding: const EdgeInsets.all(5), size: 60),
                      onPressed: () async {
                        Duration? pos = await ctrl.position;
                        if(pos != null) await ctrl.seekTo(Duration(seconds: pos.inSeconds + 10));
                        // setState(() {});
                        posKey.currentState?.setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}

GlobalKey posKey = GlobalKey<_PosWidgetState>();
class PosWidget extends StatefulWidget {
  const PosWidget(this.pos, {super.key});
  final String pos;

  @override
  State<PosWidget> createState() => _PosWidgetState();
}

class _PosWidgetState extends State<PosWidget> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.pos);
  }
}