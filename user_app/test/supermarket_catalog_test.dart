import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/data/model/api_response.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/controllers/product_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/product/domain/services/product_service_interface.dart';

class _CatalogService implements ProductServiceInterface {
  int calls = 0;
  bool fail = false;
  Completer<void>? gate;

  @override
  Future<dynamic> getSupermarketProductList(String offset,
      {String? latitude, String? longitude}) async {
    calls++;
    await gate?.future;
    if (fail) throw StateError('offline');
    return ApiResponseModel.withSuccess(Response(
      requestOptions: RequestOptions(path: '/catalog'),
      statusCode: 200,
      data: {
        'total_size': 2,
        'limit': 1,
        'offset': int.parse(offset),
        'products': [
          {'id': int.parse(offset), 'name': 'Test product'}
        ]
      },
    ));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('catalog appends the next page and preserves data on failed refresh',
      () async {
    final service = _CatalogService();
    final controller = ProductController(productServiceInterface: service);
    await controller.getSupermarketProductList(1);
    await controller.getSupermarketProductList(2);
    expect(
        controller.supermarketProductModel!.products!.map((p) => p.id), [1, 2]);
    expect(controller.supermarketProductModel!.offset, 2);
    service.fail = true;
    await controller.getSupermarketProductList(1);
    expect(controller.supermarketHasError, isTrue);
    expect(controller.supermarketLoading, isFalse);
    expect(controller.supermarketProductModel!.products!.length, 2);
    controller.dispose();
  });

  test('concurrent requests do not duplicate a page', () async {
    final service = _CatalogService()..gate = Completer<void>();
    final controller = ProductController(productServiceInterface: service);
    final pending = controller.getSupermarketProductList(1);
    expect(controller.supermarketLoading, isTrue);
    await controller.getSupermarketProductList(1);
    expect(service.calls, 1);
    service.gate!.complete();
    await pending;
    expect(controller.supermarketLoading, isFalse);
    controller.dispose();
  });
}
