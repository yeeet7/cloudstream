
// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

final BASE = 'http://localhost:8000';

decode_url(String encrypted_source_url, String VIDSRC_KEY) async {
    String standardized_input = encrypted_source_url.replaceAll('_', '/').replaceAll('-', '+');
    Uint8List binary_data = base64.decode(standardized_input);
    Uint8List encoded = Uint8List.fromList(binary_data);
    Uint8List key_bytes = Uint8List.fromList(VIDSRC_KEY.codeUnits);
    var j = 0;
    Uint8List s = Uint8List.fromList(List.generate(256, (index) => index));

    for (int i = 0; i < 256; i++) {
      j = (j + s[i] + key_bytes[i % key_bytes.length]) & 0xff;
      var temp = s[i];
      s[i] = s[j];
      s[j] = temp;
    }

    var decoded = Uint8List(encoded.length);
    var i = 0;
    var k = 0;
    for (int index = 0; index < encoded.length; index++) {
      i = (i + 1) & 0xff;
      k = (k + s[i]) & 0xff;
      var temp = s[i];
      s[i] = s[k];
      s[k] = temp;
      var t = (s[i] + s[k]) & 0xff;
      decoded[index] = encoded[index] ^ s[t];
    }
    var decoded_text = String.fromCharCodes(decoded);
    return Uri.decodeComponent(decoded_text);
}

Future<HttpClientResponse?> fetch({required String url,Map headers=const {}, String method="GET", data, bool redirects=true}) async {
  HttpClient client = HttpClient();
  if (method=="GET") {
      HttpClientRequest req = await client.getUrl(Uri.parse(url)); //TODO: original == response = await client.get(url,headers=headers);
      for (var header in headers.entries) {
        req.headers.set(header.key, header.value);
      }
      HttpClientResponse response = await req.close();
      return response;
    } else if (method=="POST") {
      HttpClientRequest req = await client.postUrl(Uri.parse(url));
      for (var header in headers.entries) {
        req.headers.set(header.key, header.value);
      }
      req.write(data);
      HttpClientResponse response = await req.close();
      return response;
    } else {
      return null;
    }
}