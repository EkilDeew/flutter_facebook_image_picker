/// Represent a Facebook Photo Object
class Photo {
  /// The Facebook ID of the photo
  final String id;

  /// The width of the photo in pixels
  final int width;

  // The height of the photo in pixels
  final int height;

  // The name of the photo
  final String name;

  // The source of the photo
  final String source;

  Photo(
    this.id,
    this.width,
    this.height,
    this.name,
    this.source,
  );

  Photo.fromJson(Map json)
      : id = json['id'],
        width = json['width'],
        height = json['height'],
        name = json['name'],
        source = json['source'];
  @override
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Photo && runtimeType == other.runtimeType && id == other.id;
}
