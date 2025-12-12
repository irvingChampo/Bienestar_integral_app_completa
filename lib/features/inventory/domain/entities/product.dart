class Product {
  final int id;
  final String name;
  final String description;
  final int categoryId;
  final String unit;
  final bool perishable;
  final int? shelfLifeDays;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.unit,
    required this.perishable,
    this.shelfLifeDays,
  });
}