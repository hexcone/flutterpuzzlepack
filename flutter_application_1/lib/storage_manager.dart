import 'dart:io';

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
    final LocalStorage storage = new LocalStorage('puzzle');
    await storage.ready;
    storage.setItem("difficulty", difficulty);
  }

  static Future<int> readDifficulty() async {
    final LocalStorage storage = new LocalStorage('puzzle');
    await storage.ready;
    int? difficulty = storage.getItem("difficulty");
    if (difficulty == null)
      return 1;
    return difficulty;
  }
}