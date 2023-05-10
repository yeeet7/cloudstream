

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
        onPressed: () {
          showModalBottomSheet(
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
                    Button(text: 'Watching', textColor: (widget.isMovie ? (widget.movie?.getBookmark(true) == BookmarkType.watching ? Theme.of(context).primaryColor : null) : (widget.series?.getBookmark(false) == BookmarkType.watching ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (widget.isMovie ? widget.movie?.setBookmark(BookmarkType.watching, true) : widget.series?.setBookmark(BookmarkType.watching, false)); setState(() {});},),
                    Button(text: 'Plan to Watch', textColor: (widget.isMovie ? (widget.movie?.getBookmark(true) == BookmarkType.planned ? Theme.of(context).primaryColor : null) : (widget.series?.getBookmark(false) == BookmarkType.planned ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (widget.isMovie ? widget.movie?.setBookmark(BookmarkType.planned, true) : widget.series?.setBookmark(BookmarkType.planned, false)); setState(() {});},),
                    Button(text: 'Completed', textColor: (widget.isMovie ? (widget.movie?.getBookmark(true) == BookmarkType.completed ? Theme.of(context).primaryColor : null) : (widget.series?.getBookmark(false) == BookmarkType.completed ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (widget.isMovie ? widget.movie?.setBookmark(BookmarkType.completed, true) : widget.series?.setBookmark(BookmarkType.completed, false)); setState(() {});},),
                    Button(text: 'on-Hold', textColor: (widget.isMovie ? (widget.movie?.getBookmark(true) == BookmarkType.onHold? Theme.of(context).primaryColor : null) : (widget.series?.getBookmark(false) == BookmarkType.onHold ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (widget.isMovie ? widget.movie?.setBookmark(BookmarkType.onHold, true) : widget.series?.setBookmark(BookmarkType.onHold, false)); setState(() {});},),
                    Button(text: 'Dropped', textColor: (widget.isMovie ? (widget.movie?.getBookmark(true) == BookmarkType.dropped ? Theme.of(context).primaryColor : null) : (widget.series?.getBookmark(false) == BookmarkType.dropped ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (widget.isMovie ? widget.movie?.setBookmark(BookmarkType.dropped, true) : widget.series?.setBookmark(BookmarkType.dropped, false)); setState(() {});},),
                    Button(text: 'None', textColor: (widget.isMovie ? (widget.movie?.getBookmark(true) == null ? Theme.of(context).primaryColor : null) : (widget.series?.getBookmark(false) == null ? Theme.of(context).primaryColor : null)), onTap: () {Navigator.pop(context); (widget.isMovie ? widget.movie?.setBookmark(null, true) : widget.series?.setBookmark(null, false)); setState(() {});},),
                  ],
                ),
              );
            }
          );
        }
      ),

    );
  }
}