import 'dart:convert';

Usuario motorizadoFromJson(String str) =>
    Usuario.fromJson(json.decode(str));

String motorizadoToJson(Usuario data) => json.encode(data.toJson());

class Usuario {
  Usuario({
    this.uid,
    this.email,
    this.password,
    this.name,
    this.telefono,
    this.sector,
    this.cedula,
    this.tipoLic,
    this.caducidadLic,
    this.numPlaca,
    this.colorVeh,
    this.profileImage,
    this.role,
    this.nacionalidad,
    this.coords,
  });

  String? uid;
  String? email;
  String? password;
  String? name;
  String? telefono;
  String? sector;
  String? cedula;
  String? tipoLic;
  String? caducidadLic;
  String? numPlaca;
  String? colorVeh;
  String? profileImage;
  String? role;
  String? nacionalidad;
  Map<String, dynamic>? coords;

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        uid: json["uid"],
        email: json["email"],
        password: json["password"],
        name: json["nombres"],
        telefono: json["datos"]["telefono"],
        sector: json["datos"]["sector"],
        cedula: json["datos"]["cedula"],
        tipoLic: json["datos"]["transporte"]["tipo_licencia"],
        caducidadLic: json["datos"]["transporte"]["caducidad_licencia"],
        numPlaca: json["datos"]["transporte"]["placa"],
        colorVeh: json["datos"]["transporte"]["color_vehiculo"],
        profileImage: json["datos"]["imagen"],
        role: json["rol"],
        nacionalidad: json["datos"]["transporte"]['nacionalidad'],
        coords: json["datos"]['coords'],
      );

  factory Usuario.fromJsonSave(Map<String, dynamic> json) => Usuario(
      uid: json["uid"],
      name: json["nombres"],
      telefono: json["datos"]["telefono"],
      cedula: json["datos"]["cedula"],
      numPlaca: json["datos"]["transporte"]["placa"],
      colorVeh: json["datos"]["transporte"]["color_vehiculo"],
      profileImage: json["datos"]["imagen"],
      role: json["rol"],
      coords: json["datos"]["coords"],
    );

    factory Usuario.fromJsonClient(Map<String, dynamic> json) => Usuario(
      uid: json["uid"],
      name: json["nombres"],
      telefono: json["datos"]["telefono"],
      sector: json["datos"]["sector"],
      cedula: json["datos"]["cedula"],
      profileImage: json["datos"]["imagen"],
      role: json["rol"],
    );

  Map<String, dynamic> stock() => {
        "uid": "",
        "email": "",
        "password": "",
        "nombres": "",
        "rol": "",
        "datos": {
          "telefono": "",
          "sector": "",
          "cedula": "",
          "transporte": {
            "tipo_licencia": "",
            "caducidad_licencia": "",
            "placa": "",
            "color_vehiculo": "",
            "nacionalidad": "",
          },
          "imagen": "",
          "coords": {
            "lat": "",
            "long": ""
          },
        },
      };

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
        "nombres": name,
        "rol": role,
        "datos": {
          "telefono": telefono,
          "sector": sector,
          "cedula": cedula,
          "imagen": profileImage,
          "coords": coords,

          "transporte": {
            "tipo_licencia": tipoLic,
            "caducidad_licencia": caducidadLic,
            "placa": numPlaca,
            "color_vehiculo": colorVeh,
            "nacionalidad": nacionalidad,
          },
        },
      };

  Map<String, dynamic> toJsonMot() => {
        "uid": uid,
        "nombres": name,
        "datos": {
          "telefono": telefono,
          "cedula": cedula,
          "transporte": {
            "tipo_licencia": tipoLic,
            "caducidad_licencia": caducidadLic,
            "placa": numPlaca,
            "color_vehiculo": colorVeh,
          },
          "coords": coords,
        },
      };

  Map<String, dynamic> toJsonClient() => {
        "email": email,
        "password": password,
        "nombres": name,
        "rol": role,
        "datos": {
          "telefono": telefono,
          "sector": sector,
          "cedula": cedula,
          "imagen": profileImage,
          "coords": coords,
        },
      };
}
