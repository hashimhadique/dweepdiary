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

  // Helpful display name in Malayalam if needed
  String get displayNameMalayalam {
    switch (slug.toLowerCase()) {
      case 'news':
        return 'വാർത്തകൾ';
      case 'politics':
        return 'രാഷ്ട്രീയം';
      case 'feature-stories':
        return 'ഫീച്ചർ സ്റ്റോറികൾ';
      case 'education':
        return 'വിദ്യാഭ്യാസം';
      case 'religious':
        return 'മതപരം';
      case 'sports':
        return 'കായികം';
      case 'literature':
        return 'സാഹിത്യം';
      case 'editorial':
        return 'എഡിറ്റോറിയൽ';
      case 'jobs':
        return 'തൊഴിൽ';
      case 'death':
        return 'ചരമം';
      default:
        return name;
    }
  }
}
