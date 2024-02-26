import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prowes_motorizado/src/backend/bloc/singup_bloc.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'dart:developer';

import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class SingUpPage extends StatefulWidget {
  const SingUpPage({Key? key}) : super(key: key);

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  UsuarioService singupService = UsuarioService();

  final SignUpBloc _bloc = SignUpBloc();
  bool _obscureText = true;
  int _currentStep = 0;
  String? licenciaId;

  final items = ['Tipo A', 'Tipo B', 'Tipo C', 'Tipo E'];
  final items2 = ['Motocicleta', 'Camion', 'Camioneta'];
  final itemsN = ['Ecuatoriana', 'Venezolana', 'Colombiana', 'Peruana', 'Otro'];

  String? _valueSelected = 'Tipo A';
  String? _valueSelected2 = 'Motocicleta';
  String? _valueSelectedN = 'Ecuatoriana';

  final TextEditingController _textController = TextEditingController();
  String? _fecha;
  File? _image;
  bool _onSaving = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          iconSize: 20.h,
          tooltip: 'Regresar',
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: <Widget>[
          Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 5.h, 0, 0),
              child: Image.asset(
                'assets/images/Logo_1.png',
                width: 300,
              ),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.h, 5.h, 0, 0),
                child: const Text(
                  'Registrarse',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color.fromRGBO(97, 206, 112, 1),
              ),
            ),
            child: Stepper(
              controlsBuilder:
                  (BuildContext context, ControlsDetails controls) {
                return Row(
                  children: <Widget>[
                    TextButton(
                      onPressed: controls.onStepContinue,
                      child: const Text('Continuar'),
                    ),
                    TextButton(
                      onPressed: controls.onStepCancel,
                      child: const Text('Regresar'),
                    ),
                  ],
                );
              },
              physics:  const ClampingScrollPhysics(),
              elevation: 10.h,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep != 3 && mounted) {
                  setState(() => _currentStep++);
                }
              },
              onStepCancel: () {
                if (_currentStep != 0 && mounted) {
                  setState(() => _currentStep--);
                }
              },
              onStepTapped: (index) {
                if (mounted) {
                  setState(() => _currentStep = index);
                }
              },
              steps: [
                Step(
                  isActive: _currentStep >= 0,
                  title: const Text(""),
                  content: Column(
                    children: <Widget>[
                      titulo('Datos Personales'),
                      textcamp("Correo electrónico", "",
                          const Icon(Icons.email_outlined), 0, 250),
                      textcamp("Nombre y Apellido", "",
                          const Icon(Icons.person_outlined), 1, 250),
                      textcamp("Teléfono", "",
                          const Icon(Icons.phone_android_outlined), 2, 10),
                      textcamp("Sector", " ",
                          const Icon(Icons.location_on_outlined), 3, 250),
                      Row(
                        children: [
                          const Text("Nacionalidad: "),
                          Container(
                            width: 140.h,
                            margin: EdgeInsets.fromLTRB(15.h, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10.h, 0, 8.h, 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all()),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                elevation: 0,
                                value: _valueSelectedN,
                                items: itemsN.map(buildMenuItem).toList(),
                                onChanged: (String? newValue) {
                                  if (mounted) {
                                    setState(() {
                                      _valueSelectedN = newValue!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      textcamp("Número de Identificación", "",
                          const Icon(Icons.badge_outlined), 4, 10),
                      StreamBuilder<Object>(
                        stream: _bloc.passwordStream,
                        builder: (context, snapshot) {
                          return TextField(
                            onChanged: _bloc.changePassword,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              errorText: snapshot.error?.toString(),
                              icon: const Icon(Icons.lock_outline),
                              labelText: "Contraseña",
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _obscureText = !_obscureText;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Step(
                  isActive: _currentStep >= 1,
                  title: const Text(""),
                  content: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 8.h),
                        child: titulo('Datos del Vehiculo'),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.airport_shuttle_sharp,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                          Container(
                            width: 140.h,
                            margin: EdgeInsets.fromLTRB(15.h, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(10.h, 0, 8.h, 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all()),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                elevation: 0,
                                value: _valueSelected2,
                                items: items2.map(buildMenuItem).toList(),
                                onChanged: (String? newValue) {
                                  if (mounted) {
                                    setState(() {
                                      _valueSelected2 = newValue!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.featured_play_list_outlined,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                          Container(
                            width: 100.h,
                            margin: EdgeInsets.fromLTRB(15.h, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(8.h, 0, 8.h, 0),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all()),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                elevation: 0,
                                value: _valueSelected,
                                items: items.map(buildMenuItem).toList(),
                                onChanged: (String? newValue) {
                                  if (mounted) {
                                    setState(() {
                                      _valueSelected = newValue!;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        enableInteractiveSelection: false,
                        controller: _textController,
                        keyboardType: TextInputType.datetime,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today_outlined),
                          labelText: "Fecha de Caducidad",
                        ),
                        onTap: () {
                          FocusScope.of(context).requestFocus(FocusNode());
                          _selectDate(context);
                        },
                      ),
                    ],
                  ),
                ),
                Step(
                  isActive: _currentStep >= 2,
                  title: const Text(""),
                  content: Column(
                    children: [
                      titulo('Datos del Vehículo'),
                      textcamp("Número de Placa", "XBA-2525",
                          const Icon(Icons.confirmation_num_outlined), 5, 8),
                      textcamp("Color del Vehículo", "Rojo",
                          const Icon(Icons.invert_colors_outlined), 6, 45),
                    ],
                  ),
                ),
                Step(
                  isActive: _currentStep >= 3,
                  title: const Text(""),
                  content: Column(
                    children: [
                      titulo('Datos del Perfil'),
                      Column(
                        children: <Widget>[
                          const Text(
                            'Foto de perfil',
                            style: TextStyle(
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                            ),
                          ),
                          Center(
                            child: _image == null
                                ? const Icon(Icons.add_photo_alternate_outlined,
                                    size: 100.0)
                                : Image.file(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                  ),
                          ),
                          Column(
                            verticalDirection: VerticalDirection.down,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 8.h, 0, 0),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      pickImage(ImageSource.gallery),
                                  icon: const Icon(
                                      Icons.add_photo_alternate_outlined),
                                  label: const Text("Galeria"),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 5.h, 0, 0),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text("Cámara"),
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<bool>(
                            stream: _bloc.signUpValidStream,
                            builder: (context, snapshot) {
                              return _onSaving
                                  ? Container(
                                      padding: EdgeInsets.all(12.h),
                                      child: SizedBox.square(
                                        dimension: 25.h,
                                        child: const LoadingIndicator(),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: snapshot.hasData
                                          ? () async {
                                              if (mounted) {
                                                setState(
                                                    () => _onSaving = true);
                                              }
                                              if (_image != null) {
                                                Usuario motorizado =
                                                    Usuario(
                                                  email: _bloc.email,
                                                  password: _bloc.password,
                                                );

                                                var resp = await singupService
                                                    .postMotorizado2(
                                                        motorizado);
                                                log("UID: ${resp["uid"]}");
                                                if (resp["response"] == 201) {
                                                  String urlImage =
                                                      await FirestoreManager
                                                          .instance
                                                          .uploadImageToFirestore(
                                                              _image!,
                                                              "AgricolaApp/Usuarios/${resp["uid"]}");

                                                  motorizado = Usuario(
                                                      email: _bloc.email,
                                                      password: resp["pass"],
                                                      name:_bloc.username,
                                                      telefono: _bloc.number,
                                                      sector:_bloc.direction,
                                                      cedula: _bloc.id,
                                                      tipoLic: _valueSelected,
                                                      caducidadLic: _fecha,
                                                      numPlaca: _bloc.placa,
                                                      colorVeh: _bloc.color,
                                                      profileImage: urlImage,
                                                      role: _valueSelected2,
                                                      nacionalidad:
                                                          _valueSelectedN);

                                                  Map<String, dynamic> map =
                                                      motorizado.toJson();
                                                  FirestoreManager.instance
                                                      .postData(
                                                          "UsuariosDel", map,
                                                          uid: resp["uid"],
                                                          edit: true);

                                                  if (urlImage.isEmpty) {
                                                    resp["response"] = 500;
                                                    FirestoreManager.instance
                                                        .deleteData(
                                                            "UsuariosDel",
                                                            resp["uid"]);
                                                  }
                                                }
                                                if (resp["response"] == 201) {
                                                  SnackBarTool.showSnackbar(context, text: "Motorizado Registrado",);

                                                  Navigator.popUntil(context,
                                                      ModalRoute.withName('/'));
                                                } else {
                                                  SnackBarTool.showSnackbar(context, text: "ERROR al registrar. Intentelo mas tarde.",);
                                                }
                                                if (mounted) {
                                                setState(
                                                  () => _onSaving = false);
                                                }
                                              }
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        primary: const Color.fromRGBO(
                                            97, 206, 112, 1),
                                        elevation: 15.h,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15.h)),
                                      ),
                                      child: Text(
                                        'Registrarse',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.h,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
        value: item,
        child: Text(
          item,
        ),
      );

  Widget titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget textcamp(String label, String hint, Icon icon, int id, int maxlength) {
    return StreamBuilder<String>(
      stream: id == 0
          ? _bloc.emailStream
          : id == 1
              ? _bloc.usernameStream
              : id == 2
                  ? _bloc.numberStream
                  : id == 3
                      ? _bloc.direcStream
                      : id == 4
                          ? _bloc.idStream
                          : id == 5
                              ? _bloc.placaStream
                              : _bloc.colorStream,
      builder: (context, snapshot) {
        return TextField(
          onChanged: id == 0
              ? _bloc.changeEmail
              : id == 1
                  ? _bloc.changeUsername
                  : id == 2
                      ? _bloc.changeNumber
                      : id == 3
                          ? _bloc.changeDirec
                          : id == 4
                              ? _bloc.changeId
                              : id == 5
                                  ? _bloc.changePlaca
                                  : _bloc.changeColor,
          keyboardType: id == 0
              ? TextInputType.emailAddress
              : id == 2
                  ? TextInputType.number
                  : id == 4
                      ? TextInputType.number
                      : TextInputType.text,
          maxLength: maxlength,
          controller: null,
          decoration: InputDecoration(
            errorText: snapshot.error?.toString(),
            icon: icon,
            labelText: label,
            hintText: hint,
          ),
        );
      },
    );
  }

  //Calendario
  _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2028),
    );
    if (picked != null) {
      if (mounted) {
        setState(() {
          _fecha = picked.toString();

          _textController.text =
              '${picked.day} / ${picked.month} / ${picked.year}';
        });
      }
    }
  }

  Future pickImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      SnackBarTool.showSnackbar(context, text: "Imagen seleccionada correctamente.",);
    } else {
      _image = null;
      SnackBarTool.showSnackbar(context, text: "No se seleccionó ninguna imagen.",);
    }
    if (mounted) {
      setState(() {});
    }
  }
}
