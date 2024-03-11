import 'package:calendar/pages/all_pages.dart';
import 'package:calendar/pages/authenticate/register_form.dart';
import 'package:calendar/pages/authenticate/register_manager.dart';
import 'package:calendar/pages/authenticate/user_agreement.dart';
import 'package:calendar/pages/authenticate/user_type.dart';
import 'package:calendar/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:calendar/shared/constants.dart';
import 'package:calendar/shared/globals.dart' as globals;

class Register extends StatefulWidget {

  const Register({ Key? key }) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late PageController controller;
    @override
    void initState() {
      super.initState();
      controller = new PageController(initialPage: 0);
    }
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return loading ? Loading(): ChangeNotifierProvider<RegisterManager>(
      create:(context) => RegisterManager(),
      child: Consumer<RegisterManager>(
        builder: (context, registerManager, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                   IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
                      onPressed: () {
                        if(controller.page == 0) {
                          Navigator.pop(context);
                        } else {
                            controller.previousPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
                        }
                      },
                    ),
                  Text(AppLocalizations.of(context)!.signup_title,
                    style:TextStyle(
                      color: Colors.black,
                      fontFamily:'Roboto-Bold',
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: PageView(
                controller: controller,
                children: 
                [
                  // UserType(controller: controller,),
                  RegisterForm()
                ]
              ),
            ),
          );
        }
      ),
    );
  }
}