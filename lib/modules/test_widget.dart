import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class TestWidget extends StatefulWidget {
  @override
  State<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    MyAppState appState = context.watch<MyAppState>();
    return Column(
      children: [
        Text("Test widget from a module!"),
        Text(appState.userSettings.bookDirectory)
      ],
    );
  }
}
