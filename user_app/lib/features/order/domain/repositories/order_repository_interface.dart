import 'package:flutter_sixvalley_ecommerce/interface/repo_interface.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';

abstract class OrderRepositoryInterface<T> extends RepositoryInterface{

  Future<ApiResponseModel> getOrderList(int offset, String status, {String? type});

  Future<dynamic> getTrackingInfo(String orderID);

  Future<dynamic> cancelOrder(int? orderId);


}
