import 'dart:convert';

Vendedor vendedorFromJson2(String str) => Vendedor.fromJson(json.decode(str));
String vendedorToJson(Vendedor data) => json.encode(data.toJson());

class Vendedor {
  Vendedor({
    this.ciudad,
    this.calle,
    this.lat,
    this.long,
    this.phone,
    this.nombre,
  });

  String? ciudad;
  String? calle;
  String? lat;
  String? long;
  String? phone;
  String? nombre;

  factory Vendedor.fromJson(Map<String, dynamic> json) => Vendedor(
        //ciudad: json["datos"]["ciudad"],
        calle: json["datos"]["sector"],
        lat: json["datos"]["coords"]["lat"],
        long: json["datos"]["coords"]["long"],
        phone: json["datos"]["telefono"],
        nombre: json["nombres"],
      );

  Map<String, dynamic> toJson() => {
        "datos": {
          //"ciudad": ciudad,
          "sector": calle,
          "telefono": phone,
          "coords":{
            "lat": lat,
            "long": long,
          }
        },
        "nombres": nombre,
      };
}
