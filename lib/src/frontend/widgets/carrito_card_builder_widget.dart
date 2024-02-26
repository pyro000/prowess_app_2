import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/producto_model.dart';
import 'package:prowes_motorizado/src/frontend/widgets/carrito_card_widget.dart';
import 'package:prowes_motorizado/src/backend/provider/main_provider.dart';
import 'dart:convert';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class Carrito extends StatefulWidget {
  const Carrito({Key? key}) : super(key: key);

  @override
  State<Carrito> createState() => _MotorizadosState();
}

class _MotorizadosState extends State<Carrito> {
  late Future<List<Producto>> _motorizadosFuture;

  @override
  void initState() {
    super.initState();
    _motorizadosFuture = _downloadMotorizado();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      color: Colors.white, // Establece el color de fondo
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 80.h, vertical: 10.h),
            child: Material(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(16.h),
              child: SizedBox(
                height: 30.h,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 25.h,
                        ),
                      SizedBox(width: 15.h),
                      Text(
                        "Carrito",
                        style: TextStyle(
                            fontSize: 18.h, fontWeight: FontWeight.bold
                            
                            ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Producto>>(
              future: _motorizadosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay productos en el carrito."));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final motorizado = snapshot.data![index];
                      return CarritoCard(profileImage: motorizado.imagen, producto: motorizado);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Producto>> _downloadMotorizado() async {
    final mainProvider = MainProvider.instance;
    Map<String, dynamic> content = json.decode(mainProvider.data);

    if (!content.containsKey("carrito")){
      content["carrito"] = [];
    }

    List<Producto> list = [];

    for (var p in content["carrito"]){
      list.add(Producto.fromJson2(p));
    }

    return list; // Si motorizados es nulo, devuelve una lista vacía
  }
}
