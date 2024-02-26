import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/backend/utils/math.dart';
import 'package:prowes_motorizado/src/frontend/pages/page_builder.dart';
//import 'package:prowes_motorizado/src/pages/pre_carrito_page.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/titles/button_title.dart';
import 'package:prowes_motorizado/src/frontend/widgets/buttons/checkout_button.dart';
import 'package:prowes_motorizado/src/frontend/widgets/carrito_widget.dart';

class CarritoCard extends StatefulWidget {
  @override
  const CarritoCard(
      {Key? key, required this.profileImage, required this.producto})
      : super(key: key);
  final String? profileImage;
  final Producto producto;
  _CarritoCardState createState() => _CarritoCardState();
}

class _CarritoCardState extends State<CarritoCard> {
  double? precio = 0;
  int cantidad = 1;
  TextEditingController controller = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    Producto prod = widget.producto;
    cantidad = widget.producto.cantidad!;
    precio = cantidad * prod.precio!;
    controller = TextEditingController(text: "$cantidad");
  }

  @override
  Widget build(BuildContext context) {
    Producto prod = widget.producto;
    final mainProvider = MainProvider.instance;
    Map<String, dynamic> content = json.decode(mainProvider.data);

    precio = cantidad * prod.precio!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2.h),
      child: Card(
        elevation: 3,
        shadowColor: const Color.fromARGB(255, 91, 91, 92),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.grey, width: 1.h),
          borderRadius: BorderRadius.circular(15.h),
        ),
        child: InkWell(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 3.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Contenido izquierdo (imagen, nombre, precio, stock)
                Container(
                  constraints: BoxConstraints(
                      maxWidth:
                          150.h), // Establece el ancho máximo del contenedor
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(padding: EdgeInsets.all(3.h)),
                        CircleAvatar(
                          backgroundColor: Colors.green.shade300,
                          radius: 45.h,
                          child: ClipOval(
                            child: CachedNetworkImage(
                              width: 114.h,
                              height: 114.h,
                              fit: BoxFit.cover,
                              imageUrl: prod.imagen ?? "",
                              placeholder: (context, url) =>
                                  const LoadingIndicator(
                                color: Colors.black,
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.person),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 7.h),
                          child: Text(
                            prod.nombre ?? "",
                            style: TextStyle(
                              fontSize: 13.h,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(2.h)),
                        Text(
                          "Precio: ${Math.round(precio!)}\$",
                          style: TextStyle(
                            fontSize: 15.h,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text("Stock: ${prod.stock}"),
                        Padding(padding: EdgeInsets.all(2.h)),
                      ],
                    ),
                  ),
                ),

                // Flechas y número editable a la derecha
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          // Lógica cuando se presiona la flecha izquierda

                          if (cantidad > 1) {
                            cantidad--;
                            precio = prod.precio! * cantidad;
                            controller.text = cantidad.toString();
                          }

                          content["carrito"][prod.id]["cantidad"] =
                              cantidad;
                          content["carrito"][prod.id]["total"] = precio;

                          //log("${content["carrito"]}");

                          mainProvider.data = json.encode(content);

                          setstate();
                        },
                      ),
                      SizedBox(
                        width: 30.h,
                        child: TextFormField(
                          //initialValue: "1", // Valor inicial del número editable
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: controller,
                          onChanged: (value) {
                            // Lógica cuando cambia el valor del número editable
                            try {
                              int num = int.parse(value);

                              log("${num > prod.stock!} ${num < 1}");

                              if (num > prod.stock! || num < 1) {
                                controller.text = "1";
                              }

                              cantidad = int.parse(controller.text);
                              precio = prod.precio! * cantidad;

                              content["carrito"][prod.id]["cantidad"] =
                                  cantidad;
                              content["carrito"][prod.id]["total"] = precio;
                              mainProvider.data = json.encode(content);

                              setstate();
                            } on FormatException {
                              controller.text = "1";
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          // Lógica cuando se presiona la flecha derecha
                          //log("$cantidad ${prod.stock}");
                          if (cantidad < prod.stock!) {
                            cantidad += 1;
                            precio = prod.precio! * cantidad;
                            controller.text = cantidad.toString();

                            content["carrito"][prod.id]["cantidad"] =
                                cantidad;
                            content["carrito"][prod.id]["total"] = precio;
                            mainProvider.data = json.encode(content);

                            //log("${controller.text} / $cantidad");
                            setstate();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          content["carrito"].removeAt(prod.id);

                          for (int i = 0; i < content["carrito"].length; i++) {
                            content["carrito"][i]["id"] = i;
                          }

                          mainProvider.data = json.encode(content);

                          Navigator.of(context).pop();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PageBuilder(
                                  bodyWidget: CarritoWidget(),
                                  title:
                                      ButtonTitle(bodyWidget: CheckOutButton()),
                                ),
                              ));
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void setstate() {
    if (mounted) {
      setState(() {});
    }
  }
}
