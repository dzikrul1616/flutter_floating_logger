import 'package:floating_logger/floating_logger.dart';

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ListDataModel> listData = [];
  @override
  void initState() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingLoggerControl(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: listData.map((data) {
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
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> fetchSuccess() async {
    try {
      final response = await DioLogger.instance.get(
        'https://api.genderize.io',
        queryParameters: {"name": "james"},
      );

      if (response.statusCode == 200) {
        // your's management data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }

  Future<void> fetchFailure() async {
    try {
      final response = await DioLogger.instance.get('https://api.genderize.io');

      if (response.statusCode == 200) {
        // your's management data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch facts')),
      );
    }
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
