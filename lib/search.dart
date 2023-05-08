
import 'package:cloudstream/widgets.dart';
import 'package:flutter/material.dart';
import 'package:movie_provider/movie_provider.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: FutureBuilder(
        future: MovieProvider.searchMovies('john wick'),
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            return RefreshIndicator(
              onRefresh: () async {setState(() {});},
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 5,
                  runSpacing: 10,
                  children: snapshot.data!.movies.map((e) => Movie(e)).toList(),
                ),
              ),
            );
          }
          return Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor,));
        }
      ),
    );
  }
}

