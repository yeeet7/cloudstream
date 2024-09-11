
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:reorderables/reorderables.dart';

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
  void initState() {
    super.initState();
    BookmarksStateStorage.sortType = SortType.values.elementAt(Hive.box('config').get('sortType') ?? SortType.dateAdded.index);
    BookmarksStateStorage.sortDirIsAsc = Hive.box('config').get('sortDirIsAsc') ?? true;
  }

  @override
  void dispose() {
    chipCtrl.dispose();
    bookmarksScrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        // floating: true,
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
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowDownWideShort),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                elevation: 0,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return StatefulBuilder(
                    builder: (context, setstate) {
                      return Container(
                        width: MediaQuery.of(context).size.width - 24,
                        margin: const EdgeInsets.all(12),
                        // alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            CustomChip('Custom', BookmarksStateStorage.sortType == SortType.custom, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortType', SortType.custom.index); setstate(() => BookmarksStateStorage.sortType = SortType.custom);}),
                            CustomChip('Date Added', BookmarksStateStorage.sortType == SortType.dateAdded, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortType', SortType.dateAdded.index); setstate(() => BookmarksStateStorage.sortType = SortType.dateAdded);}),
                            CustomChip('Name', BookmarksStateStorage.sortType == SortType.name, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortType', SortType.name.index); setstate(() => BookmarksStateStorage.sortType = SortType.name);}),
                            CustomChip('Average Rating', BookmarksStateStorage.sortType == SortType.averageRating, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortType', SortType.averageRating.index); setstate(() => BookmarksStateStorage.sortType = SortType.averageRating);}),
                            CustomChip('Release Year', BookmarksStateStorage.sortType == SortType.releaseYear, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortType', SortType.releaseYear.index); setstate(() => BookmarksStateStorage.sortType = SortType.releaseYear);}),
                            CustomChip('User Rating', BookmarksStateStorage.sortType == SortType.userRating, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortType', SortType.userRating.index); setstate(() => BookmarksStateStorage.sortType = SortType.userRating);}),
                            SizedBox(width: MediaQuery.of(context).size.width, height: 12,),
                            CustomChip('Ascending', BookmarksStateStorage.sortDirIsAsc == true, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortDirIsAsc', true); setstate(() => BookmarksStateStorage.sortDirIsAsc = true);}),
                            CustomChip('Descending', BookmarksStateStorage.sortDirIsAsc == false, unselectedColor: const Color(0xFF212121), onTap: () async {await Hive.box('config').put('sortDirIsAsc', false); setstate(() => BookmarksStateStorage.sortDirIsAsc = false);}),
                          ],
                        ),
                      );
                    }
                  );
                }
              ).then((value) => setState(() {}));
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(5),
          child: BookmarksStateStorage.sortType != SortType.custom ? Wrap(
            spacing: 5,
            runSpacing: 10,
            children: [
              if(BookmarksStateStorage.type == BookmarkType.watching) ...snapshot.watching.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.completed) ...snapshot.completed.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.planned) ...snapshot.planned.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.onHold) ...snapshot.onHold.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.dropped) ...snapshot.dropped.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value)).toList(),
              ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3)),
            ],
          ) : ReorderableWrap(
            spacing: 5,
            runSpacing: 10,
            children: [
              if(BookmarksStateStorage.type == BookmarkType.watching) ...snapshot.watching.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value, longTapShowsDetails: false)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.completed) ...snapshot.completed.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value, longTapShowsDetails: false)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.planned) ...snapshot.planned.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value, longTapShowsDetails: false)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.onHold) ...snapshot.onHold.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value, longTapShowsDetails: false)).toList(),
              if(BookmarksStateStorage.type == BookmarkType.dropped) ...snapshot.dropped.sortByType(BookmarksStateStorage.sortType, BookmarksStateStorage.sortDirIsAsc).map<Widget>((e) => Movie(e.value, longTapShowsDetails: false)).toList(),
              ...List.generate(2, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3)),
            ],
            onReorder: (oI, nI) async {
              await Bookmarks.set(
                watching: BookmarksStateStorage.type == BookmarkType.watching ? (snapshot.watching..insert(nI, snapshot.watching.removeAt(oI))) : snapshot.watching,
                planned: BookmarksStateStorage.type == BookmarkType.planned ? (snapshot.planned..insert(nI, snapshot.planned.removeAt(oI))) : snapshot.planned,
                completed: BookmarksStateStorage.type == BookmarkType.completed ? (snapshot.completed..insert(nI, snapshot.completed.removeAt(oI))) : snapshot.completed,
                onHold: BookmarksStateStorage.type == BookmarkType.onHold ? (snapshot.onHold..insert(nI, snapshot.onHold.removeAt(oI))) : snapshot.onHold,
                dropped: BookmarksStateStorage.type == BookmarkType.dropped ? (snapshot.dropped..insert(nI, snapshot.dropped.removeAt(oI))) : snapshot.dropped,
              );
              setState(() {});
            }
          ),
        ),
      ),

      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12))
        ),
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

enum SortType {
  dateAdded,
  name,
  averageRating,
  releaseYear,
  custom,
  userRating,
}

extension on List<MapEntry<DateTime, MovieInfo>> {
  List<MapEntry<DateTime, MovieInfo>> sortByType(SortType type, bool isAscending) {
    List<MapEntry<DateTime, MovieInfo>> originalList = toList();
    List<MapEntry<DateTime, MovieInfo>> list;
    if(type == SortType.custom) {
      return isAscending ? originalList : originalList.reversed.toList();
    } else if(type == SortType.dateAdded) {
      list = originalList..sort((a, b) => isAscending ? a.key.compareTo(b.key):b.key.compareTo(a.key));
    } else if(type == SortType.name) {
      list = originalList..sort((a, b) => isAscending ? a.value.title!.compareTo(b.value.title!):b.value.title!.compareTo(a.value.title!));
    } else if(type == SortType.averageRating) {
      list = originalList..sort((a, b) => isAscending ? a.value.rating!.compareTo(b.value.rating!):b.value.rating!.compareTo(a.value.rating!));
    } else if(type == SortType.releaseYear) {
      list = originalList..sort((a, b) => isAscending ? a.value.year!.compareTo(b.value.year!):b.value.year!.compareTo(a.value.year!));
    } else if(type == SortType.userRating) {
      list = originalList..sort((a, b) => isAscending ? (a.value.userRating ?? -1).compareTo(b.value.userRating ?? -1):(b.value.userRating ?? -1).compareTo(a.value.userRating ?? -1));
    } else {
      throw Error();
    }
    return list;
  }
}

abstract class BookmarksStateStorage {

  static BookmarkType type = BookmarkType.watching;
  static double chipOffset = 0;
  static double scrollOffset = 0;
  static SortType sortType = SortType.dateAdded;
  static bool sortDirIsAsc = true;

}