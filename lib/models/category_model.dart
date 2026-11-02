class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final int count;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  /// Clean English Display Name for categories
  String get displayName {
    final upper = name.trim().toUpperCase();
    switch (upper) {
      case 'NEWS':
        return 'News';
      case 'POLITICS':
        return 'Politics';
      case 'SPORTS':
        return 'Sports';
      case 'EDUCATION':
        return 'Education';
      case 'RELIGIOUS':
        return 'Religious';
      case 'FEATURE STORIES':
        return 'Features';
      case 'LITERATURE':
        return 'Literature';
      case 'EDITORIAL':
        return 'Editorial';
      case 'JOBS':
        return 'Jobs';
      case 'DEATH':
        return 'Obituary';
      default:
        // Capitalize first letter
        if (name.isEmpty) return 'General';
        return name[0].toUpperCase() + name.substring(1).toLowerCase();
    }
  }

  // Keep for backwards compatibility
  String get malayalamName => displayName;
}
