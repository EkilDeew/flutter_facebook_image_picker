import 'package:flutter_facebook_image_picker/model/pagination.dart';
import 'package:flutter_facebook_image_picker/model/album.dart';

class AlbumPaging {
  List<Album> data;
  Pagination pagination;

  AlbumPaging.fromJson(Map json)
      : data = (json['data'] as List)
            .map((album) => Album.fromJson(album))
            .toList(),
        pagination = Pagination.fromJson(json['paging']);
}
