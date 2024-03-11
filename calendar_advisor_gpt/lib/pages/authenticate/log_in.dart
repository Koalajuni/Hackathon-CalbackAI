import 'dart:io';

import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/services/auth.dart';
import 'package:calendar/services_kakao/kakao_auth.dart';
import 'package:flutter/material.dart';
import 'package:calendar/shared/constants.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class LogIn extends StatefulWidget {
  const LogIn({ Key? key }) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final AuthService _auth = AuthService();
  final KakaoAuthService _kakaoAuth = KakaoAuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 0,
        title: Text("CalBack AI",
          style:TextStyle(
            color: Color.fromARGB(255, 68, 62, 105),
            fontFamily:'Pretendard',
            fontSize: 36,
          ),),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: Text(AppLocalizations.of(context)!.register,
                style:TextStyle(
                  color: uiSettingColor.minimal_1,
                  fontFamily:'Roboto-Medium',
                  fontSize: 18,
                ),
              ),
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
          child: Form(
            key: _formKey,
            child: Container(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  // Text("Calendar Sharing Social Media",
                  //     style:TextStyle(color: Colors.black, fontSize: 20) ),
                  // SizedBox(height: 5),
                  // Text("캘린더 기반 소셜네트워크 서비스: 캘박",
                  //     style:TextStyle(color: Colors.black, fontSize: 13) ),
              SizedBox(height: 40),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: "Email"),
                    validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                    onChanged: (value) { //this functions runs everytime there is a change, type, etc
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    decoration: textInputDecoration.copyWith(hintText: "Password"),
                    validator: (value) => value!.length < 6 ? 'Enter a password 6+ long' : null,
                    obscureText: true,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: ElevatedButton(
                    onPressed: () async { // sign in with email and pw
                      if(_formKey.currentState!.validate()){ // if ALL validators are NULL, then it will return true
                        setState(() {
                          loading = true;
                        });
                        dynamic result = await _auth.signInWithEmailAndPw(email, password);
                        if(result == null){
                          setState(() {
                            error = "Failed to Log In";
                            loading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black),
                    child: Text(
                      AppLocalizations.of(context)!.login,
                      style: TextStyle(color: Colors.white),
                    )
                  ),
                  ),
                  SizedBox(height: 10),
                  Text(error,
                  style: TextStyle(color: Colors.red, fontSize:14),),

                  SizedBox(height: 30),
                  
                
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
}