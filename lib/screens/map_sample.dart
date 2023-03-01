import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/providers/map_provider.dart';
import 'package:map_demo/screens/widgets/header_card.dart';
import 'package:map_demo/screens/widgets/map_dot_indicator.dart';
import 'package:provider/provider.dart';
import 'package:timelines/timelines.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return Consumer<MapProvider>(
      builder: (context, state, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async => await state.onTapMarkCompleteBtn(),
            child: const Text("Mark"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 400,
                  width: double.maxFinite,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                      target: state.locationA,
                      zoom: 14,
                    ),
                    markers: {
                      if (state.userLocation != null)
                        Marker(
                          markerId: const MarkerId(
                            "0",
                          ),
                          position: state.userLocation!,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                        ),
                      if (state.currentPosition < 2)
                        Marker(
                          markerId: const MarkerId(
                            "1",
                          ),
                          position: state.locationA,
                        ),
                      if (state.currentPosition < 3)
                        Marker(
                          markerId: const MarkerId(
                            "2",
                          ),
                          position: state.locationB,
                        ),
                      if (state.currentPosition < 4)
                        Marker(
                          markerId: const MarkerId(
                            "3",
                          ),
                          position: state.locationC,
                        ),
                    },
                    polylines: Set<Polyline>.of(state.polylines.values),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                ),
                if (state.showGpsErrorMessage)
                  InkWell(
                    onTap: () => state.getLocationPermission(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22.0,
                            vertical: 12,
                          ),
                          child: Text(
                            "${state.gpsLocationErrorMessage}\nTap to Open settings",
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                HeaderCard(distance: state.totalDistance),
                Flexible(
                  child: Timeline.tileBuilder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(left: 22),
                    physics: const BouncingScrollPhysics(),
                    builder: TimelineTileBuilder.connected(
                      connectionDirection: ConnectionDirection.after,
                      indicatorBuilder: (context, index) {
                        return index == 3
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 6.0),
                                child: Icon(
                                  Icons.pin_drop_outlined,
                                  color: Colors.blue,
                                ),
                              )
                            : MapDotIndicator(mapDotStatus: () {
                                if (index == state.currentPosition) {
                                  return MapDotStatus.currentlyThere;
                                } else if (index < state.currentPosition) {
                                  return MapDotStatus.hasReached;
                                } else {
                                  return MapDotStatus.notReached;
                                }
                              }());
                      },
                      connectorBuilder: (_, index, connectorType) {
                        return Connector.solidLine(
                          color: state.currentPosition > index
                              ? Colors.green
                              : Colors.blueGrey,
                          indent: connectorType == ConnectorType.end ? 4 : 0,
                          endIndent:
                              connectorType == ConnectorType.start ? 4 : 0,
                        );
                      },
                      contentsBuilder: (context, i) => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
                        child: Text(
                          () {
                            if (i == 0) {
                              return "Pickup/Start:\n${state.getAddresses[i]}";
                            } else if (i == 3) {
                              return "Drop-off/Complete:\n${state.getAddresses[i]}";
                            } else {
                              return "Waypoint:\n${state.getAddresses[i]}";
                            }
                          }(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      itemCount: state.getAddresses.length,
                      nodePositionBuilder: (ctx, i) => 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
