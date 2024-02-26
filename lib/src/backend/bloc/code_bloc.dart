import 'package:prowes_motorizado/src/backend/bloc/validator_bloc.dart';
import 'package:rxdart/rxdart.dart';

class CodeBloc with Validator {
  CodeBloc();
  //Controllers
  final _codeController = BehaviorSubject<String>();
  //Streams, vinculados con la validación
  Stream<String> get codeStream =>
    _codeController.stream.transform(codeValidator);
  Stream<bool> get formRecoveryPasswordStream1 =>
    Rx.combineLatest2(codeStream, codeStream, (a, b) => true);
  //Funciones para el onChange cada control
  Function(String) get changeCode => _codeController.sink.add;
  //Propiedades con el valor del texto ingreso
  String get code => _codeController.value;
}
