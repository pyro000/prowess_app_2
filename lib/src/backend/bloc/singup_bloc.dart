import 'package:prowes_motorizado/src/backend/bloc/validator_bloc.dart';
import 'package:rxdart/rxdart.dart';

class SignUpBloc with Validator {
  SignUpBloc();

  final _usernameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _confirmPassword = BehaviorSubject<String>();
  final _numberController = BehaviorSubject<String>();
  final _direcController = BehaviorSubject<String>();
  final _idController = BehaviorSubject<String>();
  final _placaController = BehaviorSubject<String>();
  final _colorController = BehaviorSubject<String>();


  Stream<String> get usernameStream =>
      _usernameController.stream.transform(usernameValidator);
  Stream<String> get emailStream =>
      _emailController.stream.transform(emailValidatorReg);
  Stream<String> get passwordStream =>
      _passwordController.stream.transform(passwordValidator);

  Stream<String> get confirmPassword$ =>
      _confirmPassword.stream.transform(passwordValidator).doOnData((String c) {
        if (0 != password.compareTo(c)) {
          _confirmPassword.addError("Las contraseñas no coinciden.");
        }
      });

  Stream<String> get numberStream =>
      _numberController.stream.transform(numberValidator);
  Stream<String> get direcStream =>
      _direcController.stream.transform(direcValidator);
  Stream<String> get idStream => _idController.stream.transform(idValidator);
  Stream<String> get placaStream => _placaController.stream.transform(placaValidator);
  Stream<String> get colorStream => _colorController.stream.transform(colorValidator);

  void setConfirmPassword(String value) => _confirmPassword.sink.add(value);
   void clearConfirmPassword() => _confirmPassword.sink.add("");
  String get geConfirmPasswordStr => _confirmPassword.value;

  Stream<bool> get signUpValidStream => Rx.combineLatest8(usernameStream, emailStream, passwordStream, numberStream, direcStream, idStream, placaStream, colorStream, (a, b, c, d, e, f, g, h) => true);
  Stream<bool> get signUpAdminValidStream => Rx.combineLatest6(
    emailStream,
    passwordStream,
    confirmPassword$,
    usernameStream,
    numberStream,
    idStream,
    (a, b, c, d, e, f) =>
        true);

  Stream<bool> get signUpAdminValidStream1 => Rx.combineLatest2(
    passwordStream,
    confirmPassword$,
    (a, b) =>
        true);
    
  Function(String) get changeUsername => _usernameController.sink.add;
  Function(String) get changeEmail => _emailController.sink.add;
  Function(String) get changePassword => _passwordController.sink.add;
  Function(String) get changeNumber => _numberController.sink.add;
  Function(String) get changeDirec => _direcController.sink.add;
  Function(String) get changeId => _idController.sink.add;
  Function(String) get changePlaca => _placaController.sink.add;
  Function(String) get changeColor => _colorController.sink.add;

  String get username => _usernameController.value;
  String get email => _emailController.value;
  String get password => _passwordController.value;
  String get number => _numberController.value;
  String get direction => _direcController.value;
  String get id => _idController.value;
  String get placa => _placaController.value;
  String get color => _colorController.value;

  dispose() {
    _usernameController.close();
    _emailController.close();
    _passwordController.close();
    _confirmPassword.close();
    _numberController.close();
    _direcController.close();
    _idController.close();
    _placaController.close();
    _colorController.close();
  }
}
