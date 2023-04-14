part of 'map_bloc.dart';

class MapState {
  bool showLoading = true;
  final LatLng? userLocation;
  final FakeMapData? fakeMapData;
  final int? currentPosition;
  final bool? hasReachedFinalPosition;
  final Map<PolylineId, Polyline>? polylines;
  final DistanceMatrixModel? distanceMatrixModel;
  final List<LatLng>? polylineCoordinates;

  final String gpsLocationErrorMessage;

  //Mapping FakeMapData Object to LatLng List
  List<LatLng> getFakeMapDataLatLngs() {
    final fakeMapDataLatLngs = List<LatLng>.from(
      fakeMapData!.location!.map(
        (e) => LatLng(
          double.parse(e.latitude!),
          double.parse(e.longitude!),
        ),
      ),
    );
    if (userLocation != null) {
      fakeMapDataLatLngs.insert(0, userLocation!);
    }
    return fakeMapDataLatLngs;
  }

  bool get showGpsErrorMessage => gpsLocationErrorMessage.isNotEmpty;
  MapState(
    this.userLocation,
    this.currentPosition,
    this.hasReachedFinalPosition,
    this.polylines,
    this.distanceMatrixModel,
    this.polylineCoordinates,
    this.gpsLocationErrorMessage,
    this.fakeMapData,
    this.showLoading,
  );

  MapState.initialState()
      : currentPosition = 0,
        polylines = {},
        userLocation = null,
        fakeMapData = null,
        distanceMatrixModel = null,
        gpsLocationErrorMessage = "",
        hasReachedFinalPosition = false,
        polylineCoordinates = List<LatLng>.empty(growable: true);

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
    LatLng? userLocation,
    int? currentPosition,
    bool? hasReachedFinalPosition,
    Map<PolylineId, Polyline>? polylines,
    DistanceMatrixModel? distanceMatrixModel,
    List<LatLng>? polylineCoordinates,
    String? gpsLocationErrorMessage,
    FakeMapData? fakeMapData,
    bool? showLoading,
  }) {
    return MapState(
      userLocation ?? this.userLocation,
      currentPosition ?? this.currentPosition,
      hasReachedFinalPosition ?? this.hasReachedFinalPosition,
      polylines ?? this.polylines,
      distanceMatrixModel ?? this.distanceMatrixModel,
      polylineCoordinates ?? this.polylineCoordinates,
      gpsLocationErrorMessage ?? this.gpsLocationErrorMessage,
      fakeMapData ?? this.fakeMapData,
      showLoading ?? this.showLoading,
    );
  }
}
