import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/util/validator.dart';

void main() {
  setUp(() {
    SDUIWidgetRegistry.instance.clear();
    SDUIPhoneFieldRegistry.instance.clear();
    SDUIInitializer.initialize();
  });

  testWidgets('phone registry exposes reusable phone context', (tester) async {
    late SDUIPhoneFieldContext capturedContext;

    SDUIPhoneFieldRegistry.instance.register((context, phoneContext) {
      capturedContext = phoneContext;
      return Text(
        'phone:${phoneContext.selectedCountry?.countryCode ?? 'none'}',
      );
    }, override: true);

    await tester.pumpWidget(_wrap(_buildPhoneForm()));
    await tester.pump();
    await tester.pump();

    expect(find.text('phone:KE'), findsOneWidget);
    expect(capturedContext.format, 'international');
    expect(capturedContext.codeType, 'alpha_2');
    expect(
      capturedContext.availableCountries.map((country) => country.countryCode),
      ['KE'],
    );
    expect(capturedContext.selectedCountry?.countryCode, 'KE');

    capturedContext.onChanged('712345678');
    await tester.pump();

    expect(capturedContext.rawValue, '712345678');
    expect(capturedContext.normalizedValue, '+254712345678');
    expect(capturedContext.internationalValue, '+254712345678');
    expect(capturedContext.validate(), isNull);
  });

  test('phone validator enforces allowed country constraints', () {
    final field = _buildPhoneField();
    final formManager = FormManager();
    formManager.updateSelectedCountry(
      field.key,
      CountryForm(countryCode: 'NG', countryName: 'Nigeria'),
    );

    final error = FieldValidator.instance.validateField(
      field: field,
      formManager: formManager,
      value: '8031234567',
      selectedCountryCode: 'NG',
    );

    expect(error, 'Country is not allowed');
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

SDUIForm _buildPhoneForm() {
  return SDUIForm.fromJson({
    'name': 'Phone registry test',
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
                'id': 'account_number',
                'key': 'account_number',
                'label': 'Account Number / Phone Number',
                'placeholder': 'Enter phone number',
                'type': 'phone',
                'hidden': false,
                'readonly': false,
                'required': false,
                'conditionals': [],
                'visible_if': {'all': [], 'any': [], 'not': null},
                'validations': const [],
                'constraints': const {
                  'code_type': 'alpha_2',
                  'allow_countries': ['KE'],
                  'exclude_countries': [],
                  'format': 'international',
                },
                'ui': const {'input_mode': 'tel', 'autocomplete': 'tel'},
              },
            ],
          },
        ],
      },
    ],
  });
}

SDUIField _buildPhoneField() {
  return _buildPhoneForm().form.pages.first.sections.first.fields.first;
}
