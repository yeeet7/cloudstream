
import 'package:cloudstream/main.dart';
import 'package:cloudstream/view/primary/search.dart';
import 'package:cloudstream/view/secondary/player.dart';
import 'package:cloudstream/view/secondary/video.dart';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  PageController scrollingVideosCtrl = PageController(initialPage: HomeStateStorage.scrollingPageOffset);
  final mainScrollCtrl = ScrollController(initialScrollOffset: HomeStateStorage.mainScrollOffset);
  final moviesScrollCtrl = ScrollController(initialScrollOffset: HomeStateStorage.moviesScrollOffset);
  final tvshowsScrollCtrl = ScrollController(initialScrollOffset: HomeStateStorage.seriesScrollOffset);

  @override
  void dispose() {
    scrollingVideosCtrl.dispose();
    mainScrollCtrl.dispose();
    moviesScrollCtrl.dispose();
    tvshowsScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<MainPageInfo>(
        future: MovieProvider.getMainPage(),
        initialData: HomeStateStorage.data,
        builder: (context, snapshot) {
          if(snapshot.hasData == false) {
            return SingleChildScrollView(
              controller: ScrollController(initialScrollOffset: 0),
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40,),
                  Transform.translate(
                    offset: Offset(-MediaQuery.of(context).size.width / 2, 0),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ContainerShimmer(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.5 * 1.6,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                          ContainerShimmer(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.6 * 1.6,
                          ),
                          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
                          ContainerShimmer(
                            width: MediaQuery.of(context).size.width * 0.6,
                            height: MediaQuery.of(context).size.width * 0.5 * 1.6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ButtonShimmer(),
                  Container(margin: const EdgeInsets.only(right: 5), child: Row(children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(left: 5), child: const MovieShimmer())))),
                  const ButtonShimmer(),
                  Container(margin: const EdgeInsets.only(right: 5), child: Row(children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(left: 5), child: const MovieShimmer())))),
                  const ButtonShimmer(),
                  Container(margin: const EdgeInsets.only(right: 5), child: Row(children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(left: 5), child: const MovieShimmer())))),
                ],
              ),
            );
          }
          HomeStateStorage.data = snapshot.data;
          return RefreshIndicator(
            onRefresh: () async {
              HomeStateStorage.data = null;
              HomeStateStorage.mainScrollOffset = 0; mainScrollCtrl.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
              HomeStateStorage.scrollingPageOffset = 0; scrollingVideosCtrl.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
              HomeStateStorage.moviesScrollOffset = 0; moviesScrollCtrl.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
              HomeStateStorage.seriesScrollOffset = 0; tvshowsScrollCtrl.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
              await Future.delayed(const Duration(milliseconds: 300));
              setState(() {});
            },
            child: SingleChildScrollView(
              controller: mainScrollCtrl..addListener(() => HomeStateStorage.mainScrollOffset = mainScrollCtrl.offset),
              child: Column(
                children: [
          
                  /// scrolling video list
                  StatefulBuilder(
                    builder: (context, setstate) {
                      return SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: Stack(
                          children: [
                            PageView.builder(
                              itemCount: snapshot.data!.scrollingVideos.isNotEmpty ? snapshot.data?.scrollingVideos.length : 1,
                              scrollDirection: Axis.horizontal,
                              controller: scrollingVideosCtrl,
                              onPageChanged: (index) => setstate(() => HomeStateStorage.scrollingPageOffset = index),
                              itemBuilder: (BuildContext context, int index) => ScrollingVideoCard(snapshot.data!.scrollingVideos.isNotEmpty ? snapshot.data!.scrollingVideos[index] : MovieInfo(title: 'No videos found', id: 0, year: ':(', poster: null, banner: null, cast: null, desc: null, genres: null, rating: null)),
                            ),
                            IgnorePointer(
                              ignoring: true,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withOpacity(.8),
                                      ...List.generate(3, (index) => Colors.transparent),
                                      Colors.black.withOpacity(.6),
                                      Colors.black,
                                    ]
                                  )
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              top: 22,
                              child: IconButton(
                                icon: PictureIcon('assets/search.png', color: Colors.white,),
                                onPressed: () async {await Main.pushSearch(); searchNode.requestFocus(); mainStateKey. currentState?.setState(() {});},
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    '${snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset].title}',
                                    key: Key('${snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset].title}'),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxLines: 2
                                  )
                                ),
                                const SizedBox(height: 10,),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Text(
                                    '${snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset].movie ? 'Movie':'Tv show'}•${snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset].rating.toString().splitMapJoin('.', onNonMatch: (m) => m[0])}/10.0•${snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset].year?.split('-')[0]}',
                                    key: Key('${snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset].id}')
                                  )
                                ),
                                const SizedBox(height: 15,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Button(
                                      text: 'play',
                                      textColor: Theme.of(context).primaryColor,
                                      buttonColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(6),
                                      iconIsLeading: true,
                                      centerTitle: true,
                                      icon: Icon(Icons.play_arrow_rounded, color: Theme.of(context).primaryColor),
                                      onTap: () async {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => Video(snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset])));
                                        Navigator.of(context, rootNavigator: true).push<bool?>(MaterialPageRoute(builder: (context) => Player(false, movie: snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset]))).then(
                                          (val) {
                                            if(val != null) {
                                              showNoLinksSnackbar(context);
                                            }
                                          }
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 24),
                                    Button(
                                      text: 'info',
                                      textColor: Theme.of(context).primaryColor,
                                      buttonColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(6),
                                      centerTitle: true,
                                      icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).primaryColor),
                                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Video(snapshot.data!.scrollingVideos[HomeStateStorage.scrollingPageOffset])));},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  ),
                  // PageIndicator(scrollingVideosCtrl.positions.isNotEmpty ? scrollingVideosCtrl.page?.toInt() ?? 0 : 0, snapshot.data?.scrollingVideos.isNotEmpty ?? false ? snapshot.data!.scrollingVideos.length : 1),//TODO: page indicator
          
                  /// movies
                  if(snapshot.data!.movies.isEmpty) Container(padding: const EdgeInsets.only(top: 10, bottom: 5), child: const Center(child: Text('No movies found :(', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),))),
                  if(snapshot.data!.movies.isNotEmpty) const Button(text: 'Popular Movies'),
                  if(snapshot.data!.movies.isNotEmpty) SingleChildScrollView(
                    controller: moviesScrollCtrl..addListener(() => HomeStateStorage.moviesScrollOffset = moviesScrollCtrl.offset),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      child: Row(
                        children: [
                          ...snapshot.data!.movies.map((e) => Container(margin: const EdgeInsets.only(left: 5), child: Movie(e))).toList(),
                          // ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3))
                        ]
                      ),
                    ),
                  ),
          
                  /// series
                  if(snapshot.data!.series.isEmpty) Container(padding: const EdgeInsets.only(top: 5), child: const Center(child: Text('No series found :(', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),))),
                  if(snapshot.data!.series.isNotEmpty) const Button(text: 'Popuplar TV Shows'),
                  if(snapshot.data!.series.isNotEmpty) SingleChildScrollView(
                    controller: tvshowsScrollCtrl..addListener(() => HomeStateStorage.seriesScrollOffset = tvshowsScrollCtrl.offset),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      margin: const EdgeInsets.only(right: 5),
                      child: Row(
                        children: [
                          ...snapshot.data!.series.map((e) => Container(margin: const EdgeInsets.only(left: 5), child: Movie(e))).toList(),
                          // ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3))
                        ]
                      ),
                    ),
                  ),
          
                ]
              ),
            ),
          );
        }
      )

    );
  }
}

class ScrollingVideoCard extends StatefulWidget {
  const ScrollingVideoCard(this.movie, {super.key});
  final MovieInfo movie;

  @override
  State<ScrollingVideoCard> createState() => _ScrollingVideoCardState();
}

class _ScrollingVideoCardState extends State<ScrollingVideoCard> {

  final GlobalKey videoKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height *0.6,
      child: Stack(
        children: [
          Flow(
            delegate: ParallaxFlowDelegate(
              scrollable: Scrollable.of(context),
              listItemContext: context,
              backgroundImageKey: videoKey,
            ),
            children: [
              widget.movie.poster != null ? Image(
                // width: MediaQuery.of(context).size.width * 1.1,
                key: videoKey,
                image: Image.network(widget.movie.poster!).image,
                fit: BoxFit.cover,
              ) : const SizedBox(),
            ],
          ),
          
        ],
      ),
    );
  }
}

abstract class HomeStateStorage {

  static MainPageInfo? data;
  static double mainScrollOffset = 0;
  static int scrollingPageOffset = 0;
  static double moviesScrollOffset = 0;
  static double seriesScrollOffset = 0;

}