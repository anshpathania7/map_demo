import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/bloc/map_bloc/map_bloc.dart';
import 'package:map_demo/images.dart';
import 'package:map_demo/screens/widgets/header_card.dart';
import 'package:map_demo/screens/widgets/map_dot_indicator.dart';
import 'package:timelines/timelines.dart';

import 'widgets/mark_location_dialog.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  Future<Set<Marker>> _generateMarkersSet(List<LatLng> latlngs) async {
    if (latlngs.isEmpty) {
      return {};
    }
    final markers = <Marker>{};
    final ic = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration.empty, Png.ic_car);
    for (int i = 0; i < latlngs.length; i++) {
      markers.add(
        Marker(
          icon: (i == 0) ? ic : BitmapDescriptor.defaultMarker,
          markerId: MarkerId(
            i.toString(),
          ),
          position: latlngs[i],
        ),
      );
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => MarkLocationDialog(
                onMarkDestination: () {
                  context.read<MapBloc>().add(MarkAsDestinationReached());
                  Navigator.pop(context);
                },
                onMarkWaypoint: () {
                  context.read<MapBloc>().add(OnTapMarkCompleteBtn());
                  Navigator.pop(context);
                },
              ),
            ),
            child: const Text("Mark"),
          ),
          body: (state.showLoading)
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FutureBuilder(
                          future: _generateMarkersSet(state.latLngList),
                          initialData: const <Marker>{},
                          builder: (context, snapshot) {
                            return SizedBox(
                              height: 400,
                              width: double.maxFinite,
                              child: GoogleMap(
                                mapType: MapType.normal,
                                initialCameraPosition: CameraPosition(
                                  target: state.latLngList.first,
                                  zoom: 14,
                                ),
                                myLocationEnabled: true,
                                markers: snapshot.data!,
                                polylines: (state.polyline == null)
                                    ? {}
                                    : {state.polyline!},
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                              ),
                            );
                          }),
                      if (state.showGpsErrorMessage)
                        InkWell(
                          onTap: () => context
                              .read<MapBloc>()
                              .add(OnGetLocationTapped()),
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
                      HeaderCard(
                        distance: state.totalDistance,
                        tripId: "1234",
                      ),
                      Flexible(
                        child: Timeline.tileBuilder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.only(left: 22),
                          physics: const BouncingScrollPhysics(),
                          builder: TimelineTileBuilder.connected(
                            connectionDirection: ConnectionDirection.after,
                            indicatorBuilder: (context, index) {
                              return state.hasReachedFinalPosition &&
                                      index == state.getAddresses.length - 1
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 6.0),
                                      child: Icon(
                                        Icons.pin_drop_outlined,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : MapDotIndicator(mapDotStatus: () {
                                      if (index == state.currentPosition) {
                                        return MapDotStatus.currentlyThere;
                                      } else if (index <
                                          state.currentPosition!) {
                                        return MapDotStatus.hasReached;
                                      } else {
                                        return MapDotStatus.notReached;
                                      }
                                    }());
                            },
                            connectorBuilder: (_, index, connectorType) {
                              return Connector.solidLine(
                                color: state.currentPosition! > index
                                    ? Colors.green
                                    : Colors.blueGrey,
                                indent:
                                    connectorType == ConnectorType.end ? 4 : 0,
                                endIndent: connectorType == ConnectorType.start
                                    ? 4
                                    : 0,
                              );
                            },
                            contentsBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 20),
                              child: Text(
                                () {
                                  if (i == 0) {
                                    return "Pickup/Start:\n${state.getAddresses[i]}";
                                  } else if (i == state.latLngList.length - 1 &&
                                      state.hasReachedFinalPosition) {
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
