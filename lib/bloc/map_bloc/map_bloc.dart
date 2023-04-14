import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_demo/constants.dart';
import 'package:map_demo/models/distance_matrix_model.dart';
import 'package:map_demo/models/fake_map_data.dart';
import 'package:map_demo/repository/map_repository.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(MapState.initialState()) {
    ///Call this as Bloc is intialized to retrieve all the values and update the state
    on<Initial>((event, emit) async {
      //

      try {
        final userLatLng = await _determinePosition();
        emit(state.copyWith(
          userLocation: userLatLng,
        ));
      } on Exception catch (e) {
        emit(
          state.copyWith(
            gpsLocationErrorMessage: e.toString(),
          ),
        );
      }

      final mapData = await MapRepository().getMapData();

      emit(state.copyWith(
        fakeMapData: mapData,
      ));

      final polyline = await getPolyLineForThisIndex(
        state.currentPosition ?? 0,
        state.getFakeMapDataLatLngs(),
      );
      final distanceMatrix =
          await MapRepository().getDistance(state.getFakeMapDataLatLngs());

      emit(
        state.copyWith(
            distanceMatrixModel: distanceMatrix,
            polylines: {const PolylineId("poly"): polyline!}),
      );
      emit(state.copyWith(showLoading: false));
    });

    ///get Location for current user (if not provided already)
    ///first try to get user location, if retrieved update it and refresh the polylines
    on<OnGetLocationTapped>((event, emit) async {
      LatLng? userLatLng;
      try {
        userLatLng = await _determinePosition();
        emit(state.copyWith(
          userLocation: userLatLng,
        ));
      } on Exception catch (e) {
        emit(
          state.copyWith(
            gpsLocationErrorMessage: e.toString(),
          ),
        );
      }
      final polyLines =
          await getPolyLineForThisIndex(0, state.getFakeMapDataLatLngs());
      if (userLatLng != null && polyLines != null) {
        emit(
          state.copyWith(
            polylines: {const PolylineId("poly"): polyLines},
          ),
        );
      }
    });

    ///Handle Mark Button onClick events
    ///As User moves ahead of waypoint, mark it as complete on UI
    ///and redraw the polylines from current waypoint to destination
    on<OnTapMarkCompleteBtn>((event, emit) async {
      Polyline? polyline;
      polyline = await getPolyLineForThisIndex(
          state.currentPosition! + 1, state.getFakeMapDataLatLngs());

      if (polyline != null) {
        emit(
          state.copyWith(
            polylines: {const PolylineId("poly"): polyline},
            currentPosition: state.currentPosition! + 1,
          ),
        );
      } else {
        emit(
          state.copyWith(
            polylines: _resetPolyLine(),
            currentPosition: state.currentPosition! + 1,
          ),
        );
      }
    });
  }

  Future<Polyline?> getPolyLineForThisIndex(int i, List<LatLng> latlngs) async {
    int n = latlngs.length;
    if (i == n - 1) {
      return null;
    }
    final polyline = await getGoogleMapRoute(
      start: latlngs[i],
      waypoint: (i + 1 != n - 1) ? latlngs.sublist(i + 1, n - 2) : [],
      destination: latlngs[n - 1],
    );
    return polyline;
  }

  Future<LatLng?> _determinePosition() async {
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
    if (errorMessage.isNotEmpty) {
      throw Exception(errorMessage);
    }

    return getUserPosition;
  }

  Future<LatLng?> get getUserPosition async {
    try {
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      //
    }
    return null;
  }

  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      getUserPosition;
      return true;
    }

    if (permission == LocationPermission.deniedForever) {
      Geolocator.openAppSettings();
    } else {
      Geolocator.openLocationSettings();
    }
    return false;
  }

  Map<PolylineId, Polyline> _resetPolyLine() {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
    );
    return {id: polyline};
  }

  Future<Polyline> getGoogleMapRoute({
    required LatLng start,
    required LatLng destination,
    List<LatLng> waypoint = const [],
  }) async {
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = List.empty(growable: true);

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
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print(result.errorMessage);
    }
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 2,
    );
    return polyline;
  }
}
