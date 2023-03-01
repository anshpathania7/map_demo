import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

enum MapDotStatus {
  hasReached,
  notReached,
  currentlyThere,
}

class MapDotIndicator extends StatelessWidget {
  final MapDotStatus mapDotStatus;

  const MapDotIndicator({super.key, required this.mapDotStatus});

  Color get bgColor {
    Color bgColor;
    if (mapDotStatus == MapDotStatus.currentlyThere) {
      bgColor = Colors.yellow;
    } else if (mapDotStatus == MapDotStatus.hasReached) {
      bgColor = Colors.green;
    } else {
      bgColor = Colors.grey;
    }
    return bgColor;
  }

  IconData get dotIcon {
    IconData icon;
    if (mapDotStatus == MapDotStatus.currentlyThere) {
      icon = Icons.circle;
    } else if (mapDotStatus == MapDotStatus.hasReached) {
      icon = Icons.check;
    } else {
      icon = Icons.circle;
    }
    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return DotIndicator(
      border: Border.all(
        color: bgColor,
        width: 2,
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Icon(
          dotIcon,
          color: bgColor,
          size: 16,
        ),
      ),
    );
  }
}
