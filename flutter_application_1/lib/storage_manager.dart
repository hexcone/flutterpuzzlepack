import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';

class StorageManager {
  static Future<String> getFilePath() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory(); // 1
    String appDocumentsPath = appDocumentsDirectory.path; // 2
    String filePath = '$appDocumentsPath/difficulty.sav'; // 3

    return filePath;
  }

  static void saveDifficulty(int difficulty) async {
    // if(kIsWeb) {
    //   final html.Storage _localStorage = html.window.localStorage;
    //   _localStorage['difficulty'] = difficulty.toString();
    // } else {
    //   File file = File(await getFilePath()); // 1
    //   file.writeAsString(difficulty.toString()); // 2
    // }
    final LocalStorage storage = new LocalStorage('puzzle');
    await storage.ready;
    storage.setItem("difficulty", difficulty);
  }

  static Future<int> readDifficulty() async {
    // if(kIsWeb) {
    //   final html.Storage _localStorage = html.window.localStorage;
    //   if(_localStorage['difficulty'] )
    //   return _localStorage['difficulty'];
    // } else {
    //   try {
    //     File file = File(await getFilePath()); // 1
    //     String fileContent = await file.readAsString(); // 2
    //     return int.parse(fileContent);
    //   } catch(ex) {
    //     return 1;
    //   }
    // }
    final LocalStorage storage = new LocalStorage('puzzle');
    await storage.ready;
    int? difficulty = storage.getItem("difficulty");
    if(difficulty == null)
      return 1;
    return difficulty;
  }
}