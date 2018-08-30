import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_image_picker/model/album.dart';
import 'package:flutter_facebook_image_picker/graph_api.dart';
import 'package:flutter_facebook_image_picker/model/album_paging.dart';
import 'package:flutter_facebook_image_picker/model/photo.dart';
import 'package:flutter_facebook_image_picker/model/photo_paging.dart';
import 'package:flutter_facebook_image_picker/ui/album_grid.dart';
import 'package:flutter_facebook_image_picker/ui/photo_grid.dart';

class FacebookImagePicker extends StatefulWidget {
  final String _accessToken;

  /// AppBar config
  final String appBarTitle;
  final TextStyle appBarTextStyle;
  final Color appBarColor;

  // AppBar actions
  final String doneBtnText;
  final TextStyle doneBtnTextStyle;
  final Function(List<Photo>) onDone;
  final String cancelBtnText;
  final TextStyle cancelBtnTextStyle;
  final Function onCancel;

  FacebookImagePicker(
    this._accessToken, {
    this.appBarTitle = 'Facebook Image Picker',
    this.appBarTextStyle,
    this.appBarColor,
    this.doneBtnText = 'Done',
    this.doneBtnTextStyle,
    @required this.onDone,
    this.cancelBtnText = 'Cancel',
    this.cancelBtnTextStyle,
    @required this.onCancel,
  }) : assert(_accessToken != null);

  @override
  _FacebookImagePickerState createState() => _FacebookImagePickerState();
}

class _FacebookImagePickerState extends State<FacebookImagePicker>
    with TickerProviderStateMixin {
  GraphApi _client;
  Album _selectedAlbum;
  List<Album> _albums = [];
  String _albumsNextLink;
  List<Photo> _photos = [];
  String _photosNextLink;
  List<Photo> _selectedPhotos;

  AnimationController _controller;
  Animation<Offset> _imageListPosition;

  @override
  void initState() {
    super.initState();
    _selectedPhotos = List<Photo>();
    _client = GraphApi(widget._accessToken);
    _fetchAlbums();

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _imageListPosition = new Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(new CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get title {
    return _selectedAlbum == null ? widget.appBarTitle : _selectedAlbum.name;
  }

  Future<void> _fetchAlbums() async {
    AlbumPaging albums = await _client.fetchAlbums();
    setState(() {
      _albums.addAll(albums.data);
      _albumsNextLink = albums.pagination.next;
    });
  }

  Future<void> _paginateAlbums() async {
    if (_albumsNextLink == null) {
      return;
    }
    AlbumPaging albums = await _client.fetchAlbums(_albumsNextLink);
    setState(() {
      _albums.addAll(albums.data);
      _albumsNextLink = albums.pagination.next;
    });
  }

  Future<void> _paginatePhotos() async {
    if (_photosNextLink == null) {
      return;
    }
    PhotoPaging photos =
        await _client.fetchPhotos(_selectedAlbum, _photosNextLink);
    setState(() {
      _photos.addAll(photos.data);
      _photosNextLink = photos.pagination.next;
    });
  }

  void _onAlbumSelected(Album album) async {
    PhotoPaging photos = await _client.fetchPhotos(album);
    setState(() {
      _selectedAlbum = album;
      _photos.addAll(photos.data);
      _photosNextLink = photos.pagination.next;
    });
    _controller.forward();
  }

  void _reset() {
    setState(() {
      _selectedAlbum = null;
      _selectedPhotos = [];
      _albumsNextLink = null;
      _photosNextLink = null;
    });
  }

  void _onDone() {
    widget.onDone(_selectedPhotos);
    _reset();
  }

  Widget _buildDoneButton() {
    return GestureDetector(
      onTap: _onDone,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(right: 5.00),
          child: Text(
            '${widget.doneBtnText}(${_selectedPhotos.length})',
            textScaleFactor: 1.3,
            style: widget.doneBtnTextStyle ??
                TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }

  void _onCancel() {
    _reset();
    widget.onCancel();
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: _onCancel,
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 5.00),
          child: Text(
            '${widget.cancelBtnText}',
            textScaleFactor: 1.3,
            style: widget.cancelBtnTextStyle ??
                TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }

  void _onPhotoTap(Photo photo) {
    int itemIndex = _selectedPhotos.indexOf(photo);

    if (itemIndex == -1) {
      return setState(() {
        _selectedPhotos.add(photo);
      });
    }

    setState(() {
      _selectedPhotos.removeAt(itemIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: widget.appBarColor,
        title: Text(
          title,
          style: widget.appBarTextStyle,
        ),
        leading: _selectedAlbum == null
            ? _buildCancelButton()
            : IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  _controller.reverse();
                  setState(() {
                    _selectedAlbum = null;
                    _photos = [];
                    _photosNextLink = null;
                  });
                },
              ),
        actions: <Widget>[
          _buildDoneButton(),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: PhotoGrid(
                _photos,
                _selectedPhotos,
                onPhotoTap: _onPhotoTap,
                onLoadMore: _paginatePhotos,
              ),
            ),
            SlideTransition(
              position: _imageListPosition,
              child: Container(
                color: Colors.white,
                child: AlbumGrid(
                  _albums,
                  onAlbumSelected: _onAlbumSelected,
                  onLoadMore: _paginateAlbums,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
