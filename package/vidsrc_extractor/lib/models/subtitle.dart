// CUSTOM utility FUNCTIONS FOR SUBTITLE MANAGEMENT.

// ignore_for_file: non_constant_identifier_names, constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'package:vidsrc_extractor/models/utils.dart';

subfetch(String code, String language) async {
  final String subBaseUrl = "$BASE/subs?url=";
  String url;

  if (code.contains('_')) {
    var _code = code.split('_');
    var season_episode = code.split('_');
    var season = season_episode[0].split('x');
    var episode = season_episode[1].split('x');
    url = "https://rest.opensubtitles.org/search/episode-$episode/imdbid-${_code[0]}/season-$season/sublanguageid-$language";
  } else {
    url = "https://rest.opensubtitles.org/search/imdbid-$code/sublanguageid-$language";
  }

  var headers = {
    'authority': 'rest.opensubtitles.org',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.105 Safari/537.36',
    'x-user-agent': 'trailers.to-UA',
  };

  var response = await fetch(url: url, headers: headers);
  if (response!.statusCode == 200) {
    var bestSubtitle = (jsonDecode(await response.transform(utf8.decoder).join()) as List).reduce((curr, next) => curr['score'] > next['score'] ? curr : next);
    if (bestSubtitle == null) return null;
    return [
      {
        "lang": language,
        "file": "$subBaseUrl${bestSubtitle['SubDownloadLink']}"
      }
    ];
  }
  return 1310;
}

vscsubs(url) async {
  var subtitles_url = RegExp(r"info=([^&]+)").firstMatch(url);
  if (subtitles_url == null) {
    return {};
  }
  
  var subtitles_url_formatted = Uri.decodeComponent(subtitles_url.group(1)!);
  int MAX_ATTEMPTS = 10;
  for (int i = 0; i < MAX_ATTEMPTS; i++) {
      try {
        var req = await fetch(url: subtitles_url_formatted);
            
        // if (req.status_code == 200) {
        if (req!.statusCode == 200) {
          List subtitles =  [];
          for (var subtitle in jsonDecode(await req.transform(utf8.decoder).join())) {
            subtitles.add({"lang": subtitle["label"], "file": subtitle["file"]});
          }
          return subtitles;
        }
      } catch(e) {
        continue;
      }
  }
  return 1310;
}
// file made by @cool-dev-guy
