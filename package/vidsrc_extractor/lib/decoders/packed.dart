
// ignore_for_file: non_constant_identifier_names, prefer_spread_collections

import 'dart:core';

Future<String> unpack(p, a, c, k, [dynamic e, dynamic d]) async {
  for (int i = c - 1; i >= 0; i--) {
    if (k[i] != null) {
      p = (p as String).replaceAll(RegExp(r'\b' + await int2Base(i, a) + r'\b'), k[i]!);
    }
  }
  return p;
}

Future<String> int2Base(int x, int base) async {
  const String charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
  
  int sign;
  if (x < 0) {
    sign = -1;
  } else if (x == 0) {
    return '0';
  } else {
    sign = 1;
  }

  x *= sign;
  List<String> digits = [];

  while (x > 0) {
    digits.add(charset[x % base]);
    x = (x / base).floor();
  }

  if (sign < 0) {
    digits.add('-');
  }
  digits = digits.reversed.toList();

  return digits.join('');
}

Future<List<dynamic>> process_packed_args(String context) async {
  final matches = RegExp(r'return p}\((.+)\)').firstMatch(context);
  final processed_matches = <dynamic>[];
  
  if (matches != null) {
    final split_matches = matches.group(1)!.split(",");
    final corrected_split_matches = [
      split_matches.sublist(0, split_matches.length - 3).join(",")
    ]..addAll(split_matches.sublist(split_matches.length - 3));

    for (var val in corrected_split_matches) {
      val = val.trim();
      val = val.replaceAll(".split('|'))", "");
      if (int.tryParse(val) != null) {
        processed_matches.add(int.parse(val));
      } else if (val.startsWith("'") && val.endsWith("'")) {
        processed_matches.add(val.substring(1, val.length - 1));
      }
    }

    processed_matches[processed_matches.length - 1] = 
        processed_matches.last.split("|");
  }
  
  return processed_matches;
}
