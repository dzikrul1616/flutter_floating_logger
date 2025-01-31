<div align="center">

![Live Demo](images/logger%20logo.png)

[![Stars](https://img.shields.io/github/stars/dzikrul1616/flutter_floating_logger?style=social)](https://github.com/dzikrul1616/flutter_floating_logger)
[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/dzikrul1616/flutter_floating_logger/testing.yml?label=CI&style=social)](https://github.com/dzikrul1616/flutter_floating_logger/actions/workflows/testing.yml)
![Version](https://img.shields.io/badge/pub-v0.0.1-orange.svg) 
![License](https://img.shields.io/badge/License-MIT-blue.svg)
[![Issues](https://img.shields.io/badge/Issues-Open-brightgreen.svg)](https://github.com/dzikrul1616/flutter_floating_logger/issues) 

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen?style=for-the-badge)](https://dzikrul1616.github.io/preview_floating_logger.github.io/)
</div>

# floating_logger 🚀

**`floating_logger`** is a Flutter library designed to help developers debug and test API calls with ease. It provides a floating widget that allows you to monitor API requests in real-time and even **copy the curl command** for quick testing. Perfect for anyone who wants to streamline the development and debugging process! ⚡

## 📌 Features

- 🎨 **Beautify Debugger Console** - Improved readability for logs
- 📜 **Beautify JSON Response Item** - Better JSON formatting
- 📋 **Copy cURL (Long Tap)** - Easily copy API requests
- 🎈 **Floating Button (Flexible Logger)** - Moveable debugging widget
- 🔄 **Preferences for Global Hide/Show** - Toggle visibility globally
- 🔧 **Custom Item List** - Customize how log items are displayed

## Installation 🔧

To get started, add `floating_logger` to your `pubspec.yaml`:

```yaml
dependencies:
  floating_logger: ^latest_version

```
package import :

```dart 
import 'package:floating_logger/floating_logger.dart';
```


## Demo 🎥

![logo](images/preview.gif)

<div align="center">

Check out the live demo of **Floating Logger**:  

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen?style=for-the-badge)](https://dzikrul1616.github.io/preview_floating_logger.github.io/)

</div>


## Preview Debug

Here is the preview of the debug console log for the HTTP request:

![logo](images/%5BGET%5Drequest_debug_api.png)  
*Above: Example of the HTTP request.*

![logo](images/%5BGET%5Dresponse_debug_api.png)  
*Middle: HTTP response log.*

![logo](images/%5BGET%5Derror_debug_api.png)  
*Below: HTTP error log.*


## 📖 Usage

### 🏗 Wrapping Your App with `FloatingLoggerControl`
To activate the floating logger, wrap your main widget inside `FloatingLoggerControl`.

```dart
return FloatingLoggerControl(
  child: Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("Floating Logger Test"),
    ),
  ),
);
```

### 🌍 Logging API Calls with `DioLogger`
Replace your `Dio` instance with `DioLogger` to ensure API logs appear in the floating logger.

```dart
Future<void> fetchData() async {
  try {
    final response = await DioLogger.instance.get(
      'https://api.genderize.io',
      queryParameters: { "name": "james" },
    );
    if (response.statusCode == 200) {
      // Handle API response
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('API request failed')),
    );
  }
}
```

---

## 🎚 Toggle Floating Logger Visibility Using Preferences
Use `ValueNotifier` to toggle the logger visibility dynamically. This allows you to enable or disable the logger and persist the setting across app sessions.

### 📌 Define the Visibility Notifier
```dart
final ValueNotifier<bool> isLoggerVisible = ValueNotifier<bool>(true);

@override
void initState() {
  loadLoggerSettings();
  super.initState();
}

Future<void> loadLoggerSettings() async {
  try {
    bool pref = await getStoredPreference();
    setState(() {
      isLoggerVisible.value = pref;
    });
  } catch (e) {
    print(e);
  }
}

Future<bool> getStoredPreference() async {
  return await CustomSharedPreferences.getDebugger();
}
```

### 📌 Apply Preferences in `FloatingLoggerControl`
```dart
return FloatingLoggerControl(
  getPreference: getStoredPreference,
  isShow: isLoggerVisible,
  child: Scaffold(
    appBar: AppBar(title: Text("Logger Toggle Test")),
    body: Switch(
      activeTrackColor: Colors.blue,
      value: isLoggerVisible.value,
      onChanged: (value) {
        setState(() {
          isLoggerVisible.value = value;
          CustomSharedPreferences.saveDebugger(value);
        });
      },
    ),
  ),
);
```

---

## 🎨 Customizing Floating Logger UI
You can modify the floating logger’s UI using `widgetItemBuilder` to create a custom log display format.

```dart
return FloatingLoggerControl(
  widgetItemBuilder: (index, data) {
    final item = data[index];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: ListTile(
          title: Text('${item.type!} [${item.response}]', style: TextStyle(fontSize: 12.0)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("URL   : ${item.path}", style: TextStyle(fontSize: 12.0)),
              Text("Data  : ${item.data}", style: TextStyle(fontSize: 12.0)),
              Text("cURL  : ${item.curl}", style: TextStyle(fontSize: 12.0)),
            ],
          ),
        ),
      ),
    );
  },
  child: child,
);
```

---

## 🎯 Conclusion
`floating_logger` is a powerful tool that simplifies debugging API calls in Flutter applications. Whether you need to inspect responses, copy cURL commands, or customize the UI, this package provides a seamless experience for developers. Integrate it today and streamline your debugging process! 🚀

📌 **For more details, visit the [GitHub Repository](https://github.com/dzikrul1616/flutter_floating_logger).**
