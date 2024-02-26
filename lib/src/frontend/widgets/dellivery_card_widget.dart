import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/comprador_model.dart';
import 'package:prowes_motorizado/src/backend/models/pedido_model.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
//import 'package:prowes_motorizado/src/models/detalle_model.dart';
//import 'package:prowes_motorizado/src/pages/detalle_pedido_page.dart';
import 'package:prowes_motorizado/src/frontend/pages/location_page.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/detalle_pedido_widget.dart';


class DeliveryCardWidget extends StatelessWidget {
  const DeliveryCardWidget({Key? key, required this.pedido, required this.onDataUpdated}) : super(key: key);
  final Pedido pedido;
  final VoidCallback onDataUpdated;

  @override
  Widget build(BuildContext context) {
    Comprador? comprador = pedido.comprador;
    String? estado = pedido.estado;

    final mainProvider = MainProvider.instance;
    Map<String, dynamic> content = json.decode(mainProvider.data);

    Color color = Colors.green;
    if (estado != null) {
      if (estado == "Procesando") {
        color = Colors.lime;
      } else if (estado == "Entregando") {
        color = Colors.cyan;
      } else if (estado == "Completado") {
        color = Colors.white;
      }
    }
    
    bool client = content["rol"] == "Cliente"  || content["rol"] == "Administrador";

    bool tomap = !client && (pedido.estado == "Procesando" || pedido.estado == "Entregando");
    
    /*bool cond1_1 = !content.containsKey("mot_ord_activa") || content["mot_ord_activa"] == null || content["mot_ord_activa"] == "";
    bool cond1_2 = pedido.uidMot == null || pedido.uidMot == "";
    bool cond1 = cond1_1 && cond1_2;

    bool cond2_1 = pedido.uidMot == content["user_id"];
    bool cond2_2 = pedido.estado == "Completado";

    bool cond2 = !cond1_1 && cond2_1 && !cond2_2;
    bool cond3 = cond1_1 && cond2_1 && cond2_2;
    
    bool condfinal = cond1 || cond2 || cond3;*/

    //log("$cond1_1 $cond1_2 $cond2_1 $cond2_2 / $cond1 $cond2 $cond3 $condfinal ${pedido.estado}");
    
    var prods = "Productos: ";
    
    var len = pedido.productos!.length;

    for (int i = 0; i < len; i++){
      Producto d = pedido.productos![i];

      prods += "${d.nombre}";
      if (i < len-1) {
        prods += ", ";
      } 
    }

    //var latlng = LatLng(pedido.lat)
    //var dist1 = dist.

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.h, vertical: 2.h),
      child: /*condfinal ?*/ Card(
        elevation: 3,
        shadowColor: Colors.deepPurple,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 1.h),
          borderRadius: BorderRadius.circular(15.h),
        ),
        child: InkWell(
          onTap: () async {
            /*if (tomap) {
              SnackBarTool.showSnackbar(context, text: "Accediendo Pedido, recuerde presionar en 'Llegué' cuando retire/entregue el producto, y debe estar a menos de 10 metros de la ubicación que debe ir.",);
            }*/

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                  /*tomap ? PageLocation(pedido: pedido) :*/ PageBuilder(bodyWidget: DetallePedido(pedido: pedido)) ,
              ),
            );

            onDataUpdated();
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.h),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !client ? comprador!.nombre! : pedido.estado!,
                        style: TextStyle(
                          fontSize: 16.h,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        prods,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        "Precio Total: ${Math.round(pedido.total!)}\$",
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Text("Distancia: ${Math.round(pedido.distance!)} km"),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.h),
                  child: CircleAvatar(
                      backgroundImage:
                          const AssetImage("assets/images/libre.png"),
                      backgroundColor: color,
                      radius: 18.h),
                ),
              ],
            ),
            
          ),
        ),
      ) /*: null*/,
      
    );
  }
}
