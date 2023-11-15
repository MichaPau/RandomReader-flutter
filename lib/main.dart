//import 'dart:math';
//import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

import 'package:path/path.dart' as p;
import 'package:multi_split_view/multi_split_view.dart';

import 'package:window_manager/window_manager.dart';

import 'state/app_state.dart';
//import 'modules/test_widget.dart';

void showLayoutGuidelines() {
  debugPaintSizeEnabled = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.setTitle("Random Text Reader");
  windowManager.setMinimumSize(Size(300, 300));
  windowManager.setSize(Size(1300, 800));

  runApp(const MainApp());
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
  final double marginRight;
  final double margins;
  LeftPane({this.marginRight = 5.0, this.margins = 30.0});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return Container(
      margin: EdgeInsets.only(
          top: margins, bottom: margins, left: margins, right: marginRight),
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
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
                    title: Text(
                        '$index ${Uri.decodeFull(p.basenameWithoutExtension(f))}',
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
  final double marginLeft;
  RightPane({this.marginLeft = 5.0});

  @override
  State<RightPane> createState() => _RightPaneState();
}

class _RightPaneState extends State<RightPane> {
  double currentStartSliderValue = 0;
  double currentEndSliderValue = 0;
  double maxSliderValue = 100;

  double? textFieldHeight;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    maxSliderValue = appState.userSettings.rangeModifier.toDouble();

    textFieldHeight = MediaQuery.of(context).size.height * 0.55;

    return FractionallySizedBox(
      widthFactor: 1,
      heightFactor: 1,
      child: Container(
        margin: EdgeInsets.only(
            left: widget.marginLeft, top: 30, bottom: 30, right: 30),
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
                      //appState.readFile();
                      appState.randomParagraph();
                      currentStartSliderValue = 0;
                      currentEndSliderValue = 0;
                    },
                    child: Text('Get Text'),
                  ),
                ),
                // How to use Notifications from child widgets
                // SizedBox(
                //   height: 5,
                // ),
                // NotificationListener(
                //   child: NotificationWidget(),
                //   onNotification: (DemoNotification n) {
                //     print('Received notification');
                //     print(n.value);
                //     return true;
                //   },
                // )
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
  MyAppState? appState;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

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

  // @override
  // void onWindowEvent(String eventName) {
  //   print('[WindowManager] onWindowEvent: $eventName');
  // }

  @override
  void onWindowClose() async {
    print("onWindowsClose");
    if (appState != null) {
      await appState!.saveSettings().then((res) => print("Settings saved"));
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = context.watch<MyAppState>();
    var screenWidth = MediaQuery.of(context).size.width;
    // openDrawer() {
    //   Scaffold.of(context).openDrawer();
    //}

    if (screenWidth > 600) {
      return Scaffold(
          body: MultiSplitView(
        //initialAreas: [Area(weight: 0.25)],
        controller: _splitController,
        children: [LeftPane(), RightPane()],
      ));
    } else {
      return Scaffold(
        key: _key,
        body: Stack(
          children: [
            RightPane(
              marginLeft: 30,
            ),
            Positioned(
              top: 35,
              left: 35,
              child: ElevatedButton(
                  onPressed: () {
                    _key.currentState!.openDrawer();
                  },
                  child: Text('Files')),
            ),
          ],
        ),
        drawer: Drawer(
          shape: Border.all(color: Colors.black),
          child: Stack(fit: StackFit.expand, children: [
            LeftPane(
              margins: 5,
              marginRight: 5,
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  tooltip: "Close drawer",
                  onPressed: () {
                    _key.currentState!.closeDrawer();
                  },
                  icon: Icon(
                    Icons.pets,
                    color: Colors.black,
                  )),
            ))
          ]),
        ),
      );
    }
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
