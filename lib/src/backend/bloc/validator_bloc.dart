import 'dart:async';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'dart:developer';

class Validator {

  //gmail
  final emailValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = RegExp(pattern);
      if (regExp.hasMatch(data)) {
        sink.add(data); //La validación se cumplió
      } else {
        sink.addError('Correo no válido');
      }
    },
  );

  final codeValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.length != 5) {
        sink.addError('Código debe tener al menos 5 caracteres.');
      } else {
        sink.add(data); 
      }
    },
  );

  final emailValidatorReg = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) async {
      String pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regExp = RegExp(pattern);

      if (regExp.hasMatch(data)) {
        var col = FirestoreManager.instance.firestore
            .collection("UsuariosDel")
            .where("email", isEqualTo: data);
        var list = await FirestoreManager.instance.getData("", collection: col);

        log("Consulting register");

        if (list.isNotEmpty) {
          sink.addError('Correo ya está registrado.');
        } else {
          sink.add(data); //La validación se cumplió
        }
      } else {
        sink.addError('Correo no válido');
      }
    },
  );

  //contraseña
  final passwordValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.length < 7) {
        sink.addError('Contraseña al menos 7 caracteres');
      } else if (!data.contains(RegExp(r'[0-9]'))) {
        sink.addError('La contraseña debe tener al menos un número');
      } else {
        sink.add(data); //La validación se cumplió
      }
    },
  );

  final passwordValidator1 = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {

      if (data.length < 7) {
        sink.addError('Contraseña al menos 7 caracteres');
      } else if (!data.contains(RegExp(r'[0-9]'))) {
        sink.addError('La contraseña debe tener al menos un número');
      } else {
        sink.add(data); //La validación se cumplió
      }
    },
  );

  //Nombre de usuario
  final usernameValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.isNotEmpty && double.tryParse(data) != null) {
        sink.addError('Error en el campo nombre');
      } else {
        sink.add(data); //La validación se cumplió
      }
    },
  );
  //numero celular
  final numberValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.length >= 10) {
        sink.add(data); //La validación se cumplió
      } else {
        sink.addError('Este campo requiere al menos 10 caracteres');
      }
    },
  );
  //Direccion
  final direcValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.length >= 5) {
        sink.add(data); //La validación se cumplió
      } else {
        sink.addError('Este campo requiere al menos 5 caracteres');
      }
    },
  );

  //Cedula
  final idValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      //verifica si la entrada de datos es nula o está vacía. Si es así, la función enviará un mensaje de error diciendo "Ingresa una cédula válida".
      if (data.isEmpty) {
        sink.addError('Ingresa una identificación válida');
        return;
      }

      sink.add(data); // La validación se cumplió
    },
  );

  //Placa del vehiculo
  final placaValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.length >= 5) {
        sink.add(data); //La validación se cumplió
      } else {
        sink.addError('Este campo requiere al menos 5 caracteres');
      }
    },
  );
  //Color del vehiculo
  final colorValidator = StreamTransformer<String, String>.fromHandlers(
    handleData: (data, sink) {
      if (data.isNotEmpty && double.tryParse(data) != null) {
        sink.addError('Error en el campo color');
      } else {
        sink.add(data); //La validación se cumplió
      }
    },
  );
}
