
// ignore_for_file: non_constant_identifier_names, unused_local_variable

// from .utils import fetch
// import re
// from .decoders.packed import *
// from . import subtitle
import 'dart:convert';

import 'package:vidsrc_extractor/decoders/packed.dart';
import 'package:vidsrc_extractor/models/subtitle.dart' as subtitle;
import 'package:vidsrc_extractor/models/utils.dart';

Future<Map> handle(url) async {
  var URL = (url as String).split("?");
  var SRC_URL = URL[0];
  var SUB_URL = URL[1];

  // GET SUB
  var subtitles = [];
  subtitles = await subtitle.vscsubs(SUB_URL);

  // GET SRC
  var request = await fetch(url: url);
  var processed_matches = await process_packed_args(await request!.transform(utf8.decoder).join());
  var unpacked = await unpack(processed_matches[0], processed_matches[1], processed_matches[2], processed_matches[3]);
  var hls_url = RegExp(r'file:"([^"]*)"').firstMatch(unpacked)?.group(1);
  return {
    'stream':hls_url,
    'subtitle':subtitles
  };
}