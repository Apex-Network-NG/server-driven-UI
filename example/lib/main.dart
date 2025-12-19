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
                    "id": "019b373d-b562-740e-9373-539e94c8d993",
                    "key": "page_1",
                    "label": "Page 1",
                    "sections": [
                      {
                        "id": "019b373d-b562-740e-9373-55daaef54cdf",
                        "key": "section_1",
                        "label": "Section 1",
                        "fields": [
                          {
                            "id": "019b373d-d6f4-70f3-b78f-a7422b78d531",
                            "type": "short-text",
                            "key": "short_text_1",
                            "label": "Short Text",
                            "required": false,
                            "readonly": false,
                            "validations": [],
                          },
                          {
                            "id": "019b373e-4369-760b-9d5d-56797aee5b7f",
                            "type": "number",
                            "key": "number_1",
                            "label": "Number",
                            "required": false,
                            "readonly": false,
                            "default": "{field:hidden_1}",
                            "validations": [],
                          },
                          {
                            "id": "019b3746-9d9f-72f0-8eb6-0eff225a4bc9",
                            "type": "hidden",
                            "key": "hidden_1",
                            "label": "Test",
                            "required": false,
                            "readonly": false,
                            "default": "{field:short_text_1}",
                            "validations": [],
                          },
                          {
                            "id": "019b3755-db68-72b0-9f92-9e6ebb89d6a6",
                            "type": "file",
                            "key": "file_1",
                            "label": "File",
                            "required": false,
                            "readonly": false,
                            "constraints": {
                              "accept": [],
                              "allow_multiple": false,
                              "min": 1,
                            },
                            "default": "{field:hidden_1}",
                            "validations": [],
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
