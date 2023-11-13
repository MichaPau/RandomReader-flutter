import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:multi_split_view/multi_split_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

//import 'dart:async';
import 'dart:io';
import 'package:flutter/rendering.dart';

//import 'modules/test_widget.dart';

void showLayoutGuidelines() {
  debugPaintSizeEnabled = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setTitle("Random Text Reader");
  windowManager.setMinimumSize(Size(700, 300));
  windowManager.setSize(Size(1300, 800));

  runApp(const MainApp());
}

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

    loadSettings();
    initFiles();

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

  loadSettings() async {
    var prefs = await SharedPreferences.getInstance();

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
      print(p.extension(entity.path));
      //print(p.basenameWithoutExtension(entity.path));
      if (p.extension(entity.path) == '.txt') {
        fileNames.add(entity.path);
      }

      if (userSettings.selectedIndex >= fileNames.length - 1) {
        userSettings.selectedIndex = fileNames.length - 1;
      }
      notifyListeners();
    }
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
      File(file).readAsString().then((String contents) {
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

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Color mainButtonColor = Color.fromARGB(255, 25, 60, 73);

    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          radioTheme: RadioThemeData(
            fillColor:
                MaterialStateColor.resolveWith((states) => mainButtonColor),
          ),
          sliderTheme: SliderThemeData(
            activeTrackColor: mainButtonColor,
            thumbColor: mainButtonColor,
            valueIndicatorColor: mainButtonColor,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainButtonColor, // Button color
              foregroundColor: Colors.white, // Text color
            ),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class LeftPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Container(
      margin: EdgeInsets.only(top: 30, bottom: 30, left: 30, right: 5),
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 63, 156, 192),
        border: Border.all(),
        borderRadius: BorderRadius.all(Radius.circular(3.0)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
                onPressed: () {
                  appState.pickDir();
                },
                child: Text('Select Dir')),
            ListView(
              shrinkWrap: true,
              children: [
                for (final (index, f) in appState.fileNames.indexed)
                  ListTile(
                    title: Text('$index ${p.basenameWithoutExtension(f)}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                            fontSize: 15,
                            color: Color.fromARGB(255, 255, 255, 255))),
                    leading: Radio<int>(
                      visualDensity: VisualDensity(
                          horizontal: VisualDensity.minimumDensity,
                          vertical: VisualDensity.minimumDensity),

                      value: index,
                      //groupValue: appState.selectedFileIndex,
                      groupValue: appState.userSettings.selectedIndex,
                      onChanged: (int? value) {
                        appState.changeSelection(value);
                        //appState.selectedFileIndex = value;
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RightPane extends StatefulWidget {
  @override
  State<RightPane> createState() => _RightPaneState();
}

class _RightPaneState extends State<RightPane> {
  double currentStartSliderValue = 0;
  double currentEndSliderValue = 0;
  double maxSliderValue = 100;

  var textFieldHeight;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    maxSliderValue = appState.userSettings.rangeModifier.toDouble();

    textFieldHeight = MediaQuery.of(context).size.height * 0.55;

    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Container(
        margin: EdgeInsets.only(top: 30, bottom: 30, right: 30),
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white70,
          border: Border.all(),
          borderRadius: BorderRadius.all(Radius.circular(3.0)),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                LittleSettings(),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  width: 500,
                  height: textFieldHeight,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      color: Color.fromARGB(255, 198, 224, 41),
                    ),
                    child: SelectableText(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      appState.textData.resultContent,
                      minLines: 10,
                    ),
                  ),
                ),
                Center(
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 20,
                    children: [
                      Container(
                        width: 200,
                        child: Slider(
                            value: currentStartSliderValue,
                            max: 0,
                            min: maxSliderValue * -1,
                            divisions: maxSliderValue.toInt(),
                            label: currentStartSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                currentStartSliderValue = value;
                                appState.updateRange(
                                    currentStartSliderValue.toInt(),
                                    currentEndSliderValue.toInt());
                              });
                            }),
                      ),
                      Container(
                        width: 200,
                        child: Slider(
                            value: currentEndSliderValue,
                            max: maxSliderValue,
                            min: 0,
                            divisions: maxSliderValue.toInt(),
                            label: currentEndSliderValue.round().toString(),
                            onChanged: (double value) {
                              setState(() {
                                currentEndSliderValue = value;
                                appState.updateRange(
                                    currentStartSliderValue.toInt(),
                                    currentEndSliderValue.toInt());
                              });
                            }),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      appState.readFile();
                      currentStartSliderValue = 0;
                      currentEndSliderValue = 0;
                    },
                    child: Text('Get Text'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  var appState;
  MultiSplitViewController _splitController = MultiSplitViewController(
      areas: [Area(minimalWeight: .25, weight: .25), Area(minimalWeight: .25)]);
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    print('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() async {
    print("onWindowsClose");
    await appState.saveSettings().then((res) => print("Settings saved"));
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();

    return Scaffold(
        body: MultiSplitView(
      //initialAreas: [Area(weight: 0.25)],
      controller: _splitController,
      children: [LeftPane(), RightPane()],
    )
        // body: Row(
        //   children: [
        //     Expanded(
        //       flex: 3,
        //       child: LeftPane(),
        //     ),
        //     Expanded(
        //       flex: 7,
        //       child: RightPane(),
        //     ),
        //   ],
        // ),
        );
  }
}

class LittleSettings extends StatefulWidget {
  const LittleSettings({super.key});

  @override
  State<LittleSettings> createState() => _LittleSettingsState();
}

// Define a corresponding State class.
// This class holds the data related to the Form.
class _LittleSettingsState extends State<LittleSettings> {
  // Create a text controller and use it to retrieve the current value
  // of the TextField.
  final inputCtr = TextEditingController();
  final rangeCtr = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    inputCtr.dispose();
    rangeCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    inputCtr.text = appState.userSettings.resultLength.toString();
    rangeCtr.text = appState.userSettings.rangeModifier.toString();

    return Center(
      child: SizedBox(
        width: 500,
        child: Wrap(
          spacing: 10,
          alignment: WrapAlignment.center,
          runAlignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text("Range:"),
            SizedBox(
              width: 75,
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                  //contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                ),
                //maxLength: 4,
                textAlignVertical: TextAlignVertical.center,
                controller: inputCtr,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                //decoration: InputDecoration(border: OutlineInputBorder()),
                onSubmitted: (value) {
                  appState.userSettings.resultLength = int.parse(value);
                  //appState.setMaxRange(int.parse(value));
                },
              ),
            ),
            Text("max. resize:"),
            SizedBox(
              width: 75,
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(10),
                  border: OutlineInputBorder(),
                ),
                //maxLength: 4,
                textAlignVertical: TextAlignVertical.center,
                controller: rangeCtr,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                //decoration: InputDecoration(border: OutlineInputBorder()),
                onSubmitted: (value) {
                  //appState.textData.resultLength = int.parse(value);
                  appState.setMaxRange(int.parse(value));
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  //print("ResultLength: ${inputCtr.text}");
                  appState.updateSettings(int.parse(inputCtr.text));
                  appState.setMaxRange(int.parse(rangeCtr.text));
                },
                child: Text("Update"))
          ],
        ),
      ),
    );
  }
}
