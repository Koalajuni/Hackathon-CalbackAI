import 'package:calendar/pages/authenticate/register_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';

class UserType extends StatefulWidget {
  final PageController controller;
  const UserType({Key? key, required this.controller}) : super(key: key);

  @override
  State<UserType> createState() => _UserTypeState();
}

class _UserTypeState extends State<UserType> {
  @override
  Widget build(BuildContext context) {
    final registerManager = Provider.of<RegisterManager>(context, listen: true);
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  child: Text('개인 유저',
                    style: TextStyle(
                      color: registerManager.isPersonal ? Colors.white : Colors.black,
                    ),
                  ),
                  onPressed: (){
                    registerManager.setIsPersonal(true);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: registerManager.isPersonal ? Colors.black : Colors.white,

                  ),
                )
              ),
              Expanded(
                child: TextButton(
                  child: Text('그룹 생성',
                    style: TextStyle(
                      color: registerManager.isPersonal ? Colors.black : Colors.white,
                    ),
                  ),
                  onPressed: (){
                    registerManager.setIsPersonal(false);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: registerManager.isPersonal ? Colors.white : Colors.black
                  )
                )
              ),
            ],
          ),

          Container(
            width: double.infinity,
            child: TextButton(
              child: Text('다음',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: (){
                widget.controller.nextPage(duration: Duration(milliseconds: 200), curve: Curves.easeIn);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.black
              )
            ),
          )
        ],
      ),
    );
  }
}