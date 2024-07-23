// ignore_for_file: constant_identifier_names, non_constant_identifier_names, no_leading_underscores_for_local_identifiers

import 'dart:convert';
import 'dart:async';
import 'utils.dart';
import 'package:vidsrc_extractor/models/subtitle.dart' as subtitle;

const int MAX_TRIES = 10;

Future<Map<String, dynamic>> handle(String location, String hash, String _seed) async {
  final request = await fetch(url: location, headers: {"Referer": "https://vidsrc.stream/rcp/$hash"});
  String hls_url = '';

  for (int T = 0; T < MAX_TRIES; T++) {
    final hlsUrlMatch = RegExp(r'file:"([^"]*)"', multiLine: true).firstMatch(await request!.transform(utf8.decoder).join());
    if (hlsUrlMatch != null) {
      hls_url = hlsUrlMatch.group(1)!;
      hls_url = hls_url.replaceAll(RegExp(r'\/\/\S+?='), '').substring(2);
      hls_url = hls_url.replaceAll(RegExp(r"\/@#@\/[^=\/]+=="), "");
      hls_url = hls_url.replaceAll('_', '/').replaceAll('-', '+');
      hls_url = utf8.decode(base64.decode(hls_url));
      if (hls_url.isNotEmpty && hls_url.endsWith('.m3u8')) {
        break;
      }
    }
  }

  // SET PASS
  final set_path_match = RegExp(r'var pass_path = "(.*?)";', multiLine: true).firstMatch(await request!.transform(utf8.decoder).join());
  if (set_path_match != null) {
    String set_pass = set_path_match.group(1)!;
    if (set_pass.startsWith("//")) {
      set_pass = "https:$set_pass";
    }
    await fetch(url: set_pass, headers: {"Referer": hash});
  }

  final subtitles = await subtitle.subfetch(_seed, "eng");
  return {"stream": hls_url, "subtitle": subtitles};
}