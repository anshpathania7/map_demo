part of 'map_bloc.dart';

@immutable
abstract class MapEvent {}

class Initial extends MapEvent {}

class OnGetLocationTapped extends MapEvent {}

class OnTapMarkCompleteBtn extends MapEvent {}

class fetchAndUpdateCurrentLocation extends MapEvent {}

class MarkAsDestinationReached extends MapEvent {}
