part of 'map_bloc.dart';

class MapState {
  bool showLoading = true;
  final LatLng? currentLocation;
  final int? currentPosition;
  final bool hasReachedFinalPosition;
  final Polyline? polyline;
  final DistanceMatrixModel? distanceMatrixModel;
  final List<LatLng> latLngList;
  final List<LatLng> waypoint;

  final String gpsLocationErrorMessage;

  bool get showGpsErrorMessage => gpsLocationErrorMessage.isNotEmpty;
  MapState(
    this.currentLocation,
    this.currentPosition,
    this.hasReachedFinalPosition,
    this.polyline,
    this.distanceMatrixModel,
    this.latLngList,
    this.gpsLocationErrorMessage,
    this.showLoading,
    this.waypoint,
  );

  MapState.initialState()
      : currentPosition = 0,
        polyline = null,
        currentLocation = null,
        distanceMatrixModel = null,
        gpsLocationErrorMessage = "",
        hasReachedFinalPosition = false,
        waypoint = List<LatLng>.empty(growable: true),
        latLngList = List<LatLng>.empty(growable: true);

  String get totalDistance {
    if (distanceMatrixModel == null) return "Loading";

    num total = 0;

    final n = distanceMatrixModel!.rows!.length;
    for (int i = 0; i < n; i++) {
      total += distanceMatrixModel!.rows![i].elements![i].distance!.value!;
    }

    if (total < 1000) {
      return "$total meter";
    } else {
      final totalInKm = total / 1000;
      return "$totalInKm km";
    }
  }

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

  MapState copyWith({
    LatLng? currentLocation,
    int? currentPosition,
    bool? hasReachedFinalPosition,
    Polyline? polyline,
    DistanceMatrixModel? distanceMatrixModel,
    List<LatLng>? latLngList,
    String? gpsLocationErrorMessage,
    FakeMapData? fakeMapData,
    bool? showLoading,
    List<LatLng>? waypoint,
  }) {
    return MapState(
      currentLocation ?? this.currentLocation,
      currentPosition ?? this.currentPosition,
      hasReachedFinalPosition ?? this.hasReachedFinalPosition,
      polyline ?? this.polyline,
      distanceMatrixModel ?? this.distanceMatrixModel,
      latLngList ?? this.latLngList,
      gpsLocationErrorMessage ?? this.gpsLocationErrorMessage,
      showLoading ?? this.showLoading,
      waypoint ?? this.waypoint,
    );
  }
}
