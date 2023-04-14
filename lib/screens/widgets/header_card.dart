import 'package:flutter/material.dart';

class HeaderCard extends StatelessWidget {
  String distance;
  String? tripId;

  HeaderCard({
    Key? key,
    required this.distance,
    this.tripId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
              child: const Padding(
                padding: EdgeInsets.all(4.0),
                child: Icon(
                  Icons.person,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome Raj",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Trip ${tripId ?? "xyz"}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  distance,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Total Distance",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
