import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui/sdui.dart';

void main() {
  testWidgets('applies external field errors and clears them on change', (
    tester,
  ) async {
    final formManager = FormManager();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SDUIFrame(
            formManager: formManager,
            formJson: {
              'name': 'External Error Test',
              'pages': [
                {
                  'id': 'page-1',
                  'key': 'page_1',
                  'label': '',
                  'hidden': false,
                  'conditionals': [],
                  'sections': [
                    {
                      'id': 'section-1',
                      'key': 'section_1',
                      'label': null,
                      'hidden': false,
                      'conditionals': [],
                      'fields': [
                        {
                          'id': 'field-1',
                          'key': 'iban',
                          'label': 'IBAN',
                          'placeholder': 'Enter IBAN',
                          'default': null,
                          'type': 'short-text',
                          'hidden': false,
                          'visible_if': {'all': [], 'any': [], 'not': null},
                          'conditionals': [],
                          'readonly': false,
                          'required': false,
                          'ui': {
                            'icon': null,
                            'prefix': null,
                            'suffix': null,
                            'mask': null,
                            'input_mode': null,
                            'autocomplete': null,
                            'multiline_rows': 1,
                            'max_length': null,
                          },
                          'autofill': null,
                          'validations': [],
                          'constraints': [],
                        },
                      ],
                    },
                  ],
                },
              ],
              'meta': {},
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    formManager.applyErrorPayload({
      'status': 'error',
      'message':
          'Unable to validate IBAN. Please check the number and try again..',
      'errors': {
        'iban': [
          'Unable to validate IBAN. Please check the number and try again..',
        ],
      },
    });
    await tester.pump();

    expect(
      find.text(
        'Unable to validate IBAN. Please check the number and try again..',
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextFormField),
      'DE89370400440532013000',
    );
    await tester.pump();

    expect(
      find.text(
        'Unable to validate IBAN. Please check the number and try again..',
      ),
      findsNothing,
    );
  });
}
