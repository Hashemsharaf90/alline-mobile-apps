import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/helper/financial_input.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';
import 'package:sixvalley_delivery_boy/features/profile/screens/bank_info_edit_screen.dart';
class BankInfoScreen extends StatelessWidget {
 const BankInfoScreen({super.key});
 @override Widget build(BuildContext context)=>Scaffold(appBar:CustomAppBarWidget(title:'bank_info'.tr,isBack:true),
 body:SingleChildScrollView(padding:const EdgeInsets.all(16),child:GetBuilder<ProfileController>(builder:(controller){
 final profile=controller.profileModel;
 if(profile==null)return AllineErrorState(onRetry:()=>controller.getProfile());
 return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
 AllineMoneyRow(label:'ac_holder'.tr,value:profile.holderName??''),AllineMoneyRow(label:'bank'.tr,value:profile.bankName??''),
 AllineMoneyRow(label:'branch'.tr,value:profile.branch??''),AllineMoneyRow(label:'account_no'.tr,value:FinancialInput.maskAccount(profile.accountNo))]))),
 const SizedBox(height:16),OutlinedButton.icon(onPressed:()=>Get.to(()=>const BankInfoEditScreen()),icon:const Icon(Icons.edit_outlined),label:Text('edit_info'.tr))]);
 })));
}
