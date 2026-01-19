<div align="center">
  <img src="https://github.com/dzikrul1616/flutter_floating_logger/blob/main/images/logger%20logo.png?raw=true" alt="Logo Floating Logger" />
  <br />

  <a href="https://app.codecov.io/gh/dzikrul1616/flutter_floating_logger">
    <img src="https://codecov.io/gh/dzikrul1616/flutter_floating_logger/branch/main/graph/badge.svg" alt="Codecov" />
  </a>

  <a href="https://pub.dev/packages/floating_logger/score">
    <img src="https://img.shields.io/pub/points/floating_logger" alt="Pub Points" />
  </a>

  <br />
  <a href="https://github.com/dzikrul1616/flutter_floating_logger">
    <img src="https://img.shields.io/github/stars/dzikrul1616/flutter_floating_logger?style=social" alt="Stars" />
  </a>
  <a href="https://github.com/dzikrul1616/flutter_floating_logger/actions/workflows/testing.yml">
    <img src="https://img.shields.io/github/actions/workflow/status/dzikrul1616/flutter_floating_logger/testing.yml?label=CI&style=social" alt="GitHub Actions" />
  </a>
  <img src="https://img.shields.io/badge/pub-v2.1.2-orange.svg" alt="Version" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
  <a href="https://github.com/dzikrul1616/flutter_floating_logger/issues">
    <img src="https://img.shields.io/badge/Issues-Open-brightgreen.svg" alt="Issues" />
  </a>

  <br />
  <a href="https://dzikrul1616.github.io/preview_floating_logger.github.io/">
    <img src="https://img.shields.io/badge/Live-Demo-brightgreen?style=for-the-badge" alt="Live Demo" />
  </a>
</div>

# floating_logger 🚀

**`floating_logger`** is a Flutter library designed to help developers debug and test API calls with ease. It provides a floating widget that allows you to monitor API requests in real-time and even **copy the curl command** for quick testing. Perfect for anyone who wants to streamline the development and debugging process! ⚡

## 📌 Features

- ✅ **Advanced Search & Deep Debugging** - Search log path, headers, body, response, and deep JSON content with highlighting and auto-expansion
- ✅ **Dynamic Search Navigation** - Easily navigate through multiple search matches with up/down arrows
- ✅ **Beautify JSON Response Item** - Collapsible and formatted JSON viewer
- ✅ **Network Simulator** - Test Slow, Offline, and Normal network conditions
- ✅ **Copy cURL (Long Tap)** - Easily copy API requests
- ✅ **Floating Button (Flexible Logger)** - Moveable debugging widget
- ✅ **Preferences for Global Hide/Show** - Toggle visibility globally
- ✅ **Custom Item List** - Customize how log items are displayed

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

![logo](https://github.com/dzikrul1616/flutter_floating_logger/blob/main/images/preview.gif?raw=true)

<div align="center">

Check out the live demo of **Floating Logger**:  

[![Live Demo](https://img.shields.io/badge/Live-Demo-brightgreen?style=for-the-badge)](https://dzikrul1616.github.io/preview_floating_logger.github.io/)

</div>


## Preview Debug

Here is the preview of the debug console log for the HTTP request:

![logo](https://github.com/dzikrul1616/flutter_floating_logger/blob/main/images/%5BGET%5Drequest_debug_api.png?raw=true)  
*Above: Example of the HTTP request.*

![logo](https://github.com/dzikrul1616/flutter_floating_logger/blob/main/images/%5BGET%5Dresponse_debug_api.png?raw=true)  
*Middle: HTTP response log.*

![logo](https://github.com/dzikrul1616/flutter_floating_logger/blob/main/images/%5BGET%5Derror_debug_api.png?raw=true)  
*Below: HTTP error log.*


## 📖 Usage

### 🚀 Step 1: Logging Your API Calls

There are **two ways** to ensure your API calls are captured by the floating logger. Choose the one that best fits your project:

#### Option A: Use `FloatingLoggerInterceptor` (For existing custom Dio)
If you already have your own `Dio` instance and don't want to change it, simply add the interceptor:

```dart
final dio = Dio();
dio.interceptors.add(FloatingLoggerInterceptor());
```

#### Option B: Use `DioLogger` (Easiest / No-config)
If you don't want the hassle of configuring a custom Dio instance, use the built-in `DioLogger` directly:

```dart
Future<void> fetchData() async {
  try {
    final response = await DioLogger.instance.get(
      'https://api.genderize.io',
      queryParameters: { "name": "james" },
    );
    // ... handle response
  } catch (e) {
    // ... handle error
  }
}
```

---

### 🏗 Step 2: Displaying the Logger with `FloatingLoggerControl`

Once you've set up the logging (Step 1), you need to wrap your app (or a specific page) with `FloatingLoggerControl` to show the floating debug button.

```dart
return FloatingLoggerControl(
  child: Scaffold(
    appBar: AppBar(
      title: const Text("Floating Logger Test"),
    ),
    body: Center(child: Text("Logger is active!")),
  ),
);
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

## 🎨 Add Style to Floating Widget

You can easily customize the appearance of your floating logger widget by using the `style` property. This allows you to adjust the background color, tooltip, icon, and even the size of the floating widget to match your app’s theme. 🎨✨

```dart
FloatingLoggerControl(
      style: FloatingLoggerStyle(
        backgroundColor: Colors.green,
        tooltip: "Testing",
        icon: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.offline_bolt,
              color: Colors.white,
              size: 20,
            ),
            Text(
              "Test",
              style: TextStyle(
                fontSize: 8.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      child : child,
),
```
🖌️ What You Can Customize:
- `backgroundColor`: Set a vibrant color to make your floating widget stand out.
- `tooltip`: Add a custom tooltip text to provide helpful hints when hovering over the widget.
- `icon`: Choose an icon (like offline_bolt, info, etc.) and customize its size, color, and appearance.
- `size`: Adjust the size using `Size` class to adjust floating widget size.

## 🛠️ Adding a Single Custom Interceptor

To add a single custom interceptor to `DioLogger`, you can use the `addInterceptor` method. Here’s an example of adding a custom `InterceptorsWrapper` that handles the `onResponse` and `onError` events.

```dart
/// Example to add a custom single interceptor
DioLogger.instance.addInterceptor(
  InterceptorsWrapper(
    onResponse: (response, handler) {
      // Add custom logic for onResponse
      print('Custom onResponse interceptor');
      handler.next(response);
    },
    onError: (error, handler) {
      // Add custom logic for onError
      print('Custom onError interceptor');
      handler.next(error);
    },
  ),
);
```
Explanation:
- `onResponse` : This is triggered when a successful response is received. You can add custom logic here, such as logging or modifying the response.
- `onError` : This is triggered when an error occurs. You can handle errors, log them, or perform recovery actions.
- `handler.next()` : This ensures the interceptor chain continues to the next interceptor or the final handler.

## 🛠️ Add List Custom Interceptor

If you want to add multiple interceptors at once, you can use the `addListInterceptor` method. This is useful when you have several interceptors that need to be applied together.

Here’s an example:

```dart
DioLogger.instance.addListInterceptor(
  [
    InterceptorsWrapper(
      onResponse: (response, handler) {
        // Add custom logic for onResponse
        print('Custom onResponse interceptor');
        handler.next(response);
      },
      onError: (error, handler) {
        // Add custom logic for onError
        print('Custom onError interceptor');
        handler.next(error);
      },
    ),
    // You can add more interceptors in the list
  ],
);
```
Explanation:
- List of Interceptors: You can define multiple InterceptorsWrapper objects in a list. Each interceptor will be executed in the order they are added.
- Order Matters: The first interceptor in the list will be executed first, followed by the next, and so on.

---



## ⚡ Network Simulator (Built-in)

`floating_logger` comes with a powerful **Network Simulator** built right in! No extra packages needed. You can easily simulate different network conditions to test how your app handles:

- **Normal**: Standard network behavior.
- **Slow**: Simulates a 3-second delay (configurable).
- **Offline**: Simulates no internet connection (throws error).

### Usage

```dart
// Enable logs (default)
NetworkSimulator.instance.setSimulation(NetworkSimulation.normal);

// Simulate slow network (3s delay)
NetworkSimulator.instance.setSimulation(NetworkSimulation.slow);

// Simulate offline mode (throws error)
NetworkSimulator.instance.setSimulation(NetworkSimulation.offline);
```


---

## 🎯 Conclusion
`floating_logger` is a powerful tool that simplifies debugging API calls in Flutter applications. Whether you need to inspect responses, copy cURL commands, or customize the UI, this package provides a seamless experience for developers. Integrate it today and streamline your debugging process! 🚀

📌 **For more details, visit the [GitHub Repository](https://github.com/dzikrul1616/flutter_floating_logger).**
📌 **For floating logger boilerplate, visit the [Boilerplate Repository](https://github.com/dzikrul1616/floating_logger_boilerplate).**