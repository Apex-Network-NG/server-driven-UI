import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';

class FormView extends StatefulWidget {
  final Map<String, dynamic>? formJson;
  final String? formId;
  final String? formUrl;
  const FormView({super.key, this.formJson, this.formId, this.formUrl});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("Form View"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SDUIFrame(
                formJson: widget.formJson,
                formId: widget.formId,
                formUrl: widget.formUrl,
                onSubmit: (data) async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Form Submitted"),
                      content: Text("Form submitted with data: $data"),
                    ),
                  );
                },
                onFieldChanged: (key, value) {},
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
