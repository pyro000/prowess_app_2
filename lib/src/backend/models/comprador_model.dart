import 'dart:convert';

Comprador compradorFromJson(String str) => Comprador.fromJson(json.decode(str));

String compradorToJson(Comprador data) => json.encode(data.toJson());

class Comprador {
  Comprador({
    this.uid,
    this.long,
    this.lat,
    this.ciudad,
    this.nombre,
    this.dir,
    this.phone,
  });

  String? uid;
  String? long;
  String? lat;
  String? ciudad;
  String? nombre;
  String? dir;
  String? phone;

  factory Comprador.fromJson(Map<String, dynamic> json) => Comprador(
        uid: json["uid"],
        long: json["datos"]["coords"]["long"].toString(),
        lat: json["datos"]["coords"]["lat"].toString(),
        //ciudad: json["datos"]["ciudad"],
        nombre: json["nombres"],
        dir: json["datos"]["sector"],
        phone: json["datos"]["telefono"],
      );

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "nombres": nombre,
    "datos": {
      "sector": dir,
      "coords": {
        "long": long,
        "lat": lat,
      },
      //"ciudad": ciudad,
      "telefono": phone,
    },
  };
}
