import 'package:flutter/material.dart';

class MarkLocationDialog extends StatelessWidget {
  final Function() onMarkWaypoint;
  final Function() onMarkDestination;
  const MarkLocationDialog(
      {super.key,
      required this.onMarkWaypoint,
      required this.onMarkDestination});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              "Notes for current location",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Write a note...",
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: onMarkWaypoint,
                child: const Text("Mark Waypoint"),
              ),
              TextButton(
                onPressed: onMarkDestination,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  "Mark Destination",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
