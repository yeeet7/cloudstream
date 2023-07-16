


import 'package:cloudstream/widgets.dart';
import 'package:cloudstream/player.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movie_provider/movie_provider.dart';

class Video extends StatefulWidget {
  const Video(this.movie, {super.key});
  final MovieInfo movie;

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        toolbarHeight: kToolbarHeight - 10,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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

                /// image
                Container(
                  height: MediaQuery.of(context).size.width * 0.6,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: Image.network(snapshot.banner!).image, fit: BoxFit.cover),
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
                SizedBox(width: MediaQuery.of(context).size.width * 0.95, child: Text('${snapshot.desc}', textAlign: TextAlign.center)),
                const SizedBox(height: 10),
                Text('Cast: ${snapshot.cast?.join(", ")}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54),),
                const SizedBox(height: 10),
                const Text('Genres', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                
                FutureBuilder(
                  future: snapshot.genres?.getGenresFromIds(snapshot.movie),
                  builder: (context, snap) {
                    if(snap.hasData)  {
                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: snap.data!.map<Widget>((e) => Container(padding: const EdgeInsets.all(7.5), decoration: BoxDecoration(color: Theme.of(context).bottomNavigationBarTheme.backgroundColor, borderRadius: BorderRadius.circular(8)), child: Text(e),)).toList()
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                const SizedBox(height: 20),

                SizedBox(
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
                          // ignore_for_file: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                              width: textToSize('No links found', const TextStyle(color: Colors.white)).width + 32,
                              content: const Center(child: Text('No links found', style: TextStyle(color: Colors.white),)),
                            )
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.play_arrow_rounded),
                          Text('Play Movie'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
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
          await showBookmarkSheet(context, widget.movie.movie, movie: widget.movie, series: widget.movie);
          setState(() {});
        }
      ),

    );
  }
}

Future<T?> showBookmarkSheet<T>(BuildContext context, bool isMovie, {MovieInfo? movie, MovieInfo? series}) async {
  assert(isMovie ? (movie != null) : (series != null));
  return await showModalBottomSheet<T>(
    context: context,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Button(text: 'Watching', textColor: ((Bookmarks.findMovie(movie!) == BookmarkType.watching ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); Bookmarks.setBookmark(BookmarkType.watching, movie);},),
            Button(text: 'Plan to Watch', textColor: ((Bookmarks.findMovie(movie) == BookmarkType.planned ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); Bookmarks.setBookmark(BookmarkType.planned, movie);},),
            Button(text: 'Completed', textColor: ((Bookmarks.findMovie(movie) == BookmarkType.completed ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); Bookmarks.setBookmark(BookmarkType.completed, movie);},),
            Button(text: 'on-Hold', textColor: ((Bookmarks.findMovie(movie) == BookmarkType.onHold? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); Bookmarks.setBookmark(BookmarkType.onHold, movie);},),
            Button(text: 'Dropped', textColor: ((Bookmarks.findMovie(movie) == BookmarkType.dropped ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); Bookmarks.setBookmark(BookmarkType.dropped, movie);},),
            Button(text: 'None', textColor: ((Bookmarks.findMovie(movie) == null ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); Bookmarks.setBookmark(null, movie);},),
          ],
        ),
      );
    }
  );
}