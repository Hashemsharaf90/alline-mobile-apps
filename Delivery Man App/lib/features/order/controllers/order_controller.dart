import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/date_type.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/services/order_service_interface.dart';
import 'package:sixvalley_delivery_boy/data/api/api_checker.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';

class OrderController extends GetxController implements GetxService {
  final OrderServiceInterface orderServiceInterface;
  OrderController({required this.orderServiceInterface});


  List<OrderModel> _currentOrders = [];
  List<OrderModel> get currentOrders => _currentOrders;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  int _orderTypeIndex = 0;
  int get orderTypeIndex => _orderTypeIndex;
  List<OrderModel>? _allOrderHistory;
  List<OrderModel>? pauseOrderHistory;
  List<OrderModel>? deliveredOrderHistory;
  List<OrderModel>? get allOrderHistory => _allOrderHistory;

  String? selectedOrderLat = '23.83721';
  String? selectedOrderLng = '90.363715';

  void setSelectedOrderLatLng(LatLng latLng) {
    selectedOrderLat = latLng.latitude.toString();
    selectedOrderLng = latLng.longitude.toString();
  }


  void selectedOrderLatLng(String? lat, String? lng){
    selectedOrderLat = lat;
    selectedOrderLng = lng;
    update();
  }

  String dateType = DateType.overall.key;

  List<OrderModel>? _orderList;
  List<OrderModel>? get orderList => _orderList != null ? _orderList!.reversed.toList() : _orderList;


  bool _isSearchActive = false;
  bool get isSearchActive => _isSearchActive;



  Future<void> getCurrentOrders() async {
    _isLoading = true;
    _currentOrders = await orderServiceInterface.getCurrentOrders();
    _isLoading = false;
    update();
  }




  Future <void> getAllOrderHistory(String dateType, String type, String startDate, String endDate, String search, int isPause) async {
    _isLoading = true;
    Response response = await orderServiceInterface.getAllOrderHistory(dateType, type,startDate,endDate, search, isPause);
    if (response.body != null && response.statusCode == 200) {
      deliveredOrderHistory = null;
      pauseOrderHistory = null;
      _allOrderHistory = null;

      if(type == 'delivered') {
        deliveredOrderHistory = [];
        response.body.forEach((order) {deliveredOrderHistory!.add(OrderModel.fromJson(order));});
      } else if(isPause == 1 ) {
        pauseOrderHistory = [];
        response.body.forEach((order) {pauseOrderHistory!.add(OrderModel.fromJson(order));});
      } else {
        _allOrderHistory = [];
        response.body.forEach((order) {_allOrderHistory!.add(OrderModel.fromJson(order));});
      }
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }




  Future orderRefresh(BuildContext context) async{
    getCurrentOrders();
    return getCurrentOrders();
  }



  void setOrderTypeIndex(int index, {String startDate = '', String endDate = '', String search = '', bool reload = false, isUpdate = true}) {
    _orderTypeIndex = index;
    if(orderTypeIndex == 0) {
      getAllOrderHistory(dateType, '', startDate, endDate, search, 0);
    }else if(orderTypeIndex == 1){
      getAllOrderHistory(dateType, 'out_for_delivery', startDate, endDate, search, 0);
    } else if(orderTypeIndex == 2){
      getAllOrderHistory(dateType, '', startDate, endDate, search, 1);
    } else if(orderTypeIndex == 3){
      getAllOrderHistory(dateType, 'delivered', startDate, endDate, search, 0);
    }else if(orderTypeIndex == 4){
      getAllOrderHistory(dateType, 'return', startDate, endDate, search, 0);
    }else if(orderTypeIndex == 5){
      getAllOrderHistory(dateType, 'canceled', startDate, endDate, search, 0);
    }

    if(search.trim().isNotEmpty) {
      _isSearchActive = true;
    }

    if(isUpdate){
      update();
    }
  }

  void setDateType(DateType type, {bool isUpdate = true}){
    dateType = type.key;
    if(isUpdate) {
      update();
    }
  }

  void setSearchStatus(bool status, {bool isUpdate = true}) {
    _isSearchActive = status;
    if(isUpdate) {
      update();
    }
  }



  String? _startDate;
  String? _endDate;
  final DateFormat _dateFormat = DateFormat('yyyy-MM-d');
  String ? get startDate => _startDate;
  String ? get endDate => _endDate;
  DateFormat get dateFormat => _dateFormat;

  void selectDate({required String startDate, required String endDate}){
    _startDate = startDate;
    _endDate = endDate;
    update();
  }


  TextEditingController searchOrderController = TextEditingController();

  void setSearchText({String? searchText, bool isUpdate = true}){
    searchOrderController.text = searchText ?? '';
    if(isUpdate){
      update();
    }
  }


  void resetFilters({bool isUpdate = false}){
    _startDate = null;
    _endDate = null;
    dateType = DateType.overall.key;
    searchOrderController.clear();

    if(isUpdate) {
      update();
    }
  }


}
