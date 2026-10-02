import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/profile/controllers/profile_controller.dart';
import 'package:sixvalley_delivery_boy/helper/price_converter.dart';
import 'package:sixvalley_delivery_boy/features/withdraw/screens/withdraw_request_screen.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';
class WalletSendWithdrawCardWidget extends StatelessWidget {
 const WalletSendWithdrawCardWidget({super.key});
 @override Widget build(BuildContext context)=>GetBuilder<ProfileController>(builder:(controller){
 final profile=controller.profileModel;
 if(profile==null)return controller.profileLoadFailed?AllineErrorState(message:'alline_wallet_error'.tr,onRetry:()=>controller.getProfile()):const AllineSkeleton(count:2);
 return Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
 Card(child:Padding(padding:const EdgeInsets.all(24),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 Text('alline_current_balance'.tr,style:Theme.of(context).textTheme.bodyMedium),const SizedBox(height:8),
 Text(PriceConverter.convertPrice(profile.currentBalance),style:Theme.of(context).textTheme.displayMedium),
 AllineMoneyRow(label:'total_withdrawable_balance'.tr,value:PriceConverter.convertPrice(profile.withdrawableBalance)),
 const SizedBox(height:16),ElevatedButton.icon(onPressed:controller.profileLoadFailed||(profile.withdrawableBalance??0)<=0?null:()=>Get.to(()=>const BalanceWithdrawScreen()),
 icon:const Icon(Icons.account_balance_outlined),label:Text('send_withdraw_request'.tr,textAlign:TextAlign.center))]))),
 Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
 AllineMoneyRow(label:'cash_in_hand'.tr,value:PriceConverter.convertPrice(profile.cashInHand)),
 Align(alignment:AlignmentDirectional.centerStart,child:Text('alline_cash_custody'.tr,style:Theme.of(context).textTheme.bodySmall)),
 const Divider(),AllineMoneyRow(label:'pending_withdrawn'.tr,value:PriceConverter.convertPrice(profile.pendingWithdraw)),
 AllineMoneyRow(label:'alline_total_earnings'.tr,value:PriceConverter.convertPrice(profile.totalEarn)),
 AllineMoneyRow(label:'withdrawn'.tr,value:PriceConverter.convertPrice(profile.totalWithdraw)),
 AllineMoneyRow(label:'already_deposited'.tr,value:PriceConverter.convertPrice(profile.totalDeposit))]))),
 if(controller.profileLoadFailed)AllineErrorState(message:'alline_wallet_error'.tr,onRetry:()=>controller.getProfile()),
 ]);
 });
}
