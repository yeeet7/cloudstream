
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'package:vidsrc_extractor/models/subtitle.dart' as subtitle;
import 'package:vidsrc_extractor/models/utils.dart' show fetch;
// from typing import Union
// from . import subtitle
// import re
// import base64

Future<Uint8List?> decode_data(String key, dynamic data /*TODO: Union[bytearray, str] */) async {
    Uint8List key_bytes = Uint8List.fromList(key.codeUnits);
    var s = Uint8List.fromList(List.generate(256, (index) => index));
    var j = 0;

    for (int i = 0; i < 256; i++) {
      j = (j + s[i] + key_bytes[i % key_bytes.length]) & 0xff;
      var temp = s[i];
      s[i] = s[j];
      s[j] = temp;
    } 

    var decoded = Uint8List(data.length);
    var i = 0;
    var k = 0;

    for (int index = 0; index < data.length; index++) {
      i = (i + 1) & 0xff;
      k = (k + s[i]) & 0xff;
      var temp = s[i];
      s[i] = s[k];
      s[k] = temp;
      var t = (s[i] + s[k]) & 0xff;

      if (data[index] is String) {
        decoded[index] = (data[index] as String).codeUnitAt(0) ^ s[t];
      } else if (data[index] is int) {
        decoded[index] = data[index] ^ s[t];
      } else {
        return null;
      }
    }
    return decoded;
}

Future<Map> handle(url) async {
  var URL = url.split("?");
  var SRC_URL = URL[0];
  var SUB_URL = URL[1];

  // GET SUB
  var subtitles = {};
  subtitles = await subtitle.vscsubs(SUB_URL);

  // DECODE SRC
  var key_req        = await fetch(url:'https://raw.githubusercontent.com/Ciarands/vidsrc-keys/main/keys.json');
  var key1           = (jsonDecode(await key_req!.transform(utf8.decoder).join()) as Map).entries.toList()[0].key;
  var key2           = (jsonDecode(await key_req.transform(utf8.decoder).join()) as Map).entries.toList()[1].key;
  var decoded_id     = await decode_data(key1, SRC_URL.split('/e/')[-1]);
  var encoded_result = await decode_data(key2, decoded_id);
  var encoded_base64 = Uint8List.fromList(base64.encode(encoded_result!.toList()).codeUnits);
  var key            = base64.encode(encoded_base64).replaceAll('/', '_');

  // GET FUTOKEN
  var req = await fetch(url:"https://vidplay.online/futoken", headers:{"Referer": url});
  var fu_key = (await req!.transform(utf8.decoder).join()).substring(RegExp(r"var\s+k\s*=\s*'([^']+)'").allMatches(await req.transform(utf8.decoder).join()).first.start, RegExp(r"var\s+k\s*=\s*'([^']+)'").allMatches(await req.transform(utf8.decoder).join()).first.end);
  List l = [];
  for (var i = 0; i < key.length; i++) {
    l.add((fu_key[i % fu_key.length].codeUnitAt(0) + key[i].codeUnitAt(0)).toString());
  }
  var data = "$fu_key,${l.join(',')}";
  
  // GET SRC
  req = await fetch(url:"https://vidplay.online/mediainfo/$data?$SUB_URL&autostart=true", headers:{"Referer": url});
  var req_data = jsonDecode(await req!.transform(utf8.decoder).join());

  // RETURN IT
  if (req_data["result"].runtimeType == Map) {
    return {
      'stream':(req_data["result"]["sources"] ?? [{}])[0]["file"],
      'subtitle':subtitles
    };
  } else {
    return {};
  }
}