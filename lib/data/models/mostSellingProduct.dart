class MostSellingProduct {
  int? id;
  String? productName;
  String? shortDescription;
  String? image;
  String? rating;
  int? noOfRatings;
  int? specialPrice;
  int? price;
  String? totalQuantitySold;
  int? totalSales;
  String? type;
  String? isFavorite;

  MostSellingProduct(
      {this.id,
      this.productName,
      this.shortDescription,
      this.image,
      this.rating,
      this.noOfRatings,
      this.specialPrice,
      this.price,
      this.totalQuantitySold,
      this.type,
      this.totalSales,
      this.isFavorite});

  MostSellingProduct.fromJson(Map<String, dynamic> json) {
    id = json['product_id'];
    productName = json['product_name'];
    shortDescription = json['short_description'];
    image = json['image'];
    rating = json['rating'] != null ? json['rating'].toString() : "";
    noOfRatings = json['no_of_ratings'];
    specialPrice = json['special_price'];
    price = json['price'];
    type = json['type'];
    totalQuantitySold = json['total_quantity_sold'];
    totalSales = json['total_sales'];
    isFavorite = json['is_favorite'].toString();
  }
  bool isFavoriteProduct() {
    return isFavorite == "1";
  }

  setFavoriteProduct(bool value) {
    isFavorite = value ? "1" : "0";
  }

  bool hasAnyRating() {
    return (rating ?? "").toString().isNotEmpty &&
        (double.tryParse(rating!.toString())) != 0;
  }

  double getDiscoutPercentage() {
    if (specialPrice != null) {
      return ((price!.toDouble() - specialPrice!.toDouble()) * 100) /
          price!.toDouble();
    }
    return 0.0;
  }
}
