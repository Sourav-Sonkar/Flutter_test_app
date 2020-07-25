class Images {
  int _id;
  String _imglink;

  Images(this._id, this._imglink);
  Images.withoutId(this._imglink);

  int get id => _id;
  String get imglink => _imglink;
  set imglink(String value) => _imglink = value;

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    if (_id != null) {
      map['imgId'] = _id;
    }
    map['imglink'] = _imglink;

    return map;
  }

  Images.fromMapObject(Map<String, dynamic> map) {
    this._id = map['imgId'];
    this._imglink = map['imglink'];
  }
}
