import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../pages/all_pages.dart';



class Storage {


  Storage({required this.uid});

  late final String uid;
  late final imgRef;


  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;


  Future<void> uploadFile(String filePath, String fileName) async {
    File file = File(filePath);

    try {
      await storage.ref('${uid}').child(fileName).putFile(file);
    } on firebase_core.FirebaseException catch (e) {
      print("Error uploading image to storage:${e}");
    }
  }

}