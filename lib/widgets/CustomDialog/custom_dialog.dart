import 'package:flutter/material.dart';

void showCustomDialog(
    {required BuildContext context,
    String? title,
    required List<Widget> listWidgets}) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: title == null ? null : Text(title),
            content: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: listWidgets,
            ));
      });
}
