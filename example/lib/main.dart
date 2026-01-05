import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';

void main() {
  SDUIWidgetRegistry.instance.register(SDUIFieldType.shortText, ({
    required field,
    required formManager,
    onChanged,
  }) {
    return BrandedTextField(
      field: field,
      formManager: formManager,
      onChanged: onChanged,
    );
  }, override: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  tap() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SDUIFrame(
              formJson: {
                "name": "UK (CHAPS) Transfer (clone 1) - Version 1",
                "description":
                    "Collect wire transfer details for US transfers.",
                "pages": [
                  {
                    "id": "019b75d5-210c-71e2-a5dc-c98853dff20f",
                    "key": "account_details",
                    "label": "Account Details",
                    "description": null,
                    "order": 1,
                    "textOnly": false,
                    "hidden": false,
                    "conditionals": [
                      {
                        "then": {
                          "action": "show",
                          "targets": [
                            {
                              "key": "business_details",
                              "type": "section",
                              "pageKey": "account_details",
                            },
                          ],
                        },
                        "when": {
                          "field": "recipient_type",
                          "value": "business",
                          "operator": "is",
                        },
                      },
                    ],
                    "sections": [
                      {
                        "id": "019b75d5-210d-72fc-8041-10a57fee9b6e",
                        "key": "recipient_details",
                        "label": "Recipient",
                        "description": null,
                        "order": 1,
                        "hidden": false,
                        "conditionals": [],
                        "fields": [
                          {
                            "id": "019b75d5-210d-72fc-8041-146953d28884",
                            "key": "transfer_type",
                            "label": "Transfer type",
                            "placeholder": null,
                            "help_text": null,
                            "default": "wire",
                            "type": "hidden",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": [],
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-1baa00be5e9f",
                            "key": "recipient_country",
                            "label": "Recipient Country",
                            "placeholder": null,
                            "help_text": null,
                            "default": null,
                            "type": "country",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": {
                              "code_type": "alpha_2",
                              "allow_countries": ["US"],
                              "exclude_countries": [],
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-1f89facbd070",
                            "key": "currency",
                            "label": "Currency",
                            "placeholder": null,
                            "help_text": null,
                            "default": "USD",
                            "type": "options",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": [],
                            "option_properties": {
                              "type": "select",
                              "data": [
                                {"key": "USD", "value": "USD"},
                              ],
                              "max_select": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-20e9b909c6f4",
                            "key": "recipient_type",
                            "label": "Paying a business?",
                            "placeholder": null,
                            "help_text": null,
                            "default": "personal",
                            "type": "options",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": [],
                            "option_properties": {
                              "type": "radio",
                              "data": [
                                {"key": "personal", "value": "Personal"},
                                {"key": "business", "value": "Business"},
                              ],
                              "max_select": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-240b73c127ad",
                            "key": "account_holder_name",
                            "label": "Full name of the account holder",
                            "placeholder": "Enter full name",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": "name",
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-2b7a0e319388",
                            "key": "recipient_email",
                            "label": "Their email (optional)",
                            "placeholder": "Enter email",
                            "help_text": null,
                            "default": null,
                            "type": "email",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": "email",
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": {
                              "allowed_domains": [],
                              "disallowed_domains": [],
                              "max_length": null,
                            },
                          },
                        ],
                      },
                      {
                        "id": "019b75d5-210d-72fc-8041-2e006f10d935",
                        "key": "wire_details",
                        "label": "Wire details",
                        "description": null,
                        "order": 2,
                        "hidden": false,
                        "conditionals": [],
                        "fields": [
                          {
                            "id": "019b75d5-210d-72fc-8041-311163f90691",
                            "key": "wire_routing_number",
                            "label": "Fedwire routing number",
                            "placeholder": "Enter routing number",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": "999999999",
                              "input_mode": "numeric",
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": 9,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-344acc2b415e",
                            "key": "wire_account_number",
                            "label": "Account number",
                            "placeholder": "Enter account number",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": "numeric",
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": {
                              "map": [
                                {
                                  "path": "data.accountDetails.name",
                                  "target": "account_holder_name",
                                },
                                {
                                  "path": "data.currency.code",
                                  "target": "currency",
                                },
                              ],
                              "when": {
                                "all": [
                                  {
                                    "key": "wire_account_number",
                                    "value": 10,
                                    "operator": "length_gte",
                                  },
                                ],
                              },
                              "method": "POST",
                              "params": [
                                {
                                  "key": "account_number",
                                  "value": "{field:account_number}",
                                },
                                {"key": "bank", "value": "{field:bank}"},
                              ],
                              "enabled": true,
                              "headers": [],
                              "trigger": "debounce",
                              "endpoint": "https://google.com",
                              "overwrite": "empty",
                              "debounce_ms": 600,
                            },
                            "validations": [],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-3be070ce6472",
                            "key": "wire_account_type",
                            "label": "Account type",
                            "placeholder": null,
                            "help_text": null,
                            "default": null,
                            "type": "options",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": true,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": [],
                            "option_properties": {
                              "type": "select",
                              "data": [
                                {"key": "checking", "value": "Checking"},
                                {"key": "savings", "value": "Savings"},
                              ],
                              "max_select": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-3db97a1ecc41",
                            "key": "wire_bank_name",
                            "label": "Bank name (optional)",
                            "placeholder": "Enter bank name",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                        ],
                      },
                      {
                        "id": "019b75d5-210d-72fc-8041-42994f40c4e9",
                        "key": "business_details",
                        "label": "Business details",
                        "description": null,
                        "order": 3,
                        "hidden": true,
                        "conditionals": [],
                        "fields": [
                          {
                            "id": "019b75d5-210d-72fc-8041-47e32f3c3333",
                            "key": "business_name",
                            "label": "Business name",
                            "placeholder": "Enter business name",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [
                              {
                                "rule": "required_if",
                                "params": [
                                  "{field:recipient_type}",
                                  "business",
                                ],
                              },
                            ],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-4a8ed49a5280",
                            "key": "business_address",
                            "label": "Business address",
                            "placeholder": "Enter address",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [
                              {
                                "rule": "required_if",
                                "params": [
                                  "{field:recipient_type}",
                                  "business",
                                ],
                              },
                            ],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-4c5e76eb4183",
                            "key": "business_city",
                            "label": "City",
                            "placeholder": "Enter city",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [
                              {
                                "rule": "required_if",
                                "params": [
                                  "{field:recipient_type}",
                                  "business",
                                ],
                              },
                            ],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-513404306d20",
                            "key": "business_postal_code",
                            "label": "Postal code",
                            "placeholder": "Enter postal code",
                            "help_text": null,
                            "default": null,
                            "type": "short-text",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [
                              {
                                "rule": "required_if",
                                "params": [
                                  "{field:recipient_type}",
                                  "business",
                                ],
                              },
                            ],
                            "constraints": {
                              "min": null,
                              "max": null,
                              "min_length": null,
                              "max_length": null,
                              "accept": [],
                              "max_size": null,
                              "step": null,
                            },
                          },
                          {
                            "id": "019b75d5-210d-72fc-8041-5756dac0a78a",
                            "key": "business_country",
                            "label": "Business country",
                            "placeholder": null,
                            "help_text": null,
                            "default": null,
                            "type": "country",
                            "hidden": false,
                            "visible_if": {"all": [], "any": [], "not": null},
                            "conditionals": [],
                            "readonly": false,
                            "required": false,
                            "ui": {
                              "icon": null,
                              "prefix": null,
                              "suffix": null,
                              "mask": null,
                              "input_mode": null,
                              "autocomplete": null,
                              "multiline_rows": 1,
                              "max_length": null,
                            },
                            "autofill": null,
                            "validations": [
                              {
                                "rule": "required_if",
                                "params": [
                                  "{field:recipient_type}",
                                  "business",
                                ],
                              },
                            ],
                            "constraints": {
                              "code_type": "alpha_2",
                              "allow_countries": [],
                              "exclude_countries": [],
                            },
                          },
                        ],
                      },
                    ],
                  },
                ],
                "meta": {},
              },

              onSubmit: (formData) {
                tap();
                // print('Form submitted with data: $formData');
                // Handle form submission
              },
              onFieldChanged: (key, value) {
                print('Field $key changed to: $value');
                // Handle field changes
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BrandedTextField extends SDUIBaseWidget {
  const BrandedTextField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = formManager.getController(field.key);
    final focusNode = formManager.getFocusNode(field.key);
    final error = formManager.getError(field.key);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(field.label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          enabled: !field.readonly,
          maxLines: field.ui?.multilineRows,
          keyboardType: field.type.textInputType,
          decoration: InputDecoration(
            hintText: field.placeholder ?? field.label,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) => onFieldChanged(value),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
          ),
        ],
      ],
    );
  }
}
