import 'package:flutter_test/flutter_test.dart';

import 'package:TravelMate/main.dart';

void main() {
  testWidgets('Textul corect este afișat', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello team! :)'), findsOneWidget);
    expect(find.text('Hello World'), findsNothing);
  });
}
