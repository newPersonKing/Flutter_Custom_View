
import 'package:flutter/material.dart';

import 'cloud_render.dart';

/*自定义Widget*/
class CloudWidget extends MultiChildRenderObjectWidget {
  final Clip overflow;
  final double ratio;

  CloudWidget({
    Key key,
    this.ratio = 1,
    this.overflow = Clip.hardEdge,
    List<Widget> children = const <Widget>[],
  }) : super(key: key, children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderCloudWidget(
      ratio: ratio,
      overflow: overflow,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderCloudWidget renderObject) {
    renderObject
      ..ratio = ratio
      ..overflow = overflow;
  }
}