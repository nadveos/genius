

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Enviroment {

  static String gemini = dotenv.env['GEMINI_API_KEY'] ?? 'Gemini Key dont exist';

}