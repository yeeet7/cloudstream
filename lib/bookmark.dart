

import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

class BookmarkWidget extends StatefulWidget {
  const BookmarkWidget({super.key});

  @override
  State<BookmarkWidget> createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget> {

  BookmarkType bookmarkType = BookmarkType.watching;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: NestedScrollView(
        headerSliverBuilder: (context, scrolled) => [

          SliverAppBar(
            automaticallyImplyLeading: false,
            title: TextField(
              // controller: searchCtrl,
              onSubmitted: (text) {},
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: Container(margin: const EdgeInsets.all(10), child: PictureIcon('assets/search.png', size: 20,)),
                prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),
                fillColor: Colors.black,
                filled: true,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.black)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.black)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.black)),
              ),
            ),
          ),

        ],
        
        body: Container(
          margin: const EdgeInsets.all(5),
          child: FutureBuilder(
            future: MovieProvider.getBookmarks(),
            builder: (context, snapshot) {
              if(snapshot.hasData == false) {
                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 10,
                    children: List.generate(12, (index) => const MovieShimmer()),
                  ),
                );
              }
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 10,
                  children: [
                    if(bookmarkType == BookmarkType.watching) ...[...snapshot.data!.movies.watching.map<Widget>((e) => Movie(e as MovieInfo)).toList(), ...snapshot.data!.series.watching.map<Widget>((e) => Series(e as MovieInfo)).toList()],
                    if(bookmarkType == BookmarkType.completed) ...[...snapshot.data!.movies.completed.map<Widget>((e) => Movie(e as MovieInfo)).toList(), ...snapshot.data!.series.completed.map<Widget>((e) => Series(e as MovieInfo)).toList()],
                    if(bookmarkType == BookmarkType.planned) ...[...snapshot.data!.movies.planned.map<Widget>((e) => Movie(e as MovieInfo)).toList(), ...snapshot.data!.series.planned.map<Widget>((e) => Series(e as MovieInfo)).toList()],
                    if(bookmarkType == BookmarkType.onHold) ...[...snapshot.data!.movies.onHold.map<Widget>((e) => Movie(e as MovieInfo)).toList(), ...snapshot.data!.series.onHold.map<Widget>((e) => Series(e as MovieInfo)).toList()],
                    if(bookmarkType == BookmarkType.dropped) ...[...snapshot.data!.movies.dropped.map<Widget>((e) => Movie(e as MovieInfo)).toList(), ...snapshot.data!.series.dropped.map<Widget>((e) => Series(e as MovieInfo)).toList()],
                    ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3)),
                  ],
                ),
              );
            }
          ),
        ),

      ),

      bottomNavigationBar: Container(
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        width: MediaQuery.of(context).size.width,
        // height: 60,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CustomChip('Watching', bookmarkType == BookmarkType.watching, onTap: () => setState(() => bookmarkType = BookmarkType.watching),),
              CustomChip('Plan to Watch', bookmarkType == BookmarkType.planned, onTap: () => setState(() => bookmarkType = BookmarkType.planned),),
              CustomChip('Completed', bookmarkType == BookmarkType.completed, onTap: () => setState(() => bookmarkType = BookmarkType.completed),),
              CustomChip('On-Hold', bookmarkType == BookmarkType.onHold, onTap: () => setState(() => bookmarkType = BookmarkType.onHold),),
              CustomChip('Dropped', bookmarkType == BookmarkType.dropped, onTap: () => setState(() => bookmarkType = BookmarkType.dropped),),
            ],
          )
        ),
      ),

    );
  }
}