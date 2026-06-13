import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shop_flow/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Shop Flow app renders lists overview', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ShopFlowApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Shop Flow'), findsOneWidget);
    expect(find.text('New list'), findsOneWidget);
  });
}
