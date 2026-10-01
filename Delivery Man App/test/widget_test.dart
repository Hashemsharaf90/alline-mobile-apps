import 'package:flutter_test/flutter_test.dart';
import 'package:sixvalley_delivery_boy/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    const app = MyApp(languages: {});
    expect(app, isNotNull);
  });
}
