

import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

final bookmarksTextCtrl = TextEditingController();

class BookmarkWidget extends StatefulWidget {
  const BookmarkWidget({super.key});

  @override
  State<BookmarkWidget> createState() => _BookmarkWidgetState();
}

class _BookmarkWidgetState extends State<BookmarkWidget> {

  final snapshot = Bookmarks.get();
  final chipCtrl = ScrollController(initialScrollOffset: BookmarksStateStorage.chipOffset);
  final bookmarksScrollCtrl = ScrollController(initialScrollOffset: BookmarksStateStorage.scrollOffset);

  @override
  void dispose() {
    chipCtrl.dispose();
    bookmarksScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: CustomScrollView(
        controller: bookmarksScrollCtrl..addListener(() => BookmarksStateStorage.scrollOffset = bookmarksScrollCtrl.offset),
        shrinkWrap: true,
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            title: TextField(
              controller: bookmarksTextCtrl,
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
                child: Wrap(
                  spacing: 5,
                  runSpacing: 10,
                  children: [
                    if(BookmarksStateStorage.type == BookmarkType.watching) ...snapshot.watching.map<Widget>((e) => Movie(e)).toList(),
                    if(BookmarksStateStorage.type == BookmarkType.completed) ...snapshot.completed.map<Widget>((e) => Movie(e)).toList(),
                    if(BookmarksStateStorage.type == BookmarkType.planned) ...snapshot.planned.map<Widget>((e) => Movie(e)).toList(),
                    if(BookmarksStateStorage.type == BookmarkType.onHold) ...snapshot.onHold.map<Widget>((e) => Movie(e)).toList(),
                    if(BookmarksStateStorage.type == BookmarkType.dropped) ...snapshot.dropped.map<Widget>((e) => Movie(e)).toList(),
                    ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3)),
                  ],
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
          controller: chipCtrl..addListener(() => BookmarksStateStorage.chipOffset = chipCtrl.offset),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CustomChip('Watching', BookmarksStateStorage.type == BookmarkType.watching, onTap: () => setState(() => BookmarksStateStorage.type = BookmarkType.watching),),
              CustomChip('Plan to Watch', BookmarksStateStorage.type == BookmarkType.planned, onTap: () => setState(() => BookmarksStateStorage.type = BookmarkType.planned),),
              CustomChip('Completed', BookmarksStateStorage.type == BookmarkType.completed, onTap: () => setState(() => BookmarksStateStorage.type = BookmarkType.completed),),
              CustomChip('On-Hold', BookmarksStateStorage.type == BookmarkType.onHold, onTap: () => setState(() => BookmarksStateStorage.type = BookmarkType.onHold),),
              CustomChip('Dropped', BookmarksStateStorage.type == BookmarkType.dropped, onTap: () => setState(() => BookmarksStateStorage.type = BookmarkType.dropped),),
            ],
          )
        ),
      ),

    );
  }
}

abstract class BookmarksStateStorage {

  static BookmarkType type = BookmarkType.watching;
  static double chipOffset = 0;
  static double scrollOffset = 0;

}