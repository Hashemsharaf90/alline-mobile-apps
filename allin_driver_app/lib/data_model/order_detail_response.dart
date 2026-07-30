// To parse this JSON data, do
//
//     final orderDetailResponse = orderDetailResponseFromJson(jsonString);
//https://app.quicktype.io/
import 'dart:convert';

OrderDetailResponse orderDetailResponseFromJson(String str) =>
    OrderDetailResponse.fromJson(json.decode(str));

String orderDetailResponseToJson(OrderDetailResponse data) =>
    json.encode(data.toJson());

class OrderDetailResponse {
  OrderDetailResponse({this.detailed_orders, this.success, this.status});

  List<DetailedOrder>? detailed_orders;
  bool? success;
  int? status;

  factory OrderDetailResponse.fromJson(Map<String, dynamic> json) =>
      OrderDetailResponse(
        detailed_orders: List<DetailedOrder>.from(
          (json["data"] ?? []).map((x) => DetailedOrder.fromJson(x)),
        ),
        success: json["success"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from((detailed_orders ?? []).map((x) => x.toJson())),
    "success": success,
    "status": status,
  };
}

class DetailedOrder {
  DetailedOrder({
    this.id,
    this.code,
    this.user_id,
    this.shipping_address,
    this.shipping_type,
    this.shipping_type_string,
    this.payment_type,
    this.payment_status,
    this.payment_status_string,
    this.delivery_status,
    this.delivery_status_string,
    this.grand_total,
    this.coupon_discount,
    this.shipping_cost,
    this.subtotal,
    this.tax,
    this.date,
    this.cancel_request,
    this.links,
  });

  int? id;
  String? code;
  int? user_id;
  ShippingAddress? shipping_address;
  String? shipping_type;
  String? shipping_type_string;
  String? payment_type;
  String? payment_status;
  String? payment_status_string;
  String? delivery_status;
  String? delivery_status_string;
  String? grand_total;
  String? coupon_discount;
  String? shipping_cost;
  String? subtotal;
  String? tax;
  String? date;
  bool? cancel_request;
  Links? links;

  factory DetailedOrder.fromJson(Map<String, dynamic> json) => DetailedOrder(
    id: json["id"],
    code: json["code"]?.toString() ?? '',
    user_id: json["user_id"],
    shipping_address:
        json["shipping_address"] == null
            ? ShippingAddress()
            : ShippingAddress.fromJson(json["shipping_address"]),
    shipping_type: json["shipping_type"]?.toString() ?? '',
    shipping_type_string: json["shipping_type_string"]?.toString() ?? '',
    payment_type: json["payment_type"]?.toString() ?? '',
    payment_status: json["payment_status"]?.toString() ?? '',
    payment_status_string: json["payment_status_string"]?.toString() ?? '',
    delivery_status: json["delivery_status"]?.toString() ?? '',
    delivery_status_string: json["delivery_status_string"]?.toString() ?? '',
    grand_total: json["grand_total"]?.toString() ?? '',
    coupon_discount: json["coupon_discount"]?.toString() ?? '',
    shipping_cost: json["shipping_cost"]?.toString() ?? '',
    subtotal: json["subtotal"]?.toString() ?? '',
    tax: json["tax"]?.toString() ?? '',
    date: json["date"]?.toString() ?? '',
    cancel_request: json["cancel_request"] ?? false,
    links: json["links"] == null ? Links() : Links.fromJson(json["links"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "user_id": user_id,
    "shipping_address": shipping_address?.toJson(),
    "shipping_type": shipping_type,
    "shipping_type_string": shipping_type_string,
    "payment_type": payment_type,
    "payment_status": payment_status,
    "payment_status_string": payment_status_string,
    "delivery_status": delivery_status,
    "delivery_status_string": delivery_status_string,
    "grand_total": grand_total,
    "coupon_discount": coupon_discount,
    "shipping_cost": shipping_cost,
    "subtotal": subtotal,
    "tax": tax,
    "date": date,
    "cancel_request": cancel_request,
    "links": links?.toJson(),
  };
}

class Links {
  Links({this.details});

  String? details;

  factory Links.fromJson(Map<String, dynamic> json) =>
      Links(details: json["details"]?.toString() ?? '');

  Map<String, dynamic> toJson() => {"details": details};
}

class ShippingAddress {
  ShippingAddress({
    this.name,
    this.email,
    this.address,
    this.country,
    this.city,
    this.postal_code,
    this.phone,
    this.checkout_type,
  });

  String? name;
  String? email;
  String? address;
  String? country;
  String? city;
  String? postal_code;
  String? phone;
  String? checkout_type;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        name: json["name"]?.toString() ?? '',
        email: json["email"]?.toString() ?? '',
        address: json["address"]?.toString() ?? '',
        country: json["country"]?.toString() ?? '',
        city: json["city"]?.toString() ?? '',
        postal_code: json["postal_code"]?.toString() ?? '',
        phone: json["phone"]?.toString() ?? '',
        checkout_type: json["checkout_type"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "address": address,
    "country": country,
    "city": city,
    "postal_code": postal_code,
    "phone": phone,
    "checkout_type": checkout_type,
  };
}
