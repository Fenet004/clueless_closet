import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:clueless_closet/widgets/selection_chips.dart';

void main() {
  testWidgets(
    'shows title and all options',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SelectionChips(
              title:
                  'Where are you going?',
              options: const [
                'Everyday',
                'Work',
                'Party',
              ],
              selectedValue:
                  'Everyday',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(
        find.text(
          'Where are you going?',
        ),
        findsOneWidget,
      );

      expect(
        find.text('Everyday'),
        findsOneWidget,
      );

      expect(
        find.text('Work'),
        findsOneWidget,
      );

      expect(
        find.text('Party'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'calls onSelected when a new option is tapped',
    (
        WidgetTester tester,
    ) async {
        String? selected;

        await tester.pumpWidget(
        MaterialApp(
            home: Scaffold(
            body: SelectionChips(
                title: 'Season',
                options: const [
                'All',
                'Summer',
                'Winter',
                ],
                selectedValue: 'All',
                onSelected: (value) {
                selected = value;
                },
            ),
            ),
        ),
        );

        await tester.tap(
        find.text(
            'Summer',
        ),
        );

        await tester.pump();

        expect(
        selected,
        'Summer',
        );
    },
    );
}