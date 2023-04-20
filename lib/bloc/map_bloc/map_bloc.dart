import 'dart:async';

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
  StreamSubscription? _getLocationSubscription;

  MapBloc() : super(MapState.initialState()) {
    ///Call this as Bloc is intialized to retrieve all the values and update the state
    on<Initial>((event, emit) async {
      //
      final latlngs = state.latLngList;
      latlngs.add(const LatLng(19.0760, 72.8777));
      emit(state.copyWith(
        latLngList: latlngs,
      ));

      _getLocationSubscription ??= Stream.periodic(const Duration(seconds: 5))
          .listen((_) => add(fetchAndUpdateCurrentLocation()));

      // try {
      //   final userLatLng = await _determinePosition();
      //   emit(state.copyWith(
      //     currentLocation: userLatLng,
      //   ));
      // } on Exception catch (e) {
      //   emit(
      //     state.copyWith(
      //       gpsLocationErrorMessage: e.toString(),
      //     ),
      //   );
      // }
      add(OnTapMarkCompleteBtn());

      if (state.latLngList.length > 1) {
        final polyline =
            await getPolyLineForThisIndex(latlngs: state.latLngList);
        final distanceMatrix =
            await MapRepository().getDistance(state.waypoint);

        emit(
          state.copyWith(
              distanceMatrixModel: distanceMatrix, polyline: polyline!),
        );
      }
      emit(state.copyWith(showLoading: false));
    });

    ///get Location for current user (if not provided already)
    ///first try to get user location, if retrieved update it and refresh the polyline
    on<OnGetLocationTapped>((event, emit) async {
      LatLng? userLatLng;
      try {
        userLatLng = await _determinePosition();
        emit(state.copyWith(
          currentLocation: userLatLng,
        ));
      } on Exception catch (e) {
        emit(
          state.copyWith(
            gpsLocationErrorMessage: e.toString(),
          ),
        );
      }
      final polyline = await getPolyLineForThisIndex(latlngs: state.latLngList);
      if (userLatLng != null && polyline != null) {
        emit(
          state.copyWith(
            polyline: polyline,
          ),
        );
      }
    });

    ///Handle Mark Button onClick events

    on<OnTapMarkCompleteBtn>((event, emit) async {
      try {
        final userLatLng = await _determinePosition();
        final latLngList = state.latLngList;
        final waypoint = state.waypoint;
        if (waypoint.isEmpty) {
          waypoint.add(latLngList.first);
        }
        latLngList.add(userLatLng!);
        if (waypoint.last.latitude != userLatLng.latitude &&
            waypoint.last.longitude != userLatLng.longitude) {
          waypoint.add(userLatLng);
          final distanceMatrix = await MapRepository().getDistance(waypoint);
          emit(
            state.copyWith(
              distanceMatrixModel: distanceMatrix,
            ),
          );
        }

        final polyline = await getPolyLineForThisIndex(latlngs: latLngList);

        emit(
          state.copyWith(
            currentLocation: userLatLng,
            latLngList: latLngList,
            waypoint: waypoint,
            polyline: polyline!,
          ),
        );
      } on Exception catch (e) {
        emit(
          state.copyWith(
            gpsLocationErrorMessage: e.toString(),
          ),
        );
      }
    });

    on<fetchAndUpdateCurrentLocation>((event, emit) async {
      final updatedState = await _getUpdatedCurrentLocation();
      emit(updatedState);
    });

    on<MarkAsDestinationReached>((event, emit) async {
      add(OnTapMarkCompleteBtn());
      emit(state.copyWith(hasReachedFinalPosition: true));
    });
  }

  Future<MapState> _getUpdatedCurrentLocation() async {
    try {
      final userLatLng = await _determinePosition();
      final latLngList = state.latLngList;
      final waypoint = state.waypoint;
      latLngList.add(userLatLng!);
      final polyline = await getPolyLineForThisIndex(
          latlngs: state.latLngList, waypoints: waypoint);
      final distanceMatrix = await MapRepository().getDistance(state.waypoint);

      return state.copyWith(
        currentLocation: userLatLng,
        latLngList: latLngList,
        distanceMatrixModel: distanceMatrix,
        polyline: polyline!,
      );
    } on Exception catch (e) {
      return state.copyWith(
        gpsLocationErrorMessage: e.toString(),
      );
    }
  }

  Future<Polyline?> getPolyLineForThisIndex({
    required List<LatLng> latlngs,
    List<LatLng> waypoints = const [],
  }) async {
    int n = latlngs.length;
    if (n <= 1) {
      return null;
    }
    final polyline = await getGoogleMapRoute(
      start: latlngs.first,
      waypoint: waypoints,
      destination: latlngs.last,
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
