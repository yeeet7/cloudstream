
library movie_provider;




import 'dart:developer';

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

  static const String _url = 'https://popcornflix.xyz';

  static Future<MainPageInfo> getMainPage() async {

    log((await http.get(Uri.parse('https://v2.vidsrc.me/embed/tt5433140')).then((value) => BeautifulSoup(value.body))).body.toString());
    
    // DateTime datetime = DateTime.now();
    final BeautifulSoup soup =  await http.get(
      Uri.parse(_url),
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

    http.Response html = await http.get(
      Uri.parse('$_url/?s=${prompt.split(' ').join('+')}'),
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
    List<Bs4Element>? bsVideos = soup.find('section', class_: 'mopie-fade')?.find('div', class_: 'row')?.children; // for s2dfree.cc = soup.find('div', class_: 'panelMLlist')!.find('div', class_: 'divMLlist')!.findAll('div');
    List<MovieInfo> movies = [];
    List<MovieInfo> series = [];
    if(bsVideos != null) {
      for (var element in bsVideos) {

        String? img = element.find('img')?.attributes['src'];
        String url = '${element.find('a')?.attributes['href']}';

        if(url.split('/')[1] == 'movie') {
          movies.add(MovieInfo(
            title: element.find('a')?.attributes['title']?.split(' (').first,
            url: '$_url/$url',
            year: element.find('a')?.attributes['title']?.split('(').last.split(')').first,
            image: img != null ? Image.network(img, fit: BoxFit.contain,) : null,
          ));
        } else {
          series.add(MovieInfo(
            title: element.find('a')?.attributes['title']?.split(' (').first,
            url: '$_url/$url',
            year: element.find('a')?.attributes['title']?.split('(').last.split(')').first,
            image: img != null ? Image.network(img, fit: BoxFit.contain,) : null,
          ));
        }
      }
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
    return await DetailedMovieInfo.fromUrl('${url?.replaceFirst('//', '/', 7)}');
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
    required this.videoImage,
    super.title,
    super.url,
    super.year,
    super.image,
  });

  // final String? title;
  // final String? url;
  // final Image? image;
  // final String? year;
  final Image? videoImage;
  final String? desc;
  final List<String?>? genres;
  final List<String?>? cast;
  final String? rating;
  final String? vidurl;

  static Future<DetailedMovieInfo> fromUrl(String url) async {

    BeautifulSoup soup = await http.get(Uri.parse(url)).then((val) => BeautifulSoup(val.body));
    Bs4Element? info = soup.find('section', class_: 'container')?.find('div', class_: 'row')?.find('div', class_: 'row');

    String? img = info?.find('div')?.find('img')?.attributes['src'];
    
    String desc;
    if(url.split('.')[1].split('/')[1] == 'movie') {
      List<String>? tempDesc = info?.children[1].find('div', class_: 'entry-desciption')?.find('p')?.innerHtml.split('Full Movie Online Free ');
      tempDesc?.removeAt(0);
      desc = '${tempDesc?.join('')}';
    } else {
      String? tempDesc = info?.children[1].find('div', class_: 'entry-desciption')?.find('p')?.innerHtml;
      desc = tempDesc.toString();
    }
    List<Bs4Element>? year = info?.children[1].find('div', class_: 'entry-table')?.children[0].children;
    String? rating = info?.children[1].find('div', class_: 'entry-info')?.find('div', class_: '__info')?.find('span')?.innerHtml.split('/').first;
    List<String?>? genres = year?[2].find('span')?.findAll('span').map((e) => e.find('a')?.innerHtml).toList();
    List<String?>? cast = year?[3].find('span')?.findAll('span').map((e) => e.find('span')?.innerHtml).where((element) => element != null).toList();
    String? vidImage = soup.find('video')?.attributes['poster'];

    return DetailedMovieInfo._init(
      title: info?.children[1].find('div')?.find('h1')?.innerHtml.split('<').first,
      url: url,
      image: img != null ? Image.network('${MovieProvider._url}/$img', fit: BoxFit.contain,) : null,
      vidurl: soup.find('video')?.attributes['src'],
      desc: desc,
      year: year?[0].innerHtml.split(' <').first == 'First Air Date: ' ? year![0].find('span')?.innerHtml.split('-').first : year?[0].find('span')?.innerHtml.split(', ').last,
      genres: genres,
      cast: cast,
      rating: rating?.replaceRange(3, null, ''),
      videoImage: vidImage != null ? Image.network(vidImage, fit: BoxFit.contain,) : null
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