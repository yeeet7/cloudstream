


import 'package:cloudstream/video.dart';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late PageController scrollingVideosCtrl;
  int scrollingIndex = 0;
  
  @override
  void initState() {
    super.initState();
    scrollingVideosCtrl = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    scrollingVideosCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder(
        future: MovieProvider.getMainPage(),
        builder: (context, snapshot) {
          if(snapshot.hasData == false) {
            return SingleChildScrollView(
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
          return SingleChildScrollView(
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
                            onPageChanged: (index) => setstate(() => scrollingIndex = index),
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  '${snapshot.data!.scrollingVideos[scrollingIndex].title}',
                                  key: Key('${snapshot.data!.scrollingVideos[scrollingIndex].title}'),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                  maxLines: 2
                                )
                              ),
                              const SizedBox(height: 10,),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  '${snapshot.data!.scrollingVideos[scrollingIndex].movie ? 'Movie':'Tv show'}•${snapshot.data!.scrollingVideos[scrollingIndex].rating.toString().splitMapJoin('.', onNonMatch: (m) => m[0])}/10.0•${snapshot.data!.scrollingVideos[scrollingIndex].year?.split('-')[0]}',
                                  key: Key('${snapshot.data!.scrollingVideos[scrollingIndex].id}')
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
                                    onTap: () {},//TODO: scrolling play button onTap
                                  ),
                                  const SizedBox(width: 24),
                                  Button(
                                    text: 'info',
                                    textColor: Theme.of(context).primaryColor,
                                    buttonColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(6),
                                    centerTitle: true,
                                    icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).primaryColor),
                                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => Video(snapshot.data!.scrollingVideos[scrollingIndex])));},
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
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    margin: const EdgeInsets.only(right: 5),
                    child: Row(
                      children: [
                        ...snapshot.data!.series.map((e) => Container(margin: const EdgeInsets.only(left: 5), child: Series(e))).toList(),
                        // ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3))
                      ]
                    ),
                  ),
                ),

              ]
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