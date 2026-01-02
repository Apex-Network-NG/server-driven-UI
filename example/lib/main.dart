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
                "name": "Euro Sepa IBAN Form - Version 1",
                "description": "",
                "pages": [
                  {
                    "id": "019b744e-ab87-7253-aceb-7a3f66732656",
                    "key": "page_1",
                    "label": "",
                    "description": null,
                    "order": 1,
                    "textOnly": false,
                    "hidden": false,
                    "conditionals": [],
                    "sections": [
                      {
                        "id": "019b744e-ab87-7253-aceb-7a3f660258e4",
                        "key": "section_1",
                        "label": null,
                        "description": null,
                        "order": 1,
                        "hidden": false,
                        "conditionals": [],
                        "fields": [
                          {
                            "id": "019b2ec6-3c37-74db-a639-5fd955333c3c",
                            "key": "full_name",
                            "label": "Full name of the account holder",
                            "placeholder": "John Doe",
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
                              "multiline_rows": 1,
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
                            "id": "019b2ec7-2609-71b1-9a56-e4b0fc0ecd69",
                            "key": "iban",
                            "label": "IBAN",
                            "placeholder": "e.g. DE44 0000 0000 0000 0000 00",
                            "help_text":
                                "IBANs are international bank account numbers used for transfers abroad. They always begin with a two-letter country code, like DE for Germany.",
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
                              "multiline_rows": 1,
                            },
                            "validations": [
                              {
                                "rule": "regex",
                                "params": [
                                  r"^(?:((?:IT|SM)\d{2}[A-Z]{1}\d{22})|(NL\d{2}[A-Z]{4}\d{10})|(LV\d{2}[A-Z]{4}\d{13})|((?:BG|GB|IE)\d{2}[A-Z]{4}\d{14})|(GI\d{2}[A-Z]{4}\d{15})|(RO\d{2}[A-Z]{4}\d{16})|(MT\d{2}[A-Z]{4}\d{23})|(NO\d{13})|((?:DK|FI|FO)\d{16})|((?:SI)\d{17})|((?:AT|EE|LU|LT)\d{18})|((?:HR|LI|CH)\d{19})|((?:DE)\d{20})|((?:CZ|ES|SK|SE)\d{22})|(PT\d{23})|((?:IS)\d{24})|((?:BE)\d{14})|((?:FR|MC|GR)\d{25})|((?:PL|HU|CY)\d{26}))$",
                                ],
                                "message": null,
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
                            "id": "019b2ee2-0351-7057-8da9-0e2688d56fa7",
                            "key": "email",
                            "label": "Enter their email (optional)",
                            "placeholder": "Email address",
                            "help_text": null,
                            "default": null,
                            "type": "text",
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
                              "multiline_rows": 2,
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
