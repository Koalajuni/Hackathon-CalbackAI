import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true, //must be true to show fillColor
  enabledBorder: OutlineInputBorder( //applied when not in focused.
    borderSide: BorderSide(color: Color.fromRGBO(28, 39, 41, 100), width: 2.0)
  ), 
  focusedBorder: OutlineInputBorder( //applied when focused.
    borderSide: BorderSide(color: Color.fromRGBO(215, 212, 241, 100), width: 2.0)
  ),
);
