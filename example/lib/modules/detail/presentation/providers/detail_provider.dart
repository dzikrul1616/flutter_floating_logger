import 'package:example/core/packages/packages.dart';

class DetailProvider extends ChangeNotifier {
  ListData? _item;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isFavorite = false;
  int _quantity = 1;

  ListData? get item => _item;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFavorite => _isFavorite;
  int get quantity => _quantity;

  void init(int id, [ListData? initial]) {
    if (initial != null) {
      _item = initial;
      notifyListeners();
    } else {
      fetchDetail(id);
    }
  }

  void toggleFavorite() {
    _isFavorite = !_isFavorite;
    notifyListeners();
  }

  void incrementQuantity() {
    _quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  Future<void> fetchDetail(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await DioLogger.instance.get(
        'https://fakestoreapi.com/products/$id',
        options: Options(headers: {
          "Accept": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        _item = ListData.fromJson(response.data as Map<String, dynamic>);
      } else {
        _errorMessage = 'Failed to load product details (${response.statusCode})';
      }
    } on DioException catch (e) {
      _errorMessage = CustomError.mapDioErrorToMessage(e);
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
