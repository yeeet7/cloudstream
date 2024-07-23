
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:vidsrc_extractor/models/utils.dart';
import 'package:vidsrc_extractor/models/vidplay.dart' as vidplay;
import 'package:vidsrc_extractor/models/filemoon.dart' as filemoon;
// import 'package:vidsrc_api_dart/models/filemoon.dart' as filemoon;
// import 'asyncio';
// from . import vidplay,filemoon
// from .utils import fetch,error,decode_url

String VIDSRC_KEY = "WXrUARXb1aDLaZjI";
List SOURCES = ['Vidplay','Filemoon'];

Future<Map> get_source(String source_id, String SOURCE_NAME) async {
  HttpClientResponse? api_request = await fetch(url:"https://vidsrc.to/ajax/embed/source/$source_id");
  try {
    Map data = jsonDecode(await api_request!.transform(utf8.decoder).join());
    var encrypted_source_url = (data["result"] ?? {})["url"];
    return {"decoded":await decode_url(encrypted_source_url,VIDSRC_KEY),"title":SOURCE_NAME};
  } catch(e) {
    return {};
  }
}
        
get_stream(String source_url, String SOURCE_NAME) async {
  var RESULT = {};
  RESULT['name'] = SOURCE_NAME;
  if (SOURCE_NAME==SOURCES[0]) {
    RESULT['data'] = await vidplay.handle(source_url);
    return RESULT;
  } else if (SOURCE_NAME==SOURCES[1]) {
    RESULT['data'] = await filemoon.handle(source_url);
    return RESULT;
  } else {
    return {"name":SOURCE_NAME,"source":'',"subtitle":[]};
  }
}

get(String dbid, int? s, int? e) async {
  String media = (s != null && e != null) ? 'tv' : 'movie';
  String idUrl = 'https://vidsrc.to/embed/$media/$dbid${(s != null && e != null) ? '/$s/$e' : ''}';
  print(idUrl);
  
  var idRequest = await fetch(url: idUrl);
  if (idRequest!.statusCode == 200) {
    try {
      var soup = BeautifulSoup(await idRequest.transform(utf8.decoder).join());
      var sourcesCode = soup.find('a', attrs: {'data-id': true})?.attributes.entries.firstWhere((entry) => entry.key == "data-id").value;
      if (sourcesCode == null) {
        return await error("media unavailable.");
      } else {
        var sourceIdRequest = await fetch(url: 'https://vidsrc.to/ajax/embed/episode/$sourcesCode/sources');
        // print("source_id_request.json() ${await sourceIdRequest!.transform(utf8.decoder).join()}");
        Iterable sourceId = jsonDecode(await sourceIdRequest!.transform(utf8.decoder).join())['result'] ?? [];
        List<Map<String, dynamic>> sourceResults = [];
        
        for (var source in sourceId) {
          if (SOURCES.contains(source['title'])) {
            sourceResults.add({'id': source['id'], 'title': source['title']});
          }
        }

        var sourceUrls = await Future.wait(
          sourceResults.map((R) => get_source(R['id'], R['title']))
        );
        var sourceStreams = await Future.wait(
          sourceUrls.map((R) => get_stream(R['decoded'], R['title']))
        );
        return sourceStreams;
      }
    } catch (e) {
      // return await error("backend id not working.");
      rethrow;
    }
  } else {
    return await error("backend not working.[${idRequest.statusCode}]");
  }
}

Future<List<dynamic>> error(String message) async {
  // Handle error
  print(message);
  return [];
}