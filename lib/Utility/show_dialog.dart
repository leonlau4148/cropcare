import 'package:flutter/material.dart';

Future<void> showDialogPromt(
    BuildContext context,
    String text,text2
    ) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(text),
        content: Text(text2),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}


