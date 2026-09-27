import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_sixvalley_ecommerce/features/product_details/domain/models/product_details_model.dart';

void main() {
  test('ProductDetailsModel deserialization test with live product 698', () {
    final file = File(r'C:\Users\Hashem Sharaf\.gemini\antigravity\brain\fa97c83a-1a44-4471-9cc1-a62601788a51\scratch\product_698.json');
    final rawJson = file.readAsStringSync();
    final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;

    final product = ProductDetailsModel.fromJson(jsonMap);
    expect(product.id, equals(698));
    expect(product.unitPrice, equals(1500.0));
    expect(product.categoryIds, isNotNull);
    expect(product.categoryIds!.length, equals(2));
    expect(product.categoryIds![0].id, equals('12137'));
    print('Product successfully parsed: id=${product.id}, name=${product.name}, price=${product.unitPrice}, categories=${product.categoryIds?.length}');
  });
}
