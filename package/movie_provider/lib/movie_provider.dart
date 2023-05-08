
library movie_provider;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

abstract class MovieProvider {

  static Future<SearchResult> searchMovies(String prompt) async {
    assert(prompt.split(' ').join('').isNotEmpty);

    http.Response html = await http.get(Uri.parse('https://secretlink.xyz/search/keyword/${prompt.split(' ').join('%20')}'));
    assert(html.statusCode == 200);
    
    final soup = BeautifulSoup(html.body);
    List<Bs4Element> bsMovies = soup.findAll('div', class_: "col-lg-2 col-md-3 col-sm-4 col-xs-6 no-padding");
    List<MovieInfo> movies = [];
    for (var element in bsMovies) {

      String? img = element.find('img')?.attributes['src'];
      String url = 'https://secretlink.xyz${element.find('div', class_: 'img-group')?.find('a')?.attributes['href']}';
      
      Future<BeautifulSoup> detailedMovie = http.get(Uri.parse(url)).then((value) => BeautifulSoup(value.body));
      // Future<String?> vidurl = detailedMovie.then((val) => val.body?.innerHtml);
      Future<String?> desc = detailedMovie.then((val) => val.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.innerHtml);
      Future<Bs4Element?> rating = detailedMovie.then((val) => val.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.parent?.findAll('div')[3].find('a')?.parent);
      Future<Bs4Element?> genres = rating.then((val) => val?.parent?.previousElement?.previousElement?.previousElement?.previousElement?.previousElement);
      Future<List<String?>?> cast = genres.then((val) => val?.previousElement?.previousElement?.previousElement?.previousElement?.findAll('a').map((e) => e.innerHtml).toList());

      // log('pre ${uh.HttpRequest.supportsCrossOrigin}');
      // // uh.HttpRequest page = await uh.HttpRequest.request(url, onProgress: (event) {log(event.total.toString());});
      // String page = await uh.HttpRequest.requestCrossOrigin(url);
      // log('mid $page');
      // // page.onLoad.listen((event) {
      // //   print(event.toString());
      // //   print(page.response);
      // // });
      // log('post');
//       WebViewController? cunt;
//       var page = WebView(
//         initialUrl: url,
//         onWebViewCreated: (ctrl) {
//           cunt = ctrl;
//           log('cunt');
//         },
//         onProgress: (val) {log(val.toString());},
//         javascriptMode: JavascriptMode.unrestricted,
//         onPageFinished: (val) {
//           log('loaded=$val');
//           cunt?.runJavascriptReturningResult('''
// document.querySelector('video')
// ''');
//         }
//       );
//       var res = await cunt?.runJavascriptReturningResult('''document.querySelector('video')''');
//       log('$res');

      movies.add(MovieInfo._init(
        title: element.find('h5')?.find('a')?.innerHtml,
        url: url,
        vidurl: Future(() => null),
        desc: desc,
        year: element.find('img')?.parent?.parent?.find('div')?.innerHtml,
        genres: genres.then((val) => val?.findAll('a').map((e) => e.innerHtml).toList()),
        cast: cast,
        rating: rating.then((value) => value?.innerHtml.split(' ')[0]),
        image: img != null ? Image.network('https://secretlink.xyz/${File.fromUri(Uri.parse(img)).path}', fit: BoxFit.contain,) : null,
      ));
    }

    return SearchResult._init(movies, []);
  }

}

class MovieInfo {

  MovieInfo._init({
    required this.title,
    required this.url,
    required this.vidurl,
    required this.desc,
    required this.year,
    required this.genres,
    required this.cast,
    required this.rating,
    required this.image,
  });

  final String? title;
  final String? url;
  final Future<String?> desc;
  final String? year;
  final Future<List<String?>?> genres;
  final Future<List<String?>?> cast;
  final Future<String?> rating;
  final Future<String?> vidurl;
  final Image? image;

  @override
  String toString() {
    return 'Movie($title)';
  }

}

class SeriesInfo {

  SeriesInfo._init({
    required this.title,
    required this.url,
    // required this.vidurl,
    required this.desc,
    required this.year,
    required this.genres,
    required this.cast,
    required this.rating,
    required this.image,
  });

  final String? title;
  final String? url;
  final Future<String?> desc;
  final String? year;
  final Future<List<String?>?> genres;
  final Future<List<String?>?> cast;
  final Future<String?> rating;
  // final Future<String?> vidurl;
  final Image? image;

  @override
  String toString() {
    return 'Series($title)';
  }
}

class SearchResult {
  SearchResult._init(this.movies, this.series);
  final List<MovieInfo> movies;
  final List<SeriesInfo> series;
}