import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:test_app/widgets/app_drawer.dart';
import 'package:test_app/models/Images.dart';
import 'package:test_app/utils/database_helper.dart';

class AppScreen extends StatefulWidget {
  AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  var _testConnection = true;
  var _isloading = true;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Images> _offlineimgList;
  int _count = 0;

  var imageList;
  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _testConnection = false;
      });
    }
  }

  void _fetchData() async {
    setState(() {
      _isloading = true;
    });
    final response = await http.get(
        "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=20&page=1&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s");
    if (response.statusCode == 200) {
      imageList = json.decode(response.body);
      setState(() {
        _isloading = false;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  void _updateImageView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Images>> imgListFuture = databaseHelper.getImagesList();
      imgListFuture.then((imgList) {
        setState(() {
          this._offlineimgList = imgList;
          this._count = imgList.length;
        });
      });
    });
  }

  void _delete() async {
    int result = await databaseHelper.deleteImg();
  }

  void _save(_singleImage) async {
    int result = await databaseHelper.insertImg(_singleImage);
  }

  @override
  void initState() {
    // TODO: implement initState
    if (_offlineimgList == null) {
      _offlineimgList = List<Images>();
      _updateImageView();
    }
    _checkConnectivity().then((_) {
      if (_testConnection) {
        _fetchData();
        _delete();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ATG Flutter'),
      ),
      drawer: AppDrawer(),
      body: _testConnection
          ? _isloading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    var _singleImage =new Images.withoutId(imageList['photos']['photo'][index]['url_s']);
                    _save(_singleImage);
                    return CachedNetworkImage(
                      imageUrl: imageList['photos']['photo'][index]['url_s'],
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    );
                  },
                  padding: const EdgeInsets.all(10.0),
                  itemCount: imageList['photos']['perpage'],
                )
          : _count > 0
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: _offlineimgList[index].imglink,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    );
                  },
                  padding: const EdgeInsets.all(10.0),
                  itemCount: _count,
                )
              : Center(
                  child: Text("No images Stored"),
                ),
    );
  }
}
