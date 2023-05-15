
library movie_provider;


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'movie_provider.g.dart';

abstract class MovieProvider {

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(('bookmarksMovies'));
    await Hive.openBox(('bookmarksSeries'));
    await MovieInfo._init();
  }

  static Future<MainPageInfo> getMainPage() async {
    
    final BeautifulSoup soup =  await http.get(Uri.parse('https://secretlink.xyz')).then((val) => BeautifulSoup(val.body));

    final List<Future<MovieInfo>>? scrolling = soup.findAll('div', class_: 'panel-body')[6].find('div')?.children[1].findAll('p', class_: 'text-default').map((e) => MovieProvider.getVideoFromUrl(true, '${e.find('a')?.attributes['href']}')).toList();
    List<MovieInfo> scrollingVideos = [];
    if(scrolling != null) {
      for (var i in scrolling) {
        scrollingVideos.add(await i);
      }
    }

    List<MovieInfo> movies = [];
    for (var e in soup.findAll('div', class_: 'row')[2].find('div', class_: 'row')!.find('div')!.findAll('div', class_: 'no-padding')) {
      var imgGroup = e.find('div', class_: 'img-group');
      String? img = imgGroup?.find('img')?.attributes['src']?.replaceAll('file://', '');
      movies.add(MovieInfo(
        title: imgGroup?.nextSibling?.find('a')?.innerHtml,
        url: imgGroup?.find('a')?.attributes['href'],
        year: imgGroup?.find('div')?.innerHtml,
        image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
      ));
    }

    List<MovieInfo> series = [];
    for (var e in soup.findAll('div', class_: 'row')[5].find('div', class_: 'row')!.find('div')!.findAll('div', class_: 'no-padding')) {
      var imgGroup = e.find('div', class_: 'img-group');
      String? img = imgGroup?.find('img')?.attributes['src']?.replaceAll('file://', '');
      series.add(MovieInfo(
        title: imgGroup?.nextSibling?.find('a')?.innerHtml,
        url: imgGroup?.find('a')?.attributes['href'],
        year: imgGroup?.find('div')?.innerHtml,
        image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
      ));
    }

    return MainPageInfo(
      scrollingVideos: scrollingVideos,
      movies: movies,
      series: series,
    );
  }

  static Future<SearchResult> search(String prompt) async {
    assert(prompt.split(' ').join('').isNotEmpty);

    http.Response html = await http.get(Uri.parse('https://secretlink.xyz/search/keyword/${prompt.split(' ').join('%20')}'));
    assert(html.statusCode == 200);
    
    final soup = BeautifulSoup(html.body);
    // this find everithing on the page not only movies based on the search prompt
    // List<Bs4Element> bsMovies = soup.findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding"); // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    List<Bs4Element> bsMovies = soup.find('div', class_: 'panel-body')!.find('div', class_: 'row')!.find('div', class_: 'row')!.find('div')!.children[0].findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding"); // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    List<Bs4Element> bsSeries = soup.findAll('div', class_: 'panel-body')[1].find('div', class_: 'row')!.find('div', class_: 'row')!.find('div')!.children[0].findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding"); // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    List<MovieInfo> movies = [];
    List<MovieInfo> series = [];
    for (var element in bsMovies) {

      String? img = element.find('img')?.attributes['src'];
      String url = 'https://secretlink.xyz${element.find('img')?.parent?.attributes['href']}';
      
      // Future<String?> vidurl = detailedMovie.then((val) => val.body?.innerHtml);

      movies.add(MovieInfo(
        title: element.find('h5')?.find('a')?.innerHtml.replaceAll('&amp;', '&'),
        url: url,
        year: element.find('img')?.parent?.parent?.find('div')?.innerHtml,
        image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
      ));
    }
    for (var element in bsSeries) {

      String? img = element.find('img')?.attributes['src'];
      String url = 'https://secretlink.xyz${element.find('img')?.parent?.attributes['href']}';
      
      // Future<String?> vidurl = detailedMovie.then((val) => val.body?.innerHtml);

      series.add(MovieInfo(
        title: element.find('h5')?.find('a')?.innerHtml.replaceAll('&amp;', '&'),
        url: url,
        year: element.find('img')?.parent?.parent?.find('div')?.innerHtml,
        image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
      ));
    }
    return SearchResult._init(movies, series);
  }

  static Future<BookmarksSep> getBookmarks() async {
    return BookmarksSep(
      await Bookmarks._fromMap(Hive.box('bookmarksMovies').toMap(), true),
      await Bookmarks._fromMap(Hive.box('bookmarksSeries').toMap(), false),
    );
  }

  static Future<MovieInfo> getVideoFromUrl(bool isMovie, String url) async {
    final uri = url.startsWith('/') ? Uri.parse('https://secretlink.xyz$url') : Uri.parse(url);
    BeautifulSoup soup = await http.get(uri).then((value) => BeautifulSoup(value.body));
    String? img = soup.find('div', class_: 'thumbnail')?.find('img')?.attributes['src'];
    String? year = soup.find('div', class_: 'thumbnail')?.parent?.parent?.parent?.find('p', id: 'wrap')?.previousSibling?.previousSibling?.previousSibling?.previousSibling?.previousSibling?.innerHtml.split('-')[0];
    return MovieInfo(
      title: soup.find('div', class_: 'thumbnail')?.previousSibling?.innerHtml.replaceAll('&amp;', '&'),
      url: url,
      year: year,
      image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
    );

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
    required this.title,
    required this.url,
    required this.year,
    required this.image,
  });

  @HiveField(0)
  final String? title;
  @HiveField(1)
  final String? url;
  @HiveField(2)
  final String? year;
  @HiveField(3)
  final Image? image;

  Future<DetailedMovieInfo> getDetails() async {

    BeautifulSoup detailedMovie = await http.get(Uri.parse('$url')).then((value) => BeautifulSoup(value.body));
    String? desc = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.innerHtml;
    Bs4Element? rating = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.parent?.findAll('div')[3].find('a')?.parent;
    Bs4Element? genres = rating?.parent?.previousElement?.previousElement?.previousElement?.previousElement?.previousElement;
    List<String?>? cast = genres?.previousElement?.previousElement?.previousElement?.previousElement?.findAll('a').map((e) => e.innerHtml).toList();

    return DetailedMovieInfo._init(
      title: title,
      url: url,
      image: image,
      vidurl: null,
      desc: desc,
      year: year,
      genres: genres?.findAll('a').map((e) => e.innerHtml).toList(),
      cast: cast,
      rating: rating?.innerHtml.split(' ')[0],
    );
  }

  Future<void> setBookmark(BookmarkType? bookmark, bool isMovie) async {
    if(bookmark == null) Hive.box(isMovie ? 'bookmarksMovies' : 'bookmarksSeries').delete(url);
    await Hive.box(isMovie ? 'bookmarksMovies' : 'bookmarksSeries').put(url, bookmark?.index);
  }

  BookmarkType? getBookmark(bool isMovie) {
    int? bm = Hive.box(isMovie ? 'bookmarksMovies' : 'bookmarksSeries').get(url);
    if(bm == null) return null;
    return BookmarkType.values.elementAt(bm);
  }

  @override
  String toString() {
    return 'Movie($title, $url, $year, $image)';
  }

}

class DetailedMovieInfo extends MovieInfo {
  
  DetailedMovieInfo._init({
    required this.vidurl,
    required this.desc,
    required this.genres,
    required this.cast,
    required this.rating,
    super.title,
    super.url,
    super.year,
    super.image,
  });

  // final String? title;
  // final String? url;
  // final Image? image;
  final String? desc;
  // final String? year;
  final List<String?>? genres;
  final List<String?>? cast;
  final String? rating;
  final String? vidurl;

  static Future<DetailedMovieInfo> fromUrl(String url) async {

    BeautifulSoup soup = await http.get(Uri.parse(url)).then((val) => BeautifulSoup(val.body));

    String? img = soup.find('img')?.attributes['src'];
    BeautifulSoup detailedMovie = await http.get(Uri.parse(url)).then((value) => BeautifulSoup(value.body));
    String? desc = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.innerHtml;
    Bs4Element? rating = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.parent?.findAll('div')[3].find('a')?.parent;
    Bs4Element? genres = rating?.parent?.previousElement?.previousElement?.previousElement?.previousElement?.previousElement;
    List<String?>? cast = genres?.previousElement?.previousElement?.previousElement?.previousElement?.findAll('a').map((e) => e.innerHtml).toList();

    return DetailedMovieInfo._init(
      title: soup.find('h5')?.find('a')?.innerHtml.replaceAll('&amp;', '&'),
      url: url,
      image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
      vidurl: null,
      desc: desc,
      year: soup.find('img')?.parent?.parent?.find('div')?.innerHtml,
      genres: genres?.findAll('a').map((e) => e.innerHtml).toList(),
      cast: cast,
      rating: rating?.innerHtml.split(' ')[0],
    );
  }
}

class SearchResult {
  SearchResult._init(this.movies, this.series);
  final List<MovieInfo> movies;
  final List<MovieInfo> series;
}