

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class RoteStateWidget extends StatefulWidget{

  final ValueListenable valueListenable;
  final Widget child;

  RoteStateWidget({this.valueListenable,this.child});

  @override
  State<StatefulWidget> createState()=> _RoteStateWidgetState();

}

class _RoteStateWidgetState extends State<RoteStateWidget>{
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.valueListenable,
        builder: (context,value,child){
          return widget.child;
        });
  }

}