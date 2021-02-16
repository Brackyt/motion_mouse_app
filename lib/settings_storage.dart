import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'gesture.dart';

class SettingStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localGesturesFile async {
    final path = await _localPath;
    return File('$path/gestures');
  }

  Future<List<Gesture>> readGestures() async {
    try {
      final file = await _localGesturesFile;
      List<Gesture> gestures;

      // Read the file
      String contents = await file.readAsString();
      gestures = (json.decode(contents) as List).map((i) =>
                    Gesture.fromJson(i)).toList();
      return gestures;
    } catch (e) {
      print(e);
      return new List<Gesture>();
    }
  }

  Future<File> writeGestures(List<Gesture> gestures) async {
    final file = await _localGesturesFile;
    var json = jsonEncode(gestures.map((g) => g.toJson()).toList());

    return file.writeAsString('$json');
  }
}