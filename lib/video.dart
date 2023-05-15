

import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:movie_provider/movie_provider.dart';

class Video extends StatefulWidget {
  const Video(this.isMovie,{this.movie, this.series, super.key});
  final bool isMovie;
  final MovieInfo? movie;
  final MovieInfo? series;

  @override
  State<Video> createState() => _VideoState();
}

class _VideoState extends State<Video> {
  @override
  Widget build(BuildContext context) {
    assert(widget.isMovie ? (widget.movie != null) : (widget.series != null));
    return Scaffold(

      appBar: AppBar(
        toolbarHeight: kToolbarHeight - 10,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new_rounded)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(FontAwesomeIcons.earthAmericas)),
        ],
      ),

      body: FutureBuilder(
        future: widget.isMovie ? widget.movie!.getDetails() : widget.series!.getDetails(),
        builder: (context, snapshot) {
          if(snapshot.hasData == false) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(margin: const EdgeInsets.all(20), child: ContainerShimmer(width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.width * 0.6,)),
                  ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * 0.6),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(3, (index) => ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * 0.25))),
                  const SizedBox(height: 10),
                  ...List.generate(7, (index) => Container(margin: const EdgeInsets.all(2.5), child: ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * (index % 2 == 0 ? 0.9 : 0.8)))),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(4, (index) => ContainerShimmer(height: 15, width: MediaQuery.of(context).size.width * 0.2))),
                  const SizedBox(height: 10),
                  ContainerShimmer(height: 40, width: MediaQuery.of(context).size.width * 0.95),
                  const SizedBox(height: 5),
                  ContainerShimmer(height: 40, width: MediaQuery.of(context).size.width * 0.95),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [

                /// image
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: snapshot.data!.image!.image, fit: BoxFit.cover)
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.width * 0.6,
                    width: MediaQuery.of(context).size.width,
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
                Text('${snapshot.data!.title}', maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 5),
                Text('${widget.isMovie ? 'Movie' : 'TV Show'}   ${snapshot.data!.year}   ${snapshot.data!.rating}/10.0', maxLines: 1, textAlign: TextAlign.center),
                Text('${snapshot.data!.desc}', textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text('Cast: ${snapshot.data!.cast?.join(", ")}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white54),),
                const SizedBox(height: 10),
                const Text('Genres', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: snapshot.data!.genres?.map((e) => Container(padding: const EdgeInsets.all(7.5), decoration: BoxDecoration(color: Theme.of(context).bottomNavigationBarTheme.backgroundColor, borderRadius: BorderRadius.circular(8)), child: Text('$e'),)).toList() ?? []
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
                      onTap: () {},
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
              ],
            ),
          );
        }
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: PictureIcon('assets/bookmark.png', color: ((widget.isMovie ? (widget.movie?.getBookmark(true) != null) : (widget.series?.getBookmark(false) != null)) ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary)),
        onPressed: () async {
          await showBookmarkSheet(context, widget.isMovie, movie: widget.movie, series: widget.series);
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
            Button(text: 'Watching', textColor: (isMovie ? (movie?.getBookmark(true) == BookmarkType.watching ? Theme.of(context).primaryColor : null) : (series?.getBookmark(false) == BookmarkType.watching ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (isMovie ? movie?.setBookmark(BookmarkType.watching, true) : series?.setBookmark(BookmarkType.watching, false));},),
            Button(text: 'Plan to Watch', textColor: (isMovie ? (movie?.getBookmark(true) == BookmarkType.planned ? Theme.of(context).primaryColor : null) : (series?.getBookmark(false) == BookmarkType.planned ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (isMovie ? movie?.setBookmark(BookmarkType.planned, true) : series?.setBookmark(BookmarkType.planned, false));},),
            Button(text: 'Completed', textColor: (isMovie ? (movie?.getBookmark(true) == BookmarkType.completed ? Theme.of(context).primaryColor : null) : (series?.getBookmark(false) == BookmarkType.completed ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (isMovie ? movie?.setBookmark(BookmarkType.completed, true) : series?.setBookmark(BookmarkType.completed, false));},),
            Button(text: 'on-Hold', textColor: (isMovie ? (movie?.getBookmark(true) == BookmarkType.onHold? Theme.of(context).primaryColor : null) : (series?.getBookmark(false) == BookmarkType.onHold ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (isMovie ? movie?.setBookmark(BookmarkType.onHold, true) : series?.setBookmark(BookmarkType.onHold, false));},),
            Button(text: 'Dropped', textColor: (isMovie ? (movie?.getBookmark(true) == BookmarkType.dropped ? Theme.of(context).primaryColor : null) : (series?.getBookmark(false) == BookmarkType.dropped ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (isMovie ? movie?.setBookmark(BookmarkType.dropped, true) : series?.setBookmark(BookmarkType.dropped, false));},),
            Button(text: 'None', textColor: (isMovie ? (movie?.getBookmark(true) == null ? Theme.of(context).primaryColor : null) : (series?.getBookmark(false) == null ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (isMovie ? movie?.setBookmark(null, true) : series?.setBookmark(null, false));},),
          ],
        ),
      );
    }
  );
}