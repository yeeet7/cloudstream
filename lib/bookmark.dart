

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

      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
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

          SliverList(
            delegate: SliverChildListDelegate([
              Container(
                margin: const EdgeInsets.all(5),
                child: Builder(
                  builder: (context) {
                    final snapshot = Bookmarks.get();
                    return SingleChildScrollView(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        children: [
                          if(bookmarkType == BookmarkType.watching) ...snapshot.watching.map<Widget>((e) => Movie(e)).toList(),
                          if(bookmarkType == BookmarkType.completed) ...snapshot.completed.map<Widget>((e) => Movie(e)).toList(),
                          if(bookmarkType == BookmarkType.planned) ...snapshot.planned.map<Widget>((e) => Movie(e)).toList(),
                          if(bookmarkType == BookmarkType.onHold) ...snapshot.onHold.map<Widget>((e) => Movie(e)).toList(),
                          if(bookmarkType == BookmarkType.dropped) ...snapshot.dropped.map<Widget>((e) => Movie(e)).toList(),
                          ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3)),
                        ],
                      )
                    );
                  }
                ),
              ),
            ])
          ),
        ],

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