import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prowes_motorizado/src/backend/bloc/singup_bloc.dart';
import 'package:prowes_motorizado/src/backend/models/usuario_model.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:prowes_motorizado/src/backend/firestore/firestore_manager.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class SignUpUserPage extends StatefulWidget {
  const SignUpUserPage({Key? key, required this.role}) : super(key: key);

  final String role;
  @override
  State<SignUpUserPage> createState() => _SignUpUserPage();
}

class _SignUpUserPage extends State<SignUpUserPage> {
  final SignUpBloc _bloc = SignUpBloc();
  bool _obscureText = true;
  bool _onSaving = false;
  File? _image;
  UsuarioService adminServices = UsuarioService();

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
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: Image.asset(
                  'assets/images/Logo_1.png',
                  width: 200.h,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
              child: Text(
                'Registrarse',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25.h,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  textcamp(
                    'Correo electrónico',
                    '',
                    const Icon(Icons.email_outlined),
                    0,
                    250,
                  ),
                  textcamp(
                    "Nombre y Apellido",
                    "",
                    const Icon(Icons.person_outlined),
                    1,
                    250,
                  ),
                  textcamp(
                    "Sector",
                    "",
                    const Icon(Icons.location_on_outlined),
                    4, // Cambiado a 4 para representar la dirección
                    250,
                  ),
                  textcamp(
                    "Teléfono",
                    "",
                    const Icon(Icons.phone_android_outlined),
                    2,
                    10,
                  ),
                  textcamp("Número de Cedula", "",
                      const Icon(Icons.badge_outlined), 3, 10),
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
                  StreamBuilder<Object>(
                    stream: _bloc.confirmPassword$,
                    builder: (context, snapshot) {
                      return TextField(
                        onChanged: (value) {
                          _bloc.setConfirmPassword(value);
                        },
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          errorText: snapshot.error?.toString(),
                          icon: const Icon(Icons.lock_outline),
                          labelText: "Confirmar Contraseña",
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
                  SizedBox(height: 40.h),
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
                  Row(
                    verticalDirection: VerticalDirection.down,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8.h, 0, 0),
                        child: ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text("Galeria"),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5.h, 0, 0),
                        child: ElevatedButton.icon(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text("Cámara"),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25, bottom: 25),
                    child: StreamBuilder<bool>(
                      stream: _bloc.signUpAdminValidStream,
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
                                          setState(() => _onSaving = true);
                                        }

                                        Usuario motorizado = Usuario(
                                          email: _bloc.email,
                                          password: _bloc.password,
                                        );

                                        var resp = await adminServices
                                            .postMotorizado2(motorizado);
                                        log("UID: ${resp["uid"]}");
                                        if (resp["response"] == 201) {
                                          String urlImage;

                                          try {
                                            urlImage = await FirestoreManager
                                                .instance
                                                .uploadImageToFirestore(_image!,
                                                    "AgricolaApp/Usuarios/${resp["uid"]}");
                                          } catch (ex) {
                                            log("Error SignupPageUser: $ex");
                                            urlImage = "";
                                          }

                                          if (urlImage.isNotEmpty) {
                                            motorizado = Usuario(
                                                email: _bloc.email,
                                                password: resp["pass"],
                                                name: _bloc.username,
                                                telefono: _bloc.number,
                                                sector: _bloc.direction,
                                                cedula: _bloc.id,
                                                profileImage: urlImage,
                                                role: widget.role,
                                            );

                                            Map<String, dynamic> map =
                                                motorizado.toJsonClient();
                                            FirestoreManager.instance.postData(
                                                "UsuariosDel", map,
                                                uid: resp["uid"], edit: true);
                                          } else {
                                            resp["response"] = 500;
                                          }
                                        }
                                        if (resp["response"] == 201) {
                                          SnackBarTool.showSnackbar(context, text: "Cliente Registrado.",);
                                          if (mounted) {
                                            setState(() => _onSaving = false);
                                          }
                                          Navigator.popUntil(context,
                                              ModalRoute.withName('/'));
                                        } else {
                                          SnackBarTool.showSnackbar(context, text: "Error al registrar. Intentelo más tarde.",);
                                          await FirestoreManager.instance
                                              .deleteData(
                                                  "UsuariosDel", resp["uid"]);

                                          if (mounted) {
                                            setState(() => _onSaving = false);
                                          }
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  primary:
                                      const Color.fromRGBO(97, 206, 112, 1),
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
                  ),
                ],
              ),
            ),
          ],
        ),
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
                      ? _bloc.idStream
                      : id == 4
                          ? _bloc
                              .direcStream // Cambiado a 4 para representar la dirección
                          : _bloc.passwordStream,
      builder: (context, snapshot) {
        return TextField(
          onChanged: id == 0
              ? _bloc.changeEmail
              : id == 1
                  ? _bloc.changeUsername
                  : id == 2
                      ? _bloc.changeNumber
                      : id == 3
                          ? _bloc.changeId
                          : id == 4
                              ? _bloc
                                  .changeDirec // Cambiado a 4 para representar la dirección
                              : _bloc.changePassword,
          keyboardType: id == 0
              ? TextInputType.emailAddress
              : id == 2
                  ? TextInputType.number
                  : id == 4
                      ? TextInputType.text // Cambiado para la dirección
                      : TextInputType.text,
          controller: null,
          maxLength: maxlength,
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
