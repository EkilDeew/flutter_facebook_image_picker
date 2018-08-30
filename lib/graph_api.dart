import 'dart:async';
import 'dart:convert';

import 'package:flutter_facebook_image_picker/model/album.dart';
import 'package:flutter_facebook_image_picker/graph_api_exception.dart';
import 'package:flutter_facebook_image_picker/model/album_paging.dart';
import 'package:flutter_facebook_image_picker/model/photo_paging.dart';
import 'package:http/http.dart' as http;

class GraphApi {
  static const String _graphApiEndpoint = 'https://graph.facebook.com/v3.1';

  final String _accessToken;

  GraphApi(this._accessToken);

  Future<AlbumPaging> fetchAlbums([String nextUrl]) async {
    String url = nextUrl ??
        '$_graphApiEndpoint/me/albums?access_token=$_accessToken&fields=cover_photo{source},id,name,count&format=json';
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw GraphApiException(body['error']['message'].toString());
    }

    return AlbumPaging.fromJson(body);
  }

  Future<PhotoPaging> fetchPhotos(Album album, [String nextUrl]) async {
    String url = nextUrl ??
        '$_graphApiEndpoint/${album.id}/photos?access_token=$_accessToken&fields=id,name,width,height,photo,source&format=json';
    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> body = json.decode(response.body);

    if (response.statusCode != 200) {
      throw GraphApiException(body['error']['message'].toString());
    }

    return PhotoPaging.fromJson(body);
  }
}
