
import 'dart:developer';
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

TextEditingController searchCtrl = TextEditingController();
bool submitted = false;

class _SearchState extends State<Search> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: Container(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 35),
          child: TextField(
            controller: searchCtrl,
            onSubmitted: (text) {log('submit');setState(() => submitted = text.trim().isNotEmpty);},
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: const TextStyle(color: Colors.white70),
              prefixIcon: Container(margin: const EdgeInsets.all(10), child: PictureIcon('assets/search.png', size: 20,)),
              prefixIconConstraints: const BoxConstraints(minHeight: 20, minWidth: 20),
              fillColor: Colors.black,
              filled: true,
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.black)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.black)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.black)),
            ),
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
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                Button(
                  text: 'See all movies',
                  onTap: () {},//TODO
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: RefreshIndicator(
                    onRefresh: () async {setState(() {});},
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        // children: snapshot.data!.movies.sublist(0, 6).map((e) => Movie(e)).toList(),
                        children: [
                          ...snapshot.data!.movies.map((e) => Movie(e)).toList(),
                          SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3,), // if there is only 1 (or 2) item/s this pushes it to the left
                          SizedBox(width: (MediaQuery.of(context).size.width - 20) / 3,), // if there is only 1 (or 2) item/s this pushes it to the left
                        ]
                      ),
                    ),
                  )
                ),
                Button(
                  text: 'See all Tv shows',
                  onTap: () {},
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: RefreshIndicator(
                    onRefresh: () async {setState(() {});},
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        // children: snapshot.data!.movies.sublist(0, 6).map((e) => Movie(e)).toList(),
                        children: [
                          ...snapshot.data!.series.map((e) => Series(e)).toList(),
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
      ) : null,

      bottomNavigationBar: submitted ? null : Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},//TODO
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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

