
// ignore_for_file: use_build_context_synchronously



import 'dart:developer';
import 'dart:ui';

import 'package:cloudstream/widgets.dart';
import 'package:cloudstream/view/secondary/player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movie_provider/movie_provider.dart';

Object dropdownValue = 1;
int season = 1;
int episode = 1;

// ignore: must_be_immutable
class Video extends StatefulWidget {
  Video(this.movie, {super.key});
  MovieInfo movie;

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        surfaceTintColor: Colors.transparent,
        toolbarHeight: kToolbarHeight - 10,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(FontAwesomeIcons.earthAmericas)),
        ],
      ),

      body: Builder(
        builder: (context) {
          MovieInfo snapshot = widget.movie;
          // return SingleChildScrollView(
          //   physics: const NeverScrollableScrollPhysics(),
          //   child: Column(
          //     children: [
          //       Container(margin: const EdgeInsets.all(20), child: ContainerShimmer(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.width * 0.6,)),
          //       ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * 0.6),
          //       const SizedBox(height: 5),
          //       Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (index) => ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * 0.25))),
          //       const SizedBox(height: 10),
          //       ...List.generate(7, (index) => Container(margin: const EdgeInsets.all(2.5), child: ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * (index % 2 == 0 ? 0.9 : 0.8)))),
          //       const SizedBox(height: 5),
          //       Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (index) => ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * 0.2))),
          //       const SizedBox(height: 10),
          //       ContainerShimmer(height: 40, width: MediaQuery.of(context).size.width * 0.95),
          //       const SizedBox(height: 5),
          //       ContainerShimmer(height: 40, width: MediaQuery.of(context).size.width * 0.95),
          //     ],
          //   ),
          // );
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),

                /// image
                Container(
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: snapshot.banner == null ? Theme.of(context).bottomNavigationBarTheme.backgroundColor:null,
                    image: snapshot.banner != null ? DecorationImage(image: Image.network(snapshot.banner!).image, fit: BoxFit.cover):null,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.transparent, Colors.transparent, Colors.black],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                ///details
                Text('${snapshot.title}', maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 5),
                Text('${widget.movie.movie ? 'Movie' : 'TV Show'}   ${snapshot.year}   ${snapshot.rating.toString().splitMapJoin('.', onNonMatch: (m) => m[0][0])}/10.0', maxLines: 1, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                // user rating
                if(widget.movie.userRating != null && Bookmarks.findMovie(widget.movie) != null) Container(
                  padding: const EdgeInsets.all(7.5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text('You rated: ${''.padRight((widget.movie.userRating!/2).floor(), '★').padRight((widget.movie.userRating!/2).floor() + widget.movie.userRating!%2, '½')}'),
                ),
                if(widget.movie.userRating != null && Bookmarks.findMovie(widget.movie) != null)const SizedBox(height: 10),
                SizedBox(width: MediaQuery.of(context).size.width * 0.95, child: Text('${snapshot.desc}', textAlign: TextAlign.center)),
                const SizedBox(height: 10),
                
                FutureBuilder(
                  future: MovieProvider.getDetailsById(snapshot),
                  builder: (context, snap) {
                    return Column(
                      children: [

                        const Text('Cast:', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54),),
                        const SizedBox(height: 10),
                        if(snap.hasData) SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: snap.data!.cast.map((e) => Container(width: MediaQuery.of(context).size.width/5, margin: const EdgeInsets.symmetric(horizontal: 6), child: PersonWidget(e.name, e.role, e.image))).toList()
                          ),
                        )else Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(4, (index) => CircleAvatar(child: ContainerShimmer(backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor, borderRadius: BorderRadius.circular(50))))
                        ),
                        
                        const SizedBox(height: 10),
                        const Text('Genres', style: TextStyle(fontSize: 18)),
                        const SizedBox(height: 10),
                        if(snap.hasData) Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10,
                          runSpacing: 10,
                          children: snap.data!.genres.map<Widget>((e) => Container(padding: const EdgeInsets.all(7.5), decoration: BoxDecoration(color: Theme.of(context).bottomNavigationBarTheme.backgroundColor, borderRadius: BorderRadius.circular(8)), child: Text(e),)).toList()
                        ) else Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ContainerShimmer(borderRadius: BorderRadius.circular(8), backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor, height: 24, width: 75,),
                            const SizedBox(width: 12,),
                            ContainerShimmer(borderRadius: BorderRadius.circular(8), backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor, height: 24, width: 75,),
                            const SizedBox(width: 12,),
                            ContainerShimmer(borderRadius: BorderRadius.circular(8), backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor, height: 24, width: 75,),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Buttons
                // movie
                if(widget.movie.movie) SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 40,
                  child: Material(
                    borderRadius: BorderRadius.circular(6),
                    color: Theme.of(context).primaryColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        bool? res = await Navigator.of(context, rootNavigator: true).push<bool?>(MaterialPageRoute(builder: (context) => Player(false, movie: widget.movie)));
                        if(res != null) {
                          showNoLinksSnackbar(context);
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded),
                          Text('Play Movie'),
                        ],
                      ),
                    ),
                  ),
                ),
                if(widget.movie.movie) const SizedBox(height: 10),
                if(widget.movie.movie) SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: 40,
                  child: Material(
                    borderRadius: BorderRadius.circular(6),
                    color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PictureIcon('assets/download.png'),
                          const Text('Download'),
                        ],
                      ),
                    ),
                  ),
                ),
                // series
                if(!widget.movie.movie) FutureBuilder(
                  future: MovieProvider.tmdbapi.v3.tv.getDetails(widget.movie.id!),// Seasons.getDetails(widget.movie.id!, 1),
                  builder: (context, snapshot) {
                    return StatefulBuilder(
                      builder: (context, setstate) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            if(snapshot.data != null) Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  margin: const EdgeInsets.only(bottom: 12, left: 12),
                                  child: DropdownButton(
                                    borderRadius: BorderRadius.circular(12),
                                    dropdownColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                    icon: const Icon(Icons.arrow_drop_down_rounded),
                                    underline: const SizedBox(),
                                    onChanged: (obj) {setstate(() {dropdownValue = (obj??1); season = ((obj as int?)??1);});},
                                    value: dropdownValue,
                                    items: List.generate(snapshot.data?['seasons'].length, (index) => DropdownMenuItem(value: snapshot.data?['seasons'][index]['season_number'],child: Text('${snapshot.data?['seasons'][index]['name']}'),))
                                  ),
                                ),
                              ],
                            ) else Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12, left: 12),
                                  child: ContainerShimmer(
                                    backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    height: 32 + 12,
                                    width: 32 + 100,
                                  ),
                                ),
                              ],
                            ),

                            FutureBuilder(
                              future: MovieProvider.tmdbapi.v3.tvSeasons.getDetails(widget.movie.id!, season),
                              builder: (context, snap) {

                                if(snapshot.data != null && snap.data != null) {

                                  final List episodes = snap.data!['episodes'];

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: episodes.map(
                                      (e) => EpisodeButton(
                                        title: e['name'],//'Episode ${e['episode_number']} - ${e['name']}',
                                        onTap: () async {
                                          bool? res = await Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) => Player(false, movie: widget.movie, season: season, episode: e['episode_number'],)));
                                          if(res != null) showNoLinksSnackbar(context);
                                        },
                                        onDownloadTap: () {},
                                        width: MediaQuery.of(context).size.width * 0.95
                                      )
                                    ).toList()
                                  );
                                }
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(10, (index) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ContainerShimmer(
                                      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                                      borderRadius: BorderRadius.circular(12),
                                      height: 30,
                                      width: MediaQuery.of(context).size.width * 0.95
                                    ),
                                  ))
                                );
                              }

                            ),
                          ],
                        );
                      }
                    );
                  }
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        }
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: PictureIcon('assets/bookmark.png', color: (Bookmarks.findMovie(widget.movie) != null ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary)),
        onPressed: () async {
          await showBookmarkSheet<bool>(context, widget).then((value) async {
            if(value == true) await showRatingSheet(context, widget);
          });
          setState(() {});
        }
      ),

    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showNoLinksSnackbar(BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      width: textToSize('No links found', const TextStyle(color: Colors.white)).width + 32,
      content: const Center(child: Text('No links found', style: TextStyle(color: Colors.white),)),
    )
  );
}

Future<T?> showBookmarkSheet<T>(BuildContext context, Video widget) async {
  return await showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(text: 'Watching', icon: const Icon(Icons.arrow_forward_ios_rounded), textColor: ((Bookmarks.findMovie(widget.movie) == BookmarkType.watching ? Theme.of(context).primaryColor : null)), onTap: () async {Navigator.pop(context, false); await Bookmarks.setBookmark(BookmarkType.watching, widget.movie);},),
            Button(text: 'Plan to Watch', icon: const Icon(Icons.arrow_forward_ios_rounded), textColor: ((Bookmarks.findMovie(widget.movie) == BookmarkType.planned ? Theme.of(context).primaryColor : null)), onTap: () async {Navigator.pop(context, false); await Bookmarks.setBookmark(BookmarkType.planned, widget.movie);},),
            Button(text: 'Completed', icon: const Icon(Icons.arrow_forward_ios_rounded), textColor: ((Bookmarks.findMovie(widget.movie) == BookmarkType.completed ? Theme.of(context).primaryColor : null)), onTap: () async {Navigator.pop(context, true);},),
            Button(text: 'on-Hold', icon: const Icon(Icons.arrow_forward_ios_rounded), textColor: ((Bookmarks.findMovie(widget.movie) == BookmarkType.onHold? Theme.of(context).primaryColor : null)), onTap: () async {Navigator.pop(context, false); await Bookmarks.setBookmark(BookmarkType.onHold, widget.movie);},),
            Button(text: 'Dropped', icon: const Icon(Icons.arrow_forward_ios_rounded), textColor: ((Bookmarks.findMovie(widget.movie) == BookmarkType.dropped ? Theme.of(context).primaryColor : null)), onTap: () async {Navigator.pop(context, false); await Bookmarks.setBookmark(BookmarkType.dropped, widget.movie);},),
            Button(text: 'None', icon: const Icon(Icons.arrow_forward_ios_rounded), textColor: ((Bookmarks.findMovie(widget.movie) == null ? Theme.of(context).primaryColor : null)), onTap: () async {Navigator.pop(context, false); await Bookmarks.setBookmark(null, widget.movie);},),
          ],
        ),
      );
    }
  );
}
Future<T?> showRatingSheet<T>(BuildContext context, Video widget) async {
  int rating = widget.movie.userRating ?? 0;
  return await showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setstate) {
          return Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12)
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      5,
                      (index) => IconButton(
                        icon: ShaderMask(
                          child: const Icon(
                            Icons.star,
                            color: Colors.white
                          ),
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: () {
                                if(index == 0)return rating >= 2 ? [Colors.yellow, Colors.yellow,] : rating == 1 ? [Colors.yellow, Theme.of(context).colorScheme.secondary]:[Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary];
                                if(index == 1)return rating >= 4 ? [Colors.yellow, Colors.yellow,] : rating == 3 ? [Colors.yellow, Theme.of(context).colorScheme.secondary]:[Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary];
                                if(index == 2)return rating >= 6 ? [Colors.yellow, Colors.yellow,] : rating == 5 ? [Colors.yellow, Theme.of(context).colorScheme.secondary]:[Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary];
                                if(index == 3)return rating >= 8 ? [Colors.yellow, Colors.yellow,] : rating == 7 ? [Colors.yellow, Theme.of(context).colorScheme.secondary]:[Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary];
                                return rating >= 10 ? [Colors.yellow, Colors.yellow,] : rating == 9 ? [Colors.yellow, Theme.of(context).colorScheme.secondary]:[Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary];
                              }.call(),
                              stops: const [0.5, 0.5],
                            ).createShader(bounds);},
                        ),
                        onPressed: () {
                          if(index == 0)rating == 2 ? rating = 1 : rating == 1 ? rating = 0 : rating = 2;
                          if(index == 1)rating == 4 ? rating = 3 : rating = 4;
                          if(index == 2)rating == 6 ? rating = 5 : rating = 6;
                          if(index == 3)rating == 8 ? rating = 7 : rating = 8;
                          if(index == 4)rating == 10 ? rating = 9 : rating = 10;
                          setstate(() {});
                        },
                      )
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomChip('Cancel', false, onTap: () => Navigator.pop(context)),
                    CustomChip(
                      'Save',
                      true,
                      onTap: () async {
                        Navigator.pop(context);
                        widget.movie.userRating = rating;
                        log(widget.movie.userRating.toString());
                        return await Bookmarks.setBookmark(BookmarkType.completed, widget.movie);
                      }
                    ),
                  ],
                )
              ],
            ),
          );
        }
      );
    }
  );
}