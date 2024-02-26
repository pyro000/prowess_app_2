import 'dart:convert';

Pago pagoFromJson(String str) => Pago.fromJson(json.decode(str));

String pagoToJson(Pago data) => json.encode(data.toJson());

class Pago {
  Pago({
    this.totalTax,
    this.tipoDePago,
  });

  String? totalTax;
  String? tipoDePago;

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
        totalTax: json["total_tax"],
        tipoDePago: json["tipo_de_pago"],
      );

  Map<String, dynamic> toJson() => {
        "total_tax": totalTax,
        "tipo_de_pago": tipoDePago,
      };
}
