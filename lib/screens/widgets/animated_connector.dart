import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

class AnimatedConnector extends StatefulWidget {
  final ConnectorType connectorType;
  final Color loadingColor;
  final Color bgColor;
  const AnimatedConnector(
      {super.key,
      required this.connectorType,
      required this.loadingColor,
      required this.bgColor});

  @override
  State<AnimatedConnector> createState() => _AnimatedConnectorState();
}

class _AnimatedConnectorState extends State<AnimatedConnector> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      color: widget.loadingColor,
      child: Connector.solidLine(
        color: widget.bgColor,
        indent: widget.connectorType == ConnectorType.end ? 4 : 0,
        endIndent: widget.connectorType == ConnectorType.start ? 4 : 0,
      ),
    );
    ;
  }
}
