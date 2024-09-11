
import 'dart:ui';
import 'package:cloudstream/view/secondary/items.dart';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

final TextEditingController searchCtrl = TextEditingController();
final ScrollController searchScrollCtrl = ScrollController();
final FocusNode searchNode = FocusNode();
bool submitted = false;

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    searchNode.unfocus();
    searchScrollCtrl.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    searchScrollCtrl.addListener(() {searchScrollCtrl.offset > 0.0 ? (searchNode.hasFocus && MediaQuery.of(Navigator.of(context, rootNavigator: true).context).viewInsets.bottom > 0.0 ? searchNode.unfocus():null) : (!searchNode.hasFocus ? searchNode.requestFocus():null);});
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        // preferredSize: Size(MediaQuery.of(context).size.width, 65),
        // padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 35),
        surfaceTintColor: Colors.transparent,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor?.withAlpha(200),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        title: TextField(
          controller: searchCtrl,
          focusNode: searchNode,
          onSubmitted: (text) {
            setState(() => submitted = text.trim().isNotEmpty);
            if(text.trim().isEmpty) return;
            List<String> history = Hive.box('config').get('searchHistory', defaultValue: <String>[]) as List<String>;
            if(history.contains(text.trim())) {
              history.remove(text.trim());
            }
            history.insert(0, text.trim());
            Hive.box('config').put('searchHistory', history);
          },
          onChanged: (text) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: const TextStyle(color: Colors.white70),
            prefixIcon: Container(margin: const EdgeInsets.all(10), child: PictureIcon('assets/search.png', size: 20,)),
            prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),
            suffixIcon: searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(CupertinoIcons.xmark), onPressed: () => setState(() {searchCtrl.text = ''; submitted = false; searchNode.requestFocus();})) : null,
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

      body: submitted ? FutureBuilder(
        future: MovieProvider.search(searchCtrl.text),
        builder: (context, snapshot) {
          if (snapshot.hasData == false) {
            return SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  const ButtonShimmer(),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Wrap(
                      spacing: 5,
                      children: List.generate(6, (index) => const MovieShimmer()),
                    ),
                  ),
                  const ButtonShimmer(),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Wrap(
                      spacing: 5,
                      children: List.generate(3, (index) => const MovieShimmer()),
                    ),
                  ),
                ],
              ),
            );
          } else if(snapshot.data!.movies.isEmpty && snapshot.data!.series.isEmpty) {
            return const Center(child: Text('Nothing was found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),);
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                Button(
                  text: 'See all movies',
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ItemsView(RichText(text: TextSpan(children: [TextSpan(text: '"${searchCtrl.text}" ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const TextSpan(text: 'in Movies', style: TextStyle(fontSize: 18, color: Colors.white54))])))));},
                ),
                if(snapshot.data != null && snapshot.data!.movies.isNotEmpty) Padding(
                  padding: const EdgeInsets.all(5),
                  child: RefreshIndicator(
                    onRefresh: () async {setState(() {});},
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        // children: snapshot.data!.movies.sublist(0, 6).map((e) => Movie(e)).toList(),
                        children: [
                          ...snapshot.data!.movies.map((e) => Movie(e)).toList().sublist(0, snapshot.data!.movies.length.clamp(0, 6)),
                          SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3,), // if there is only 1 (or 2) item/s this pushes it to the left
                          SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3,), // if there is only 1 (or 2) item/s this pushes it to the left
                        ]
                      ),
                    ),
                  )
                ),
                Button(
                  text: 'See all Tv shows',
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ItemsView(RichText(text: TextSpan(children: [TextSpan(text: '"${searchCtrl.text}" ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const TextSpan(text: 'in Tv', style: TextStyle(fontSize: 18, color: Colors.white54))])), movies: false)));},
                ),
                if(snapshot.data != null && snapshot.data!.series.isNotEmpty) Padding(
                  padding: const EdgeInsets.all(5),
                  child: RefreshIndicator(
                    onRefresh: () async {setState(() {});},
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        // children: snapshot.data!.movies.sublist(0, 6).map((e) => Movie(e)).toList(),
                        children: [
                          ...snapshot.data!.series.map((e) => Movie(e)).toList().sublist(0, snapshot.data!.series.length.clamp(0, 6)),
                          SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3,), // if there is only 1 (or 2) item/s this pushes it to the left
                          SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3,), // if there is only 1 (or 2) item/s this pushes it to the left
                        ]
                      ),
                    ),
                  )
                ),
              ],
            ),
          );
        }
      ) : SingleChildScrollView(
        controller: searchScrollCtrl,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + (Theme.of(context).appBarTheme.toolbarHeight ?? kToolbarHeight)),
            ...(Hive.box('config').get('searchHistory', defaultValue: <String>[]) as List<String>).where((element) => element.contains(searchCtrl.text)).mapIndexed(
              (e, index) => SearchHistoryItem(
                e,
                () => setState(() {searchCtrl.text = e; submitted = true; List<String> history = Hive.box('config').get('searchHistory', defaultValue: <String>[]); history.remove(e); history.insert(0, e); searchNode.unfocus();}),
                () => setState(() {List<String> history = (Hive.box('config').get('searchHistory') as List<String>); history.removeAt(index); Hive.box('config').put('searchHistory', history);}),
              )
            ).toList()
          ],
        ),
      ),

      bottomNavigationBar: submitted ? null : Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => Hive.box('config').put('searchHistory', <String>[])),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete_outline_rounded),
                SizedBox(width: 10,),
                Text('Clear history'),
              ],
            ),
          ),
        ),
      ),

    );
  }
}

class SearchHistoryItem extends StatelessWidget {
  const SearchHistoryItem(this.text, this.onTap, this.onIconTap, {super.key});
  final String text;
  final void Function() onTap;
  final void Function() onIconTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
              IconButton(onPressed: onIconTap, icon: const Icon(CupertinoIcons.xmark))
            ],
          ),
        ),
      ),
    );
  }
}