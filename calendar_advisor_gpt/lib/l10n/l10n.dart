import 'dart:ui';
import 'package:flutter/material.dart';




class L10n{
  static final all = [
    const Locale('en'),
    const Locale('ko'),
  ];


  static getLanguage(String code){
    switch (code){
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
    }
  }

}