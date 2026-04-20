import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:twothumbs/screens/home/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders brand heading', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('TwoThumbs'), findsOneWidget);
    expect(find.text('Korean Food Guide'), findsOneWidget);
  });
}
