import 'package:url_launcher/url_launcher.dart';

lauchCorreoElectronico() async {
  final Uri _correoElectronico = Uri(
    scheme: 'mailto',
    path: 'prowessagronomia@gmail.com',
  );

  _launch(_correoElectronico.toString());
}

launchLlamada() async {
  const numeroTelefonico = "tel:+593998160293";
  _launch(numeroTelefonico);
}

launchPhone(String number) async {
  var numeroTelefonico = "tel:$number";
  _launch(numeroTelefonico);
}

launchWhatsApp(String number) async {
  var url = "https://wa.me/+593$number";
  _launch(url);
}

launchURL(String number) {
  var number1 = "";
  if (number.startsWith("+")) {
    number1 = number;
  } else {
    number1 = "+593${number.substring(1)}";
  }

  var url = "https://wa.me/$number1";
  _launch(url);
}

_launch(url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    //throw 'No se encuentra el URL: $url';
  }
}
