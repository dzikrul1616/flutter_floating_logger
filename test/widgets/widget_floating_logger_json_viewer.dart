import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:floating_logger/src/widgets/floating_logger_json_viewer.dart';

void widgetFloatingLoggerJsonViewerTest() {
  group('JsonViewer Tests', () {
    testWidgets('renders primitive string correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer('test string'),
          ),
        ),
      );

      expect(find.text('"test string",'), findsOneWidget);
    });

    testWidgets('renders primitive number correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(123),
          ),
        ),
      );

      expect(find.text('123,'), findsOneWidget);
    });

    testWidgets('renders empty Map correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer({}),
          ),
        ),
      );

      expect(find.text('{}'), findsOneWidget);
    });

    testWidgets('renders primitive map correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer({'key': 'value'}),
          ),
        ),
      );

      expect(find.textContaining('"key": "value",'), findsOneWidget);
    });

    testWidgets('renders empty List correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer([]),
          ),
        ),
      );

      expect(find.text('[],'), findsOneWidget);
    });

    testWidgets('renders primitive list correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(['item1', 123]),
          ),
        ),
      );

      expect(find.text('"item1",'), findsOneWidget);
      expect(find.text('123,'), findsOneWidget);
    });

    testWidgets('renders nested Map correctly', (WidgetTester tester) async {
      final jsonMap = {
        'user': {'name': 'John', 'age': 30}
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:
                SingleChildScrollView(child: FloatinLoggerJsonViewer(jsonMap)),
          ),
        ),
      );

      // "user": { is now one text widget
      // Use textContaining to find the line
      expect(find.textContaining('"user": {'), findsOneWidget);

      // Inside user: "name": "John" are primitives. now RichText.
      expect(find.textContaining('"name": "John",'), findsOneWidget);
      expect(find.textContaining('"age": 30,'), findsOneWidget);
    });

    testWidgets('renders nested List with collapsible logic',
        (WidgetTester tester) async {
      final jsonList = [
        {"id": 1},
        {"id": 2}
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body:
                SingleChildScrollView(child: FloatinLoggerJsonViewer(jsonList)),
          ),
        ),
      );

      // Initially expanded
      expect(find.textContaining('"id": 1,'), findsNWidgets(1));
      expect(find.textContaining('"id": 2,'), findsNWidgets(1));

      // Collapse first item
      final collapseIcons = find.byIcon(Icons.arrow_drop_down);
      expect(collapseIcons, findsWidgets);

      await tester.tap(collapseIcons.first);
      await tester.pumpAndSettle();

      // Should show collapsed text > {0},
      expect(find.text('> {0},'), findsOneWidget);

      // Expand again
      await tester.tap(find.text('> {0},'));
      await tester.pumpAndSettle();

      expect(find.textContaining('"id": 1,'), findsOneWidget);
    });
    testWidgets('renders null value correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(null),
          ),
        ),
      );

      expect(find.text('null,'), findsOneWidget);
    });

    testWidgets('renders empty complex objects inside Map correctly',
        (WidgetTester tester) async {
      final jsonMap = {
        'empty_map': {},
        'empty_list': [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(jsonMap),
          ),
        ),
      );

      expect(find.text('"empty_map": {},'), findsOneWidget);
      expect(find.text('"empty_list": [],'), findsOneWidget);
    });

    testWidgets('renders search highlighting in primitives',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer('highlight me', searchQuery: 'light'),
          ),
        ),
      );

      // Verify that the text exists (it will be in a RichText)
      expect(find.textContaining('highlight me'), findsOneWidget);

      // We can also verify that there's a RichText with specific styling if we want to be more precise
      final richText = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richText.text as TextSpan;
      bool foundHighlight = false;
      textSpan.visitChildren((span) {
        if (span is TextSpan && span.style?.backgroundColor == Colors.orange) {
          foundHighlight = true;
        }
        return true;
      });
      expect(foundHighlight, isTrue);
    });

    testWidgets('renders search highlighting in Map values',
        (WidgetTester tester) async {
      final jsonMap = {'key': 'highlight me'};
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(jsonMap, searchQuery: 'light'),
          ),
        ),
      );

      expect(find.textContaining('highlight me'), findsOneWidget);
    });

    testWidgets('auto-expands item when search matches content',
        (WidgetTester tester) async {
      final jsonList = [
        {'id': 1, 'name': 'target'}
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(
              jsonList,
              searchQuery: 'target',
              key: UniqueKey(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should be auto-expanded
      final crossFade = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(crossFade.crossFadeState, CrossFadeState.showSecond);
    });

    testWidgets('updates expansion when search query changes',
        (WidgetTester tester) async {
      final jsonList = [
        {'id': 1, 'name': 'specific_val'}
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(
              jsonList,
              searchQuery: 'nomatch',
              key: UniqueKey(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should be collapsed initially
      final crossFade1 = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(crossFade1.crossFadeState, CrossFadeState.showFirst);

      // Update widget with matching query
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FloatinLoggerJsonViewer(
              jsonList,
              searchQuery: 'specific',
              key: UniqueKey(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final crossFade2 = tester.widget<AnimatedCrossFade>(
        find.byType(AnimatedCrossFade),
      );
      expect(crossFade2.crossFadeState, CrossFadeState.showSecond);
    });

    testWidgets('Primitive highlighting and didUpdateWidget coverage',
        (WidgetTester tester) async {
      final content = ["apple", 123, "banana", "apple pie"];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FloatinLoggerJsonViewer(
            content,
            searchQuery: 'apple',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      // Verify multiple highlights for "apple"
      expect(find.textContaining('apple'), findsWidgets);

      // Verify multiple highlights for "apple"
      expect(find.textContaining('apple'), findsWidgets);

      // Verify highlighting style (RichText with orange background somewhere in its spans)
      final highlighted = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final span = widget.text;
          if (span is TextSpan) {
            bool found = false;
            span.visitChildren((child) {
              if (child is TextSpan &&
                  child.style?.backgroundColor == Colors.orange) {
                found = true;
                return false;
              }
              return true;
            });
            return found;
          }
        }
        return false;
      });
      expect(highlighted, findsWidgets);

      // Verify no highlighting when search is empty (covers line 259)
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FloatinLoggerJsonViewer(
            content,
            searchQuery: '',
          ),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.textContaining('apple'), findsWidgets);

      // Should not have orange RichText
      final orangeRichText = find.byWidgetPredicate((widget) {
        if (widget is RichText) {
          final span = widget.text;
          if (span is TextSpan) {
            bool found = false;
            span.visitChildren((child) {
              if (child is TextSpan &&
                  child.style?.backgroundColor == Colors.orange) {
                found = true;
                return false;
              }
              return true;
            });
            return found;
          }
        }
        return false;
      });
      expect(orangeRichText, findsNothing);

      // Test didUpdateWidget coverage by changing searchQuery with a fixed key
      const viewerKey = ValueKey('viewer');
      final complexContent = [
        {"target": "value"}
      ];

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FloatinLoggerJsonViewer(
            complexContent,
            key: viewerKey,
            searchQuery:
                'nomatch', // Start with non-matching search to ensure it is collapsed
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final crossFadeBefore = tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade).first);
      expect(crossFadeBefore.crossFadeState, CrossFadeState.showFirst);

      // Change search to "target" which should trigger expansion in didUpdateWidget (covers line 235-241)
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: FloatinLoggerJsonViewer(
            complexContent,
            key: viewerKey,
            searchQuery: 'target',
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final crossFadeAfter = tester
          .widget<AnimatedCrossFade>(find.byType(AnimatedCrossFade).first);
      expect(crossFadeAfter.crossFadeState, CrossFadeState.showSecond);
    });
  });
}

void main() {
  widgetFloatingLoggerJsonViewerTest();
}
