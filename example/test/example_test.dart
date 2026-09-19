// The example shows the deprecated 0.5.x compatible API on purpose.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_manager_example/main.dart';
import 'package:window_manager_example/window_controller.dart';

// The window itself is not there in a test, so the shell is given a controller
// that never talks to it; what is checked is that the whole surface builds.
void main() {
  testWidgets('the example window builds', (tester) async {
    tester.view.physicalSize = const Size(820, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      WindowManagerExampleApp(
        shell: Shell(controller: WindowController(listen: false)),
      ),
    );
    await tester.pump();

    expect(find.text('Full screen'), findsOneWidget);
    expect(find.text('Prevent close'), findsOneWidget);
  });
}
