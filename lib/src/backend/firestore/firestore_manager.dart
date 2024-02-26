import 'dart:developer';
import 'dart:typed_data';

import 'package:firedart/auth/exceptions.dart';
import 'package:firedart/firedart.dart';
import 'package:firedart/firestore/token_authenticator.dart';
//import 'package:prowes_motorizado/src/backend/firestore/sharedpref.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/services.dart' show ByteData, VoidCallback, rootBundle;
//import 'dart:typed_data';
import 'dart:io';

class FirestoreManager {
  static final FirestoreManager _instance =
      FirestoreManager._privateConstructor();
  FirestoreManager._privateConstructor();
  static FirestoreManager get instance => _instance;

  final String apikey = "AIzaSyBIU01HicfGx6dYpdMyTA2nJ4ZVeyW0V8o";
  final String projectId = 'prowess-web-database';
  final String collectionName = 'key';
  //bool lock = false;
  bool connected = false;

  // La colección que se va a usar para comprobar que funciona la conexión,
  // LA COLECCIÓN DEBE ESTAR CON UN ELEMENTO MÍNIMO.
  final String testCollection = 'usuario';

  final Map<String, dynamic> defaultcreds = {
    'email': 'prowess@key.com',
    'password': 'prowess'
  };

  dynamic firestore;

  Map<String, dynamic> subscriptions = {};

  Future<void> connect() async {
    //Agarrando la Key

    try {
      Firestore.initialize(projectId);
    } catch (e) {
      log(e.toString());
    }

    var kmap = await Firestore.instance.collection(collectionName).get();

    //Iniciando interfaz de inicio de sesión
    var firebaseAuth = FirebaseAuth(apikey, VolatileStore());

    var auth = TokenAuthenticator.from(firebaseAuth)?.authenticate;
    firestore = Firestore(projectId, authenticator: auth);

    dynamic key;

    if (kmap.isEmpty) {
      key = defaultcreds;
    } else {
      key = kmap.first;
    }

    dynamic user;

    try {
      user = await firebaseAuth.signIn(key['email'], key['password']);
    } on AuthException catch (e) {
      log(e.toString());
      // Registra la cuenta artificial si no existe.
      if (e.toString().contains('EMAIL_NOT_FOUND')) {
        user = await firebaseAuth.signUp(key['email'], key['password']);
      }
    }

    var data = {
      "email": key['email'],
      "password": key['password'],
      "description":
          "Cuenta artifical utilizada para autentificarse a Firestore Database."
    };

    await postData('key', data, uid: user.id);
    var map = await getData(testCollection);
    //print(map);

    if (map.isNotEmpty) {
      log('CONNECTED TO FIRESTORE.');
    } else {
      throw Exception("FIRESTORE_CONNECT_FAILED");
    }

    File imageFile =
        await loadImageFromAssets('assets/images/admin.jpg', 'admin.jpg');

    var fsref = FirebaseStorage.instance.ref();
    var ch = fsref.child('AgricolaApp/Usuarios/admin.jpg');
    var uploadTask = ch.putFile(imageFile);
    final snapshot = await uploadTask.whenComplete(() => null);
    var downloadUrl = await snapshot.ref.getDownloadURL();

    log("Connected to Firebase Storage: $downloadUrl");
    connected = true;
  }

  Future<File> loadImageFromAssets(String assetPath, String fileName) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(bytes);
    return file;
  }

  Future<String> uploadImageToFirestore(File image, String folderPath) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(folderPath);
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask.whenComplete(() => null);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('Error al subir la imagen: $e');
      return "";
    }
  }

  Future<void> deleteData(String table, String uid) async {
    try {
      final collection = firestore.collection(table);
      final document = collection.document(uid);
      document.delete().then(
            (doc) => log("Document $uid deleted"),
            onError: (e) => log("Error deleting document $uid: $e"),
          );
    } catch (e) {
      log("Error al eliminar el documento: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getData(String table,
      {String uid = '', var collection}) async {
    final List<Map<String, dynamic>> result = [];

    log("FM.getData($table) ${uid.isEmpty}");

    try {
      collection ??= firestore.collection(table);
      if (uid.isNotEmpty) {
        collection = collection.document(uid);
      }

      var querySnapshot = await collection.get();

      if (uid.isNotEmpty) {
        Map<String, dynamic> m = {};
        m['uid'] = querySnapshot.id;
        for (var map in querySnapshot.map.entries) {
          m[map.key] = map.value;
        }
        result.add(m);
        return result;
      }

      for (var doc in querySnapshot) {
        Map<String, dynamic> m = {};
        m['uid'] = doc.id;
        for (var map in doc.map.entries) {
          m[map.key] = map.value;
        }
        result.add(m);
      }
    } catch (e) {
      log('Error getData: $e');
    }
    return result;
  }

  Future<void> subscribe(String table,
      {String uid = '',
      var collection,
      VoidCallback? callback,
      String customId = ""}) async {
    log("FM.subscribe($table/$uid/$customId) ${uid.isEmpty}");

    try {
      collection ??= firestore.collection(table);
      if (uid.isNotEmpty) {
        collection = collection.document(uid);
      }

      var map = await getData("", collection: collection);

      if (subscriptions.containsKey(table + uid + customId)) {
        subscriptions[table + uid + customId]["id"].cancel();
      }
      subscriptions[table + uid + customId] = {};
      subscriptions[table + uid + customId]["count"] = 0;

      final subscription = collection.stream.listen((document) {
        if (subscriptions[table + uid + customId]["count"] >= map.length-1) {
          final List<Map<String, dynamic>> result = [];
          log('updated ${table + uid + customId}: $document');

          if (uid.isNotEmpty) {
            Map<String, dynamic> m = {};
            m['uid'] = document.id;
            for (var map in document.map.entries) {
              m[map.key] = map.value;
            }
            result.add(m);
          } else {
            for (var doc in document) {
              Map<String, dynamic> m = {};
              m['uid'] = doc.id;
              for (var map in doc.map.entries) {
                m[map.key] = map.value;
              }
              result.add(m);
            }
          }
          subscriptions[table + uid + customId]["data"] = result;
          callback?.call();
        } else {
          subscriptions[table + uid + customId]["count"]++;
        }
      });

      subscriptions[table + uid + customId]["id"] = subscription;
    } catch (e) {
      log('Error FM.subscribe: $e');
    }
  }

  Future<String> postData(String table, Map<String, dynamic> data,
      {String uid = '', bool edit = false}) async {
    log("FM.setData($table)");
    //writing = true;
    try {
      var target = firestore.collection(table);
      Document? docRef;

      if (uid.isNotEmpty) {
        target = target.document(uid);

        if (edit) {
          target.update(data);
        } else {
          target.set(data);
        }
      } else {
        docRef = await target.add(data);
      }

      if (docRef != null) {
        uid = docRef.id;
      }
      //writing = false;
      return uid;
    } catch (e) {
      log("Error postData: $e");
      //writing = false;
      return "";
    }
  }
}
