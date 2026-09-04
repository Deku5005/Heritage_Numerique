import 'package:flutter_test/flutter_test.dart';
import 'package:heritage_numerique/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HeritageNumeriqueApp());
    expect(find.byType(HeritageNumeriqueApp), findsOneWidget);
  });
}
