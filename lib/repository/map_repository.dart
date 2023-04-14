import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/constants.dart';
import 'package:map_demo/models/fake_map_data.dart';

import '../models/distance_matrix_model.dart';

class MapRepository {
  static final MapRepository _singleton = MapRepository._internal();

  factory MapRepository() {
    return _singleton;
  }

  MapRepository._internal();

  String _generateOriginsForApi(List<LatLng> waypoints) {
    String output = "";
    for (int i = 0; i < waypoints.length - 1; i++) {
      output += "${waypoints[i].latitude},${waypoints[i].longitude}|";
    }
    return output;
  }

  String _generateDestinationsForApi(List<LatLng> waypoints) {
    String output = "";
    for (int i = 1; i < waypoints.length; i++) {
      output += "${waypoints[i].latitude},${waypoints[i].longitude}|";
    }
    return output;
  }

  Future<FakeMapData> getMapData() async {
    await Future.delayed(Duration(milliseconds: 400));
    final json = {
      "trip_id": "4514",
      "location": [
        {
          "latitude": "22.5448",
          "longitude": "88.3426",
          "name": "Victoria Memorial",
          "type": "PICK_UP",
          "position": "0"
        },
        {
          "latitude": "22.5401",
          "longitude": "88.3961",
          "name": "Science City",
          "type": "DROP_OFF",
          "position": "1"
        },
        {
          "latitude": "22.5711",
          "longitude": "88.4206",
          "name": "Nicco Park",
          "type": "DROP_OFF",
          "position": "2"
        },
        {
          "latitude": "22.5786",
          "longitude": "88.4718",
          "name": "Biswa Bangle",
          "type": "COMPLETE",
          "position": "3"
        }
      ]
    };

    final data = FakeMapData.fromJson(json);
    print(data.tripId);
    return data;
  }

  Future<DistanceMatrixModel> getDistance(
    List<LatLng> waypoints,
  ) async {
    Dio dio = Dio();

    //for traversing through A,B,C,D
    //origins will be => [A,B,C]
    //destination will be => [B,C,D]
    //
    //A 2d array will be returned in form of
    // [[A,B,C,D]
    //  [A,B,C,D]]
    //where distance is given between first row element and second row element
    //(distance between each element of first row and second row)
    Response response = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?",
        queryParameters: {
          "units": "imperial",
          "origins": _generateOriginsForApi(waypoints),
          "destinations": _generateDestinationsForApi(waypoints),
          "key": googleApiKey,
        });
    return DistanceMatrixModel.fromJson(response.data);
  }
}
