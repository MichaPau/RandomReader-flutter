import 'dart:math';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import 'package:shared_preferences/shared_preferences.dart';

class TextData {
  String fileName = "empty";
  String fileContent = "empty";
  String resultContent = 'empty';
  //int resultLength = 0;
  int startIndex = 0;
  int endIndex = 0;
}

class UserSettings {
  String bookDirectory = p.join(Directory.current.path, 'assets', 'books');
  int selectedIndex = 0;

  int resultLength = 250;
  int rangeModifier = 100;
}

class MyAppState extends ChangeNotifier {
  var info = "Info string";
  //var bookDirPath = p.join(Directory.current.path, 'assets', 'books');
  var fileNames = <String>[];

  //int selectedFileIndex = 0;
  //int maxRange = 100;

  var textData = TextData();
  var userSettings = UserSettings();

  MyAppState() {
    // _localPath.then((value) {
    //   dir = Directory(value);
    //   initFiles();
    // });

    init();

    textData.fileName = 'empty';
    textData.fileContent = 'empty';
    textData.resultContent = 'empty';
    //textData.resultLength = 250;
    textData.startIndex = 0;
    textData.endIndex = 0;
  }
  // Future<String> get _localPath async {
  //   final directory = Directory(bookDirPath);

  //   return directory.path;
  // }

  init() async {
    await loadSettings();
    await initFiles();
  }

  Future<void> loadSettings() async {
    var prefs = await SharedPreferences.getInstance();

    print("Default path:${userSettings.bookDirectory}");
    // if (prefs.containsKey("bookDirectory")) {
    //   userSettings.bookDirectory = prefs.getString("bookDirectory")!;
    // }

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
      //print(p.canonicalize(entity.path));
      //print(p.basenameWithoutExtension(entity.path));
      if (p.extension(entity.path) == '.txt') {
        fileNames.add(entity.path);
      }
    }
    if (userSettings.selectedIndex >= fileNames.length - 1) {
      userSettings.selectedIndex = fileNames.length - 1;
    }

    notifyListeners();
  }

  pickDir() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
    } else {
      print(selectedDirectory);
      userSettings.bookDirectory = selectedDirectory.toString();
      //saveSettings();
      initFiles();
    }
  }

  changeSelection(value) {
    print("changeSelection: $value");
    //selectedFileIndex = value;
    userSettings.selectedIndex = value;
    //saveSettings();
    notifyListeners();
  }

  debugInfo() async {
    print('button pressed!');
    //print(dir);

    // _localPath.then((value) {
    //   print(value);
    // });
  }

  setMaxRange(value) {
    //maxRange = value;
    userSettings.rangeModifier = value;
    //saveSettings();
    notifyListeners();
  }

  updateSettings(resultLength) {
    //textData.resultLength = resultLength;

    userSettings.resultLength = resultLength;
    //saveSettings();
    notifyListeners();
  }

  readFile() {
    //var file = fileNames[selectedFileIndex];
    var file = fileNames[userSettings.selectedIndex];
    print(file);

    try {
      // Stream<List<int>> stream = File(file).openRead();
      // StringBuffer buffer = StringBuffer();

      // stream.transform(utf8.decoder).transform(LineSplitter()).listen((line) {
      //   buffer.writeln(line);
      // }, onDone: () => print(buffer.toString()), onError: (e) => print(e));

      File(file).readAsString().then((String contents) {
        //var utf8content = utf8.decode(contents);
        //textData.fileContent = utf8content;
        textData.fileContent = contents;

        if (textData.fileContent.length <= userSettings.resultLength) {
          userSettings.resultLength = contents.length - 5;
        }
        textData.startIndex = Random()
            .nextInt(textData.fileContent.length - userSettings.resultLength);
        textData.endIndex = textData.startIndex + userSettings.resultLength;
        textData.resultContent =
            contents.substring(textData.startIndex, textData.endIndex);

        notifyListeners();
      }).onError((error, stackTrace) {
        print(error);
        textData.resultContent = error.toString();
        notifyListeners();
      });
    } catch (e) {
      print(e);
      textData.resultContent = e.toString();
    }
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
