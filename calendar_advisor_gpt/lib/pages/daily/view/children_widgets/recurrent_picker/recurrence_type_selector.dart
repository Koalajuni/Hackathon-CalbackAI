import 'package:flutter/material.dart';

class RecurrenceTypeSelector extends StatefulWidget {
  Function callback;

  RecurrenceTypeSelector({Key? key, required this.callback}) : super(key: key);

  @override
  State<RecurrenceTypeSelector> createState() => _RecurrenceTypeSelectorState();
}

class _RecurrenceTypeSelectorState extends State<RecurrenceTypeSelector> {

  @override
  Widget build(BuildContext context) {
    Function callback = widget.callback;
    String rType = 'none';

    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF5562FE)),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Spoqa'
                  ),
                  foregroundColor: Color(0xFF888888),
                  backgroundColor: Color(0xFFE7E7F8),
                ),
                onPressed: () {
                  rType = 'none';
                  callback(rType);
                },
                child: Text('없음')
            
              ),
            ),
          ),
    
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF5562FE)),
                  top: BorderSide(color: Color(0xFF5562FE)),
                  right: BorderSide(color: Color(0xFF5562FE)),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Spoqa'
                  ),
                  foregroundColor: Color(0xFF888888),
                  backgroundColor: Color(0xFFE7E7F8),
                ),
                onPressed: () {
                  rType = 'daily';
                  callback(rType);
                },
                child: Text('매일')
                      
              ),
            ),
          ),
    
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF5562FE)),
                  top: BorderSide(color: Color(0xFF5562FE)),
                  right: BorderSide(color: Color(0xFF5562FE)),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Spoqa'
                  ),
                  foregroundColor: Color(0xFF888888),
                  backgroundColor: Color(0xFFE7E7F8),
                ),
                onPressed: () {
                  rType = 'weekly';
                  callback(rType);
                },
                child: Text('매주')
                      
              ),
            ),
          ),
    
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF5562FE)),
                  top: BorderSide(color: Color(0xFF5562FE)),
                  right: BorderSide(color: Color(0xFF5562FE)),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Spoqa'
                  ),
                  foregroundColor: Color(0xFF888888),
                  backgroundColor: Color(0xFFE7E7F8),
                ),
                onPressed: () {
                  rType = 'monthly';
                  callback(rType);},
                child: Text('매월')
              ),
            ),
          ),
    
          Expanded(
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF5562FE)),
                  top: BorderSide(color: Color(0xFF5562FE)),
                  right: BorderSide(color: Color(0xFF5562FE)),
                ),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  textStyle: TextStyle(
                    fontSize: 14, fontFamily: 'Spoqa'
                  ),
                  foregroundColor: Color(0xFF888888),
                  backgroundColor: Color(0xFFE7E7F8),
                ),
                onPressed: () {
                  rType = 'yearly';
                  callback(rType);
                },
                child: Text('매년')
                      
              ),
            ),
          ),
        ],
      ),
    );
  }
}