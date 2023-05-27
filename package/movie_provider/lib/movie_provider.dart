
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
    
    // DateTime datetime = DateTime.now();
    final BeautifulSoup soup =  await http.get(
      Uri.parse('https://secretlink.xyz'),
      headers: {
        // // 'cookie': 'cf_clearance=bfKlKCiENlUD.zmFQ4DNO7XWilbYkgKi_QtKR7RzgCc-1685209554-0-160; path=/; expires=${toWeekday(datetime.weekday)}, ${datetime.day}-${datetime.month}-${int.parse(datetime.year.toString().substring(2)) + 1} ${datetime.hour}:${datetime.minute}:${datetime.second} GMT; domain=.secretlink.xyz; HttpOnly; Secure; SameSite=None',
        // 'authority': 'secretlink.xyz',
        // 'method': 'GET',//'POST',
        // 'path': '/',
        // 'scheme': 'https',
        // 'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        // 'accept-encoding': 'gzip, deflate, br',
        // 'accept-language': 'sk-SK,sk;q=0.6',
        // 'cache-control': 'max-age=0',
        // 'content-length': '3019',
        // 'content-type': 'application/x-www-form-urlencoded',
        // 'cookie': 'cf_clearance=rMbhyb0SjOEkOP0zEFAhb.S.vSUIrPIcZFlIMUSUUZA-1685211928-0-160',
        // 'origin': 'https://secretlink.xyz',
        // 'referer': 'https://secretlink.xyz/?__cf_chl_tk=opR9FFjraC7p9NjjZ7Zu7plyuoz7Gec2Sy8HqAxL6Dc-1685209554-0-gaNycGzNCyU',
        // 'sec-ch-ua': '"Brave";v="113", "Chromium";v="113", "Not-A.Brand";v="24"',
        // 'sec-ch-ua-mobile': '?0',
        // 'sec-ch-ua-platform': "Windows",
        // 'sec-fetch-dest': 'document',
        // 'sec-fetch-mode': 'navigate',
        // 'sec-fetch-site': 'same-origin',
        // 'sec-fetch-user': '?1',
        // 'sec-gpc': '1',
        // 'upgrade-insecure-requests': '1',
        // 'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
      }
    ).then((val) => BeautifulSoup(val.body));

    final scrolling1 = soup.findAll('div', class_: 'panel-body');
    List<Future<MovieInfo>> scrolling = [];
    if(scrolling1.length >= 7) {
      scrolling = scrolling1.elementAt(6).find('div')?.children[1].findAll('p', class_: 'text-default').map((e) => MovieProvider.getVideoFromUrl(true, '${e.find('a')?.attributes['href']}')).toList() ?? [];
    }
    List<MovieInfo> scrollingVideos = [];
    for (var i in scrolling) {
      scrollingVideos.add(await i);
    }

    List<MovieInfo> movies = [];
    final movies1 = soup.findAll('div', class_: 'row');
    if(movies1.length >= 3) {
      for (var e in movies1[2].find('div', class_: 'row')!.find('div')!.findAll('div', class_: 'no-padding')) {
        var imgGroup = e.find('div', class_: 'img-group');
        String? img = imgGroup?.find('img')?.attributes['src']?.replaceAll('file:///', '');
        movies.add(MovieInfo(
          title: imgGroup?.nextSibling?.find('a')?.innerHtml,
          url: imgGroup?.find('a')?.attributes['href'],
          year: imgGroup?.find('div')?.innerHtml,
          image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
        ));
      }
    }

    List<MovieInfo> series = [];
    final series1 = soup.findAll('div', class_: 'row');
    if(series1.length >= 6) {
      for (var e in series1[5].find('div', class_: 'row')!.find('div')!.findAll('div', class_: 'no-padding')) {
        var imgGroup = e.find('div', class_: 'img-group');
        String? img = imgGroup?.find('img')?.attributes['src']?.replaceAll('file://', '');
        series.add(MovieInfo(
          title: imgGroup?.nextSibling?.find('a')?.innerHtml,
          url: imgGroup?.find('a')?.attributes['href'],
          year: imgGroup?.find('div')?.innerHtml,
          image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
        ));
      }
    }

    return MainPageInfo(
      scrollingVideos: scrollingVideos,
      movies: movies,
      series: series,
    );
  }

  static Future<SearchResult> search(String prompt) async {
    assert(prompt.split(' ').join('').isNotEmpty);

    http.Response html = await http.get(
      Uri.parse('https://secretlink.xyz/search/keyword/${prompt.split(' ').join('%20')}'),
      headers: {
        // // 'cookie': 'cf_clearance=bfKlKCiENlUD.zmFQ4DNO7XWilbYkgKi_QtKR7RzgCc-1685209554-0-160; path=/; expires=${toWeekday(datetime.weekday)}, ${datetime.day}-${datetime.month}-${int.parse(datetime.year.toString().substring(2)) + 1} ${datetime.hour}:${datetime.minute}:${datetime.second} GMT; domain=.secretlink.xyz; HttpOnly; Secure; SameSite=None',
        // 'authority': 'secretlink.xyz',
        // 'method': 'GET',//'POST',
        // 'path': '/',
        // 'scheme': 'https',
        // 'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        // 'accept-encoding': 'gzip, deflate, br',
        // 'accept-language': 'sk-SK,sk;q=0.6',
        // 'cache-control': 'max-age=0',
        // 'content-length': '3019',
        // 'content-type': 'application/x-www-form-urlencoded',
        // 'cookie': 'cf_clearance=rMbhyb0SjOEkOP0zEFAhb.S.vSUIrPIcZFlIMUSUUZA-1685211928-0-160',
        // 'origin': 'https://secretlink.xyz',
        // 'referer': 'https://secretlink.xyz/?__cf_chl_tk=opR9FFjraC7p9NjjZ7Zu7plyuoz7Gec2Sy8HqAxL6Dc-1685209554-0-gaNycGzNCyU',
        // 'sec-ch-ua': '"Brave";v="113", "Chromium";v="113", "Not-A.Brand";v="24"',
        // 'sec-ch-ua-mobile': '?0',
        // 'sec-ch-ua-platform': "Windows",
        // 'sec-fetch-dest': 'document',
        // 'sec-fetch-mode': 'navigate',
        // 'sec-fetch-site': 'same-origin',
        // 'sec-fetch-user': '?1',
        // 'sec-gpc': '1',
        // 'upgrade-insecure-requests': '1',
        // 'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
      }
    );
    // assert(html.statusCode == 200);
    
    final soup = BeautifulSoup(html.body);
    // this find everithing on the page not only movies based on the search prompt
    // List<Bs4Element> bsMovies = soup.findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding"); // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    List<Bs4Element>? bsMovies = soup.find('div', class_: 'panel-body')?.find('div', class_: 'row')!.find('div', class_: 'row')!.find('div')!.children[0].findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding"); // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    final bsSeries1 = soup.findAll('div', class_: 'panel-body');
    List<Bs4Element>? bsSeries = [];
    if(bsSeries1.isNotEmpty) {
      bsSeries = bsSeries1[1].find('div', class_: 'row')!.find('div', class_: 'row')!.find('div')!.children[0].findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding"); // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    }
    List<MovieInfo> movies = [];
    List<MovieInfo> series = [];
    if(bsMovies != null) {
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
    BeautifulSoup soup = await http.get(
      uri,
      headers: {
        // // 'cookie': 'cf_clearance=bfKlKCiENlUD.zmFQ4DNO7XWilbYkgKi_QtKR7RzgCc-1685209554-0-160; path=/; expires=${toWeekday(datetime.weekday)}, ${datetime.day}-${datetime.month}-${int.parse(datetime.year.toString().substring(2)) + 1} ${datetime.hour}:${datetime.minute}:${datetime.second} GMT; domain=.secretlink.xyz; HttpOnly; Secure; SameSite=None',
        // 'authority': 'secretlink.xyz',
        // 'method': 'GET',//'POST',
        // 'path': '/',
        // 'scheme': 'https',
        // 'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
        // 'accept-encoding': 'gzip, deflate, br',
        // 'accept-language': 'sk-SK,sk;q=0.6',
        // 'cache-control': 'max-age=0',
        // 'content-length': '3019',
        // 'content-type': 'application/x-www-form-urlencoded',
        // 'cookie': 'cf_clearance=rMbhyb0SjOEkOP0zEFAhb.S.vSUIrPIcZFlIMUSUUZA-1685211928-0-160',
        // 'origin': 'https://secretlink.xyz',
        // 'referer': 'https://secretlink.xyz/?__cf_chl_tk=opR9FFjraC7p9NjjZ7Zu7plyuoz7Gec2Sy8HqAxL6Dc-1685209554-0-gaNycGzNCyU',
        // 'sec-ch-ua': '"Brave";v="113", "Chromium";v="113", "Not-A.Brand";v="24"',
        // 'sec-ch-ua-mobile': '?0',
        // 'sec-ch-ua-platform': "Windows",
        // 'sec-fetch-dest': 'document',
        // 'sec-fetch-mode': 'navigate',
        // 'sec-fetch-site': 'same-origin',
        // 'sec-fetch-user': '?1',
        // 'sec-gpc': '1',
        // 'upgrade-insecure-requests': '1',
        // 'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36',
      }
    ).then((value) => BeautifulSoup(value.body));
    String? img = soup.find('div', class_: 'thumbnail')?.find('img')?.attributes['src'];
    String? title = soup.find('div', class_: 'thumbnail')?.previousSibling?.innerHtml.replaceAll('&amp;', '&');
    if(title == null && img == null) return MovieInfo(title: 'failed to load', url: null, year: null, image: null);
    String? year = soup.find('div', class_: 'thumbnail')?.parent?.parent?.parent?.find('p', id: 'wrap')?.previousSibling?.previousSibling?.previousSibling?.previousSibling?.previousSibling?.innerHtml.split('-')[0];
    return MovieInfo(
      title: title,
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

    final Uri uri = url!.startsWith('/') ? Uri.parse('https://secretlink.xyz$url') : Uri.parse(url!);
    BeautifulSoup detailedMovie = await http.get(Uri.parse('$uri')).then((value) => BeautifulSoup(value.body));
    String? desc = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.innerHtml;
    Bs4Element? rating = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.parent?.findAll('div')[4].find('a')?.parent;
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
      rating: rating?.innerHtml.split(' from ')[0],
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