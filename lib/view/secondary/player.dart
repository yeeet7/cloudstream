
import 'dart:async';
import 'dart:io';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:video_player/video_player.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audio_service/audio_service.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart' show WebKitWebViewControllerCreationParams;

MyAudioHandler? audioHandler;

class Player extends StatefulWidget {
  const Player(this.isFile, {this.file, this.movie, this.season = 1, this.episode = 1, super.key}) : assert(isFile ? (file != null) : (movie != null));
  final bool isFile;
  final File? file;
  final MovieInfo? movie;
  final int season;
  final int episode;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> with TickerProviderStateMixin {

  WebViewController webviewcontroller = WebViewController.fromPlatformCreationParams(WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const {}))
    ..setJavaScriptMode(JavaScriptMode.unrestricted);
  VideoPlayerController? ctrl;
  late AnimationController animation;
  late AnimationController sliderAnim;
  bool controlsShown = true;
  DragStartDetails? slideSeekDetails;
  Duration slideSeekTo = Duration.zero;
  DragStartDetails? dragStart;
  double? currentBrightness;
  double? currentVolume;

  bool locked = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    PerfectVolumeControl.hideUI = true;
    Future.delayed(Duration.zero, () => WakelockPlus.enable());
    // Future.delayed(Duration.zero, () => FlutterScreenWake.keepOn(true));
    animation = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    sliderAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

    if(widget.isFile && widget.file != null) {
      ctrl = VideoPlayerController.file(widget.file!, videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    } else if(!widget.isFile) {
      // vidsrc extractor
      // Navigator.pop(context, true);

      // Future.delayed(
      //   Duration.zero,
      //   () async {
          // try {
          //   http.Response res = await http.get(Uri.parse('https://vidsrc.me/embed/${widget.movie!.id}${widget.movie!.movie ? '' : '${widget.serie}-${widget.episode}'}'),);
          //   dom.Document document = parse(res.body);
          //   log(document.querySelector('iframe')!.text.toString());
          // } catch(e) {
          //   pop = true;
          //   Navigator.pop(context, false);
          // }
      //   }
      // );
    } else {
      Navigator.pop(context, true);
      // ctrl = VideoPlayerController.network('https://vidsrc.me/embed/tt10293938/1-1');
    }

    Future.delayed(Duration.zero, () async => await ctrl?.initialize());
    ctrl?.addListener(() {if(mounted) setState(() {});});
    ctrl?.play();
    
    if(audioHandler == null) {
      AudioService.init(cacheManager: null, builder: () => MyAudioHandler(ctrl)).then((value) => audioHandler = value);
    } else {
      audioHandler?.videoPlayerController = ctrl;
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
    Future.delayed(Duration.zero, () => WakelockPlus.disable());
    // Future.delayed(Duration.zero, () => FlutterScreenWake.keepOn(false));
    Future.delayed(Duration.zero, () => ctrl?.pause());
    Future.delayed(Duration.zero, () => ctrl?.removeListener(() {}));
    ctrl?.dispose();
    animation.dispose();
    super.dispose();
  }

  Timer? timer;

  @override
  Widget build(BuildContext context) {

    webviewcontroller
      ..setBackgroundColor(Theme.of(context).scaffoldBackgroundColor)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if(request.url.contains('vidsrc')) return NavigationDecision.navigate;
            return NavigationDecision.prevent;
          },
        )
      );

    return Scaffold(

      body: widget.isFile ? AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              alignment: Alignment.center,
              child: SizedBox(
                height: ctrl?.value.size.height,
                width: ctrl?.value.size.width,
                child: ctrl != null ? VideoPlayer(ctrl!) : const SizedBox(),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => controlsShown = !controlsShown);
                if(controlsShown) {
                  animation.forward();
                  timer?.cancel();
                } else {
                  timer = Timer(const Duration(seconds: 5), () {
                    if(ctrl != null && ctrl!.value.isPlaying) {
                      controlsShown = true;
                      animation.forward();
                    }
                  });
                  animation.reverse();
                }
              },
              onDoubleTapDown: (details) async {
                if(locked) return;
                if(!controlsShown) return;
                double size = MediaQuery.of(context).size.width / 2;
                Duration? pos = await ctrl?.position;
                /// right forward
                if(details.globalPosition.dx > size) {
                  if(pos != null) await ctrl?.seekTo(Duration(seconds: pos.inSeconds + 10));
                } else {
                  /// left backward
                  if(pos != null) await ctrl?.seekTo(Duration(seconds: pos.inSeconds - 10));
                }
                posKey.currentState?.setState(() {});
              },
              onHorizontalDragStart: (details) {if(locked) return; controlsShown = true; animation.forward(); slideSeekDetails = details;},
              onHorizontalDragEnd: (details) async {if(locked) return; if(slideSeekDetails != null) {await ctrl?.seekTo(slideSeekTo);} posKey.currentState?.setState(() {}); slideSeekDetails = null;},
              onHorizontalDragCancel: () {if(locked) return; slideSeekDetails = null;},
              onHorizontalDragUpdate: (details) {
                if(locked) return;
                int seekOffset = remap((details.globalPosition.dx - slideSeekDetails!.globalPosition.dx).toInt(), 0, MediaQuery.of(context).size.width.toInt(), 0, ctrl!.value.duration.inSeconds).toInt();
                slideSeekTo = Duration(seconds: (ctrl!.value.position.inSeconds + seekOffset).clamp(0, ctrl!.value.duration.inSeconds));
                slideSeekKey.currentState?.setState(() {});
                setState(() {});
                // log(slideSeekTo.toString());
              },
              onVerticalDragStart: (details) async {if(locked) return; dragStart = details; currentBrightness = await ScreenBrightness().current; currentVolume = await PerfectVolumeControl.getVolume(); sliderAnim.forward(); controlsShown = true; animation.forward();},
              onVerticalDragEnd: (details) {if(locked) return; dragStart = null; currentBrightness = null; currentVolume = null; sliderAnim.reverse();},
              onVerticalDragCancel: () {if(locked) return; dragStart = null; currentBrightness = null; currentVolume = null; sliderAnim.reverse();},
              onVerticalDragUpdate: (details) async {
                if(locked) return;
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
                  if(dragStart != null && dragStart!.globalPosition.dx > MediaQuery.of(context).size.width / 2 && locked == false) Container(
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
                  if(dragStart != null && dragStart!.globalPosition.dx < MediaQuery.of(context).size.width / 2 && locked == false) Container(
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
            if(Tween(begin: 1.0, end: 0.0).animate(animation).value != 0 && locked == false) Positioned(
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

            /// actions button
            // if(Tween(begin: 1.0, end: 0.0).animate(animation).value != 0 && locked == false) Positioned(
            //   right: 10,
            //   top: 10,
            //   child: Opacity(
            //     opacity: Tween(begin: 1.0, end: 0.0).animate(animation).value,
            //     child: PopupMenuButton(
            //       onSelected: (value) {
            //         if(value == 0) {
            //           OpenFilex.open(widget.file?.absolute.path);
            //         }
            //       },
            //       itemBuilder: (context) => [
            //         const PopupMenuItem(value: 0, child: Text('open in file explorer'))
            //       ]
            //     ),
            //   ),
            // ),
            
            /// video title
            if(locked == false) Positioned(
              top: Tween(begin: 20.0, end: -100.0).animate(animation).value,
              left: MediaQuery.of(context).size.width / 2 - textToSize('${widget.file?.path.split('/').last}', const TextStyle()).width / 2,
              child: Text('${widget.file?.path.split('/').last}'),
            ),

            /// slide seek text
            if(slideSeekDetails != null) SlideSeek('${formatDuration(slideSeekTo)} [${ctrl!.value.position.compareTo(slideSeekTo).isNegative ? '+' : '-'}${formatDuration(slideSeekTo - ctrl!.value.position)}]'),
      
            /// slider, options
            Positioned(
              bottom: Tween(begin: 0.0, end: -100.0).animate(animation).value,
              child: Column(
                children: [
                  if(locked == false) Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    width: MediaQuery.of(context).size.width - 40,
                    child: Row(
                      children: [
                        PosWidget('${ctrl?.value.position ?? 0.0}'.split('.')[0]),
                        Expanded(
                          child: Slider(
                            min: 0,
                            max: (ctrl?.value.duration.inSeconds ?? 0).toDouble(),
                            value: (ctrl?.value.position.inSeconds ?? 0).toDouble(),
                            // divisions: ctrl.value.duration.inSeconds + 1,
                            onChanged: (pos) async {await ctrl?.seekTo(Duration(seconds: pos.toInt()));setState(() {});}
                          ),
                        ),
                        Text('${ctrl?.value.duration ?? 0}'.split('.')[0]),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        PlayerButton(text: Text(locked ? 'Unlock' : 'Lock', style: TextStyle(color: locked ? Theme.of(context).primaryColor : null),), icon: locked ? Icon(Icons.lock_outline_rounded, color: Theme.of(context).primaryColor) : const Icon(Icons.lock_open_rounded), onTap: () => setState(() => locked = !locked))
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
      
            /// pause, resume... controls
            if(Tween(begin: 1.0, end: 0.0).animate(animation).value != 0 && locked == false) Center(
              child: Opacity(
                opacity: Tween(begin: 1.0, end: 0.0).animate(animation).value,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: PictureIcon('assets/backward.png', padding: const EdgeInsets.all(5), size: 60),
                      onPressed: () async {
                        Duration? pos = await ctrl?.position;
                        if(pos != null) await ctrl?.seekTo(Duration(seconds: pos.inSeconds - 10));
                        // setState(() {});
                        posKey.currentState?.setState(() {});
                      },
                    ),
                    IconButton(
                      icon: (ctrl?.value.isPlaying ?? false) ? const Icon(Icons.pause_outlined, size: 60,) : const Icon(Icons.play_arrow_rounded, size: 65),
                      onPressed: () async {(ctrl?.value.isPlaying ?? false) ? await ctrl?.pause() : await ctrl?.play(); setState(() {});},
                    ),
                    IconButton(
                      icon: PictureIcon('assets/forward.png', padding: const EdgeInsets.all(5), size: 60),
                      onPressed: () async {
                        Duration? pos = await ctrl?.position;
                        if(pos != null) await ctrl?.seekTo(Duration(seconds: pos.inSeconds + 10));
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
      ) : SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: FutureBuilder(
          future: webviewcontroller.loadRequest(Uri.parse("https://vidsrc.net/embed/${widget.movie!.movie ? 'movie' : 'tv'}?tmdb=${widget.movie?.id}${widget.movie!.movie ? '' : '&season=${widget.season}&episode=${widget.episode}'}")).then((value) => true),
          builder: ((context, snapshot) {
            if(!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),);
            return WebViewWidget(controller: webviewcontroller);
          })
        )
      )

      // floatingActionButton: widget.movie != null ? Offstage(
      //   offstage: true,
      //   child: WebView(
      //     initialUrl: 'https://vidsrc.me/embed/${widget.movie!.id}${widget.movie!.movie ? '' : '/1-1'}',
      //     javascriptMode: JavascriptMode.unrestricted,
      //     onWebViewCreated: (controller) async {
      //       wvctrl = controller;
      //     },
      //     onPageStarted: (_) async {
      //       await wvctrl.runJavascript("document.querySelector('script[disable-devtool-auto]').remove()");
      //     },
      //     onPageFinished: (_) {
      //       final htmls = wvctrl.runJavascriptReturningResult('new XMLSerializer().serializeToString(document)');
      //       dom.Document html = HtmlParser(htmls).parse();
      //       log(html.querySelector('iframe').toString());
      //     },
      //   ),
      // ):null

    );
  }
}

class PlayerButton extends StatelessWidget {
  const PlayerButton({required this.icon, required this.text, required this.onTap, super.key});
  final Widget icon;
  final Widget text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(9),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 12,),
              text,
            ],
          ),
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

GlobalKey slideSeekKey = GlobalKey<_SlideSeekState>();
class SlideSeek extends StatefulWidget {
  const SlideSeek(this.string, {super.key});
  final String string;

  @override
  State<SlideSeek> createState() => _SlideSeekState();
}

class _SlideSeekState extends State<SlideSeek> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 25,
      child: Container(
        width: MediaQuery.of(context).size.width,
        alignment: Alignment.center,
        child: Text(widget.string, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
      ),
    );
  }
}

class MyAudioHandler extends BaseAudioHandler {

  MyAudioHandler(this.videoPlayerController);
  VideoPlayerController? videoPlayerController;

  @override
  Future<void> click([MediaButton? button]) async {
    switch(button) {
      case MediaButton.media:
        videoPlayerController?.value.isPlaying ?? false ? videoPlayerController?.pause() : videoPlayerController?.play();
        break;
      case MediaButton.next:
        Duration? pos = await videoPlayerController?.position;
        if(pos != null) await videoPlayerController?.seekTo(Duration(seconds: pos.inSeconds + 10));
        break;
      case MediaButton.previous:
        Duration? pos = await videoPlayerController?.position;
        if(pos != null) await videoPlayerController?.seekTo(Duration(seconds: pos.inSeconds - 10));
        break;
      default: break;
    }
  }

}

String formatDuration(Duration duration) {
  String res = duration.toString().split('.')[0];
  if(duration.inHours > 0) return res;
  List<String> resList = res.split(':');
  resList.removeAt(0);
  res = resList.join(':');
  return res;
}