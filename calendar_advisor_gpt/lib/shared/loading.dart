import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
// L15
class Loading extends StatelessWidget {
  const Loading({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: SpinKitCubeGrid(
          color: Color.fromRGBO(106, 103, 172,1),
          size: 50,
        ),)
      
    );
  }
}