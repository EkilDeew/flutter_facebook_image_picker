class Album {
  final String id;
  final int count;
  final String name;
  final String coverPhoto;

  Album(
    this.id,
    this.count,
    this.name,
    this.coverPhoto,
  );

  Album.fromJson(Map json)
      : id = json['id'],
        count = json['count'],
        name = json['name'],
        coverPhoto = json['cover_photo']['source'];
}
