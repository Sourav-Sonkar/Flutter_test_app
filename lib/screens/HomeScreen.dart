import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

import 'package:test_app/widgets/app_drawer.dart';

class AppScreen extends StatefulWidget {
  AppScreen({Key key}) : super(key: key);

  @override
  _AppScreenState createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  var _testConnection = true;
  var _isloading = true;

  var imageList;
  Future<void> _checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _testConnection = false;
      });
    }
    print(_testConnection);
  }

  void _fetchData() async {
    setState(() {
      _isloading = true;
    });
    final response = await http.get(
        "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&per_page=20&page=1&api_key=6f102c62f41998d151e5a1b48713cf13&format=json&nojsoncallback=1&extras=url_s");
    if (response.statusCode == 200) {
      imageList = json.decode(response.body);
      print(imageList['photos']['perpage']);
      setState(() {
        _isloading = false;
      });
    } else {
      throw Exception('Failed to load photos');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkConnectivity().then((_) {
      if (_testConnection) {
        _fetchData();
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
                    return Image.network(
                        imageList['photos']['photo'][index]['url_s']);
                  },
                  padding: const EdgeInsets.all(10.0),
                  itemCount: imageList['photos']['perpage'],
                )
          : Text("No Internet"),
    );
  }
}
