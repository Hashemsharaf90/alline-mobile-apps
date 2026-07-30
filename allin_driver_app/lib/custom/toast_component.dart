// import 'package:toast/toast.dart';
// import 'package:flutter/material.dart';
// import 'package:active_flutter_delivery_app/my_theme.dart';
// class ToastComponent {
//   static showDialog(String msg, context, {duration = 0, gravity = 0}) {
//     ToastContext().init(context);
//     Toast.show(
//       msg,
//       duration: duration != 0 ? duration : Toast.lengthShort,
//       gravity: gravity != 0 ? gravity : Toast.bottom,
//         backgroundColor:
//         Color.fromRGBO(239, 239, 239, .9),
//         textStyle: TextStyle(color: MyTheme.font_grey),
//         border: Border(
//             top: BorderSide(
//               color: Color.fromRGBO(203, 209, 209, 1),
//             ),bottom:BorderSide(
//           color: Color.fromRGBO(203, 209, 209, 1),
//         ),right: BorderSide(
//           color: Color.fromRGBO(203, 209, 209, 1),
//         ),left: BorderSide(
//           color: Color.fromRGBO(203, 209, 209, 1),
//         )),
//         backgroundRadius: 6
//     );
//   }
// }

import 'package:active_flutter_delivery_app/custom/custom_dependency/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:active_flutter_delivery_app/my_theme.dart';

class ToastComponent {
  static void showDialog(String msg, BuildContext context,
      {int duration = 3, ToastGravity gravity = ToastGravity.BOTTOM}) {
    Toast.show(
      msg,
      context,
      duration: duration, // Use the provided duration or the default.
      gravity: gravity, // Use the provided gravity or the default.
      backgroundColor: const Color.fromRGBO(239, 239, 239, .9),
      textStyle: TextStyle(color: MyTheme.font_grey),
      border: const Border(
        top: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
        bottom: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
        left: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
        right: BorderSide(color: Color.fromRGBO(203, 209, 209, 1)),
      ),
      backgroundRadius: 6.0,
    );
  }
}
