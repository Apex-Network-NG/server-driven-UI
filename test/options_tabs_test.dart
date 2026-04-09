import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui/sdui.dart';

void main() {
  setUp(() {
    SDUIWidgetRegistry.instance.clear();
    SDUIOptionsUiRegistry.instance.clear();
    SDUIInitializer.initialize();
  });

  testWidgets('tabs option type updates selected value', (tester) async {
    final formManager = FormManager();

    await tester.pumpWidget(_wrap(_buildTabsForm(), formManager: formManager));
    await tester.pump();

    expect(formManager.getSelectedOption('account_type'), isNull);

    await tester.tap(find.text('Business'));
    await tester.pumpAndSettle();

    expect(formManager.getSelectedOption('account_type'), ['business']);
    expect(formManager.getFieldValue('account_type'), 'business');
  });

  testWidgets('tabs option type uses options ui registry', (tester) async {
    late SDUIOptionsUiContext capturedContext;

    SDUIOptionsUiRegistry.instance.register(SDUIOptionsUiType.tabs, (
      context,
      optionsContext,
    ) {
      capturedContext = optionsContext;
      return Text('custom-tabs:${optionsContext.options.length}');
    }, override: true);

    await tester.pumpWidget(_wrap(_buildTabsForm()));
    await tester.pump();

    expect(find.text('custom-tabs:2'), findsOneWidget);
    expect(capturedContext.uiType, SDUIOptionsUiType.tabs);
    expect(capturedContext.maxSelect, 1);
    expect(capturedContext.selectedKeys, isEmpty);
  });
}

Widget _wrap(SDUIForm form, {ThemeData? theme, FormManager? formManager}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      body: SDUIRenderer(
        form: form,
        formManager: formManager ?? FormManager(),
        showNavigationButtons: false,
      ),
    ),
  );
}

SDUIForm _buildTabsForm() {
  return SDUIForm.fromJson({
    'name': 'Options tabs test',
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
                'id': 'account_type',
                'key': 'account_type',
                'label': 'Account Type',
                'type': 'options',
                'hidden': false,
                'readonly': false,
                'required': false,
                'conditionals': [],
                'visible_if': {'all': [], 'any': [], 'not': null},
                'validations': [],
                'constraints': const <String, dynamic>{},
                'option_properties': const {
                  'type': 'tabs',
                  'data': [
                    {'key': 'personal', 'value': 'Personal'},
                    {'key': 'business', 'value': 'Business'},
                  ],
                },
              },
            ],
          },
        ],
      },
    ],
  });
}
