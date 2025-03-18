import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xchange_learn/main.dart';

void main() {
  testWidgets('XChangeLearnApp smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(XChangeLearnApp());

    // Verify the presence of the title.
    expect(find.text('What skill can you teach?'), findsOneWidget);

    // Verify the presence of the input field.
    expect(find.byType(TextField), findsOneWidget);

    // Enter a skill into the input field.
    await tester.enterText(find.byType(TextField), 'Dart Programming');

    // Tap the 'Add' button.
    await tester.tap(find.text('Add'));
    await tester.pump();

    // Verify the new skill is added to the list.
    expect(find.text('Dart Programming'), findsOneWidget);

    // Tap on the added skill to navigate to the chat screen.
    await tester.tap(find.text('Dart Programming'));
    await tester.pumpAndSettle();

    // Verify the chat screen is displayed with the correct title.
    expect(find.text('Chat about Dart Programming'), findsOneWidget);
  });
}
