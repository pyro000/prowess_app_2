import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/backend/services/motorizado_service.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';
import 'package:prowes_motorizado/src/frontend/widgets/motorizado_card_widget.dart';

class Motorizados extends StatefulWidget {
  const Motorizados({Key? key, required this.role}) : super(key: key);
  final String role;

  @override
  State<Motorizados> createState() => _MotorizadosState();
}

class _MotorizadosState extends State<Motorizados> {
  final MotorizadoService _motorizadoService = MotorizadoService();
  late Future<List<Usuario>> _motorizadosFuture;
  late String role;

  @override
  void initState() {
    super.initState();
    _motorizadosFuture = _downloadMotorizado();
    role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3.h),
      //color: Colors.green, // Establece el color de fondo
      child: FutureBuilder<List<Usuario>>(
        future: _motorizadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hay $role"));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final motorizado = snapshot.data![index];
                return MotorizadoCard(
                    profileImage: motorizado.profileImage,
                    motorizado: motorizado,
                    role: role
                    );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Usuario>> _downloadMotorizado() async {
    final motorizados = await _motorizadoService.getPedidoM();
    return motorizados ??
        []; // Si motorizados es nulo, devuelve una lista vacía
  }
}
