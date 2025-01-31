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