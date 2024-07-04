
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart' show WebKitWebViewControllerCreationParams;

WebViewController webviewcontroller = WebViewController.fromPlatformCreationParams(WebKitWebViewControllerCreationParams(allowsInlineMediaPlayback: true, mediaTypesRequiringUserAction: const {}))
  ..setJavaScriptMode(JavaScriptMode.unrestricted);

class OnlineVideoPlayer extends StatefulWidget {
  OnlineVideoPlayer(this.movie, {this.season, this.episode, super.key}) : assert(movie.movie ? true : (season != null && episode != null));
  final MovieInfo movie;
  final int? season;
  final int? episode;

  @override
  State<OnlineVideoPlayer> createState() => _OnlineVideoPlayerState();
}

class _OnlineVideoPlayerState extends State<OnlineVideoPlayer> {

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    Future.delayed(Duration.zero, () => WakelockPlus.enable());
  }
  
  @override
  void dispose() {
    Future.delayed(Duration.zero, () => SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]));
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    Future.delayed(Duration.zero, () => WakelockPlus.disable());
    super.dispose();
  }

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
    
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: FutureBuilder(
        future: webviewcontroller.loadRequest(Uri.parse("https://vidsrc.net/embed/${widget.movie.movie ? 'movie' : 'tv'}?tmdb=${widget.movie.id}${widget.movie.movie ? '' : '&season=${widget.season}&episode=${widget.episode}'}")).then((value) => true),
        builder: ((context, snapshot) {
          if(!snapshot.hasData) return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,),);
          return WebViewWidget(controller: webviewcontroller);
        })
      )
    );
  }
}