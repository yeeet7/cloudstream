

import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
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

      body: Center(
        child: Text('${widget.isMovie}\n${widget.isMovie?widget.movie?.title:widget.series?.title}\n${widget.isMovie?widget.movie?.url:widget.series?.url}\n${widget.isMovie?widget.movie?.image?.image:widget.series?.image?.image}\n')
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