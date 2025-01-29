import 'package:floating_logger/floating_logger.dart';
import 'advance_example/advance_example.dart';
import 'utils/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      /// This package recomendation using route name for efficiency code
      initialRoute: MyHomePage.routeName,

      /// using [RouteGenerator] for apply testing widget
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  static const routeName = '/myPage';
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ListDataModel> listData = [];

  @override
  void initState() {
    super.initState();
    listData = [
      ListDataModel(
        message: 'Test Fetch Success 1',
        buttonText: 'Fetch Facts',
        onPressed: () => fetchSuccess(),
      ),
      ListDataModel(
        message: 'Test Fetch Success 2',
        buttonText: 'Failure',
        onPressed: () => fetchFailure(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    /// Only using this widget you display log request with DioLogger.instance
    return FloatingLoggerControl(
      /// This builder for custom list item from bottom bar Widget
      // widgetItemBuilder: (index, data) {
      //   /// Example widget
      //   return Padding(
      //     padding: const EdgeInsets.only(bottom: 10),
      //     child: Card(
      //       child: Padding(
      //         padding: const EdgeInsets.all(15),
      //         child: Row(
      //           children: [
      //             Text(
      //               "Data :",
      //               style: TextStyle(
      //                 fontSize: 14.0,
      //               ),
      //             ),
      //             const SizedBox(
      //               width: 10.0,
      //             ),
      //             Text(
      //               "${data[index].data}",
      //               style: TextStyle(
      //                 fontSize: 14.0,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   );
      // },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text("Floating Testing"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...listData.map((data) {
                return Column(
                  children: [
                    Text(data.message),
                    ElevatedButton(
                      onPressed: data.onPressed,
                      child: Text(
                        data.buttonText,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                );
              }),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, DevelopperMode.routeName),
                child: Text(
                  "Developper mode",
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchSuccess() async {
    try {
      final response = await DioLogger.instance.get(
        'https://api.genderize.io',
        queryParameters: {
          "name": "james",
        },
      );

      if (response.statusCode == 200) {
        // your's management data
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }

  Future<void> fetchFailure() async {
    try {
      /// Use DIO LOGGER to Request Rest api
      final response = await DioLogger.instance.get('https://api.genderize.io');

      if (response.statusCode == 200) {
        // your's management data
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }
}

class RouteGenerator {
  /// Apply condition using FloatingLogger package
  static MaterialPageRoute<dynamic> pageRoute(
    Widget page, {
    bool isWithoutTest = false,
  }) =>
      MaterialPageRoute(
        builder: (_) => isWithoutTest
            ? page
            : FloatingLoggerControl(
                /// get preference is Future bool type, u can using shared preferences
                /// for save floating keep active, or u can remove if u don't need to use
                /// preferences
                getPreference: () async =>
                    await CustomSharedPreferences.getDebugger(),
                child: page,
              ),
      );

  /// General page route
  static Route<dynamic> generateRoute(
    RouteSettings settings,
  ) {
    switch (settings.name) {
      case MyHomePage.routeName:
        return pageRoute(
          const MyHomePage(),

          /// Remove isWithoutTest and FloatingLoggerControl in MyHomePage if you
          /// want to activate testing
          isWithoutTest: true,
        );
      case DevelopperMode.routeName:
        return pageRoute(
          const DevelopperMode(),

          /// set true if your page doesn't need test widget
          isWithoutTest: true,
        );

      default:
        return MaterialPageRoute(builder: (context) {
          return MyHomePage();
        });
    }
  }
}
