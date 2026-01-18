import 'package:floating_logger/floating_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/error.dart';
import '../utils/models.dart';
import 'list_event.dart';
import 'list_state.dart';

class ListBloc extends Bloc<ListEvent, ListState> {
  ListBloc() : super(ListInitial()) {
    on<FetchList>(_onFetchList);
  }

  Future<void> _onFetchList(FetchList event, Emitter<ListState> emit) async {
    emit(ListLoading());
    try {
      final response = await DioLogger.instance.get(
        'https://fakestoreapi.com/products',
        options: Options(headers: {
          "content-type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;
        final data = jsonData.map((item) => ListData.fromJson(item)).toList();
        emit(ListSuccess(data));
      } else {
        emit(const ListFailure(
          title: 'Fetch Error',
          message: 'Failed to fetch data from server',
        ));
      }
    } on DioException catch (e) {
      final message = CustomError.mapDioErrorToMessage(e);
      emit(ListFailure(
        title: 'Connection Error',
        message: message,
      ));
    } catch (e) {
      emit(ListFailure(
        title: 'Unexpected Error',
        message: e.toString(),
      ));
    }
  }
}
