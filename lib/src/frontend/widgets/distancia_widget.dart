import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
//import 'dart:developer';

import 'package:prowes_motorizado/src/backend/utils/math.dart';

class DistanciaWidget extends StatefulWidget {
  const DistanciaWidget({Key? key, required this.pedido}) : super(key: key);
  final Pedido pedido;

  @override
  State<DistanciaWidget> createState() => _DistanciaWidgetState();
}

class _DistanciaWidgetState extends State<DistanciaWidget> {
  double _distancia = 0;
  final double _precioKm = 0.15;

  @override
  void initState() {
    _distancia = widget.pedido.distance!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double precioDist = _distancia * _precioKm;
    double precioProd = widget.pedido.total!;
    double total = precioProd + precioDist;

    return Container(
      margin: EdgeInsets.all(12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total Pedido",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.h),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    SizedBox(
                      height: 30.h,
                      width: 64.h,
                      child: Icon(
                        Icons.gps_fixed,
                        size: 30.h,
                      ),
                    ),
                    Text("Distancia: ${Math.round(_distancia)} km"),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                        height: 30.h,
                        width: 60.h,
                        child: Icon(
                          Icons.food_bank,
                          size: 30.h,
                        ) //Image.asset('assets/images/dollar-symbol.png'),
                        ),

                    SizedBox(
                        width:
                            5), // Agrega un espacio entre la imagen y el texto
                    Text(
                      "Compra: ${Math.round(precioProd)}\$",
                      //style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 30.h,
                      width: 60.h,
                      child: Icon(
                        Icons.delivery_dining,
                        size: 30.h,
                      ),
                    ),
                    SizedBox(
                        width:
                            5), // Agrega un espacio entre la imagen y el texto
                    Text(
                      "Delivery: ${Math.round(precioDist)}\$",
                      //style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 30.h,
                      width: 60.h,
                      child: Icon(
                        Icons.paid,
                        size: 30.h,
                      ),
                    ),
                    SizedBox(
                        width:
                            5), // Agrega un espacio entre la imagen y el texto
                    Text(
                      "Total a pagar: ${Math.round(total)}\$",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
