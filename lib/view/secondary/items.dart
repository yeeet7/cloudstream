
import 'dart:ui';
import 'package:cloudstream/view/primary/search.dart';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:movie_provider/movie_provider.dart';

class ItemsView extends StatefulWidget {
  const ItemsView(this.title, {this.movies = true, super.key});
  final Widget title;
  final bool movies;

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {

  int pageIndex = 0;
  Map<int, SearchResult> searchCache = {};
  int? totalPages;

  @override
  Widget build(BuildContext context) {    
    
    bool isEven = (pageIndex + 1) % 2 == 0;
    int apiPage = ((pageIndex + 1) * 3 / 2).floor();
    isEven ? apiPage-- : null;
    
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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: widget.title,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () {Navigator.pop(context);}),
      ),

      body: FutureBuilder(
        future: MovieProvider.search(searchCtrl.text, pageIndex+1, 20/* TODO */),
        builder: (context, snapshot) {
          int itemsInRowCount = int.parse(Hive.box('config').get('ItemsInRowCount', defaultValue: 3).toString().split('.')[0]);
          return SingleChildScrollView(
            primary: true,
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                //items
                (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting)?
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 10,
                    children: List.generate(itemsInRowCount*10, (index) => MovieShimmer(itemsInRowCount))
                  ),
                ):
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 10,
                    children: () {
                      List<Widget> items = (widget.movies ? snapshot.data!.movies : snapshot.data!.series).map<Widget>((e) => Movie(e, itemsInRowCount)).toList();
                      // return items.sublist(isEven?(items.length >= 10 ? 10:items.length-1):0, isEven?null:(items.length >= 30 ? 30 : items.length)) + List.generate(itemsInRowCount-1, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 5*(itemsInRowCount+1)) / itemsInRowCount));
                      return items + List.generate(itemsInRowCount-1, (index) => SizedBox(width: (MediaQuery.of(context).size.width - 5*(itemsInRowCount+1)) / itemsInRowCount));
                    }.call()
                  )
                ),

              ],
            ),
          );
        }
      ),

      //pages
      bottomNavigationBar: FutureBuilder(
        future: () async {
          if(totalPages != null) {
            return totalPages;
          }
          totalPages = await MovieProvider.getTotalPagesForSearch(searchCtrl.text, isMovie: widget.movies).then((val) => val == 1 ? 1 : (val * 2 / 3 - 1).ceil());
          return totalPages;
        }.call(),
        builder: (context, snapshot) {
          if(snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
            return ContainerShimmer(width: MediaQuery.of(context).size.width * 0.6, height: 40);
          }
          return Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: pageIndex == 0 ? null : () {setState(() {pageIndex -= 1; PrimaryScrollController.of(context).jumpTo(0);});},
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                  height: 44,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemExtent: 44,
                    cacheExtent: 100,
                    itemCount: snapshot.data,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) => PageButton(
                      '${index + 1}',
                      pageIndex == index,
                      () {
                        if(pageIndex == index) {
                          PrimaryScrollController.of(context).animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                          return;
                        }
                        setState(() {
                          pageIndex = index;
                          PrimaryScrollController.of(context).jumpTo(0);
                        });
                      }),
                  )
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onPressed: pageIndex == snapshot.data! - 1 ? null : () {setState(() {pageIndex += 1; PrimaryScrollController.of(context).jumpTo(0);});},
                ),
              ],
            ),
          );
        }
      ),

    );
  }
}

class PageButton extends StatelessWidget {
  const PageButton(this.text, this.selected, this.onTap, {super.key});
  final bool selected;
  final String text;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: selected ? Theme.of(context).primaryColor : Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        border: selected ? null : Border.all(color: Theme.of(context).primaryColor, width: 1),
        borderRadius: BorderRadius.circular(6)
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Center(child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, color: selected ? Theme.of(context).bottomNavigationBarTheme.backgroundColor : Theme.of(context).primaryColor))),
        ),
      ),
    );
  }
}