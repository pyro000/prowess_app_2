import 'package:flutter/material.dart';

Future<bool?> showCustomDialog(BuildContext context, {List<String> options = const ["Alerta", "Alerta", "Aceptar", "Cancelar"]}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(options[0]),
        content: Text(options[1]),
        actions: <Widget>[
          if (options.length > 3) 
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Usuario seleccionó "No"
            },
            child: Text(options[3]),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Usuario seleccionó "Sí"
            },
            child: Text(options[2]),
          ),
        ],
      );
    },
  );
}

