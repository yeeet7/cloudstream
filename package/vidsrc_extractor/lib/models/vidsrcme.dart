// import asyncio
// from bs4 import BeautifulSoup
// from . import vidsrcpro,superembed
// from .utils import fetch

// ignore_for_file: non_constant_identifier_names, constant_identifier_names, no_leading_underscores_for_local_identifiers, unused_local_variable

// SOURCES = ["VidSrc PRO","Superembed"]
import 'dart:convert';
import 'dart:typed_data';
import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:vidsrc_extractor/models/vidsrcpro.dart' as vidsrcpro;
import 'package:vidsrc_extractor/models/superembed.dart' as superembed;
import 'utils.dart' show fetch;

const List<String> SOURCES = ["VidSrc PRO", "Superembed"];

Future<Map<String, dynamic>> getSource(String hash, String url) async {
  final SOURCE_REQUEST = await fetch(url: "https://vidsrc.stream/rcp/$hash", headers: {"Referer": url});
  try {
    var _html = BeautifulSoup(await SOURCE_REQUEST!.transform(utf8.decoder).join());
    var _encoded = _html.find("div", attrs: {"id": "hidden"})?.attributes["data-h"];

    if (_encoded == null) {
      return {"stream": null, "subtitle": []};
    }

    final _seed = _html.find("body")?.attributes['data-i'];
    final encoded_buffer = Uint8List.fromList(List<int>.generate(_encoded.length ~/ 2, (i) => int.parse(_encoded.substring(i * 2, i * 2 + 2), radix: 16)));
    String decoded = "";
    for (int i = 0; i < encoded_buffer.length; i++) {
      decoded += String.fromCharCode(encoded_buffer[i] ^ _seed!.codeUnitAt(i % _seed.length));
    }
    final decoded_url = decoded.startsWith("//") ? "https:$decoded" : decoded;

    final response = await fetch(url: decoded_url, redirects: false, headers: {"Referer": "https://vidsrc.stream/rcp/$hash"});
    final String? location = jsonDecode(await response!.transform(utf8.decoder).join())['headers']['location'];
    if (location == null) {
      return {"stream": null, "subtitle": []};
    }
    if (location.contains("vidsrc.stream")) {
      return await vidsrcpro.handle(location, hash, _seed??'');
    }
    if (location.contains("multiembed.mov")) {
      return await superembed.handle(location, hash, _seed??'');
    }
  } catch (e) {
    return {"stream": null, "subtitle": []};
  }
  return {"stream": null, "subtitle": []};
}

Future<Map<String, dynamic>> getStream(String hash, String url, String SOURCE_NAME) async {
  final result = <String, dynamic>{};
  result['name'] = SOURCE_NAME;
  result['data'] = await getSource(hash, url);
  return result;
}

Future<List<Map<String, dynamic>>> get(String dbid, int? s, int? e, {String l = 'eng'}) async {
  final provider = dbid.contains("tt") ? "imdb" : "tmdb";
  final media = (s != null && e != null) ? 'tv' : "movie";
  final language = l;

  // MAKE API REQUEST TO GET ID(hash)
  final id_url = "https://vidsrc.me/embed/$dbid${(s != null && e != null) ? "/$s-$e" : ''}";
  final id_request = await fetch(url: id_url);
  var _html = BeautifulSoup(await id_request!.transform(utf8.decoder).join());
  var SOURCE_RESULTS = _html.findAll('div', attrs: {"class": "server"}).where((attr) => SOURCES.contains(attr.text)).map((attr) {
    return {"name": attr.text, "hash": attr.attributes['data-hash']};
  }).toList();

  // REQUEST THE SOURCE
  final SOURCE_STREAMS = await Future.wait(SOURCE_RESULTS.map((R) => getStream(R['hash']!, id_url, R['name']!)).toList());

  return SOURCE_STREAMS;
}