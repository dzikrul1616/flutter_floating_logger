import 'package:floating_logger/floating_logger.dart';

import 'developper_page.dart';
import 'list_page.dart';

class MyHomePage extends StatefulWidget {
  static const routeName = '/myPage';
  const MyHomePage({super.key});

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
        message: 'Test Fetch Failure 2',
        buttonText: 'Failure',
        onPressed: () => fetchFailure(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Floating Testing"),
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
              child: const Text(
                "Settings Page",
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, ListPage.routeName),
              child: const Text(
                "Example UI",
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchSuccess() async {
    try {
      final response = await DioLogger.instance.get(
        'https://api.genderize.io',
        options: Options(headers: {
          "content-type": "application/json",
        }),
        queryParameters: {
          "name": "james",
        },
      );

      if (response.statusCode == 200) {
        // your's management data
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Success Fectch',
            ),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }

  Future<void> fetchFailure() async {
    try {
      /// Use DIO LOGGER to Request Rest api
      final response = await DioLogger.instance.get(
        'https://api.genderize.io',
        options: Options(headers: {
          "content-type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        // your's management data
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch facts')),
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
