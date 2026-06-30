import 'package:flutter_test/flutter_test.dart';

import 'package:garage_obd_app/main.dart';

void main() {
  testWidgets('App loads and shows scan screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GarageOBDApp());

    // Verify the app title is shown
    expect(find.text('Garage OBD'), findsWidgets);
  });
}
