
import 'package:shared_preferences/shared_preferences.dart';

class CustomSharedPreferences {
  CustomSharedPreferences();
  static const debugger = 'Debugger';
  
  static Future<void> saveDebugger(bool value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(debugger, value);
  }

  static Future<bool> getDebugger() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(debugger) ?? true;
  }
}

class ListDataModel {
  final String message;
  final String buttonText;
  final void Function()? onPressed;

  ListDataModel({
    required this.message,
    required this.buttonText,
    this.onPressed,
  });
}