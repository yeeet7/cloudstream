
import 'dart:developer';
import 'dart:io';
import 'package:test/test.dart';
import 'package:vidsrc_extractor/vidsrc_extractor.dart';

void main() async {

  
  print('id');
  String id = stdin.readLineSync()??'';
  print('s');
  String? s = stdin.readLineSync()??'';
  print('e');
  String? e = stdin.readLineSync()??'';
  log((await vidsrc(id, int.tryParse(s), int.tryParse(e))).toString());


  group('A group of tests', () {

    setUp(() {
      // Additional setup goes here.
    });

    test('First Test', () {
      expect(0, isTrue);
    });
  });
}
