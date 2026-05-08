import 'package:flutter_test/flutter_test.dart';
import 'package:depo_yonetim/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const CaveApp());
    expect(find.text('Depo Yönetim'), findsWidgets);
  });
}
