import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';

/// Constrains web content to `Dimensions.webMaxWidth` and centers it.
class WebConstrainedBox extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const WebConstrainedBox({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? Dimensions.webMaxWidth),
        child: child,
      ),
    );
  }
}
