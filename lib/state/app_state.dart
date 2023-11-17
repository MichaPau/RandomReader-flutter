import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:filepicker_windows/filepicker_windows.dart';

import 'package:path/path.dart' as p;

import 'package:shared_preferences/shared_preferences.dart';

class TextData {
  String fileName = "empty";
  String fileContent = "empty";
  String resultContent = 'empty';
  int startIndex = 0;
  int endIndex = 0;
}

class UserSettings {
  String bookDirectory = kReleaseMode
      ? p.join(
          Directory.current.path, 'data', 'flutter_assets', 'assets', 'books')
      : p.join(Directory.current.path, 'assets', 'books');
  int selectedIndex = 0;

  int resultLength = 250;
  int rangeModifier = 100;
}

class MyAppState extends ChangeNotifier {
  var info = "Info string";
  //var bookDirPath = p.join(Directory.current.path, 'assets', 'books');
  var fileNames = <String>[];

  var textData = TextData();
  var userSettings = UserSettings();

  MyAppState() {
    init();

    textData.fileName = 'empty';
    textData.fileContent = 'empty';
    textData.resultContent = 'empty';
    textData.startIndex = 0;
    textData.endIndex = 0;
  }

  init() async {
    await loadSettings();
    await initFiles();
    readFile();
  }

  Future<void> loadSettings() async {
    var prefs = await SharedPreferences.getInstance();

    print("Default path:${userSettings.bookDirectory}");
    if (prefs.containsKey("bookDirectory")) {
      userSettings.bookDirectory = prefs.getString("bookDirectory")!;
    }

    if (prefs.containsKey("selectedIndex")) {
      userSettings.selectedIndex = prefs.getInt("selectedIndex")!;
    }

    if (prefs.containsKey("resultLength")) {
      userSettings.resultLength = prefs.getInt("resultLength")!;
    }
    if (prefs.containsKey("rangeModifier")) {
      userSettings.rangeModifier = prefs.getInt("rangeModifier")!;
    }

    print("selectedIndex(loadSettings):${userSettings.selectedIndex}");
  }

  Future<String> saveSettings() async {
    var prefs = await SharedPreferences.getInstance();

    prefs.setString("bookDirectory", userSettings.bookDirectory);
    prefs.setInt("selectedIndex", userSettings.selectedIndex);
    prefs.setInt("rangeModifier", userSettings.rangeModifier);
    prefs.setInt("resultLength", userSettings.resultLength);

    return "Saved";
  }

  initFiles() async {
    final dir = Directory(userSettings.bookDirectory);
    fileNames = [];
    await for (var entity in dir.list(recursive: false, followLinks: false)) {
      if (p.extension(entity.path) == '.txt') {
        fileNames.add(entity.path);
      }
    }
    if (userSettings.selectedIndex >= fileNames.length - 1) {
      userSettings.selectedIndex = fileNames.length - 1;
    }

    notifyListeners();
  }

  pickDir2() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: "Select a folder.",
        initialDirectory: userSettings.bookDirectory);

    if (selectedDirectory == null) {
    } else {
      print(selectedDirectory);
      userSettings.bookDirectory = selectedDirectory.toString();
      userSettings.selectedIndex = 0;
      readFile();
      initFiles();
    }
  }

  pickDir() async {
    final file = DirectoryPicker()..title = 'Select a directory';

    final result = file.getDirectory();
    if (result != null) {
      print(result.path);
      userSettings.bookDirectory = result.path;
      userSettings.selectedIndex = 0;
      readFile();
      initFiles();
    }
  }

  changeSelection(value) async {
    userSettings.selectedIndex = value;
    await readFile().then((value) {
      print(fileNames[userSettings.selectedIndex]);
      randomParagraph();
      notifyListeners();
    }).onError((error, stackTrace) {
      print("error from changeSelection:$error");
    });
  }

  debugInfo() async {
    print('button pressed!');
  }

  setMaxRange(value) {
    userSettings.rangeModifier = value;
    notifyListeners();
  }

  updateSettings(resultLength) {
    userSettings.resultLength = resultLength;
    notifyListeners();
  }

  Future<void> readFile() async {
    print("read file");
    var file = fileNames[userSettings.selectedIndex];

    await File(file).readAsString(encoding: utf8).then((String contents) {
      textData.fileContent = contents;

      if (textData.fileContent.length <= userSettings.resultLength) {
        userSettings.resultLength = contents.length - 1;
      }

      return Future(() => null);
    }).onError((error, stackTrace) {
      print("onError: $error");
      print("try ascii");
      File(file).readAsString(encoding: Latin1Codec()).then((String contents) {
        textData.fileContent = contents;

        if (textData.fileContent.length <= userSettings.resultLength) {
          userSettings.resultLength = contents.length - 1;
        }
        return Future(() => null);
      }).onError((error, stackTrace) {
        print("onError2: $error");
        textData.resultContent = error.toString();
        notifyListeners();
        throw ("No valid encoding");
      });
    });
  }

  randomParagraph() {
    textData.startIndex = Random()
        .nextInt(textData.fileContent.length - userSettings.resultLength);
    textData.endIndex = textData.startIndex + userSettings.resultLength;
    textData.resultContent =
        textData.fileContent.substring(textData.startIndex, textData.endIndex);

    notifyListeners();
  }

  updateRange(int startMod, int endMod) {
    int newStartIndex = textData.startIndex + startMod;
    if (newStartIndex < 0) {
      newStartIndex = 0;
    }

    int newEndIndex = textData.endIndex + endMod;

    if (newEndIndex > textData.fileContent.length - 1) {
      newEndIndex = textData.fileContent.length - 1;
    }
    textData.resultContent =
        textData.fileContent.substring(newStartIndex, newEndIndex);

    notifyListeners();
  }
}
