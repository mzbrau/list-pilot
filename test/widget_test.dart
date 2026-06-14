import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('List Pilot app renders lists overview', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShopFlowApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('List Pilot'), findsOneWidget);
    expect(find.text('New list'), findsOneWidget);
  });
}
