import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/constants.dart';
import 'package:map_demo/models/distance_matrix_model.dart';

class MapProvider extends ChangeNotifier {
  //
  final locationA = const LatLng(19.0354, 72.8423);
  final locationB = const LatLng(19.0269, 72.8553);
  final locationC = const LatLng(19.0178, 72.8478);

  LatLng? userLocation;

  int currentPosition = 0;
  late bool hasReachedFinalPosition;

  String gpsLocationErrorMessage = "";

  bool get showGpsErrorMessage => gpsLocationErrorMessage.isNotEmpty;

  //helper function on distance matrix object
  List<String> get getAddresses {
    final addresses = List<String>.empty(growable: true);
    distanceMatrixModel?.originAddresses?.forEach((element) {
      addresses.add(element);
    });
    if (distanceMatrixModel?.destinationAddresses?.last != null) {
      addresses.add(distanceMatrixModel!.destinationAddresses!.last);
    }
    return addresses;
  }

  set updateGpsErrorMessage(String s) {
    gpsLocationErrorMessage = s;
    notifyListeners();
  }

  set updateCurrentPosition(int i) {
    currentPosition = i;
    notifyListeners();
  }

  set updateHasReachedFinalPosition(bool v) {
    hasReachedFinalPosition = v;
    notifyListeners();
  }

  get getUserPosition async {
    try {
      final position = await Geolocator.getCurrentPosition();
      userLocation = LatLng(position.latitude, position.longitude);
    } catch (e) {
      //
    }
    notifyListeners();
  }

  Map<PolylineId, Polyline> polylines = {};
  DistanceMatrixModel? distanceMatrixModel;
  List<LatLng> polylineCoordinates = List<LatLng>.empty(growable: true);

  void init() {
    _determinePosition();
  }

  Future<void> getLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      updateGpsErrorMessage = "";
      getUserPosition;
      return;
    }
    if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
    } else {
      Geolocator.openLocationSettings();
    }
  }

  //check permission, if enabled get user location else show UI for getting permission
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    String errorMessage = "";

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      errorMessage = 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        errorMessage = 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      errorMessage =
          'Location permissions are permanently denied, we cannot request permissions.';
    }
    updateGpsErrorMessage = errorMessage;

    await getUserPosition;
    if (userLocation != null) {
      getGoogleMapRoute(
        start: userLocation!,
        destination: locationC,
        waypoint: [locationA, locationB],
      );
      _getDistance();
    }
  }

  Future<void> onTapMarkCompleteBtn() async {
    if (currentPosition == 0) {
      await getGoogleMapRoute(
        start: locationA,
        waypoint: [locationB],
        destination: locationC,
      );
    }
    if (currentPosition == 1) {
      await getGoogleMapRoute(
        start: locationB,
        destination: locationC,
      );
    }
    if (currentPosition == 2) {
      _resetPolyLine();
    }
    updateCurrentPosition = currentPosition + 1;
  }

  //get polylines for given coordinates
  Future getGoogleMapRoute({
    required LatLng start,
    required LatLng destination,
    List<LatLng> waypoint = const [],
  }) async {
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      wayPoints: List.of(
        waypoint.map(
          (point) => PolylineWayPoint(
              location: "${point.latitude},${point.longitude}"),
        ),
      ),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    _addPolyLine(polylineCoordinates);
  }

  //helper function
  void _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 2,
    );
    polylines[id] = polyline;

    notifyListeners();
  }

  void _resetPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
    );
    polylines[id] = polyline;

    notifyListeners();
  }

  //get distance between coordinates
  Future _getDistance() async {
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
          "origins":
              "${userLocation!.latitude},${userLocation!.longitude}|${locationA.latitude},${locationA.longitude}|${locationB.latitude},${locationB.longitude}|",
          "destinations":
              "${locationA.latitude},${locationA.longitude}|${locationB.latitude},${locationB.longitude}|${locationC.latitude},${locationC.longitude}",
          "key": googleApiKey,
        });
    distanceMatrixModel = DistanceMatrixModel.fromJson(response.data);
    notifyListeners();
  }

  //helper function
  String get totalDistance {
    if (distanceMatrixModel == null) return "Loading";

    num distanceUserToA =
        distanceMatrixModel!.rows![0].elements![0].distance!.value!;

    final distanceAtoB =
        distanceMatrixModel!.rows![1].elements![1].distance!.value!;
    final distanceBtoC =
        distanceMatrixModel!.rows![2].elements![2].distance!.value!;
    final total = distanceUserToA + distanceAtoB + distanceBtoC;

    if (distanceUserToA < 100) {
      distanceUserToA = 0;
    }
    if (total < 1000) {
      return "$total meter";
    } else {
      final totalInKm = total / 1000;
      return "$totalInKm km";
    }
  }
}
