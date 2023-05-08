
library movie_provider;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

abstract class MovieProvider {

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
    List<SeriesInfo> series = [];
    for (var element in bsMovies) {

      String? img = element.find('img')?.attributes['src'];
      String url = 'https://secretlink.xyz${element.find('img')?.parent?.attributes['href']}';
      
      // Future<String?> vidurl = detailedMovie.then((val) => val.body?.innerHtml);

      movies.add(MovieInfo._init(
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

      series.add(SeriesInfo._init(
        title: element.find('h5')?.find('a')?.innerHtml.replaceAll('&amp;', '&'),
        url: url,
        year: element.find('img')?.parent?.parent?.find('div')?.innerHtml,
        image: img != null ? Image.network('https://secretlink.xyz/$img', fit: BoxFit.contain,) : null,
      ));
    }
    return SearchResult._init(movies, series);
  }

}

class MovieInfo {

  MovieInfo._init({
    required this.title,
    required this.url,
    required this.year,
    required this.image,
  });

  final String? title;
  final String? url;
  final String? year;
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

  @override
  String toString() {
    return 'Movie($title)';
  }

}

class DetailedMovieInfo {
  
  DetailedMovieInfo._init({
    required this.title,
    required this.url,
    required this.image,
    required this.vidurl,
    required this.desc,
    required this.year,
    required this.genres,
    required this.cast,
    required this.rating,
  });

  final String? title;
  final String? url;
  final Image? image;
  final String? desc;
  final String? year;
  final List<String?>? genres;
  final List<String?>? cast;
  final String? rating;
  final String? vidurl;
}

class SeriesInfo {

  SeriesInfo._init({
    required this.title,
    required this.url,
    required this.year,
    required this.image,
  });

  final String? title;
  final String? url;
  final String? year;
  final Image? image;

  Future<DetailedSeriesInfo> getDetails() async {

    BeautifulSoup detailedMovie = await http.get(Uri.parse('$url')).then((value) => BeautifulSoup(value.body));
    String? desc = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.innerHtml;
    Bs4Element? rating = detailedMovie.find('div', class_: 'panel-body')?.find('p', id: 'wrap')?.parent?.findAll('div')[3].find('a')?.parent;
    Bs4Element? genres = rating?.parent?.previousElement?.previousElement?.previousElement?.previousElement?.previousElement;
    List<String?>? cast = genres?.previousElement?.previousElement?.previousElement?.previousElement?.findAll('a').map((e) => e.innerHtml).toList();

    return DetailedSeriesInfo._init(
      title: title,
      url: url,
      desc: desc,
      year: year,
      genres: genres?.findAll('a').map((e) => e.innerHtml).toList(),
      cast: cast,
      rating: rating?.innerHtml.split(' ')[0],
      image: image,
    );
  }

  @override
  String toString() {
    return 'Series($title)';
  }
}

class DetailedSeriesInfo {

  DetailedSeriesInfo._init({
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
  final String? desc;
  final String? year;
  final List<String?>? genres;
  final List<String?>? cast;
  final String? rating;
  // final Future<String?> vidurl;
  final Image? image;
}

class SearchResult {
  SearchResult._init(this.movies, this.series);
  final List<MovieInfo> movies;
  final List<SeriesInfo> series;
}