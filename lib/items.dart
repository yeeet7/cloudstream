
import 'package:cloudstream/search.dart';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

ScrollController itemsViewScrollCtrl = ScrollController();

class ItemsView extends StatefulWidget {
  const ItemsView(this.title, {this.movies = true, super.key});
  final Widget title;
  final bool movies;

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {

  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {    
    return Scaffold(

      body: FutureBuilder(
        future: MovieProvider.search(searchCtrl.text, page: pageIndex + 1),
        builder: (context, snapshot) {
          return SingleChildScrollView(
            controller: itemsViewScrollCtrl,
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                  surfaceTintColor: Colors.transparent,
                  centerTitle: true,
                  title: widget.title,
                  leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () {Navigator.pop(context);}),
                ),
                //items
                (snapshot.data == null || snapshot.connectionState == ConnectionState.waiting)?
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 10,
                    children: List.generate(12, (index) => const MovieShimmer())
                  ),
                ):
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 10,
                    children: (widget.movies ? snapshot.data!.movies:snapshot.data!.series).map<Widget>((e) => Movie(e)).toList() + List.generate(2, (index) => SizedBox(height: 0, width: (MediaQuery.of(context).size.width - 20) / 3,))
                  )
                ),

                //pages
                FutureBuilder(
                  future: MovieProvider.getTotalPagesForSearch(searchCtrl.text, isMovie: widget.movies),
                  builder: (context, snapshot) {
                    if(snapshot.data == null || snapshot.connectionState == ConnectionState.waiting) {
                      return ContainerShimmer(width: MediaQuery.of(context).size.width * 0.6, height: 40);
                    }
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            onPressed: pageIndex == 0 ? null : () {setState(() {pageIndex = pageIndex - 1; itemsViewScrollCtrl.jumpTo(0);});},
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
                                    itemsViewScrollCtrl.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                                    return;
                                  }
                                  setState(() {
                                    pageIndex = index;
                                    itemsViewScrollCtrl.jumpTo(0);
                                  });
                                }),
                            )
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios_rounded),
                            onPressed: pageIndex == snapshot.data! - 1 ? null : () {setState(() {pageIndex = pageIndex + 1; itemsViewScrollCtrl.jumpTo(0);});},
                          ),
                        ],
                      ),
                    );
                  }
                )
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