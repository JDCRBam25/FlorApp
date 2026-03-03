class Product {
  final String? id; // haz id nullable
  final String productName;
  final String productImage;
  final double originalPrice;
  final double discountedPrice;
  final String description;

  Product({
    this.id,
    required this.productName,
    required this.productImage,
    required this.originalPrice,
    required this.discountedPrice,
    required this.description,
  });

  Product copyWith({
    String? id,
    String? productName,
    String? productImage,
    double? originalPrice,
    double? discountedPrice,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is Product &&
            productName == other.productName &&
            productImage == other.productImage);
  }

  @override
  int get hashCode => productName.hashCode ^ productImage.hashCode;
}
