import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

Future<int> sendEmail(String email, String subject, String content) async {
  String brevoApiKey = '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';  // Reemplaza con tu clave de API de Brevo

  int result = 500;

  Map<String, String> headers = {
    'accept': 'application/json',
    'api-key': brevoApiKey,
    'content-type': 'application/json',
  };

  Map<String, dynamic> payload = {
    "sender": {"email": "vantablack@gmail.com", "name": "Support"},
    "subject": subject,
    "htmlContent": "<!DOCTYPE html><html><body>$content</body></html>",
    "messageVersions": [
      // Definición de la versión del mensaje 1
      {
        "to": [
          {"email": email, "name": "Cliente"},
        ],
      },
    ]
  };
  try {
    final response = await http.post(
      Uri.parse('https://api.brevo.com/v3/smtp/email'),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      log('Correo enviado exitosamente.');
    } else {
      log('Error al enviar el correo. Código de estado: ${response.statusCode}');
    }
    result = response.statusCode;
  } catch (e) {
    log('Error al enviar el correo: $e');
  }
  return result;
}

int generarNumeroAleatorio(int min, int max) {
  math.Random random = math.Random();
  return min + random.nextInt(max - min + 1);
}
