
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/*https://juejin.cn/post/6844903878509461518#heading-8*/

/*最终执行绘制*/
class RenderCloudWidget extends RenderBox
    with  ContainerRenderObjectMixin<RenderBox, RenderCloudParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RenderCloudParentData>{


  /*Clip 替换 overflow*/
  RenderCloudWidget({
    List<RenderBox> children,
    Clip overflow = Clip.hardEdge,
    double ratio,
  })  : _ratio = ratio,
        _overflow = overflow {
    addAll(children);
  }

  ///溢出
  Clip get overflow => _overflow;
  Clip _overflow;

  set overflow(Clip value) {
    assert(value != null);
    if (_overflow != value) {
      _overflow = value;
      markNeedsPaint();
    }
  }

  ///比例
  double _ratio;

  double get ratio => _ratio;

  set ratio(double value) {
    assert(value != null);

    if (_ratio != value) {
      _ratio = value;
      markNeedsPaint();
    }
  }

  ///是否重复区域了
  bool overlaps(RenderCloudParentData data) {
    /*widget的坐标区域*/
    Rect rect = data.content;

    /*前一个child*/
    RenderBox child = data.previousSibling;

    if (child == null) {
      return false;
    }

    /*遍历自己之前的所有child 查看是否有重叠*/
    do {
      RenderCloudParentData childParentData = child.parentData;
      if (rect.overlaps(childParentData.content)) {
        return true;
      }
      child = childParentData.previousSibling;
    } while (child != null);
    return false;
  }

  ///设置为我们的数据
  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderCloudParentData)
      child.parentData = RenderCloudParentData();
  }

  ///圆周
  double _mathPi = math.pi * 2;

  ///是否需要裁剪
  bool _needClip = false;

  /*布局所有的child*/
  /*在 执行performLayout 的过程中才会对 所有的parentData自定义属性 进行赋值*/
  @override
  void performLayout() {
    ///默认不需要裁剪
    _needClip = false;

    ///没有 childCount 不玩
    if (childCount == 0) {
      size = constraints.smallest;
      return;
    }

    ///初始化区域
    var recordRect = Rect.zero;
    var previousChildRect = Rect.zero;

    RenderBox child = firstChild;

    while (child != null) {
      var curIndex = -1;

      ///提出数据
      final RenderCloudParentData childParentData = child.parentData;

      /*parentUsesSize 子child 改变 是否通知父view 一起layout*/
      child.layout(constraints, parentUsesSize: true);

      var childSize = child.size;

      ///记录大小
      childParentData.width = childSize.width;
      childParentData.height = childSize.height;

      do {
        ///设置 xy 轴的比例
        var rX = ratio >= 1 ? ratio : 1.0;
        var rY = ratio <= 1 ? ratio : 1.0;

        ///调整位置
        var step = 0.02 * _mathPi;
        var rotation = 0.0;
        var angle = curIndex * step;
        var angleRadius = 5 + 5 * angle;
        var x = rX * angleRadius * math.cos(angle + rotation);
        var y = rY * angleRadius * math.sin(angle + rotation);
        var position = Offset(x, y);

        ///计算得到绝对偏移
        var childOffset = position - Alignment.center.alongSize(childSize);

        ++curIndex;

        ///设置为遏制
        childParentData.offset = childOffset;

        ///判处是否交叠
      } while (overlaps(childParentData));

      ///记录区域
      previousChildRect = childParentData.content;
      recordRect = recordRect.expandToInclude(previousChildRect);

      ///下一个
      child = childParentData.nextSibling;
    }

    ///调整布局大小
    size = constraints
        .tighten(
      height: recordRect.height,
      width: recordRect.width,
    )
        .smallest;

    ///居中
    var contentCenter = size.center(Offset.zero);
    var recordRectCenter = recordRect.center;
    var transCenter = contentCenter - recordRectCenter;
    child = firstChild;
    while (child != null) {
      final RenderCloudParentData childParentData = child.parentData;
      childParentData.offset += transCenter;
      child = childParentData.nextSibling;
    }

    ///超过了嘛？
    _needClip =
        size.width < recordRect.width || size.height < recordRect.height;
  }


  ///设置绘制默认
  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_needClip || _overflow != Clip.hardEdge) {
      defaultPaint(context, offset);
    } else {
      context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
      );
    }
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(HitTestResult result, {Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }


}

/*保存的是子widget 布局需要的信息*/
class RenderCloudParentData extends ContainerBoxParentData<RenderBox>{

  double width;
  double height;

  Rect get content => Rect.fromLTWH(
    offset.dx,
    offset.dy,
    width,
    height,
  );

}