import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui/sdui.dart';

void main() {
  setUp(() {
    SDUIWidgetRegistry.instance.clear();
    SDUIInitializer.initialize();
  });

  testWidgets('banner top spacing defaults to 12', (tester) async {
    await tester.pumpWidget(_wrap(_buildSpacingForm()));
    await tester.pump();

    final fieldRect = tester.getRect(find.byType(TextFormField));
    final bannerRect = tester.getRect(
      find.byKey(const ValueKey('sdui_banner_banner_1')),
    );

    expect((bannerRect.top - fieldRect.bottom).round(), 12);
  });

  testWidgets('banner top spacing is theme configurable', (tester) async {
    final theme = ThemeData(
      extensions: <ThemeExtension<dynamic>>[
        SDUITheme.fromTheme(ThemeData.light()).copyWith(bannerTopSpacing: 24),
      ],
    );

    await tester.pumpWidget(_wrap(_buildSpacingForm(), theme: theme));
    await tester.pump();

    final fieldRect = tester.getRect(find.byType(TextFormField));
    final bannerRect = tester.getRect(
      find.byKey(const ValueKey('sdui_banner_banner_1')),
    );

    expect((bannerRect.top - fieldRect.bottom).round(), 24);
  });
}

Widget _wrap(SDUIForm form, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: SDUIRenderer(
        form: form,
        formManager: FormManager(),
        showNavigationButtons: false,
      ),
    ),
  );
}

SDUIForm _buildSpacingForm() {
  return SDUIForm.fromJson({
    'name': 'Banner spacing test',
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
                'id': 'field_1',
                'key': 'field_1',
                'label': 'Account number',
                'placeholder': 'Enter account number',
                'type': 'short-text',
                'hidden': false,
                'readonly': false,
                'required': false,
                'conditionals': [],
                'visible_if': {'all': [], 'any': [], 'not': null},
                'validations': [],
                'constraints': const <String, dynamic>{},
              },
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
                'banner_properties': const {
                  'variant': 'info',
                  'message': 'Incoming wire fees may apply.',
                },
              },
            ],
          },
        ],
      },
    ],
  });
}
