import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';

void main() {
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
                "name": "Untitled Form",
                "description": "",
                "pages": [
                  {
                    "id": "019b36ff-3f20-702b-a11f-54dddb450d10",
                    "key": "page_1",
                    "label": "Page 1",
                    "sections": [
                      {
                        "id": "019b36ff-3f20-702b-a11f-5ab9200d5401",
                        "key": "section_1",
                        "label": "Section 1",
                        "fields": [
                          {
                            "id": "019b36ff-610b-711f-a108-9482f179cf5e",
                            "type": "short-text",
                            "key": "short_text_1",
                            "label": "Short Text",
                            "required": false,
                            "readonly": false,
                            "placeholder": "Enter text",
                            "validations": [
                              {
                                "rule": "min",
                                "message": null,
                                "params": ["15"],
                              },
                            ],
                            "constraints": {
                              "min_length": 10,
                              "max_length": 100,
                            },
                            "help_text": "Enter text",
                          },
                          {
                            "id": "019b36ff-fb77-7233-b99c-95a01ee5b06b",
                            "type": "date",
                            "key": "date_1",
                            "label": "Date",
                            "required": false,
                            "readonly": false,
                            "validations": [
                              {
                                "rule": "before",
                                "message": null,
                                "params": ["2015-12-24"],
                              },
                            ],
                            "placeholder": "Enter Date",
                            "help_text": "Enter date",
                          },
                        ],
                      },
                    ],
                  },
                ],
                "meta": {},
              },
              onSubmit: (formData) {
                print('Form submitted with data: $formData');
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

class SizedBoxWidget extends SDUIBaseWidget {
  const SizedBoxWidget({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }

  @override
  String? validateField(value) {
    return null;
  }
}
