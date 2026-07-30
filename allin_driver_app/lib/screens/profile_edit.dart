// // // import 'dart:convert';
// // // import 'dart:io';
// // //
// // // import 'package:active_flutter_delivery_app/custom/custom_dependency/custom_toast.dart';
// // // import 'package:active_flutter_delivery_app/custom/input_decorations.dart';
// // // import 'package:active_flutter_delivery_app/custom/lang_text.dart';
// // // import 'package:active_flutter_delivery_app/custom/toast_component.dart';
// // // import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
// // // import 'package:active_flutter_delivery_app/my_theme.dart';
// // // import 'package:active_flutter_delivery_app/repositories/profile_repositories.dart';
// // // import 'package:active_flutter_delivery_app/ui_sections/drawer.dart';
// // // import 'package:flutter/cupertino.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:image_picker/image_picker.dart';
// // // import 'package:permission_handler/permission_handler.dart';
// // //
// // // class ProfileEdit extends StatefulWidget {
// // //   ProfileEdit({super.key, this.show_back_button = false});
// // //
// // //   bool show_back_button;
// // //   @override
// // //   _ProfileEditState createState() => _ProfileEditState();
// // // }
// // //
// // // class _ProfileEditState extends State<ProfileEdit> {
// // //   final ScrollController _mainScrollController = ScrollController();
// // //
// // //   final TextEditingController _nameController =
// // //       TextEditingController(text: "${user_name.$}");
// // //   final TextEditingController _passwordController = TextEditingController();
// // //   final TextEditingController _passwordConfirmController = TextEditingController();
// // //
// // //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// // //
// // //   //for image uploading
// // //   File? _file;
// // //
// // //   chooseAndUploadImage(context) async {
// // //     var status = await Permission.photos.request();
// // //
// // //     if (status.isDenied) {
// // //       // We didn't ask for permission yet.
// // //       showDialog(
// // //           context: context,
// // //           builder: (BuildContext context) => CupertinoAlertDialog(
// // //                 title: Text(LangText(context).local!.photo_permission_ucf),
// // //                 content: Text(
// // //                     'This app needs photo to take pictures for upload user profile photo'),
// // //                 actions: <Widget>[
// // //                   CupertinoDialogAction(
// // //                     child: Text(LangText(context).local!.deny_ucf),
// // //                     onPressed: () => Navigator.of(context).pop(),
// // //                   ),
// // //                   CupertinoDialogAction(
// // //                     child: Text(LangText(context).local!.settings_ucf),
// // //                     onPressed: () => openAppSettings(),
// // //                   ),
// // //                 ],
// // //               ));
// // //     } else if (status.isRestricted) {
// // //       ToastComponent.showDialog(
// // //           "Go to your application settings and give photo permission ", context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //     } else if (status.isGranted) {
// // //       //file = await ImagePicker.pickImage(source: ImageSource.camera);
// // //
// // //     XFile? tmpFile =
// // //         (await ImagePicker.platform.getImage(source: ImageSource.gallery));
// // //
// // //     // new File( await ImagePicker.pickImage(source: ImageSource.gallery));
// // //
// // //     if (tmpFile == null) {
// // //       ToastComponent.showDialog(
// // //           LangText(context).local!.no_file_is_chosen, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     }
// // //
// // //     _file = File(tmpFile.path);
// // //     //return;
// // //     String base64Image = base64Encode(_file!.readAsBytesSync());
// // //     String fileName = _file!.path.split("/").last;
// // //
// // //     var profileImageUpdateResponse =
// // //         await ProfileRepository().getProfileImageUpdateResponse(
// // //       base64Image,
// // //       fileName,
// // //     );
// // //
// // //     if (profileImageUpdateResponse.result == false) {
// // //       ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     } else {
// // //       ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //
// // //       // print("path");
// // //       // print(profileImageUpdateResponse.path);
// // //
// // //       avatar_original.$ = profileImageUpdateResponse.path;
// // //       setState(() {});
// // //     }
// // //     // }
// // //   }}
// // //
// // //   Future<void> _onPageRefresh() async {}
// // //
// // //   onPressUpdate() async {
// // //     var name = _nameController.text.toString();
// // //     var password = _passwordController.text.toString();
// // //     var passwordConfirm = _passwordConfirmController.text.toString();
// // //
// // //     var changePassword = password != "" ||
// // //         passwordConfirm !=
// // //             ""; // if both fields are empty we will not change user's password
// // //
// // //     if (name == "") {
// // //       ToastComponent.showDialog(
// // //           LangText(context).local!.enter_your_name, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     }
// // //     if (changePassword && password == "") {
// // //       ToastComponent.showDialog(
// // //           LangText(context).local!.enter_password, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     }
// // //     if (changePassword && passwordConfirm == "") {
// // //       ToastComponent.showDialog(
// // //           LangText(context).local!.confirm_your_password, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     }
// // //     if (changePassword && password.length < 6) {
// // //       ToastComponent.showDialog(
// // //           "Password must contain atleast 6 characters", context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     }
// // //     if (changePassword && password != passwordConfirm) {
// // //       ToastComponent.showDialog(
// // //           LangText(context).local!.passwords_do_not_match, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //       return;
// // //     }
// // //
// // //     var profileUpdateResponse =
// // //         await ProfileRepository().getProfileUpdateResponse(
// // //       name,
// // //       changePassword ? password : "",
// // //     );
// // //
// // //     if (profileUpdateResponse.result == false) {
// // //       ToastComponent.showDialog(profileUpdateResponse.message!, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //     } else {
// // //       ToastComponent.showDialog(profileUpdateResponse.message!, context,
// // //           gravity: Toast.center, duration: Toast.lengthLong);
// // //
// // //       user_name.$ = name;
// // //       setState(() {});
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       key: _scaffoldKey,
// // //       drawer: MainDrawer(),
// // //       backgroundColor: Colors.white,
// // //       appBar: buildAppBar(context),
// // //       body: buildBody(context),
// // //     );
// // //   }
// // //
// // //   AppBar buildAppBar(BuildContext context) {
// // //     return AppBar(
// // //       centerTitle: true,
// // //       backgroundColor: MyTheme.white,
// // //       leading: GestureDetector(
// // //         child: widget.show_back_button
// // //             ? Builder(
// // //                 builder: (context) => IconButton(
// // //                   icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
// // //                   onPressed: () => Navigator.of(context).pop(),
// // //                 ),
// // //               )
// // //             : Builder(
// // //                 builder: (context) => GestureDetector(
// // //                   onTap: () {
// // //                     _scaffoldKey.currentState!.openDrawer();
// // //                   },
// // //                   child: Padding(
// // //                     padding: const EdgeInsets.symmetric(
// // //                         vertical: 18.0, horizontal: 0.0),
// // //                     child: Container(
// // //                       child: Image.asset(
// // //                         'assets/hamburger.png',
// // //                         height: 16,
// // //                         color: MyTheme.dark_grey,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //       ),
// // //       title: Text(
// // //         LangText(context).local?.account_ucf ?? 'Account',
// // //         style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
// // //       ),
// // //       elevation: 0.0,
// // //       titleSpacing: 0,
// // //     );
// // //   }
// // //
// // //   buildBody(context) {
// // //     if (is_logged_in.$ == false) {
// // //       return SizedBox(
// // //           height: 100,
// // //           child: Center(
// // //               child: Text(
// // //             LangText(context).local!.please_log_in_to_see_the_profile,
// // //             style: TextStyle(color: MyTheme.font_grey),
// // //           )));
// // //     } else {
// // //       return RefreshIndicator(
// // //         color: MyTheme.red,
// // //         backgroundColor: Colors.white,
// // //         onRefresh: _onPageRefresh,
// // //         displacement: 10,
// // //         child: CustomScrollView(
// // //           controller: _mainScrollController,
// // //           physics: const BouncingScrollPhysics(
// // //               parent: AlwaysScrollableScrollPhysics()),
// // //           slivers: [
// // //             SliverList(
// // //               delegate: SliverChildListDelegate([
// // //                 buildTopSection(),
// // //                 Padding(
// // //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
// // //                   child: Divider(
// // //                     height: 24,
// // //                   ),
// // //                 ),
// // //                 buildProfileForm(context)
// // //               ]),
// // //             )
// // //           ],
// // //         ),
// // //       );
// // //     }
// // //   }
// // //
// // //   buildTopSection() {
// // //     return Column(
// // //       children: [
// // //         Padding(
// // //           padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
// // //           child: Stack(
// // //             children: [
// // //               Container(
// // //                 width: 120,
// // //                 height: 120,
// // //                 decoration: BoxDecoration(
// // //                   borderRadius: BorderRadius.circular(100),
// // //                   border: Border.all(
// // //                       color: Color.fromRGBO(112, 112, 112, .3), width: 2),
// // //                   //shape: BoxShape.rectangle,
// // //                 ),
// // //                 child: ClipRRect(
// // //                     clipBehavior: Clip.hardEdge,
// // //                     borderRadius: BorderRadius.all(Radius.circular(100.0)),
// // //                     child: FadeInImage.assetNetwork(
// // //                       placeholder: 'assets/profile.png',
// // //                       image: "${avatar_original.$}",
// // //                       fit: BoxFit.fill,
// // //                     )),
// // //               ),
// // //               Positioned(
// // //                 right: 8,
// // //                 bottom: 8,
// // //                 child: SizedBox(
// // //                   width: 24,
// // //                   height: 24,
// // //                   child: TextButton(
// // //                     style: TextButton.styleFrom(
// // //                       shape: CircleBorder(
// // //                         side: BorderSide(
// // //                             color: MyTheme.light_grey, width: 1.0),
// // //                       ),
// // //                       padding: EdgeInsets.all(0),
// // //                       backgroundColor: MyTheme.light_grey,
// // //                     ),
// // //                     child: Icon(
// // //                       Icons.edit,
// // //                       color: MyTheme.font_grey,
// // //                       size: 14,
// // //                     ),
// // //                     onPressed: () {
// // //                       chooseAndUploadImage(context);
// // //                     },
// // //                   ),
// // //                 ),
// // //               )
// // //             ],
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   buildProfileForm(context) {
// // //     return Padding(
// // //       padding:
// // //           const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
// // //       child: Container(
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 8.0),
// // //               child: Text(
// // //                 LangText(context).local!.basic_information_ucf,
// // //                 style: TextStyle(
// // //                     color: MyTheme.grey_153,
// // //                     fontWeight: FontWeight.w600,
// // //                     fontSize: 14.0),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 4.0),
// // //               child: Text(
// // //                 LangText(context).local!.name_ucf,
// // //                 style:
// // //                     TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 8.0),
// // //               child: SizedBox(
// // //                 height: 36,
// // //                 child: TextField(
// // //                   controller: _nameController,
// // //                   autofocus: false,
// // //                   decoration: InputDecorations.buildInputDecoration_1(
// // //                       hint_text: "John Doe"),
// // //                 ),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 4.0),
// // //               child: Text(
// // //                 LangText(context).local!.password_ucf,
// // //                 style:
// // //                     TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 8.0),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.end,
// // //                 children: [
// // //                   SizedBox(
// // //                     height: 36,
// // //                     child: TextField(
// // //                       controller: _passwordController,
// // //                       autofocus: false,
// // //                       obscureText: true,
// // //                       enableSuggestions: false,
// // //                       autocorrect: false,
// // //                       decoration: InputDecorations.buildInputDecoration_1(
// // //                           hint_text: "• • • • • • • •"),
// // //                     ),
// // //                   ),
// // //                   Text(
// // //                     LangText(context)
// // //                         .local!
// // //                         .password_must_contain_at_least_6_characters,
// // //                     style: TextStyle(
// // //                         color: MyTheme.textfield_grey,
// // //                         fontStyle: FontStyle.italic),
// // //                   )
// // //                 ],
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 4.0),
// // //               child: Text(
// // //                 LangText(context).local!.retype_password_ucf,
// // //                 style:
// // //                     TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
// // //               ),
// // //             ),
// // //             Padding(
// // //               padding: const EdgeInsets.only(bottom: 8.0),
// // //               child: SizedBox(
// // //                 height: 36,
// // //                 child: TextField(
// // //                   controller: _passwordConfirmController,
// // //                   autofocus: false,
// // //                   obscureText: true,
// // //                   enableSuggestions: false,
// // //                   autocorrect: false,
// // //                   decoration: InputDecorations.buildInputDecoration_1(
// // //                       hint_text: "• • • • • • • •"),
// // //                 ),
// // //               ),
// // //             ),
// // //             Row(
// // //               children: [
// // //                 Spacer(),
// // //                 Padding(
// // //                   padding: const EdgeInsets.only(top: 16.0),
// // //                   child: Container(
// // //                     width: 120,
// // //                     height: 36,
// // //                     decoration: BoxDecoration(
// // //                         border:
// // //                             Border.all(color: MyTheme.textfield_grey, width: 1),
// // //                         borderRadius:
// // //                             const BorderRadius.all(Radius.circular(8.0))),
// // //                     child: TextButton(
// // //                       style: TextButton.styleFrom(
// // //                         minimumSize: Size(MediaQuery.of(context).size.width, 0),
// // //                         backgroundColor: MyTheme.red,
// // //                         shape: RoundedRectangleBorder(
// // //                             borderRadius:
// // //                                 const BorderRadius.all(Radius.circular(8.0))),
// // //                       ),
// // //                       child: Text(
// // //                         LangText(context).local!.update_profile_ucf,
// // //                         style: TextStyle(
// // //                             color: Colors.white,
// // //                             fontSize: 14,
// // //                             fontWeight: FontWeight.w600),
// // //                       ),
// // //                       onPressed: () {
// // //                         onPressUpdate();
// // //                       },
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:active_flutter_delivery_app/custom/custom_dependency/custom_toast.dart';
// // import 'package:active_flutter_delivery_app/custom/input_decorations.dart';
// // import 'package:active_flutter_delivery_app/custom/lang_text.dart';
// // import 'package:active_flutter_delivery_app/custom/toast_component.dart';
// // import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
// // import 'package:active_flutter_delivery_app/my_theme.dart';
// // import 'package:active_flutter_delivery_app/repositories/profile_repositories.dart';
// // import 'package:active_flutter_delivery_app/ui_sections/drawer.dart';
// // import 'package:flutter/cupertino.dart';
// // import 'package:flutter/material.dart';
// // import 'package:image_picker/image_picker.dart';
// // import 'package:permission_handler/permission_handler.dart';
// //
// // class ProfileEdit extends StatefulWidget {
// //   ProfileEdit({super.key, this.show_back_button = false});
// //
// //   final bool show_back_button;
// //   @override
// //   _ProfileEditState createState() => _ProfileEditState();
// // }
// //
// // class _ProfileEditState extends State<ProfileEdit> {
// //   final ScrollController _mainScrollController = ScrollController();
// //
// //   final TextEditingController _nameController =
// //   TextEditingController(text: "${user_name.$}");
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _passwordConfirmController =
// //   TextEditingController();
// //
// //   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
// //
// //   // For image uploading
// //   File? _file;
// //   final ImagePicker _picker = ImagePicker();
// //
// //   // This function handles picking and uploading an image.
// //   // It now uses the recommended 'pickImage' method and has refined permission handling.
// //   chooseAndUploadImage(context) async {
// //     // Request permission to access the photo gallery.
// //     // On Android 13+, this requests READ_MEDIA_IMAGES.
// //     // On older versions, it requests READ_EXTERNAL_STORAGE.
// //     var status = await Permission.photos.request();
// //
// //     if (status.isGranted) {
// //       // If permission is granted, pick an image from the gallery.
// //       final XFile? tmpFile =
// //       await _picker.pickImage(source: ImageSource.gallery);
// //
// //       if (tmpFile == null) {
// //         ToastComponent.showDialog(
// //             LangText(context).local!.no_file_is_chosen, context,
// //             gravity: Toast.center, duration: Toast.lengthLong);
// //         return;
// //       }
// //
// //       // Set the file and proceed with the upload process.
// //       _file = File(tmpFile.path);
// //       String base64Image = base64Encode(_file!.readAsBytesSync());
// //       String fileName = _file!.path.split("/").last;
// //
// //       var profileImageUpdateResponse =
// //       await ProfileRepository().getProfileImageUpdateResponse(
// //         base64Image,
// //         fileName,
// //       );
// //
// //       if (profileImageUpdateResponse.result == false) {
// //         ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
// //             gravity: Toast.center, duration: Toast.lengthLong);
// //       } else {
// //         ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
// //             gravity: Toast.center, duration: Toast.lengthLong);
// //
// //         avatar_original.$ = profileImageUpdateResponse.path;
// //         setState(() {});
// //       }
// //     } else if (status.isPermanentlyDenied) {
// //       // If permission is permanently denied, open app settings.
// //       openAppSettings();
// //     } else if (status.isDenied) {
// //       // If permission is denied, show a dialog explaining why it's needed.
// //       showDialog(
// //           context: context,
// //           builder: (BuildContext context) => CupertinoAlertDialog(
// //             title: Text(LangText(context).local!.photo_permission_ucf),
// //             content: const Text(
// //                 'This app needs photo gallery access to upload a profile picture.'),
// //             actions: <Widget>[
// //               CupertinoDialogAction(
// //                 child: Text(LangText(context).local!.deny_ucf),
// //                 onPressed: () => Navigator.of(context).pop(),
// //               ),
// //               CupertinoDialogAction(
// //                   child: Text(LangText(context).local!.settings_ucf),
// //                   onPressed: () {
// //                     // Close the dialog and open app settings.
// //                     Navigator.of(context).pop();
// //                     openAppSettings();
// //                   }
// //               ),
// //             ],
// //           ));
// //     }
// //   }
// //
// //   Future<void> _onPageRefresh() async {
// //     // Implement your refresh logic here if needed.
// //   }
// //
// //   onPressUpdate() async {
// //     var name = _nameController.text.toString();
// //     var password = _passwordController.text.toString();
// //     var passwordConfirm = _passwordConfirmController.text.toString();
// //
// //     var changePassword = password.isNotEmpty || passwordConfirm.isNotEmpty;
// //
// //     if (name.isEmpty) {
// //       ToastComponent.showDialog(
// //           LangText(context).local!.enter_your_name, context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //       return;
// //     }
// //     if (changePassword && password.isEmpty) {
// //       ToastComponent.showDialog(
// //           LangText(context).local!.enter_password, context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //       return;
// //     }
// //     if (changePassword && passwordConfirm.isEmpty) {
// //       ToastComponent.showDialog(
// //           LangText(context).local!.confirm_your_password, context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //       return;
// //     }
// //     if (changePassword && password.length < 6) {
// //       ToastComponent.showDialog(
// //           "Password must contain at least 6 characters", context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //       return;
// //     }
// //     if (changePassword && password != passwordConfirm) {
// //       ToastComponent.showDialog(
// //           LangText(context).local!.passwords_do_not_match, context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //       return;
// //     }
// //
// //     var profileUpdateResponse =
// //     await ProfileRepository().getProfileUpdateResponse(
// //       name,
// //       changePassword ? password : "",
// //     );
// //
// //     if (profileUpdateResponse.result == false) {
// //       ToastComponent.showDialog(profileUpdateResponse.message!, context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //     } else {
// //       ToastComponent.showDialog(profileUpdateResponse.message!, context,
// //           gravity: Toast.center, duration: Toast.lengthLong);
// //
// //       user_name.$ = name;
// //       setState(() {});
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       key: _scaffoldKey,
// //       drawer: MainDrawer(),
// //       backgroundColor: Colors.white,
// //       appBar: buildAppBar(context),
// //       body: buildBody(context),
// //     );
// //   }
// //
// //   AppBar buildAppBar(BuildContext context) {
// //     return AppBar(
// //       centerTitle: true,
// //       backgroundColor: MyTheme.white,
// //       leading: widget.show_back_button
// //           ? IconButton(
// //         icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
// //         onPressed: () => Navigator.of(context).pop(),
// //       )
// //           : IconButton(
// //         icon: Image.asset(
// //           'assets/hamburger.png',
// //           height: 16,
// //           color: MyTheme.dark_grey,
// //         ),
// //         onPressed: () {
// //           _scaffoldKey.currentState!.openDrawer();
// //         },
// //       ),
// //       title: Text(
// //         LangText(context).local?.account_ucf ?? 'Account',
// //         style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
// //       ),
// //       elevation: 0.0,
// //       titleSpacing: 0,
// //     );
// //   }
// //
// //   Widget buildBody(BuildContext context) {
// //     if (is_logged_in.$ == false) {
// //       return Center(
// //           child: Text(
// //             LangText(context).local!.please_log_in_to_see_the_profile,
// //             style: TextStyle(color: MyTheme.font_grey),
// //           ));
// //     } else {
// //       return RefreshIndicator(
// //         color: MyTheme.red,
// //         backgroundColor: Colors.white,
// //         onRefresh: _onPageRefresh,
// //         displacement: 10,
// //         child: CustomScrollView(
// //           controller: _mainScrollController,
// //           physics: const BouncingScrollPhysics(
// //               parent: AlwaysScrollableScrollPhysics()),
// //           slivers: [
// //             SliverList(
// //               delegate: SliverChildListDelegate([
// //                 buildTopSection(),
// //                 const Padding(
// //                   padding: EdgeInsets.symmetric(horizontal: 16.0),
// //                   child: Divider(
// //                     height: 24,
// //                   ),
// //                 ),
// //                 buildProfileForm(context)
// //               ]),
// //             )
// //           ],
// //         ),
// //       );
// //     }
// //   }
// //
// //   Widget buildTopSection() {
// //     return Column(
// //       children: [
// //         Padding(
// //           padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
// //           child: Stack(
// //             children: [
// //               Container(
// //                 width: 120,
// //                 height: 120,
// //                 decoration: BoxDecoration(
// //                   borderRadius: BorderRadius.circular(100),
// //                   border: Border.all(
// //                       color: const Color.fromRGBO(112, 112, 112, .3),
// //                       width: 2),
// //                 ),
// //                 child: ClipRRect(
// //                     clipBehavior: Clip.hardEdge,
// //                     borderRadius: const BorderRadius.all(Radius.circular(100.0)),
// //                     child: FadeInImage.assetNetwork(
// //                       placeholder: 'assets/profile.png',
// //                       image: "${avatar_original.$}",
// //                       fit: BoxFit.cover,
// //                       imageErrorBuilder: (context, error, stackTrace) {
// //                         return Image.asset(
// //                           'assets/profile.png',
// //                           fit: BoxFit.cover,
// //                         );
// //                       },
// //                     )),
// //               ),
// //               Positioned(
// //                 right: 8,
// //                 bottom: 8,
// //                 child: SizedBox(
// //                   width: 24,
// //                   height: 24,
// //                   child: TextButton(
// //                     style: TextButton.styleFrom(
// //                       shape: CircleBorder(
// //                         side:
// //                         BorderSide(color: MyTheme.light_grey, width: 1.0),
// //                       ),
// //                       padding: EdgeInsets.zero,
// //                       backgroundColor: MyTheme.light_grey,
// //                     ),
// //                     child: Icon(
// //                       Icons.edit,
// //                       color: MyTheme.font_grey,
// //                       size: 14,
// //                     ),
// //                     onPressed: () {
// //                       chooseAndUploadImage(context);
// //                     },
// //                   ),
// //                 ),
// //               )
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget buildProfileForm(BuildContext context) {
// //     return Padding(
// //       padding:
// //       const EdgeInsets.symmetric(horizontal: 16.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 8.0),
// //             child: Text(
// //               LangText(context).local!.basic_information_ucf,
// //               style: TextStyle(
// //                   color: MyTheme.grey_153,
// //                   fontWeight: FontWeight.w600,
// //                   fontSize: 14.0),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 4.0),
// //             child: Text(
// //               LangText(context).local!.name_ucf,
// //               style:
// //               TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 8.0),
// //             child: SizedBox(
// //               height: 36,
// //               child: TextField(
// //                 controller: _nameController,
// //                 autofocus: false,
// //                 decoration: InputDecorations.buildInputDecoration_1(
// //                     hint_text: "John Doe"),
// //               ),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 4.0),
// //             child: Text(
// //               LangText(context).local!.password_ucf,
// //               style:
// //               TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 8.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.end,
// //               children: [
// //                 SizedBox(
// //                   height: 36,
// //                   child: TextField(
// //                     controller: _passwordController,
// //                     autofocus: false,
// //                     obscureText: true,
// //                     enableSuggestions: false,
// //                     autocorrect: false,
// //                     decoration: InputDecorations.buildInputDecoration_1(
// //                         hint_text: "• • • • • • • •"),
// //                   ),
// //                 ),
// //                 Text(
// //                   LangText(context)
// //                       .local!
// //                       .password_must_contain_at_least_6_characters,
// //                   style: TextStyle(
// //                       color: MyTheme.textfield_grey,
// //                       fontStyle: FontStyle.italic),
// //                 )
// //               ],
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 4.0),
// //             child: Text(
// //               LangText(context).local!.retype_password_ucf,
// //               style:
// //               TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.only(bottom: 8.0),
// //             child: SizedBox(
// //               height: 36,
// //               child: TextField(
// //                 controller: _passwordConfirmController,
// //                 autofocus: false,
// //                 obscureText: true,
// //                 enableSuggestions: false,
// //                 autocorrect: false,
// //                 decoration: InputDecorations.buildInputDecoration_1(
// //                     hint_text: "• • • • • • • •"),
// //               ),
// //             ),
// //           ),
// //           Align(
// //             alignment: Alignment.centerRight,
// //             child: Padding(
// //               padding: const EdgeInsets.only(top: 16.0),
// //               child: SizedBox(
// //                 width: 120,
// //                 height: 36,
// //                 child: TextButton(
// //                   style: TextButton.styleFrom(
// //                     backgroundColor: MyTheme.red,
// //                     shape: RoundedRectangleBorder(
// //                         borderRadius:
// //                         const BorderRadius.all(Radius.circular(8.0))),
// //                   ),
// //                   child: Text(
// //                     LangText(context).local!.update_profile_ucf,
// //                     style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600),
// //                   ),
// //                   onPressed: () {
// //                     onPressUpdate();
// //                   },
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:active_flutter_delivery_app/custom/custom_dependency/custom_toast.dart';
// import 'package:active_flutter_delivery_app/custom/input_decorations.dart';
// import 'package:active_flutter_delivery_app/custom/lang_text.dart';
// import 'package:active_flutter_delivery_app/custom/toast_component.dart';
// import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
// import 'package:active_flutter_delivery_app/my_theme.dart';
// import 'package:active_flutter_delivery_app/repositories/profile_repositories.dart';
// import 'package:active_flutter_delivery_app/ui_sections/drawer.dart';
// import 'package:flutter/material.dart'; // Changed to material.dart for AlertDialog
// import 'package:image_picker/image_picker.dart';
// // permission_handler is no longer needed for this specific flow
// // import 'package:permission_handler/permission_handler.dart';
//
// class ProfileEdit extends StatefulWidget {
//   const ProfileEdit({super.key, this.show_back_button = false});
//
//   final bool show_back_button;
//   @override
//   _ProfileEditState createState() => _ProfileEditState();
// }
//
// class _ProfileEditState extends State<ProfileEdit> {
//   final ScrollController _mainScrollController = ScrollController();
//
//   final TextEditingController _nameController =
//   TextEditingController(text: "${user_name.$}");
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _passwordConfirmController =
//   TextEditingController();
//
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   // For image uploading
//   File? _file;
//   final ImagePicker _picker = ImagePicker();
//
//   // ------------------- CORRECTED FUNCTION -------------------
//   // This function handles picking and uploading an image,
//   // now with a prominent disclosure dialog to meet Google Play policies.
//   chooseAndUploadImage(context) async {
//     // --- START: Prominent Disclosure Dialog ---
//     // First, show a dialog to explain to the user WHY the permission is needed,
//     // before the system permission dialog is shown.
//     bool? userAgreed = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: Text(LangText(context).local!.photo_permission_ucf),
//         // This content text is crucial for the policy.
//         content: const Text(
//             "To set your profile picture, this app needs access to your photo gallery."),
//         actions: <Widget>[
//           TextButton(
//             // If user cancels, we pop 'false'.
//             onPressed: () => Navigator.of(context).pop(false),
//             child: Text(LangText(context).local!.deny_ucf),
//           ),
//           TextButton(
//             // If user agrees, we pop 'true'.
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text("Agree"), // Or use a localized string if available
//           ),
//         ],
//       ),
//     );
//     // --- END: Prominent Disclosure Dialog ---
//
//     // If the user did not agree in our custom dialog, stop here.
//     if (userAgreed == null || !userAgreed) {
//       ToastComponent.showDialog("Permission to access photos was denied.", context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//
//     // Now that the user has agreed to the purpose, let 'image_picker'
//     // handle the actual system permission request and image picking.
//     final XFile? tmpFile =
//     await _picker.pickImage(source: ImageSource.gallery);
//
//     if (tmpFile == null) {
//       ToastComponent.showDialog(
//           LangText(context).local!.no_file_is_chosen, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//
//     // --- The rest of your original upload logic remains the same ---
//     _file = File(tmpFile.path);
//     String base64Image = base64Encode(_file!.readAsBytesSync());
//     String fileName = _file!.path.split("/").last;
//
//     var profileImageUpdateResponse =
//     await ProfileRepository().getProfileImageUpdateResponse(
//       base64Image,
//       fileName,
//     );
//
//     if (profileImageUpdateResponse.result == false) {
//       ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//     } else {
//       ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//
//       avatar_original.$ = profileImageUpdateResponse.path;
//       setState(() {});
//     }
//   }
//   // ------------------- END OF CORRECTION -------------------
//
//
//   Future<void> _onPageRefresh() async {
//     // Implement your refresh logic here if needed.
//   }
//
//   onPressUpdate() async {
//     var name = _nameController.text.toString();
//     var password = _passwordController.text.toString();
//     var passwordConfirm = _passwordConfirmController.text.toString();
//
//     var changePassword = password.isNotEmpty || passwordConfirm.isNotEmpty;
//
//     if (name.isEmpty) {
//       ToastComponent.showDialog(
//           LangText(context).local!.enter_your_name, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     if (changePassword && password.isEmpty) {
//       ToastComponent.showDialog(
//           LangText(context).local!.enter_password, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     if (changePassword && passwordConfirm.isEmpty) {
//       ToastComponent.showDialog(
//           LangText(context).local!.confirm_your_password, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     if (changePassword && password.length < 6) {
//       ToastComponent.showDialog(
//           "Password must contain at least 6 characters", context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//     if (changePassword && password != passwordConfirm) {
//       ToastComponent.showDialog(
//           LangText(context).local!.passwords_do_not_match, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       return;
//     }
//
//     var profileUpdateResponse =
//     await ProfileRepository().getProfileUpdateResponse(
//       name,
//       changePassword ? password : "",
//     );
//
//     if (profileUpdateResponse.result == false) {
//       ToastComponent.showDialog(profileUpdateResponse.message!, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//     } else {
//       ToastComponent.showDialog(profileUpdateResponse.message!, context,
//           gravity: Toast.center, duration: Toast.lengthLong);
//
//       user_name.$ = name;
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: const MainDrawer(),
//       backgroundColor: Colors.white,
//       appBar: buildAppBar(context),
//       body: buildBody(context),
//     );
//   }
//
//   AppBar buildAppBar(BuildContext context) {
//     return AppBar(
//       centerTitle: true,
//       backgroundColor: MyTheme.white,
//       leading: widget.show_back_button
//           ? IconButton(
//         icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
//         onPressed: () => Navigator.of(context).pop(),
//       )
//           : IconButton(
//         icon: Image.asset(
//           'assets/hamburger.png',
//           height: 16,
//           color: MyTheme.dark_grey,
//         ),
//         onPressed: () {
//           _scaffoldKey.currentState!.openDrawer();
//         },
//       ),
//       title: Text(
//         LangText(context).local?.account_ucf ?? 'Account',
//         style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
//       ),
//       elevation: 0.0,
//       titleSpacing: 0,
//     );
//   }
//
//   Widget buildBody(BuildContext context) {
//     if (is_logged_in.$ == false) {
//       return Center(
//           child: Text(
//             LangText(context).local!.please_log_in_to_see_the_profile,
//             style: TextStyle(color: MyTheme.font_grey),
//           ));
//     } else {
//       return RefreshIndicator(
//         color: MyTheme.red,
//         backgroundColor: Colors.white,
//         onRefresh: _onPageRefresh,
//         displacement: 10,
//         child: CustomScrollView(
//           controller: _mainScrollController,
//           physics: const BouncingScrollPhysics(
//               parent: AlwaysScrollableScrollPhysics()),
//           slivers: [
//             SliverList(
//               delegate: SliverChildListDelegate([
//                 buildTopSection(),
//                 const Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Divider(
//                     height: 24,
//                   ),
//                 ),
//                 buildProfileForm(context)
//               ]),
//             )
//           ],
//         ),
//       );
//     }
//   }
//
//   Widget buildTopSection() {
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
//           child: Stack(
//             children: [
//               Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(100),
//                   border: Border.all(
//                       color: const Color.fromRGBO(112, 112, 112, .3),
//                       width: 2),
//                 ),
//                 child: ClipRRect(
//                     clipBehavior: Clip.hardEdge,
//                     borderRadius: const BorderRadius.all(Radius.circular(100.0)),
//                     child: FadeInImage.assetNetwork(
//                       placeholder: 'assets/profile.png',
//                       image: "${avatar_original.$}",
//                       fit: BoxFit.cover,
//                       imageErrorBuilder: (context, error, stackTrace) {
//                         return Image.asset(
//                           'assets/profile.png',
//                           fit: BoxFit.cover,
//                         );
//                       },
//                     )),
//               ),
//               Positioned(
//                 right: 8,
//                 bottom: 8,
//                 child: SizedBox(
//                   width: 24,
//                   height: 24,
//                   child: TextButton(
//                     style: TextButton.styleFrom(
//                       shape: CircleBorder(
//                         side: BorderSide(color: MyTheme.light_grey, width: 1.0),
//                       ),
//                       padding: EdgeInsets.zero,
//                       backgroundColor: MyTheme.light_grey,
//                     ),
//                     child: Icon(
//                       Icons.edit,
//                       color: MyTheme.font_grey,
//                       size: 14,
//                     ),
//                     onPressed: () {
//                       chooseAndUploadImage(context);
//                     },
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget buildProfileForm(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Text(
//               LangText(context).local!.basic_information_ucf,
//               style: TextStyle(
//                   color: MyTheme.grey_153,
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14.0),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 4.0),
//             child: Text(
//               LangText(context).local!.name_ucf,
//               style: TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: SizedBox(
//               height: 36,
//               child: TextField(
//                 controller: _nameController,
//                 autofocus: false,
//                 decoration: InputDecorations.buildInputDecoration_1(
//                     hint_text: "John Doe"),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 4.0),
//             child: Text(
//               LangText(context).local!.password_ucf,
//               style: TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 SizedBox(
//                   height: 36,
//                   child: TextField(
//                     controller: _passwordController,
//                     autofocus: false,
//                     obscureText: true,
//                     enableSuggestions: false,
//                     autocorrect: false,
//                     decoration: InputDecorations.buildInputDecoration_1(
//                         hint_text: "• • • • • • • •"),
//                   ),
//                 ),
//                 Text(
//                   LangText(context)
//                       .local!
//                       .password_must_contain_at_least_6_characters,
//                   style: TextStyle(
//                       color: MyTheme.textfield_grey,
//                       fontStyle: FontStyle.italic),
//                 )
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 4.0),
//             child: Text(
//               LangText(context).local!.retype_password_ucf,
//               style: TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(bottom: 8.0),
//             child: SizedBox(
//               height: 36,
//               child: TextField(
//                 controller: _passwordConfirmController,
//                 autofocus: false,
//                 obscureText: true,
//                 enableSuggestions: false,
//                 autocorrect: false,
//                 decoration: InputDecorations.buildInputDecoration_1(
//                     hint_text: "• • • • • • • •"),
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.centerRight,
//             child: Padding(
//               padding: const EdgeInsets.only(top: 16.0),
//               child: SizedBox(
//                 width: 120,
//                 height: 36,
//                 child: TextButton(
//                   style: TextButton.styleFrom(
//                     backgroundColor: MyTheme.red,
//                     shape: const RoundedRectangleBorder(
//                         borderRadius: BorderRadius.all(Radius.circular(8.0))),
//                   ),
//                   child: Text(
//                     LangText(context).local!.update_profile_ucf,
//                     style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600),
//                   ),
//                   onPressed: () {
//                     onPressUpdate();
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';

import 'package:active_flutter_delivery_app/custom/custom_dependency/custom_toast.dart';
import 'package:active_flutter_delivery_app/custom/input_decorations.dart';
import 'package:active_flutter_delivery_app/custom/lang_text.dart';
import 'package:active_flutter_delivery_app/custom/toast_component.dart';
import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
import 'package:active_flutter_delivery_app/my_theme.dart';
import 'package:active_flutter_delivery_app/repositories/profile_repositories.dart';
import 'package:active_flutter_delivery_app/ui_sections/drawer.dart';
import 'package:flutter/material.dart'; // Changed to material.dart for AlertDialog
import 'package:image_picker/image_picker.dart';

import '../app_config.dart';
// permission_handler is no longer needed for this specific flow
// import 'package:permission_handler/permission_handler.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key, this.show_back_button = false});

  final bool show_back_button;
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final ScrollController _mainScrollController = ScrollController();

  final TextEditingController _nameController =
  TextEditingController(text: "${user_name.$}");
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmController =
  TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // For image uploading
  File? _file;
  final ImagePicker _picker = ImagePicker();

  // Add state variables for password visibility
  bool _isPasswordObscured = true;
  bool _isPasswordConfirmObscured = true;

  chooseAndUploadImage(context) async {

    bool? userAgreed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(backgroundColor: Colors.white,
        title: Text(LangText(context).local!.photo_permission_ucf),

        content: Text(
            "To set your profile picture, ${AppConfig.app_name} needs access to your photo gallery."),
        actions: <Widget>[
          TextButton(
            // If user cancels, we pop 'false'.
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(LangText(context).local!.deny_ucf),
          ),
          TextButton(
            // If user agrees, we pop 'true'.
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text("Agree"),
          ),
        ],
      ),
    );

    if (userAgreed == null || !userAgreed) {
      ToastComponent.showDialog("Permission to access photos was denied.", context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    final XFile? tmpFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (tmpFile == null) {
      ToastComponent.showDialog(
          LangText(context).local!.no_file_is_chosen, context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    _file = File(tmpFile.path);
    String base64Image = base64Encode(_file!.readAsBytesSync());
    String fileName = _file!.path.split("/").last;

    var profileImageUpdateResponse =
    await ProfileRepository().getProfileImageUpdateResponse(
      base64Image,
      fileName,
    );

    if (profileImageUpdateResponse.result == false) {
      ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(profileImageUpdateResponse.message!, context,
          gravity: Toast.center, duration: Toast.lengthLong);

      avatar_original.$ = profileImageUpdateResponse.path;
      setState(() {});
    }
  }

  // ------------------- END OF CORRECTION -------------------

  Future<void> _onPageRefresh() async {
    // Implement your refresh logic here if needed.
  }

  onPressUpdate() async {
    var name = _nameController.text.toString();
    var password = _passwordController.text.toString();
    var passwordConfirm = _passwordConfirmController.text.toString();

    var changePassword = password.isNotEmpty || passwordConfirm.isNotEmpty;

    if (name.isEmpty) {
      ToastComponent.showDialog(
          LangText(context).local!.enter_your_name, context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (changePassword && password.isEmpty) {
      ToastComponent.showDialog(
          LangText(context).local!.enter_password, context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (changePassword && passwordConfirm.isEmpty) {
      ToastComponent.showDialog(
          LangText(context).local!.confirm_your_password, context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (changePassword && password.length < 6) {
      ToastComponent.showDialog(
          "Password must contain at least 6 characters", context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }
    if (changePassword && password != passwordConfirm) {
      ToastComponent.showDialog(
          LangText(context).local!.passwords_do_not_match, context,
          gravity: Toast.center, duration: Toast.lengthLong);
      return;
    }

    var profileUpdateResponse =
    await ProfileRepository().getProfileUpdateResponse(
      name,
      changePassword ? password : "",
    );

    if (profileUpdateResponse.result == false) {
      ToastComponent.showDialog(profileUpdateResponse.message!, context,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(profileUpdateResponse.message!, context,
          gravity: Toast.center, duration: Toast.lengthLong);

      user_name.$ = name;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MainDrawer(),
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: MyTheme.white,
      leading: widget.show_back_button
          ? IconButton(
        icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
        onPressed: () => Navigator.of(context).pop(),
      )
          : IconButton(
        icon: Image.asset(
          'assets/hamburger.png',
          height: 16,
          color: MyTheme.dark_grey,
        ),
        onPressed: () {
          _scaffoldKey.currentState!.openDrawer();
        },
      ),
      title: Text(
        LangText(context).local?.account_ucf ?? 'Account',
        style: TextStyle(fontSize: 16, color: MyTheme.accent_color),
      ),
      elevation: 0.0,
      titleSpacing: 0,
    );
  }

  Widget buildBody(BuildContext context) {
    if (is_logged_in.$ == false) {
      return Center(
          child: Text(
            LangText(context).local!.please_log_in_to_see_the_profile,
            style: TextStyle(color: MyTheme.font_grey),
          ));
    } else {
      return RefreshIndicator(
        color: MyTheme.red,
        backgroundColor: Colors.white,
        onRefresh: _onPageRefresh,
        displacement: 10,
        child: CustomScrollView(
          controller: _mainScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate([
                buildTopSection(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 24,
                  ),
                ),
                buildProfileForm(context)
              ]),
            )
          ],
        ),
      );
    }
  }

  Widget buildTopSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      color: const Color.fromRGBO(112, 112, 112, .3),
                      width: 2),
                ),
                child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: const BorderRadius.all(Radius.circular(100.0)),
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/profile.png',
                      image: "${avatar_original.$}",
                      fit: BoxFit.cover,
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/profile.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: CircleBorder(
                        side: BorderSide(color: MyTheme.light_grey, width: 1.0),
                      ),
                      padding: EdgeInsets.zero,
                      backgroundColor: MyTheme.light_grey,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: MyTheme.font_grey,
                      size: 14,
                    ),
                    onPressed: () {
                      chooseAndUploadImage(context);
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget buildProfileForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              LangText(context).local!.basic_information_ucf,
              style: TextStyle(
                  color: MyTheme.grey_153,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              LangText(context).local!.name_ucf,
              style: TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _nameController,
                autofocus: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "John Doe"),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              LangText(context).local!.password_ucf,
              style: TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _passwordController,
                    autofocus: false,
                    obscureText: _isPasswordObscured, // MODIFIED
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecorations.buildInputDecoration_1(
                        hint_text: "• • • • • • • •")
                        .copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: MyTheme.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordObscured = !_isPasswordObscured;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Text(
                  LangText(context)
                      .local!
                      .password_must_contain_at_least_6_characters,
                  style: TextStyle(
                      color: MyTheme.textfield_grey,
                      fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              LangText(context).local!.retype_password_ucf,
              style: TextStyle(color: MyTheme.red, fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _passwordConfirmController,
                autofocus: false,
                obscureText: _isPasswordConfirmObscured, // MODIFIED
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecorations.buildInputDecoration_1(
                    hint_text: "• • • • • • • •")
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordConfirmObscured
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: MyTheme.red,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordConfirmObscured =
                        !_isPasswordConfirmObscured;
                      });
                    },
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: SizedBox(
                width: 120,
                height: 36,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: MyTheme.red,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  ),
                  child: Text(
                    LangText(context).local!.update_profile_ucf,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  onPressed: () {
                    onPressUpdate();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}