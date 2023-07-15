
library movie_provider;



import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmdb_api/tmdb_api.dart';
part 'movie_provider.g.dart';

abstract class MovieProvider {

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(('bookmarksMovies'));
    await Hive.openBox(('bookmarksSeries'));
    await MovieInfo._init();
  }

  static final tmdbapi = TMDB(ApiKeys('3f5b06db37952faf200cd81ce2bec56b', 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZjViMDZkYjM3OTUyZmFmMjAwY2Q4MWNlMmJlYzU2YiIsInN1YiI6IjY0YjFhMTdiYTNiNWU2MDBlMjNmMzc2MiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wmOhwMhnzKOVlPpEZyMGGaDKPM2Q2Rn5VRGgmWxI98Q'));

  static Future<MainPageInfo> getMainPage() async {
    List<MovieInfo> scrolling = ((await tmdbapi.v3.trending.getTrending())['results'] as List).map(
      (e) {
        bool movie = e['media_type'] == 'movie';
        return MovieInfo(
          title: movie?e['title']:e['name'],
          id: e['id'],
          year: movie?e['release_date']:e['first_air_date'],
          poster: Image.network('https://image.tmdb.org/t/p/w500${e['poster_path']}'),
          banner: Image.network('https://image.tmdb.org/t/p/w500${e['backdrop_path']}'),
          desc: e['overview'],
          cast: e['cast'],
          genres: (e['genre_ids'] as List).cast<int>(),
          rating: e['vote_average'],
        );
      }
    ).toList();

    List<MovieInfo> movies = ((await tmdbapi.v3.movies.getPopular())['results'] as List).map(
      (e) => MovieInfo(
        title: e['title'],
        id: e['id'],
        year: e['release_date'],
        poster: Image.network('https://image.tmdb.org/t/p/w300${e['poster_path']}'),
        banner: Image.network('https://image.tmdb.org/t/p/w300${e['backdrop_path']}'),
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List).cast<int>(),
        rating: e['vote_average'],
      )
    ).toList();

    List<MovieInfo> series = ((await tmdbapi.v3.tv.getPopular())['results'] as List).map(
      (e) => MovieInfo(
        title: e['name'],
        id: e['id'],
        year: e['first_air_date'],
        poster: Image.network('https://image.tmdb.org/t/p/w300${e['poster_path']}'),
        banner: Image.network('https://image.tmdb.org/t/p/w300${e['backdrop_path']}'),
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List).cast<int>(),
        rating: e['vote_average'],
      )
    ).toList();

    return MainPageInfo(
      scrollingVideos: scrolling,
      movies: movies,
      series: series,
    );
  }

  static Future<SearchResult> search(String prompt) async {
    List<MovieInfo> movies = ((await tmdbapi.v3.search.queryMovies(prompt))['results'] as List).map(
      (e) => MovieInfo(
        title: e['title'],
        id: e['id'],
        year: e['release_date'],
        poster: e['poster_path'] != null ? Image.network('https://image.tmdb.org/t/p/w300${e['poster_path']}'):null,
        banner: e['poster_path'] != null ? Image.network('https://image.tmdb.org/t/p/w300${e['poster_path']}'):null,
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List).cast<int>(),
        rating: e['vote_average'],
      )
    ).toList();
    List<MovieInfo> series = ((await tmdbapi.v3.search.queryTvShows(prompt))['results'] as List).map(
      (e) => MovieInfo(
        title: e['name'],
        id: e['id'],
        year: e['first_air_date'],
        poster: e['poster_path'] != null ? Image.network('https://image.tmdb.org/t/p/w300${e['poster_path']}'):null,
        banner: e['poster_path'] != null ? Image.network('https://image.tmdb.org/t/p/w300${e['poster_path']}'):null,
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List).cast<int>(),
        rating: e['vote_average'],
      )
    ).toList();
    
    return SearchResult._init(movies, series);
  }

  static Future<BookmarksSep> getBookmarks() async {
    return BookmarksSep(
      await Bookmarks._fromMap(Hive.box('bookmarksMovies').toMap(), true),
      await Bookmarks._fromMap(Hive.box('bookmarksSeries').toMap(), false),
    );
  }

  static Future<MovieInfo> getVideoFromUrl(bool isMovie, String url) async {
    return MovieInfo(title: 'title', id: 0, year: 'year', poster: null, banner: null, cast: [], desc: '', genres: [], rating: null, movie: true);
  }

}

extension Genres on List<int> {
  Future<List<String>> getGenresFromIds(bool isMovie) async {
    final TMDB tmdbapi = MovieProvider.tmdbapi;
    late List res;
    if(isMovie) {
      res = (await tmdbapi.v3.genres.getMovieList())['genres'];
    } else {
      res = (await tmdbapi.v3.genres.getTvlist())['genres'];
    }
    return res.where((element) => contains(element['id'])).map((e) => e['name'].toString()).toList();
  }
}

class MainPageInfo {

  MainPageInfo({
    required this.scrollingVideos,
    required this.movies,
    required this.series,
  });

  List<MovieInfo> scrollingVideos;
  List<MovieInfo> movies;
  List<MovieInfo> series;

}

enum BookmarkType {
  completed,
  watching,
  dropped,
  onHold,
  planned,
}

class BookmarksSep {
  BookmarksSep(
    this.movies,
    this.series,
  );
  final Bookmarks movies;
  final Bookmarks series;
}

class Bookmarks {

  Bookmarks({
    required this.watching,
    required this.completed,
    required this.planned,
    required this.onHold,
    required this.dropped,
  });

  static Future<Bookmarks> _fromMap(Map<dynamic, dynamic> map, bool isMovie) async {
    
    List watchingt = [];
    List completedt = [];
    List plannedt = [];
    List onHoldt = [];
    List droppedt = [];
    for (var el in map.entries) {
      if(isMovie) {
        MovieInfo movie = await MovieProvider.getVideoFromUrl(true, el.key);
        if(el.value == BookmarkType.watching.index) {
          watchingt.add(movie);
        } else if(el.value == BookmarkType.completed.index) {
          completedt.add(movie);
        } else if(el.value == BookmarkType.planned.index) {
          plannedt.add(movie);
        } else if(el.value == BookmarkType.onHold.index) {
          onHoldt.add(movie);
        } else if(el.value == BookmarkType.dropped.index) {
          droppedt.add(movie);
        } else if(el.value == null) {
          
        } else {
          throw Error();
        }
      }
      else {
        MovieInfo series = await MovieProvider.getVideoFromUrl(false, el.key);
        if(el.value == BookmarkType.watching.index) {
          watchingt.add(series);
        } else if(el.value == BookmarkType.completed.index) {
          completedt.add(series);
        } else if(el.value == BookmarkType.planned.index) {
          plannedt.add(series);
        } else if(el.value == BookmarkType.onHold.index) {
          onHoldt.add(series);
        } else if(el.value == BookmarkType.dropped.index) {
          droppedt.add(series);
        } else if(el.value == null) {
          
        } else {
          throw Error();
        }
      }
    }
    return Bookmarks(
      watching: watchingt,
      completed: completedt,
      planned: plannedt,
      onHold: onHoldt,
      dropped: droppedt,
    );
  }

  List watching = [];
  List completed = [];
  List planned = [];
  List onHold = [];
  List dropped = [];

}


@HiveType(typeId: 0)
class MovieInfo {

  static Future<void> _init() async {
    await Hive.initFlutter();
    await Hive.openBox('bookmarksMovies');
    await Hive.openBox('bookmarksSeries');
  }

  MovieInfo({
    this.movie = true,
    required this.title,
    required this.id,
    required this.year,
    required this.poster,
    required this.desc,
    required this.genres,
    required this.cast,
    required this.rating,
    required this.banner,
  });

  @HiveField(0)
  final bool movie;
  @HiveField(1)
  final String? title;
  @HiveField(2)
  final int? id;
  @HiveField(3)
  final String? year;
  @HiveField(4)
  final Image? poster;
  @HiveField(5)
  final Image? banner;
  @HiveField(6)
  final String? desc;
  @HiveField(7)
  final List<int>? genres;
  @HiveField(8)
  final List<String?>? cast;
  @HiveField(9)
  final num? rating;

  Future<void> setBookmark(BookmarkType? bookmark, bool isMovie) async {
    if(bookmark == null) Hive.box(isMovie ? 'bookmarksMovies' : 'bookmarksSeries').delete(id);
    await Hive.box(isMovie ? 'bookmarksMovies' : 'bookmarksSeries').put(id, bookmark?.index);
  }

  BookmarkType? getBookmark(bool isMovie) {
    int? bm = Hive.box(isMovie ? 'bookmarksMovies' : 'bookmarksSeries').get(id);
    if(bm == null) return null;
    return BookmarkType.values.elementAt(bm);
  }

  @override
  String toString() {
    return '${movie?'Movie':'Seies'}($title)';
  }

}

class SearchResult {
  SearchResult._init(this.movies, this.series);
  final List<MovieInfo> movies;
  final List<MovieInfo> series;
}

String toWeekday(int day) {
  switch(day) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return 'Err';
  }
}