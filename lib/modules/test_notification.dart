import 'package:flutter/material.dart';

class DemoNotification extends Notification {
  final String value;
  DemoNotification(this.value);
}

class NotificationWidget extends StatefulWidget {
  @override
  State<NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget> {
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("Try to raise notification:"),
        IconButton(
            onPressed: () {
              counter++;
              DemoNotification(counter.toString()).dispatch(context);
            },
            icon: Icon(Icons.heat_pump_rounded))
      ],
    );
  }
}
