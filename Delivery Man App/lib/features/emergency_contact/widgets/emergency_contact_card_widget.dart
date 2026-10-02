import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixvalley_delivery_boy/features/emergency_contact/domain/models/emergency_contact_model.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
class EmergencyContactCardWidget extends StatelessWidget {
 final ContactList? contactList;
 const EmergencyContactCardWidget({super.key,this.contactList});
 Future<void> _call()async{try{if(!await launchUrl(Uri(scheme:'tel',path:contactList?.phone)))showCustomSnackBarWidget('alline_support_unavailable'.tr);}catch(_){showCustomSnackBarWidget('alline_support_unavailable'.tr);}}
 @override Widget build(BuildContext context)=>Card(margin:const EdgeInsets.symmetric(horizontal:16,vertical:8),child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Text(contactList?.name??'',style:Theme.of(context).textTheme.titleMedium),Text(contactList?.phone??'',textDirection:TextDirection.ltr),const SizedBox(height:16),
 ElevatedButton.icon(onPressed:contactList?.phone?.isNotEmpty==true?_call:null,icon:const Icon(Icons.phone),label:Text('call_now'.tr))])));
}
