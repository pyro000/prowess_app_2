import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prowes_motorizado/src/backend/bloc/code_bloc.dart';
import 'package:prowes_motorizado/src/backend/bloc/login_bloc.dart';
import 'package:prowes_motorizado/src/backend/bloc/singup_bloc.dart';
import 'package:prowes_motorizado/src/backend/services/usuario_services.dart';
import 'package:prowes_motorizado/src/backend/utils/colors.dart';
import 'package:prowes_motorizado/src/backend/services/mail_service.dart';
import 'package:prowes_motorizado/src/backend/utils/snack_bar.dart';
import 'package:prowes_motorizado/src/frontend/widgets/loading_widget.dart';

class RecoveryPassword extends StatefulWidget {
  const RecoveryPassword({Key? key}) : super(key: key);

  @override
  State<RecoveryPassword> createState() => _RecoveryPasswordState();
}

class _RecoveryPasswordState extends State<RecoveryPassword> {
  final LoginBloc _recoveryPasswordBloc = LoginBloc();
  final CodeBloc _recoveryPasswordBloc1 = CodeBloc();
  final SignUpBloc _recoveryPasswordBloc2 = SignUpBloc();
  bool _onSaving = false;
  final UsuarioService _usuarioService = UsuarioService();
  int step = 1;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    String title = "";
    String buttonMsg = "";
    Widget contents = Container();
    Stream<bool> steamer = _recoveryPasswordBloc.formRecoveryPasswordtream;

    switch (step) {
      case 1:
        title = "Recupera tu Contraseña";
        buttonMsg = "Recuperar";
        contents = step1Widget();
        steamer = _recoveryPasswordBloc.formRecoveryPasswordtream;
        break;
      case 2:
        title = "Revisa tu correo";
        buttonMsg = "Continuar";
        contents = step2Widget();
        steamer = _recoveryPasswordBloc1.formRecoveryPasswordStream1;
        break;
      case 3:
        title = "Nueva contraseña";
        buttonMsg = "Aceptar";
        contents = step3Widget();
        steamer = _recoveryPasswordBloc2.signUpAdminValidStream1;
        break;
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 100.h),
          margin: EdgeInsets.all(18.h),
          color: const Color.fromRGBO(255, 255, 255, 1),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Center(
                  child: Image.asset(
                    'assets/images/Logoold_1.1.png',
                    width: 300.h,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10.h, 0, 10.h),
                child: Text(
                  //'Recupera tu Contraseña',
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 25.h,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              //Container(
              Column(
                children: [
                  //margin: EdgeInsets.symmetric(horizontal: 30.h),
                  //child:
                  contents,

                  Container(
                    margin: EdgeInsets.symmetric(vertical: 18.h),
                    child: StreamBuilder<bool>(
                      stream: steamer,
                      builder: (context, snapshot) {
                        return _onSaving
                            ? Container(
                                padding: EdgeInsets.all(12.h),
                                child: SizedBox.square(
                                  dimension: 25.h,
                                  child: const LoadingIndicator(
                                      color: Colors.black),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: snapshot.hasData
                                    ? () async {
                                        if (mounted) {
                                          setState(() => _onSaving = true);
                                        }

                                        int resp = 500;

                                        switch (step) {
                                          case 1:
                                            resp = await step1();
                                            break;
                                          case 2:
                                            resp = await step2();
                                            break;
                                          case 3:
                                            resp = await step3();
                                            break;
                                        }

                                        if (mounted) {
                                          setState(() {
                                            _onSaving = false;
                                            if (resp == 200 || resp == 201) {
                                              step++;
                                            }
                                          });
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
                                  //'Recuperar',
                                  buttonMsg,
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget step1Widget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        StreamBuilder<String>(
          stream: _recoveryPasswordBloc.emailStream,
          builder: (context, snapshot) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromRGBO(97, 206, 112, 1),
                ),
              ),
              child: TextField(
                onChanged: _recoveryPasswordBloc.changeEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: snapshot.error?.toString(),
                  icon: const Icon(Icons.email_outlined),
                  labelText: "Correo electrónico",
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget step2Widget() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      StreamBuilder<String>(
        stream: _recoveryPasswordBloc1.codeStream,
        builder: (context, snapshot) {
          return /*Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromRGBO(97, 206, 112, 1),
                ),
              ),
              child:*/
              TextField(
            onChanged: _recoveryPasswordBloc1.changeCode,
            maxLength: 5,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              errorText: snapshot.error?.toString(),
              icon: const Icon(Icons.numbers),
              labelText: "Código recibido en correo",
            ),
            //),
          );
        },
      ),
    ]);
  }

  Widget step3Widget() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      StreamBuilder<Object>(
        stream: _recoveryPasswordBloc2.passwordStream,
        builder: (context, snapshot) {
          return TextField(
            onChanged: _recoveryPasswordBloc2.changePassword,
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
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          );
        },
      ),
      StreamBuilder<Object>(
        stream: _recoveryPasswordBloc2.confirmPassword$,
        builder: (context, snapshot) {
          return TextField(
            onChanged: (value) {
              _recoveryPasswordBloc2.setConfirmPassword(value);
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
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              ),
            ),
          );
        },
      ),
    ]);
  }

  Future<int> step1() async {
    int code = generarNumeroAleatorio(11111, 99999);
    int resp =
        await _usuarioService.setRecoverCode(_recoveryPasswordBloc.email, code);
    int resp1 = 500;
    if (resp == 200) {
      resp1 = await sendEmail(
          _recoveryPasswordBloc.email,
          "Recupera tu contraseña.",
          "<h1>Recupera tu contraseña.</h1><p>Este es su código para recuperar su contraseña: <b>$code</b></p><p>Saludos.</p>");
    }
    if (resp != 200 || resp1 != 201) {
      SnackBarTool.showSnackbar(context,
          text: 'Correo incorrecto, intentelo de nuevo.');
    }
    return resp1;
  }

  Future<int> step2() async {
    int resp = 500;
    bool error = false;

    try {
      resp = await _usuarioService.checkRecoverCode(
          _recoveryPasswordBloc.email, int.parse(_recoveryPasswordBloc1.code));
      if (resp != 200) {
        error = true;
      }
    } catch (e) {
      log("recoverypass err: $e");
      error = true;
    }
    if (error) {
      SnackBarTool.showSnackbar(context,
          text: 'Código incorrecto, intentelo de nuevo.');
    }
    return resp;
  }

  Future<int> step3() async {
    int resp = await _usuarioService.resetPassword(
        _recoveryPasswordBloc.email, _recoveryPasswordBloc2.password);
    if (resp == 200) {
      SnackBarTool.showSnackbar(context,
          text: 'Restablecida contraseña correctamente.');
      Navigator.popUntil(context, ModalRoute.withName('/'));
    }
    return resp;
  }
}
