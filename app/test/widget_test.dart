import 'package:flutter_test/flutter_test.dart';
import 'package:app/app.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AccessToInsightApp());
    expect(find.text('Access to Insight'), findsOneWidget);
  });
}
