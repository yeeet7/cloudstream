
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
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: PageView.builder(
                    itemCount: snapshot.data!.scrollingVideos.isNotEmpty ? snapshot.data?.scrollingVideos.length : 1,
                    scrollDirection: Axis.horizontal,
                    controller: scrollingVideosCtrl,
                    itemBuilder: (BuildContext context, int index) => ScrollingVideoCard(snapshot.data!.scrollingVideos.isNotEmpty ? snapshot.data!.scrollingVideos[index] : MovieInfo(title: 'No videos found', id: 0, year: ':(', poster: null, banner: null, cast: null, desc: null, genres: null, rating: null))
                  ),
                ),

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
          Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${widget.movie.title}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
                const SizedBox(height: 10,),
                Text('${widget.movie.year}'),
                const SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconLabelButton(
                      onTap: () async {
                        showBookmarkSheet(context, true, movie: widget.movie);
                      },
                      label: 'Bookmark',
                      icon: PictureIcon('assets/bookmark.png', color: Bookmarks.findMovie(widget.movie) != null ? Theme.of(context).primaryColor : Colors.white),
                    ),
                    Button(text: 'play', textColor: Colors.black, buttonColor: Colors.white, borderRadius: BorderRadius.circular(6), hasIcon: false),
                    IconLabelButton(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Video(widget.movie,)));
                      },
                      label: 'Info',
                      icon: const Icon(Icons.info_outline_rounded),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}