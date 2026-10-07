import 'package:flutter_test/flutter_test.dart';
import 'package:example/core/packages/packages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Example App Modular UI Tests', () {
    testWidgets('HomePage renders all extracted widgets and components', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pump();

      // Verify Header
      expect(find.text('Floating Logger'), findsOneWidget);
      expect(find.text('v2.1.2'), findsOneWidget);
      expect(find.byType(HomeHeaderWidget), findsOneWidget);

      // Verify Status Card
      expect(find.byType(HomeStatusCardWidget), findsOneWidget);
      expect(find.text('Throttle'), findsOneWidget);
      expect(find.text('Web Inspector'), findsOneWidget);

      // Verify Quick Action Chips
      expect(find.byType(HomeQuickActionsWidget), findsOneWidget);
      expect(find.text('GraphQL'), findsOneWidget);
      expect(find.text('REST Facts'), findsOneWidget);

      // Verify Request List
      expect(find.byType(HomeRequestListWidget), findsOneWidget);
      expect(find.text('GraphQL Query (Countries)'), findsOneWidget);
      expect(find.text('REST API GET (Genderize)'), findsOneWidget);

      // Verify Nav Buttons
      expect(find.byType(HomeNavButtonsWidget), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Catalog UI'), findsOneWidget);
      expect(find.text('Guide'), findsOneWidget);
    });

    testWidgets('DeveloperPage renders tabs and sections', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DeveloperPage(),
        ),
      );

      await tester.pump();

      expect(find.text('Developer Hub'), findsOneWidget);
      expect(find.byType(DeveloperHeaderWidget), findsOneWidget);
      expect(find.byType(DeveloperTabModeWidget), findsOneWidget);
      expect(find.byType(DeveloperContentWidget), findsOneWidget);
      expect(find.byType(DeveloperControlsWidget), findsOneWidget);

      // Switch to Throttle tab
      await tester.tap(find.text('Throttle'));
      await tester.pumpAndSettle();

      expect(find.byType(DeveloperSimulationWidget), findsOneWidget);
      expect(find.text('Normal Connection'), findsOneWidget);
      expect(find.text('Slow 3G Latency'), findsOneWidget);
      expect(find.text('Offline Mode'), findsOneWidget);

      // Switch to Web Inspector tab
      await tester.tap(find.text('Web Inspector'));
      await tester.pumpAndSettle();

      expect(find.byType(DeveloperInspectorWidget), findsOneWidget);
      expect(find.text('Web Inspector Server'), findsOneWidget);

      // Switch to Style tab
      await tester.tap(find.text('Style'));
      await tester.pumpAndSettle();

      expect(find.byType(DeveloperStyleWidget), findsOneWidget);
      expect(find.text('Theme Isolation Mode'), findsOneWidget);
    });

    testWidgets('GuidePage renders code snippets and tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: GuidePage(),
        ),
      );

      await tester.pump();

      expect(find.text('Implementation Guide'), findsOneWidget);
      expect(find.byType(GuideHeaderWidget), findsOneWidget);
      expect(find.byType(GuideTabSelectorWidget), findsOneWidget);
      expect(find.byType(GuideSnippetCardWidget), findsOneWidget);
      expect(find.byType(GuideTipsWidget), findsOneWidget);

      // Tap next category
      await tester.tap(find.text('Network'));
      await tester.pumpAndSettle();

      expect(find.text('2. DioLogger (No-Config)'), findsOneWidget);
    });

    testWidgets('CatalogPage renders header and search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CatalogPage(autoFetch: false),
        ),
      );

      await tester.pump();

      expect(find.text('E-Commerce Store'), findsOneWidget);
      expect(find.byType(CatalogHeaderWidget), findsOneWidget);
      expect(find.byType(CatalogSearchBarWidget), findsOneWidget);
      expect(find.byType(CatalogGridWidget), findsOneWidget);
      expect(find.text('Search products...'), findsOneWidget);
    });
  });

  group('Provider Unit Tests', () {
    test('DeveloperProvider sets simulation and max log size', () {
      final provider = DeveloperProvider()..init();

      expect(provider.currentTab, 0);
      provider.setTab(2);
      expect(provider.currentTab, 2);

      provider.setSimulation(NetworkSimulation.slow3g);
      expect(provider.currentSimulation, NetworkSimulation.slow3g);
      expect(NetworkSimulator.instance.simulationNotifier.value, NetworkSimulation.slow3g);

      provider.setSimulation(NetworkSimulation.normal);
      expect(provider.currentSimulation, NetworkSimulation.normal);

      provider.setMaxLogSize(50);
      expect(provider.maxLogSize, 50);
      expect(DioLogger.instance.logs.maxLogSize, 50);
    });

    test('GuideProvider cycles through tabs', () {
      final provider = GuideProvider();
      expect(provider.selectedTabIndex, 0);
      expect(provider.currentSnippet.category, 'Setup');

      provider.selectTab(3);
      expect(provider.selectedTabIndex, 3);
      expect(provider.currentSnippet.category, 'Desktop');
    });

    test('CatalogProvider filtering and favorite toggle', () {
      final provider = CatalogProvider();
      expect(provider.isFavorite(1), false);
      provider.toggleFavorite(1);
      expect(provider.isFavorite(1), true);
      provider.toggleFavorite(1);
      expect(provider.isFavorite(1), false);
    });
  });
}
