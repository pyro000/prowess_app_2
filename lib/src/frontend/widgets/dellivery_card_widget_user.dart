import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
//import 'package:prowes_motorizado/src/pages/detalle_producto_page.dart';
//import 'package:prowes_motorizado/src/provider/main_provider.dart';
//import 'dart:convert';

import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/frontend/widgets/detalle_producto_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class DeliveryCardWidget extends StatelessWidget {
  const DeliveryCardWidget({
    Key? key,
    required this.producto,
    required this.onDataUpdated,
  }) : super(key: key);

  final Producto producto;
  final VoidCallback onDataUpdated;

  @override
  Widget build(BuildContext context) {
    //final mainProvider = MainProvider.instance;
    //Map<String, dynamic> content = json.decode(mainProvider.data);

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
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    PageBuilder(bodyWidget: DetalleUserPedido(producto: producto)),
              ),
            );

            onDataUpdated();
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre ?? "",
                        style: TextStyle(
                          fontSize: 16.h,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "Precio: ${Math.round(producto.precio!)}\$",
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5.h),
                      Text("Stock: ${producto.stock}"),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: CustomColors.primaryColor,
                  radius: 45.h,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      width: 114.h,
                      height: 114.h,
                      fit: BoxFit.cover,
                      imageUrl: producto.imagen ?? "",
                      placeholder: (context, url) =>
                          const LoadingIndicator(color: Colors.black,),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.person),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ) /*: null*/,
    );
  }
}
