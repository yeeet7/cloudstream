
import 'dart:core';
import 'dart:math';

Future<int> hunterDef(String d, int e, int f) async {
  const charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/";
  final sourceBase = charset.substring(0, e);
  final targetBase = charset.substring(0, f);

  final reversedInput = d.split('').reversed.toList();
  num result = 0;

  for (int power = 0; power < reversedInput.length; power++) {
    final digit = reversedInput[power];
    if (sourceBase.contains(digit)) {
      result += pow(sourceBase.indexOf(digit) * (e).toDouble(), power).toInt();
    }
  }

  String convertedResult = "";
  while (result > 0) {
    convertedResult = targetBase[(result % f).toInt()] + convertedResult;
    result = (result - (result % f)) ~/ f;
  }

  return int.tryParse(convertedResult) ?? 0;
}

Future<String> hunter(String h, int u, String n, int t, int e, int r) async {
  int i = 0;
  String resultStr = "";
  while (i < h.length) {
    int j = 0;
    String s = "";
    while (h[i] != n[e]) {
      s += h[i];
      i += 1;
    }

    while (j < n.length) {
      s = s.replaceAll(n[j], j.toString());
      j += 1;
    }

    resultStr += String.fromCharCode(await hunterDef(s, e, 10) - t);
    i += 1;
  }

  return resultStr;
}

Future<List<dynamic>> processHunterArgs(String hunterArgs) async {
  final regex = RegExp(r'^"(.*?)",(.*?),"(.+?)",(.*?),(.*?),(.*?)$');
  final matches = regex.firstMatch(hunterArgs);
  if (matches == null) {
    throw FormatException("Invalid input format");
  }
  final processedMatches = matches.groups([1, 2, 3, 4, 5, 6]);
  return [
    processedMatches[0]!,
    int.parse(processedMatches[1]!),
    processedMatches[2]!,
    int.parse(processedMatches[3]!),
    int.parse(processedMatches[4]!),
    int.parse(processedMatches[5]!)
  ];
}
// import re
// async def hunter_def(d, e, f) -> int:
//     charset = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ+/"
//     source_base = charset[0:e]
//     target_base = charset[0:f]

//     reversed_input = list(d)[::-1]
//     result = 0

//     for power, digit in enumerate(reversed_input):
//         if digit in source_base:
//             result += source_base.index(digit) * e**power

//     converted_result = ""
//     while result > 0:
//         converted_result = target_base[result % f] + converted_result
//         result = (result - (result % f)) // f

//     return int(converted_result) or 0
// async def hunter( h, u, n, t, e, r) -> str:
//         i = 0
//         result_str = ""
//         while i < len(h):
//             j = 0
//             s = ""
//             while h[i] != n[e]:
//                 s += h[i]
//                 i += 1

//             while j < len(n):
//                 s = s.replace(n[j], str(j))
//                 j += 1

//             result_str += chr(await hunter_def(s, e, 10) - t)
//             i += 1

//         return result_str
// async def process_hunter_args(hunter_args: str) -> list:
//     hunter_args = re.search(r"^\"(.*?)\",(.*?),\"(.*?)\",(.*?),(.*?),(.*?)$", hunter_args)
//     processed_matches = list(hunter_args.groups())
//     processed_matches[0] = str(processed_matches[0])
//     processed_matches[1] = int(processed_matches[1])
//     processed_matches[2] = str(processed_matches[2])
//     processed_matches[3] = int(processed_matches[3])
//     processed_matches[4] = int(processed_matches[4])
//     processed_matches[5] = int(processed_matches[5])
//     return processed_matches
