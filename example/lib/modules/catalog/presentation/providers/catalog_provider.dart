import 'package:example/core/packages/packages.dart';

class CatalogProvider extends ChangeNotifier {
  List<ListData> _allProducts = [];
  List<ListData> _filteredProducts = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final Set<int> _favoriteIds = {};

  List<ListData> get products => _filteredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  int get count => _filteredProducts.length;

  final List<String> categories = const [
    'All',
    "men's clothing",
    'jewelery',
    'electronics',
    "women's clothing",
  ];

  void init() {
    fetchProducts();
  }

  bool isFavorite(int? id) => id != null && _favoriteIds.contains(id);

  void toggleFavorite(int? id) {
    if (id == null) return;
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await DioLogger.instance.get(
        'https://fakestoreapi.com/products',
        options: Options(headers: {
          "Accept": "application/json",
        }),
      );

      if (response.statusCode == 200 && response.data is List) {
        _allProducts = (response.data as List)
            .map((item) => ListData.fromJson(item as Map<String, dynamic>))
            .toList();
        _applyFilters();
      } else {
        _errorMessage = 'Failed to load products (${response.statusCode})';
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

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void selectCategory(String cat) {
    _selectedCategory = cat;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _allProducts.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          (item.title?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesCat = _selectedCategory == 'All' ||
          item.category?.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCat;
    }).toList();
  }
}
