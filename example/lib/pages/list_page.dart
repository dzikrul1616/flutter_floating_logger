import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:floating_logger/floating_logger.dart';
import '../bloc/list_bloc.dart';
import '../bloc/list_event.dart';
import '../bloc/list_state.dart';
import '../widget/error_widget.dart';
import '../utils/models.dart';
import '../widget/refresh.dart';
import 'detail_item.dart';

class ListPage extends StatefulWidget {
  static const routeName = "/listPage";
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<ListData>? _filteredData;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListBloc()..add(FetchList()),
      child: Scaffold(
        backgroundColor: const Color(0xffF0F0F0),
        body: BlocBuilder<ListBloc, ListState>(
          builder: (context, state) {
            final data = state is ListSuccess ? state.data : <ListData>[];

            return Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerWidget(context, data),
                  Expanded(
                    child: _buildContentByState(context, state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContentByState(BuildContext context, ListState state) {
    if (state is ListLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ListFailure) {
      return CustomErrorWidget(
        title: state.title,
        subtitle: state.message,
        onRetry: () => context.read<ListBloc>().add(FetchList()),
      );
    }

    if (state is ListSuccess) {
      return _buildSuccessContent(context, state.data);
    }

    return const SizedBox.shrink();
  }

  Widget _buildSuccessContent(BuildContext context, List<ListData> data) {
    _applyFilter(data);

    return CustomRefresh(
      onRefresh: () async {
        context.read<ListBloc>().add(FetchList());
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (_filteredData!.isEmpty)
            _buildEmptyState(context)
          else
            _bodyWidget(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopify,
            size: 50,
          ),
          Text(
            'Not found item!',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
          const Text(
            'There is no item available for now!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              fontFamily: 'Inter',
              package: 'floating_logger',
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter(List<ListData> data) {
    if (_searchQuery.isEmpty) {
      _filteredData = data;
    } else {
      _filteredData = data
          .where((item) =>
              item.title!.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  Padding _bodyWidget() {
    var crossAxisCount = MediaQuery.of(context).size.width > 900 &&
            MediaQuery.of(context).size.width < 1200
        ? 3
        : MediaQuery.of(context).size.width >= 1200 &&
                MediaQuery.of(context).size.width < 1600
            ? 4
            : 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1.0,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          mainAxisExtent: 230,
        ),
        itemCount: _filteredData?.length,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final item = _filteredData![index];
          final ValueNotifier<bool> off = ValueNotifier(true);
          return GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              DetailItem.routeName,
              arguments: DetailModel(
                id: item.id!,
                off: off,
              ),
            ),
            child: ValueListenableBuilder(
                valueListenable: off,
                builder: (context, value, child) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: 120,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(
                                  10,
                                ),
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                    child: Image.network(
                                      item.image!,
                                    )),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: IconButton(
                                onPressed: () {
                                  off.value = !value;
                                },
                                icon: Icon(
                                  value
                                      ? Icons.favorite_border
                                      : Icons.favorite,
                                  color: value ? Colors.grey[700] : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                  package: 'floating_logger',
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                item.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: 'Inter',
                                  package: 'floating_logger',
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '\$${item.price.toString()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item.rating!.rate.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 15,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          );
        },
      ),
    );
  }

  Padding _headerWidget(BuildContext context, List<ListData> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey[400]!,
                      ),
                    ),
                    child: const Center(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                      ),
                    )),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6.0,
                      horizontal: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: const BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                      border: Border.all(
                        width: 1.0,
                        color: Colors.grey[400]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.search),
                        ),
                        Expanded(
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                                _applyFilter(data);
                              });
                            },
                            initialValue: null,
                            decoration: const InputDecoration.collapsed(
                              filled: true,
                              fillColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              hintText: "Search",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              'Fashion',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Get More 20% discount for new user',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
