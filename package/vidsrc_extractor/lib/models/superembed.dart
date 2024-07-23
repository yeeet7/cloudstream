// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:async';
import 'dart:convert';
import 'package:vidsrc_extractor/models/utils.dart';
import 'package:vidsrc_extractor/decoders/hunter.dart';

Future<Map<String, dynamic>> handle(String location, String hash, String _seed) async {
  final headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
  };

  final request = await fetch(url: location, headers: headers);
  final hunterArgs = RegExp(r"eval\(function\(h,u,n,t,e,r\).*?}\((.*?)\)\)").firstMatch(await request!.transform(utf8.decoder).join());

  if (hunterArgs == null) {
    return {"stream": '', "subtitle": []};
  }

  final processedHunterArgs = await processHunterArgs(hunterArgs.group(1)!);
  final unpacked = await hunter(processedHunterArgs[0], processedHunterArgs[1], processedHunterArgs[2], processedHunterArgs[3], processedHunterArgs[4], processedHunterArgs[5]);
  final subtitles = <Map<String, String>>[];

  final hlsUrls = RegExp(r'file:"([^"]*)"').allMatches(unpacked).map((m) => m.group(1)!).toList();
  final subtitleMatch = RegExp(r'subtitle:"([^"]*)"').firstMatch(unpacked);

  if (subtitleMatch != null) {
    for (final subtitle in subtitleMatch.group(1)!.split(',')) {
      final subtitleData = RegExp(r'^\[(.*?)\](.*$)').firstMatch(subtitle);
      if (subtitleData != null) {
        subtitles.add({'lang': subtitleData.group(1)!, 'file': subtitleData.group(2)!});
      }
    }
  }

  return {"stream": hlsUrls.isNotEmpty ? hlsUrls[0] : '', "subtitle": subtitles};
}
// import re
// from .utils import fetch
// from .decoders.hunter import *

// async def handle(location:str,hash:str,_seed:str):
//     headers = {
//         'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36'
//     }
//     request = await fetch(location,headers=headers)
//     hunter_args = re.search(r"eval\(function\(h,u,n,t,e,r\).*?}\((.*?)\)\)", request.text)
//     if not hunter_args:
//         return {"stream":'',"subtitle":[]}
    
//     processed_hunter_args = await process_hunter_args(hunter_args.group(1))
//     unpacked = await hunter(*processed_hunter_args)
//     subtitles = []
//     hls_urls = re.findall(r"file:\"([^\"]*)\"", unpacked)
//     subtitle_match = re.search(r"subtitle:\"([^\"]*)\"", unpacked)
//     if subtitle_match:
//         for subtitle in subtitle_match.group(1).split(","):
//             subtitle_data = re.search(r"^\[(.*?)\](.*$)", subtitle)
//             if not subtitle_data:
//                 continue
//             subtitles.append({'lang':subtitle_data.group(1),'file':subtitle_data.group(2)})
//     return {"stream":hls_urls[0],"subtitle":subtitles}
