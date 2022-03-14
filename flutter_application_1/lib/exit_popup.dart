import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showExitPopup(context, isGetX) async{
  dynamic res = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Do you want to leave?"),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isGetX) {
                            Get.offAllNamed("/");
                          } else {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text("Yes"),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade800),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                        if (isGetX) {
                          Get.back();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Text("No", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                    ))
                  ],
                )
              ],
            ),
          ),
        );
      });
    if (res != null) {
      return res;
    } else {
      return Future.value(false);
    }
} 