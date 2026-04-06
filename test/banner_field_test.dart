import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui/sdui.dart';

void main() {
  setUp(() {
    SDUIWidgetRegistry.instance.clear();
    SDUIBannerRegistry.instance.clear();
    SDUIBannerPaletteRegistry.instance.clear();
    SDUIInitializer.initialize();
  });

  testWidgets('default banner field renders and dismisses', (tester) async {
    final form = _buildBannerForm(
      bannerProperties: const {
        'variant': 'info',
        'message': 'Incoming wire fees may apply.',
        'dismissible': true,
      },
    );

    await tester.pumpWidget(_wrap(form));
    await tester.pump();

    expect(find.text('Incoming wire fees may apply.'), findsOneWidget);
    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.text('Incoming wire fees may apply.'), findsNothing);
  });

  testWidgets('default banner applies emphasis to text style', (tester) async {
    final form = _buildBannerForm(
      bannerProperties: const {
        'variant': 'info',
        'message': 'Incoming wire fees may apply.',
        'emphasis': 'strong',
      },
    );

    await tester.pumpWidget(_wrap(form));
    await tester.pump();

    final text = tester
        .widgetList<Text>(find.byType(Text))
        .firstWhere((widget) => widget.data == 'Incoming wire fees may apply.');
    expect(text.style?.fontWeight, FontWeight.w700);
  });

  testWidgets('default banner background changes across variants', (
    tester,
  ) async {
    final customBackground = await _pumpAndGetBackgroundColor(
      tester,
      _buildBannerForm(
        bannerProperties: const {
          'variant': 'custom',
          'message': 'Custom banner',
        },
      ),
    );
    final successBackground = await _pumpAndGetBackgroundColor(
      tester,
      _buildBannerForm(
        bannerProperties: const {
          'variant': 'success',
          'message': 'Success banner',
        },
      ),
    );
    final errorBackground = await _pumpAndGetBackgroundColor(
      tester,
      _buildBannerForm(
        bannerProperties: const {'variant': 'error', 'message': 'Error banner'},
      ),
    );

    expect(customBackground, isNotNull);
    expect(successBackground, isNotNull);
    expect(errorBackground, isNotNull);
    expect(successBackground, isNot(customBackground));
    expect(errorBackground, isNot(customBackground));
    expect(errorBackground, isNot(successBackground));
  });

  testWidgets('banner registry receives parsed properties', (tester) async {
    late SDUIBannerContext capturedContext;
    SDUIBannerRegistry.instance.register((context, bannerContext) {
      capturedContext = bannerContext;
      return Text('custom:${bannerContext.message}');
    }, override: true);

    final form = _buildBannerForm(
      bannerProperties: const {
        'variant': 'warning',
        'custom_variant': 'fee-warning',
        'message': '<b>Fees may apply.</b>',
        'icon': 'warning',
        'is_html': true,
        'emphasis': 'outline',
        'custom_emphasis': 'soft-outline',
        'dismissible': false,
      },
    );

    await tester.pumpWidget(_wrap(form));
    await tester.pump();

    expect(find.text('custom:Fees may apply.'), findsOneWidget);
    expect(capturedContext.variant, 'warning');
    expect(capturedContext.customVariant, 'fee-warning');
    expect(capturedContext.iconName, 'warning');
    expect(capturedContext.isHtml, true);
    expect(capturedContext.emphasis, 'outline');
    expect(capturedContext.customEmphasis, 'soft-outline');
    expect(capturedContext.dismissible, false);
    expect(capturedContext.rawMessage, '<b>Fees may apply.</b>');
    expect(capturedContext.message, 'Fees may apply.');
  });

  testWidgets('banner palette registry overrides default variant colors', (
    tester,
  ) async {
    SDUIBannerPaletteRegistry.instance.register((context, paletteContext) {
      return SDUIBannerVisualStyle(
        backgroundColor: paletteContext.variant == 'success'
            ? Colors.pink
            : paletteContext.defaultVisuals.backgroundColor,
        foregroundColor: paletteContext.defaultVisuals.foregroundColor,
        borderColor: paletteContext.defaultVisuals.borderColor,
        iconBackgroundColor: paletteContext.defaultVisuals.iconBackgroundColor,
        iconColor: paletteContext.defaultVisuals.iconColor,
        borderRadius: paletteContext.borderRadius,
        padding: paletteContext.defaultVisuals.padding,
        spacing: paletteContext.defaultVisuals.spacing,
      );
    }, override: true);

    final successBackground = await _pumpAndGetBackgroundColor(
      tester,
      _buildBannerForm(
        bannerProperties: const {
          'variant': 'success',
          'message': 'Success banner',
        },
      ),
    );

    expect(successBackground, Colors.pink);
  });
}

Widget _wrap(SDUIForm form) {
  return MaterialApp(
    home: Scaffold(
      body: SDUIRenderer(
        form: form,
        formManager: FormManager(),
        showNavigationButtons: false,
      ),
    ),
  );
}

Future<Color?> _pumpAndGetBackgroundColor(
  WidgetTester tester,
  SDUIForm form,
) async {
  await tester.pumpWidget(_wrap(form));
  await tester.pump();

  final container = tester.widget<Container>(
    find.byKey(const ValueKey('sdui_banner_banner_1')),
  );
  final decoration = container.decoration as BoxDecoration?;
  return decoration?.color;
}

SDUIForm _buildBannerForm({required Map<String, dynamic> bannerProperties}) {
  return SDUIForm.fromJson({
    'name': 'Banner test',
    'pages': [
      {
        'id': 'page_1',
        'key': 'page_1',
        'label': '',
        'hidden': false,
        'conditionals': [],
        'sections': [
          {
            'id': 'section_1',
            'key': 'section_1',
            'hidden': false,
            'conditionals': [],
            'fields': [
              {
                'id': 'banner_1',
                'key': 'banner_1',
                'label': 'Banner',
                'type': 'banner',
                'hidden': false,
                'readonly': true,
                'required': false,
                'conditionals': [],
                'visible_if': {'all': [], 'any': [], 'not': null},
                'validations': [],
                'constraints': const <String, dynamic>{},
                'banner_properties': bannerProperties,
              },
            ],
          },
        ],
      },
    ],
  });
}
