import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sebo_digital_app/src/ui_widgets.dart';

void main() {
  testWidgets('renders Sebo Digital brand', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: SeboLogo())),
      ),
    );

    expect(find.text('Sebo Digital'), findsOneWidget);
    expect(find.text('livros usados e achados raros'), findsOneWidget);
  });
}
