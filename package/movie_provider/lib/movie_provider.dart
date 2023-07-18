
library movie_provider;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:tmdb_api/tmdb_api.dart';
part 'movie_provider.g.dart';

abstract class MovieProvider {

  static Future<void> init() async {
    await Hive.initFlutter();
    await Bookmarks.init();
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
          poster: 'https://image.tmdb.org/t/p/original${e['poster_path']}',
          banner: 'https://image.tmdb.org/t/p/original${e['backdrop_path']}',
          desc: e['overview'],
          cast: e['cast'],
          genres: (e['genre_ids'] as List),
          rating: e['vote_average'],
        );
      }
    ).toList();

    List<MovieInfo> movies = ((await tmdbapi.v3.movies.getPopular())['results'] as List).map(
      (e) => MovieInfo(
        title: e['title'],
        id: e['id'],
        year: e['release_date'],
        poster: 'https://image.tmdb.org/t/p/w300${e['poster_path']}',
        banner: 'https://image.tmdb.org/t/p/original${e['backdrop_path']}',
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List),
        rating: e['vote_average'],
      )
    ).toList();

    List<MovieInfo> series = ((await tmdbapi.v3.tv.getPopular())['results'] as List).map(
      (e) => MovieInfo(
        title: e['name'],
        id: e['id'],
        year: e['first_air_date'],
        poster: 'https://image.tmdb.org/t/p/w300${e['poster_path']}',
        banner: 'https://image.tmdb.org/t/p/original${e['backdrop_path']}',
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List),
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
        poster: e['poster_path'] != null ? 'https://image.tmdb.org/t/p/w300${e['poster_path']}':null,
        banner: e['poster_path'] != null ? 'https://image.tmdb.org/t/p/w300${e['poster_path']}':null,
        cast: e['cast'],
        desc: e['overview'],
        genres: (e['genre_ids'] as List),
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
        genres: (e['genre_ids'] as List),
        rating: e['vote_average'],
        movie: false
      )
    ).toList();
    
    return SearchResult._init(movies, series);
  }

  static Future<MovieInfo> getVideoFromUrl(bool isMovie, String url) async {
    return MovieInfo(title: 'title', id: 0, year: 'year', poster: null, banner: null, cast: [], desc: '', genres: [], rating: null, movie: true);
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
    Hive.registerAdapter(MovieInfoAdapter());
    await Hive.openBox('bookmarks');
  }

  static Bookmarks get() {
    return Bookmarks._(
      watching: (Hive.box('bookmarks').get('watching') ?? []).cast<MovieInfo>(),
      planned: (Hive.box('bookmarks').get('planned') ?? []).cast<MovieInfo>(),
      onHold: (Hive.box('bookmarks').get('onHold') ?? []).cast<MovieInfo>(),
      dropped: (Hive.box('bookmarks').get('dropped') ?? []).cast<MovieInfo>(),
      completed: (Hive.box('bookmarks').get('completed') ?? []).cast<MovieInfo>(),
    );
  }

  static Future<void> setBookmark(BookmarkType? type, MovieInfo movie) async {
    BookmarkType? oldBmType = findMovie(movie);
    if(oldBmType != null) {
      List<MovieInfo> oldBm = ((Hive.box('bookmarks').get(oldBmType.name.toLowerCase()) ?? []) as List).cast<MovieInfo>();
      oldBm.remove(movie);
      await Hive.box('bookmarks').put(oldBmType.name, oldBm);
    }
    if(type != null) {
      List<MovieInfo> list = ((Hive.box('bookmarks').get(type.name) ?? []) as List).cast<MovieInfo>();
      list.add(movie);
      await Hive.box('bookmarks').put(type.name, list);
    }
  }

  static BookmarkType? findMovie(MovieInfo movie) {
    Bookmarks bookmarks = get();
    if(bookmarks.watching.map((e) => e.id).contains(movie.id)) {
      return BookmarkType.watching;
    } else if(bookmarks.completed.map((e) => e.id).contains(movie.id)) {
      return BookmarkType.completed;
    } else if(bookmarks.planned.map((e) => e.id).contains(movie.id)) {
      return BookmarkType.planned;
    } else if(bookmarks.onHold.map((e) => e.id).contains(movie.id)) {
      return BookmarkType.onHold;
    } else if(bookmarks.dropped.map((e) => e.id).contains(movie.id)) {
      return BookmarkType.dropped;
    }
    return null;
  }

  List<MovieInfo> watching = [];
  List<MovieInfo> completed = [];
  List<MovieInfo> planned = [];
  List<MovieInfo> onHold = [];
  List<MovieInfo> dropped = [];

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
  final List? genres;
  @HiveField(8)
  final List<String?>? cast;
  @HiveField(9)
  final num? rating;

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