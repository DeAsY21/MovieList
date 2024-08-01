class MovieInfo {
  final String name;
  final int id;
  MovieInfo({required this.name, required this.id});
  factory MovieInfo.fromJson(Map<String, dynamic> json) {
    return MovieInfo(
      name: json['title'] ?? 'Без назви',
      id: json['id'] ?? 0,
    );
  }
}