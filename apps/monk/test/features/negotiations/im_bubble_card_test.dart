import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monk_web/core/widgets/im_bubble_card.dart';

void main() {
  testWidgets('bubble sides brand left / creator right', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ImBubbleCard(
                side: ImBubbleSide.brand,
                child: Text('Brand offer'),
              ),
              ImBubbleCard(
                side: ImBubbleSide.creator,
                child: Text('Creator offer'),
              ),
              ImBubbleCard(
                side: ImBubbleSide.brand,
                locked: true,
                child: Text('Locked'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Brand offer'), findsOneWidget);
    expect(find.text('Creator offer'), findsOneWidget);
    expect(find.text('Locked'), findsOneWidget);
    expect(find.byType(ImBubbleCard), findsNWidgets(3));
  });
}
