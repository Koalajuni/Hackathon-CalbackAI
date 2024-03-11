import 'package:calendar/pages/authenticate/register_manager.dart';
import 'package:calendar/pages/authenticate/user_agreement.dart';
import 'package:calendar/shared/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../all_pages.dart';
import 'onboarding.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final AuthService _auth = AuthService();
  final UserAgreement userAgreement = UserAgreement();
  final OnBoarding onBoarding = OnBoarding(); 
  // L12
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final registerManager = Provider.of<RegisterManager>(context, listen: true);
    return loading ? Loading() : Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 50),
            child: Form(
              key: _formKey, // keeps track of form and state of it. needed to validation
              child: Column(
                children: [
                  SizedBox(height: 20),
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
                    obscureText: true,
                    validator: (value) => value!.length < 6 ? 'Enter a password 6+ long' : null, // validaotr is VALID if NULL
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 40,
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () async {
                        if(_formKey.currentState!.validate()){ // if ALL validators are NULL, then it will return true
                          setState(() {
                              loading = true;
                            });
                          dynamic result = await _auth.registerWithEmailAndPw(email, password, registerManager.isPersonal);
                          if(result.runtimeType == String){
                            setState(() {
                              error = "please try again";
                              loading = false;
                            });
                          }
                          else{ // popping register form to show home page
                            await userAgreement.UserLicenseAlert(context); 
                            bnbIndex = 4;
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/wrapper', (Route<dynamic> route) => false);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black),
                      child: Text(
                        AppLocalizations.of(context)!.register,
                        style: TextStyle(color: Colors.white),
                      )
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(error,
                  style: TextStyle(color: Colors.red, fontSize:14),)
                ],
              ),)
          ),
        ),
      );
  }
}