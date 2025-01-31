// ignore_for_file: use_build_context_synchronously
import 'package:floating_logger/floating_logger.dart';

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
  List<ListData>? data;
  List<ListData>? filteredData;
  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  @override
  void initState() {
    fetchSuccess();
    super.initState();
  }

  void filterSearch(String query) {
    if (query.isEmpty) {
      setState(() => filteredData = data);
      return;
    }
    setState(() {
      filteredData = data!
          .where(
              (item) => item.title!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF0F0F0),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ValueListenableBuilder(
            valueListenable: isLoading,
            builder: (context, loading, child) {
              return loading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomRefresh(
                      onRefresh: () async => fetchSuccess(),
                      child: ListView(
                        children: [
                          _headerWidget(),
                          filteredData!.isEmpty
                              ? SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.shopify,
                                        size: 50,
                                      ),
                                      Text(
                                        'Not found item!',
                                        style: GoogleFonts.oswald(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'There is no item available for now!',
                                        style: GoogleFonts.oswald(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : _bodyWidget(),
                        ],
                      ),
                    );
            }),
      ),
    );
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
        itemCount: filteredData?.length,
        shrinkWrap: true,
        physics: const ScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final item = filteredData![index];
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
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              Text(
                                item.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.normal,
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
                                    style: GoogleFonts.montserrat(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        item.rating!.rate.toString(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
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

  Padding _headerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                          onChanged: filterSearch,
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
            style: GoogleFonts.oswald(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Get More 20% discount for new user',
            style: GoogleFonts.oswald(
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      ),
    );
  }

  Future<void> fetchSuccess() async {
    try {
      final response = await DioLogger.instance.get(
        'https://fakestoreapi.com/products',
        options: Options(headers: {
          "content-type": "application/json",
        }),
      );

      if (response.statusCode == 200) {
        isLoading.value = false;
        final List<dynamic> jsonData = response.data;
        data = jsonData.map((item) => ListData.fromJson(item)).toList();
        filteredData = List.from(data!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              'Success Fectch',
            ),
          ),
        );
      } else if (response.statusCode! > 300) {
        isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Failed fetch',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch facts')),
      );
    }
  }
}
