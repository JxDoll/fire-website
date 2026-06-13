class FireExtinguisher {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String capacity;
  final double rating;
  final int reviewsCount;
  final String fireClass;
  final String dischargeTime;
  final String range;
  final String pressure;
  int stock;

  FireExtinguisher({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.capacity,
    required this.rating,
    required this.reviewsCount,
    required this.fireClass,
    required this.dischargeTime,
    required this.range,
    required this.pressure,
    required this.stock,
  });

  FireExtinguisher copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? capacity,
    double? rating,
    int? reviewsCount,
    String? fireClass,
    String? dischargeTime,
    String? range,
    String? pressure,
    int? stock,
  }) {
    return FireExtinguisher(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      capacity: capacity ?? this.capacity,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      fireClass: fireClass ?? this.fireClass,
      dischargeTime: dischargeTime ?? this.dischargeTime,
      range: range ?? this.range,
      pressure: pressure ?? this.pressure,
      stock: stock ?? this.stock,
    );
  }
}
