// ignore: depend_on_referenced_packages
import 'package:equatable/equatable.dart';

class ListData extends Equatable {
  const ListData({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  final int? id;
  final String? title;
  final num? price;
  final String? description;
  final String? category;
  final String? image;
  final Rating? rating;

  factory ListData.fromJson(Map<String, dynamic> json) {
    return ListData(
      id: json["id"],
      title: json["title"],
      price: json["price"],
      description: json["description"],
      category: json["category"],
      image: json["image"],
      rating: json["rating"] == null ? null : Rating.fromJson(json["rating"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "price": price,
        "description": description,
        "category": category,
        "image": image,
        "rating": rating?.toJson(),
      };

  @override
  String toString() {
    return "$id, $title, $price, $description, $category, $image, $rating, ";
  }

  @override
  List<Object?> get props => [
        id,
        title,
        price,
        description,
        category,
        image,
        rating,
      ];
}

class Rating extends Equatable {
  const Rating({
    required this.rate,
    required this.count,
  });

  final num? rate;
  final num? count;

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rate: json["rate"],
      count: json["count"],
    );
  }

  Map<String, dynamic> toJson() => {
        "rate": rate,
        "count": count,
      };

  @override
  String toString() {
    return "$rate, $count, ";
  }

  @override
  List<Object?> get props => [
        rate,
        count,
      ];
}
