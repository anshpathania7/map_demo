import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/models/distance_matrix_model.dart';
import 'package:map_demo/screens/widgets/header_card.dart';
import 'package:timelines/timelines.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  //Hardcoded coordinates
  static const locationA = LatLng(19.0354, 72.8423);
  static const locationB = LatLng(19.0269, 72.8553);
  static const locationC = LatLng(19.0178, 72.8478);

  //key [to be stored in env]
  static const googleApiKey = "AIzaSyAGz5RfGxyZN802LAmJRQ19m8XQ2IOgLtQ";

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: locationA,
    zoom: 14,
  );

  //state variables
  Map<PolylineId, Polyline> polylines = {};
  DistanceMatrixModel? distanceMatrixModel;
  final markers = {
    const Marker(
      markerId: MarkerId(
        "1",
      ),
      position: locationA,
    ),
    const Marker(
      markerId: MarkerId(
        "2",
      ),
      position: locationB,
    ),
    const Marker(
      markerId: MarkerId(
        "3",
      ),
      position: locationC,
    ),
  };

  @override
  void initState() {
    super.initState();
    getGoogleMapRoute();
    getDistance();
  }

  //Retrieve coordinates between given location to form a path on map
  Future getGoogleMapRoute() async {
    PolylinePoints polylinePoints = PolylinePoints();

    LatLng startLocation = locationA;
    LatLng endLocation = locationC;

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey,
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      wayPoints: [
        PolylineWayPoint(
            location: "${locationB.latitude},${locationB.longitude}")
      ],
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  void addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    polylines[id] = polyline;
    setState(() {});
  }

  //Retrieve distance between given coordinates
  Future getDistance() async {
    Dio dio = Dio();

    Response response = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?",
        queryParameters: {
          "units": "imperial",
          "origins":
              "${locationA.latitude},${locationA.longitude}|${locationB.latitude},${locationB.longitude}",
          "destinations":
              "${locationB.latitude},${locationB.longitude}|${locationC.latitude},${locationC.longitude}",
          "key": googleApiKey,
        });
    distanceMatrixModel = DistanceMatrixModel.fromJson(response.data);
    setState(() {});
    //
  }

  //helper function
  String get totalDistance {
    if (distanceMatrixModel == null) return "Loading";

    final distanceAtoB =
        distanceMatrixModel!.rows![0].elements![0].distance!.value!;
    final distanceBtoC =
        distanceMatrixModel!.rows![1].elements![1].distance!.value!;
    final total = distanceAtoB + distanceBtoC;
    if (total < 1000) {
      return "$total meter";
    } else {
      final totalInKm = total / 1000;
      return "$totalInKm km";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 400,
              width: double.maxFinite,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: _kGooglePlex,
                markers: markers,
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              ),
            ),
            HeaderCard(distance: totalDistance),
            Timeline.tileBuilder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(left: 22),
              physics: const BouncingScrollPhysics(),
              builder: TimelineTileBuilder.connected(
                connectionDirection: ConnectionDirection.after,
                indicatorBuilder: (context, index) {
                  return index > 1
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 6.0),
                          child: Icon(
                            Icons.pin_drop_outlined,
                            color: Colors.blue,
                          ),
                        )
                      : DotIndicator(
                          border: index < 2
                              ? Border.all(
                                  color: const Color.fromRGBO(158, 158, 158, 1),
                                  width: 2,
                                )
                              : Border.all(
                                  width: 2,
                                  color: const Color(0xff193fcc),
                                ),
                          color: index > 2
                              ? const Color(0xff193fcc)
                              : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Icon(
                              Icons.circle,
                              color: index > 2
                                  ? const Color(0xff193fcc)
                                  : Colors.grey,
                              size: 16,
                            ),
                          ),
                        );
                },
                connectorBuilder: (_, index, connectorType) {
                  return Connector.solidLine(
                    color: Colors.blueGrey,
                    indent: connectorType == ConnectorType.end ? 4 : 0,
                    endIndent: connectorType == ConnectorType.start ? 4 : 0,
                  );
                },
                contentsBuilder: (context, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                  child: Text(
                    () {
                      if (i == 0) {
                        return "Pickup/Start:\n${distanceMatrixModel?.originAddresses?.first ?? ""}";
                      } else if (i == 2) {
                        return "Drop-off/Complete:\n${distanceMatrixModel?.destinationAddresses?.last ?? ""}";
                      } else {
                        return "Waypoint:\n${distanceMatrixModel?.destinationAddresses?.first ?? ""}";
                      }
                    }(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                ),
                itemCount: 3,
                nodePositionBuilder: (ctx, i) => 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
