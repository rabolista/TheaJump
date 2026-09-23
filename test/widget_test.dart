import 'package:flutter_test/flutter_test.dart';

import 'package:thea_jump/main.dart';

void main() {
  testWidgets('TheaJump shows the start overlay', (WidgetTester tester) async {
    await tester.pumpWidget(const TheaJumpApp());
    await tester.pump();

    expect(find.text('TheaJump'), findsOneWidget);
    expect(find.text('JUMP!'), findsOneWidget);
  });
}

