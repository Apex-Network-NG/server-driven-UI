import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui/sdui.dart';

void main() {
  tearDown(() {
    SDUIAddressComponentRegistry.instance.clear();
  });

  testWidgets('address field validates as a single field and submits a map', (
    tester,
  ) async {
    Map<String, dynamic>? submittedData;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SDUIFrame(
            formJson: {
              'name': 'Address Test',
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
                      'fields': [_addressFieldJson()],
                    },
                  ],
                },
              ],
              'meta': {},
            },
            onSubmit: (data) {
              submittedData = data;
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), '12 Broad Street');
    await tester.pump();

    expect(find.text('City is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'Lagos');
    await tester.enterText(find.byType(TextFormField).at(3), 'Lagos');
    await tester.enterText(find.byType(TextFormField).at(4), '100001');
    await tester.enterText(find.byType(TextFormField).at(5), 'NG');
    await tester.pump();

    expect(find.text('City is required'), findsNothing);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(
      submittedData,
      equals({
        'recipient_address': {
          'address_line_1': '12 Broad Street',
          'city': 'Lagos',
          'state': 'Lagos',
          'postal_code': '100001',
          'country': 'NG',
        },
      }),
    );
  });

  testWidgets(
    'custom address registry receives bindings and submits canonically',
    (tester) async {
      Map<String, dynamic>? submittedData;

      SDUIAddressComponentRegistry.instance.register((context, addressContext) {
        final addressLine1 = addressContext.component('address_line_1')!;
        final city = addressContext.component('city')!;
        final state = addressContext.component('state')!;
        final postalCode = addressContext.component('postal_code')!;
        final country = addressContext.component('country')!;

        return Column(
          children: [
            TextFormField(
              key: const Key('street'),
              controller: addressLine1.controller,
              focusNode: addressLine1.focusNode,
              onChanged: (value) => addressLine1.onChanged(value),
            ),
            TextFormField(
              key: const Key('city'),
              controller: city.controller,
              focusNode: city.focusNode,
              onChanged: (value) => city.onChanged(value),
            ),
            TextFormField(
              key: const Key('state'),
              controller: state.controller,
              focusNode: state.focusNode,
              onChanged: (value) => state.onChanged(value),
            ),
            TextFormField(
              key: const Key('postal'),
              controller: postalCode.controller,
              focusNode: postalCode.focusNode,
              onChanged: (value) => postalCode.onChanged(value),
            ),
            TextFormField(
              key: const Key('country'),
              controller: country.controller,
              focusNode: country.focusNode,
              onChanged: (value) => country.onChanged(value),
            ),
          ],
        );
      }, override: true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SDUIFrame(
              formJson: {
                'name': 'Address Registry Test',
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
                          _addressFieldJson(countryFieldType: 'country'),
                        ],
                      },
                    ],
                  },
                ],
                'meta': {},
              },
              onSubmit: (data) {
                submittedData = data;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('street')), '10 Marina');
      await tester.enterText(find.byKey(const Key('city')), 'Lagos');
      await tester.enterText(find.byKey(const Key('state')), 'Lagos');
      await tester.enterText(find.byKey(const Key('postal')), '100001');
      await tester.enterText(find.byKey(const Key('country')), 'Nigeria');
      await tester.pump();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(
        submittedData,
        equals({
          'recipient_address': {
            'address_line_1': '10 Marina',
            'city': 'Lagos',
            'state': 'Lagos',
            'postal_code': '100001',
            'country': 'NG',
          },
        }),
      );
    },
  );
}

Map<String, dynamic> _addressFieldJson({String? countryFieldType}) {
  return {
    'id': 'field-1',
    'key': 'recipient_address',
    'label': 'Recipient address',
    'placeholder': 'Street Address',
    'default': null,
    'type': 'address',
    'hidden': false,
    'visible_if': {'all': [], 'any': [], 'not': null},
    'conditionals': [],
    'readonly': false,
    'required': true,
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
    'validation_response': null,
    'validations': [],
    'constraints': [],
    'address_properties': {
      'address_line_1': {
        'key': 'address_line_1',
        'label': 'Street Address',
        'required': true,
      },
      'address_line_2': {
        'key': 'address_line_2',
        'label': 'Apartment/Suite',
        'required': false,
      },
      'city': {'key': 'city', 'label': 'City', 'required': true},
      'state': {'key': 'state', 'label': 'State/Province', 'required': true},
      'postal_code': {
        'key': 'postal_code',
        'label': 'ZIP/Postal Code',
        'required': true,
      },
      'country': {
        'key': 'country',
        'label': 'Country',
        'required': true,
        if (countryFieldType != null) 'field_type': countryFieldType,
      },
    },
  };
}
