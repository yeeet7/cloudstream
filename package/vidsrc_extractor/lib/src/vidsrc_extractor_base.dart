
// ignore_for_file: unused_element

import 'dart:convert';
import 'dart:io';
import 'package:vidsrc_extractor/models/utils.dart';
import 'package:vidsrc_extractor/models/vidsrcto.dart' as vidsrcto;
import 'package:vidsrc_extractor/models/vidsrcme.dart' as vidsrcme;

// app = FastAPI()

// @app.get('/')
// async def index():
//     return await info()

Future<Map> vidsrc(String? dbid, int? s, int? e) async {
  if (dbid != null) {
      return {
          "status":200,
          "info":"success",
          "sources":await vidsrcto.get(dbid,s,e)
      };
  } else {
    throw HttpException('status_code=404, detail=f"Invalid id: $dbid"');
  }
}

// @app.get('/vsrcme/{dbid}')
vsrcme({String dbid = '', int? s, int? e, String l = 'eng'}) async {
  if (dbid.isNotEmpty) {
    return {
      "status":200,
      "info":"success",
      "sources":await vidsrcme.get(dbid,s,e)
    };
  } else {
    throw HttpException('status_code=404, detail=f"Invalid id: $dbid"');
  }
}

Future<Map<String, dynamic>> streams({String dbid = '', int? s, int? e, String l = 'eng'}) async {
  if (dbid.isNotEmpty) {
    return {
      "status": 200,
      "info": "success",
      "sources": await vidsrcme.get(dbid, s, e) + await vidsrcto.get(dbid, s, e)
    };
  } else {
    throw HttpException('status_code=404, detail=f"Invalid id: {dbid}"');
  }
}

Future<void> subs(String url) async {
  try {
    final response = await fetch(url: url);
    if (response!.statusCode == 200) {
      final bytes = (await response.transform(utf8.decoder).join()).codeUnits;
      final archive = GZipCodec().decode(bytes);
      final subtitleContent = utf8.decode(archive);

      Stream<List<int>> generate() async* {
        yield utf8.encode(subtitleContent);
      }

      // return Response(generate(), headers: {
      //   HttpHeaders.contentTypeHeader: 'application/octet-stream',
      //   HttpHeaders.contentDispositionHeader: 'attachment; filename=subtitle.srt'
      // });
      return;
    } else {
      throw Exception('Error fetching subtitle');
    }
  } catch (e) {
    throw Exception('Error fetching subtitle');
  }
}