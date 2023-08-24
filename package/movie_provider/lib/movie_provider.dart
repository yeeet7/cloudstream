
// ignore_for_file: non_constant_identifier_names

library movie_provider;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmdb_api/tmdb_api.dart';
// part 'movie_provider.g.dart';

abstract class MovieProvider {

  static Future<void> init([bool include_adult = false]) async {
    await Hive.initFlutter();
    await Bookmarks.init();
    includeAdult = include_adult;
  }

  static bool includeAdult = false;
  static final tmdbapi = TMDB(ApiKeys('3f5b06db37952faf200cd81ce2bec56b', 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzZjViMDZkYjM3OTUyZmFmMjAwY2Q4MWNlMmJlYzU2YiIsInN1YiI6IjY0YjFhMTdiYTNiNWU2MDBlMjNmMzc2MiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.wmOhwMhnzKOVlPpEZyMGGaDKPM2Q2Rn5VRGgmWxI98Q'));

  static Future<MainPageInfo> getMainPage() async {
    List<MovieInfo> scrolling = ((await tmdbapi.v3.trending.getTrending())['results'] as List).map(
      (e) {
        bool movie = e['media_type'] == 'movie';
        return MovieInfo(
          movie: movie,
          title: movie?e['title']:e['name'],
          id: e['id'],
          year: movie?e['release_date']:e['first_air_date'],
          poster: 'https://image.tmdb.org/t/p/original${e['poster_path']}',
          banner: 'https://image.tmdb.org/t/p/original${e['backdrop_path']}',
          desc: e['overview'],
          cast: e['cast'],
          genres: (e['genre_ids'] as List).cast<int>(),
          rating: e['vote_average'],
        );
      }
    ).toList();

    List<MovieInfo> movies = ((await tmdbapi.v3.movies.getPopular())['results'] as List).map(
      (e) => MovieInfo(
        movie: true,
        title: e['title'],
        id: e['id'],
        year: e['release_date'],
        poster: 'https://image.tmdb.org/t/p/w300${e['poster_path']}',
        banner: 'https://image.tmdb.org/t/p/original${e['backdrop_path']}',
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List).cast<int>(),
        rating: e['vote_average'],
      )
    ).toList();

    List<MovieInfo> series = ((await tmdbapi.v3.tv.getPopular())['results'] as List).map(
      (e) => MovieInfo(
        movie: false,
        title: e['name'],
        id: e['id'],
        year: e['first_air_date'],
        poster: 'https://image.tmdb.org/t/p/w300${e['poster_path']}',
        banner: 'https://image.tmdb.org/t/p/original${e['backdrop_path']}',
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

  static Future<int> getTotalPagesForSearch(String prompt, {bool isMovie = true}) async {
    Map res = isMovie ? await tmdbapi.v3.search.queryMovies(prompt, includeAdult: MovieProvider.includeAdult):await tmdbapi.v3.search.queryTvShows(prompt);
    return res['total_pages'];
  } 

  static Future<SearchResult> search(String prompt, [int page = 1]) async {
    List<MovieInfo> movies = ((await tmdbapi.v3.search.queryMovies(prompt, page: page, includeAdult: MovieProvider.includeAdult))['results'] as List).map(
      (e) => MovieInfo(
        title: e['title'],
        id: e['id'],
        year: e['release_date'],
        poster: e['poster_path'] != null ? 'https://image.tmdb.org/t/p/w300${e['poster_path']}':null,
        banner: e['poster_path'] != null ? 'https://image.tmdb.org/t/p/w300${e['poster_path']}':null,
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
        poster: e['poster_path'] != null ? 'https://image.tmdb.org/t/p/w300${e['poster_path']}':null,
        banner: e['poster_path'] != null ? 'https://image.tmdb.org/t/p/w300${e['poster_path']}':null,
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List).cast<int>(),
        rating: e['vote_average'],
        movie: false
      )
    ).toList();
    
    return SearchResult(movies, series);
  }

  static Future<Details> getDetailsById(MovieInfo movie) async {
    final TMDB tmdbapi = MovieProvider.tmdbapi;
    late List cast;
    // late List<Map<int, String?>> genres;
    late List genres;
    if(movie.movie) {
      // res = (await tmdbapi.v3.genres.getMovieList())['genres'];
      genres = ((await tmdbapi.v3.movies.getDetails(movie.id!))['genres'] as List).map((e) => e['name']).toList();// as List<Map<int, String?>>;
      cast = (await tmdbapi.v3.movies.getCredits(movie.id!))['cast'];
    } else {
      genres = ((await tmdbapi.v3.tv.getDetails(movie.id!))['genres'] as List).map((e) => e['name']).toList();// as List<Map<int, String?>>;
      cast = (await tmdbapi.v3.tv.getCredits(movie.id!))['cast'];
    }
    return Details(
      cast.map((e) => Person('${e['name']}', '${e['character']}', '${e['profile_path']}')).toList(),
      genres,
    );
  }

}

class Details {
  Details(this.cast, this.genres);
  final List<Person> cast;
  final List genres;
}

class Person {
  Person(this.name, this.role, this.image);
  final String name;
  final String role;
  final String image;
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

class Bookmarks {

  Bookmarks._({
    required this.watching,
    required this.completed,
    required this.planned,
    required this.onHold,
    required this.dropped,
  });

  static Future<void> init() async {
    // Hive.registerAdapter(MovieInfoAdapter());
    await Hive.openBox('bookmarks');
  }

  static Bookmarks get() {
    return Bookmarks._(
      watching: ((Hive.box('bookmarks').get('watching') ?? []) as List).cast<Map<dynamic, dynamic>>().map((e) => MapEntry(DateTime.parse(e['dateTime'].toString()), e.toMovieInfo())).toList(),
      planned: ((Hive.box('bookmarks').get('planned') ?? []) as List).cast<Map<dynamic, dynamic>>().map((e) => MapEntry(DateTime.parse(e['dateTime'].toString()), e.toMovieInfo())).toList(),
      completed: ((Hive.box('bookmarks').get('completed') ?? []) as List).cast<Map<dynamic, dynamic>>().map((e) => MapEntry(DateTime.parse(e['dateTime'].toString()), e.toMovieInfo())).toList(),
      onHold: ((Hive.box('bookmarks').get('onHold') ?? []) as List).cast<Map<dynamic, dynamic>>().map((e) => MapEntry(DateTime.parse(e['dateTime'].toString()), e.toMovieInfo())).toList(),
      dropped: ((Hive.box('bookmarks').get('dropped') ?? []) as List).cast<Map<dynamic, dynamic>>().map((e) => MapEntry(DateTime.parse(e['dateTime'].toString()), e.toMovieInfo())).toList(),
    );
  }

  static Future<void> set({
    required List<Map<dynamic, dynamic>> watching,
    required List<Map<dynamic, dynamic>> planned,
    required List<Map<dynamic, dynamic>> completed,
    required List<Map<dynamic, dynamic>> onHold,
    required List<Map<dynamic, dynamic>> dropped
  }) async {
    await Hive.box('bookmarks').put(BookmarkType.watching.name, watching);
    await Hive.box('bookmarks').put(BookmarkType.planned.name, planned);
    await Hive.box('bookmarks').put(BookmarkType.completed.name, completed);
    await Hive.box('bookmarks').put(BookmarkType.onHold.name, onHold);
    await Hive.box('bookmarks').put(BookmarkType.dropped.name, dropped);
  }

  static Future<void> setBookmark(BookmarkType? type, MovieInfo movie) async {
    BookmarkType? oldBmType = findMovie(movie);
    if(oldBmType != null) {
      List<Map<dynamic, dynamic>> oldBm = ((Hive.box('bookmarks').get(oldBmType.name.toLowerCase()) ?? []) as List).cast<Map<dynamic, dynamic>>();
      oldBm.removeWhere((e) => (e['id'] as int?) == movie.id);
      await Hive.box('bookmarks').put(oldBmType.name, oldBm);
    }
    if(type != null) {
      List<Map<dynamic, dynamic>> list = ((Hive.box('bookmarks').get(type.name) ?? []) as List).cast<Map<dynamic, dynamic>>();
      Map<dynamic, dynamic> movieMap = movie.toMap();
      movieMap['dateTime'] = DateTime.timestamp().toString();
      list.add(movieMap);
      await Hive.box('bookmarks').put(type.name, list);
    }
  }

  static BookmarkType? findMovie(MovieInfo movie) {
    Bookmarks bookmarks = get();
    if(bookmarks.watching.map((e) => e.value.id).contains(movie.id)) {
      return BookmarkType.watching;
    } else if(bookmarks.completed.map((e) => e.value.id).contains(movie.id)) {
      return BookmarkType.completed;
    } else if(bookmarks.planned.map((e) => e.value.id).contains(movie.id)) {
      return BookmarkType.planned;
    } else if(bookmarks.onHold.map((e) => e.value.id).contains(movie.id)) {
      return BookmarkType.onHold;
    } else if(bookmarks.dropped.map((e) => e.value.id).contains(movie.id)) {
      return BookmarkType.dropped;
    }
    return null;
  }

  List<MapEntry<DateTime, MovieInfo>> watching = [];
  List<MapEntry<DateTime, MovieInfo>> completed = [];
  List<MapEntry<DateTime, MovieInfo>> planned = [];
  List<MapEntry<DateTime, MovieInfo>> onHold = [];
  List<MapEntry<DateTime, MovieInfo>> dropped = [];

}

@HiveType(typeId: 0)
class MovieInfo {

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
  final String? poster;
  @HiveField(5)
  final String? banner;
  @HiveField(6)
  final String? desc;
  @HiveField(7)
  final List<int>? genres;
  @HiveField(8)
  final List<String?>? cast;
  @HiveField(9)
  final num? rating;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'id': id,
      'year': year,
      'poster': poster,
      'desc': desc,
      'genres': genres,
      'cast': cast,
      'rating': rating,
      'banner': banner,
      'movie': movie,
    };
  }

  @override
  String toString() {
    return '${movie?'Movie':'Seies'}($title)';
  }

}

class SearchResult {
  SearchResult(this.movies, this.series);
  final List<MovieInfo> movies;
  final List<MovieInfo> series;
}

extension Movies on Map {
  MovieInfo toMovieInfo() {
    return MovieInfo(
      title: this['title'],
      id: this['id'],
      year: this['year'],
      poster: this['poster'],
      desc: this['desc'],
      genres: this['genres'],
      cast: this['cast'],
      rating: this['rating'],
      banner: this['banner'],
      movie: this['movie'],
    );
  }
}