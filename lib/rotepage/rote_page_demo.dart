

import 'package:flutter/material.dart';
import 'package:flutter_custom_widget/rotepage/rota_widget.dart';

void main(){

  runApp(MaterialApp(
    home: HomePage(),
  ));
}


class HomePage  extends StatefulWidget{

  @override
  State<StatefulWidget> createState()=>_HomePageState();

}

class _HomePageState extends State<HomePage>{

  var data = ["1","2","3","5","5","5","5","2","3","1","2","3","1","2","3",];
  var startIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RotaWidget(
      topWidget: Container(
        alignment:Alignment.center,
        width: 300,
        height: 300,
        color: startIndex % 2 == 0 ? Colors.white : Colors.blue,
        child: Text(data[startIndex]),
      ),
      bottomWidget: Container(
          alignment:Alignment.center,
          width: 300,
          height: 300,
          color: startIndex % 2 == 0 ? Colors.blue : Colors.white,
          child: Text(data[startIndex+1])
      ),
      refreshPageCallBack: (){
        startIndex ++;
        setState(() {

        });
      },
    );
  }

}