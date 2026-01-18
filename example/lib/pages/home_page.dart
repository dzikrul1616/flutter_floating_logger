import 'dart:typed_data';
import 'package:example/utils/error.dart';

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
        message: 'Test Fetch Success GraphQL',
        buttonText: 'Succeess',
        onPressed: () => fetchSuccess(),
      ),
      ListDataModel(
        message: 'Test Fetch Failure',
        buttonText: 'Failure',
        onPressed: () => fetchFailure(),
      ),
      ListDataModel(
        message: 'Test Fetch Success GraphQL (Interceptor)',
        buttonText: 'Succeess (Int)',
        onPressed: () => fetchSuccessInterceptor(),
      ),
      ListDataModel(
        message: 'Test Fetch Failure (Interceptor)',
        buttonText: 'Failure (Int)',
        onPressed: () => fetchFailureInterceptor(),
      ),
      ListDataModel(
        message: 'Test Fetch PDF (Binary Response)',
        buttonText: 'Get PDF',
        onPressed: () => getPdf(),
      ),
      ListDataModel(
        message: 'Test Fetch Image (Binary Response)',
        buttonText: 'Get Image',
        onPressed: () => getImage(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Floating Logger Package Test"),
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
      final response = await DioLogger.instance.post(
        'https://countries.trevorblades.com/',
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
        data: {
          "query": """
          query GetCountry(\$code: ID!) {
            country(code: \$code) {
              name
              capital
              currency
            }
          }
        """,
          "variables": {"code": "ID"}
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Success Fetch Country Data'),
          ),
        );
      }
    } on DioException catch (e) {
      if (!context.mounted) return;

      final message = CustomError.mapDioErrorToMessage(e);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unexpected error occurred'),
        ),
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
    } on DioException catch (e) {
      if (!context.mounted) return;

      final message = CustomError.mapDioErrorToMessage(e);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }

  Future<void> fetchSuccessInterceptor() async {
    try {
      final dio = Dio();
      dio.interceptors.add(FloatingLoggerInterceptor());
      final response = await dio.post(
        'https://countries.trevorblades.com/',
        options: Options(headers: {
          "Content-Type": "application/json",
        }),
        data: {
          "query": """
          query GetCountry(\$code: ID!) {
            country(code: \$code) {
              name
              capital
              currency
            }
          }
        """,
          "variables": {"code": "ID"}
        },
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Success Fetch Country Data (Interceptor)'),
          ),
        );
      }
    } on DioException catch (e) {
      if (!context.mounted) return;

      final message = CustomError.mapDioErrorToMessage(e);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Unexpected error occurred'),
        ),
      );
    }
  }

  Future<void> fetchFailureInterceptor() async {
    try {
      final dio = Dio();
      dio.interceptors.add(FloatingLoggerInterceptor());

      final response = await dio.post(
        'https://api.genderize.io',
        data: FormData.fromMap({"name": "test form Data", "age": "25"}),
        options: Options(headers: {
          //"content-type": "multipart/form-data", // Dio sets this automatically for FormData
        }),
      );

      if (response.statusCode == 200) {
        // your's management data
      }
    } on DioException catch (e) {
      if (!context.mounted) return;

      final message = CustomError.mapDioErrorToMessage(e);

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }

  /// Example: Fetch PDF binary response
  Future<Uint8List?> getPdf() async {
    try {
      final response = await DioLogger.instance.get(
        'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf',
        options: Options(
          responseType: ResponseType.bytes, // IMPORTANT for binary data!
        ),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content:
                Text('PDF fetched successfully! Check logger for preview.'),
          ),
        );
        return Uint8List.fromList(response.data as List<int>);
      }
    } on DioException catch (e) {
      if (!context.mounted) return null;
      final message = CustomError.mapDioErrorToMessage(e);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!context.mounted) return null;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Error: $e'),
        ),
      );
    }
    return null;
  }

  /// Example: Fetch Image binary response
  Future<Uint8List?> getImage() async {
    try {
      final response = await DioLogger.instance.get(
        'https://picsum.photos/id/237/300/200',
        options: Options(
          responseType: ResponseType.bytes,  
        ),
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content:
                Text('Image fetched successfully! Check logger for preview.'),
          ),
        );
        return Uint8List.fromList(response.data as List<int>);
      }
    } on DioException catch (e) {
      if (!context.mounted) return null;
      final message = CustomError.mapDioErrorToMessage(e);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
    } catch (e) {
      if (!context.mounted) return null;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Error: $e'),
        ),
      );
    }
    return null;
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
