import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef RefreshPageCallBack = void Function();

class RotaWidget extends StatefulWidget {
  final Widget topWidget;
  final Widget bottomWidget;
  final RefreshPageCallBack refreshPageCallBack;


  RotaWidget({this.topWidget, this.bottomWidget,this.refreshPageCallBack});
  @override
  State<StatefulWidget> createState() => _RotaPageState();
}

class _RotaPageState extends State<RotaWidget> with TickerProviderStateMixin {
  ClipRect topLeftChild;
  ClipRect topRightChild;
  ClipRect bottomLeftChild;
  ClipRect bottomRightChild;
  AnimationController _flipLeftStep1Controller,_flipLeftStep2Controller, _flipRightStep1Controller,_flipRightStep2Controller;
  Animation _flipLeftAnimationStep1, _flipLeftAnimationStep2;
  Animation _flipRightAnimationStep1, _flipRightAnimationStep2;
  bool isLeft = true; /*往哪个方向翻转 true 向左 false 向右*/

  @override
  void didUpdateWidget(covariant RotaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    contentChange();
  }

  void contentChange(){
    topLeftChild = ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 0.5,
        child: widget.topWidget,
      ),
    );
    topRightChild = ClipRect(
      child: Align(
        alignment: Alignment.centerRight,
        widthFactor: 0.5,
        child: widget.topWidget,
      ),
    );

    bottomLeftChild = ClipRect(
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 0.5,
        child: widget.bottomWidget,
      ),
    );

    bottomRightChild = ClipRect(
      child: Align(
        alignment: Alignment.centerRight,
        widthFactor: 0.5,
        child: widget.bottomWidget,
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    _flipLeftStep1Controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _flipLeftStep2Controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _flipLeftAnimationStep1 = Tween(begin: .0, end: pi / 2).animate(
        CurvedAnimation(parent: _flipLeftStep1Controller, curve: Interval(.0, 1.0)));
    _flipLeftAnimationStep2 = Tween(begin: -pi / 2, end: 0.0).animate(
        CurvedAnimation(parent: _flipLeftStep2Controller, curve: Interval(.0, 1.0)));


    _flipRightStep1Controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));
    _flipRightStep2Controller =
        AnimationController(vsync: this, duration: Duration(seconds: 2));

    _flipRightAnimationStep1 = Tween(begin: .0, end: -pi / 2).animate(
        CurvedAnimation(parent: _flipRightStep1Controller, curve: Interval(.0, 1.0)));
    _flipRightAnimationStep2 = Tween(begin: pi / 2, end: 0.0).animate(
        CurvedAnimation(
            parent: _flipRightStep2Controller, curve: Interval(.0, 1.0)));

    _flipLeftStep1Controller.addStatusListener(step1StatusListener);

    _flipLeftStep2Controller.addStatusListener(step2StatusListener);

    _flipRightStep1Controller.addStatusListener(step1StatusListener);

    _flipRightStep2Controller.addStatusListener(step2StatusListener);

    contentChange();
  }

  void step1StatusListener(AnimationStatus status){
    if(status == AnimationStatus.forward){
      isAnimation = true;
    }

    if(status == AnimationStatus.completed){
      setState(() {
      });
      isLeft ? _flipLeftStep2Controller.forward() : _flipRightStep2Controller.forward();
    }
  }

  void step2StatusListener(AnimationStatus status){
    if(status == AnimationStatus.completed){
      isAnimation = false;
      widget.refreshPageCallBack();
      if(isLeft){
        _flipLeftStep1Controller.reset();
        _flipLeftStep2Controller.reset();
      }else{
        _flipRightStep1Controller.reset();
        _flipRightStep2Controller.reset();
      }
    }
  }

  bool isAnimation = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              children: [
                /*只展示*/
                bottomLeftChild,
                /*初始值是 0 所以能看见*/
                wrapGestureDetector(
                    isLeftView: true,
                    child: AnimatedBuilder(
                        animation: _flipRightAnimationStep1,
                        child: topLeftChild,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.centerRight,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(
                                  isLeft ? 0 : _flipRightAnimationStep1.value),
                            child: child,
                          );
                        })),
              ],
            ),
            Stack(
              children: [
                /*只负责展示*/
                bottomRightChild,
                /*初始值 是 0*/
                wrapGestureDetector(
                  isLeftView: false,
                  child: AnimatedBuilder(
                      animation: _flipLeftAnimationStep1,
                      child: topRightChild,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.centerLeft,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_flipLeftAnimationStep1.value),
                          child: child,
                        );
                      }),
                )
              ],
            ),
          ],
        ),

        /*只做动画 不处理事件*/
        isAnimation ?  Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            AnimatedBuilder(
                animation: _flipLeftAnimationStep2,
                child: bottomLeftChild,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.centerRight,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(isLeft ? _flipLeftAnimationStep2.value:0),
                    child: child,
                  );
                }),

            AnimatedBuilder(
                animation: _flipRightAnimationStep2,
                child: bottomRightChild,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.centerLeft,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(isLeft ? 0:_flipRightAnimationStep2.value),
                    child: bottomRightChild,
                  );
                })

          ],
        ): SizedBox()
      ],
    );
  }

  var dx = 0.0;
  GestureDetector wrapGestureDetector({bool isLeftView, Widget child}) {
    return GestureDetector(
      onPanStart: (details) {
        dx = 0.0;
      },
      onPanUpdate: (details) {
        dx += details.delta.dx;
        if (dx.abs() > 100) {

          isLeft = !isLeftView;

          isLeft ? _flipLeftStep1Controller.forward() :_flipRightStep1Controller.forward();

          // setState(() {
          //
          // });
        }
      },
      child: child,
    );
  }
}
