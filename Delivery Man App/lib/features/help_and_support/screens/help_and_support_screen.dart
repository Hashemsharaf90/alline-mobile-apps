import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_snackbar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';
class HelpAndSupportScreen extends StatelessWidget {
 const HelpAndSupportScreen({super.key});
 Future<void> _open(Uri uri)async{try{if(!await launchUrl(uri,mode:LaunchMode.externalApplication))showCustomSnackBarWidget('alline_support_unavailable'.tr);}catch(_){showCustomSnackBarWidget('alline_support_unavailable'.tr);}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:CustomAppBarWidget(title:'help_and_support'.tr,isBack:true),
 body:GetBuilder<SplashController>(builder:(controller){final config=controller.configModel;final email=config?.companyEmail;final phone=config?.companyPhone;
 return SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Icon(Icons.support_agent_rounded,size:64,color:Theme.of(context).colorScheme.primary),const SizedBox(height:24),
 if(email?.isNotEmpty??false)Card(child:ListTile(leading:const Icon(Icons.email_outlined),title:Text('email'.tr),subtitle:Text(email!,textDirection:TextDirection.ltr),onTap:()=>_open(Uri(scheme:'mailto',path:email)))),
 if(phone?.isNotEmpty??false)Card(child:ListTile(leading:const Icon(Icons.phone_outlined),title:Text('call'.tr),subtitle:Text(phone!,textDirection:TextDirection.ltr),onTap:()=>_open(Uri(scheme:'tel',path:phone)))),
 if(!(email?.isNotEmpty??false)&&!(phone?.isNotEmpty??false))AllineEmptyState(title:'alline_support_unavailable'.tr,subtitle:'',icon:Icons.support_agent_outlined),
 ]));
 }));
}
