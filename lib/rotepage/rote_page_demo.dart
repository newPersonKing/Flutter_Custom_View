

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

  var data = ["1","2","3","4"];
  var startIndex = 0;

  @override
  Widget build(BuildContext context) {
    return RotaWidget<String>(
      itemBuilder: (index){
        return Container(
          alignment:Alignment.center,
          width: 300,
          height: 300,
          color: index % 2 == 0 ? Colors.white : Colors.blue,
          child: Text(data[index]),
        );
      },
      itemCount: data.length,
    );
  }

}