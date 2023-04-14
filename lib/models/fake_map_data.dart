class FakeMapData {
  String? tripId;
  List<Location>? location;

  FakeMapData({this.tripId, this.location});

  FakeMapData.fromJson(Map<String, dynamic> json) {
    tripId = json['trip_id'];
    if (json['location'] != null) {
      location = <Location>[];
      json['location'].forEach((v) {
        location!.add(Location.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trip_id'] = tripId;
    if (location != null) {
      data['location'] = location!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Location {
  String? latitude;
  String? longitude;
  String? name;
  String? type;
  String? position;

  Location(
      {this.latitude, this.longitude, this.name, this.type, this.position});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    name = json['name'];
    type = json['type'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['name'] = name;
    data['type'] = type;
    data['position'] = position;
    return data;
  }
}
