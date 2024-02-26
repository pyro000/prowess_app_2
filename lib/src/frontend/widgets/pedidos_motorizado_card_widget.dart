import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/comprador_model.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
//import 'package:prowes_motorizado/src/pages/detalle_pedido_page.dart';

import 'dart:convert';

import 'package:prowes_motorizado/src/frontend/widgets/detalle_pedido_widget.dart';

class PedidoCardMotorizado extends StatelessWidget {
  const PedidoCardMotorizado({Key? key, required this.pedido, required this.onDataUpdated, required this.uid})
      : super(key: key);
  final Pedido pedido;
  final VoidCallback onDataUpdated;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final mainProvider = MainProvider.instance;
    Map<String, dynamic> content = json.decode(mainProvider.data);
    final Comprador? comprador = pedido.comprador;

    log("${comprador?.nombre} ${comprador?.phone}");

    bool cond1 = content["rol"] == "Administrador" && uid.isEmpty;
    bool cond2 = pedido.motorizado!.uid != null && pedido.motorizado!.uid!.isNotEmpty;
    bool cond3 = pedido.motorizado!.uid == uid;
    bool cond4 = pedido.comprador!.uid != null && pedido.comprador!.uid == uid;
    
    bool condfinal = cond1 || (cond2 && cond3) || cond4;

    log("$cond2 $cond3");
  
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10.h),
        child: condfinal ? Card(
                elevation: 3,
                shadowColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey, width: 1.h),
                  borderRadius: BorderRadius.circular(15.h),
                ),
                child: InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) =>
                          PageBuilder(bodyWidget: DetallePedido(pedido: pedido)) ,
                      ),
                    );

                    onDataUpdated();
                  },
                  child: Container(
                    margin: EdgeInsets.all(3.h),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(padding: EdgeInsets.all(2.h)),
                                Text(
                                  comprador!.nombre ?? "",
                                  style: TextStyle(
                                    fontSize: 15.h,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text("Telefono: " + comprador.phone!),
                                Padding(padding: EdgeInsets.all(2.h)),
                              ]),
                          pedido.estado == "Procesando"
                              ? CircleAvatar(
                                  backgroundImage: const AssetImage(
                                      "assets/images/espera.png"),
                                  backgroundColor: Colors.lime,
                                  radius: 15.h)
                              : pedido.estado == "Libre"
                                  ? CircleAvatar(
                                      backgroundImage: const AssetImage(
                                          "assets/images/libre.png"),
                                      backgroundColor: Colors.green,
                                      radius: 15.h)
                                  : pedido.estado == "Completado" ? CircleAvatar(
                                      backgroundImage: const AssetImage(
                                          "assets/images/entregado.png"),
                                      backgroundColor: Colors.white,
                                      radius: 15.h) :  CircleAvatar(
                                      backgroundImage: const AssetImage(
                                          "assets/images/espera.png"),
                                      backgroundColor: Colors.cyan,
                                      radius: 15.h),
                        ]),
                  ),
                ),
              )
            : null);
  }
}
