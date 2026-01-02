import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui/src/core/service/forms/form_provider.dart';
import 'package:sdui/src/renderer/renderer.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

/// The main SDUI widget frame that can be easily integrated into any widget tree
///
/// Example usage:
/// ```dart
/// SDUIFrame(
///   formId: 'form-id',
///   onSubmit: (data) {
///     print('Form submitted: $data');
///   },
///   onFieldChanged: (key, value) {
///     print('Field $key changed to: $value');
///   },
/// )
/// ```
class SDUIFrame extends StatefulWidget {
  /// The form configuration as JSON
  final Map<String, dynamic>? formJson;
  final String? formId;

  /// Callback when form is submitted
  final Function(Map<String, dynamic>)? onSubmit;

  /// Callback when any field value changes
  final Function(String key, dynamic value)? onFieldChanged;

  /// Whether to show the default navigation buttons
  final bool showNavigationButtons;

  /// Custom navigation builder for pagination
  /// Parameters: context, currentPage, totalPages, previousPage, nextPage, submitForm
  final Widget Function(
    BuildContext,
    int,
    int,
    VoidCallback,
    VoidCallback,
    VoidCallback,
  )?
  navigationBuilder;

  const SDUIFrame({
    super.key,
    this.formJson,
    this.formId,
    this.onSubmit,
    this.onFieldChanged,
    this.showNavigationButtons = true,
    this.navigationBuilder,
  });

  @override
  State<SDUIFrame> createState() => _SDUIFrameState();
}

class _SDUIFrameState extends State<SDUIFrame> {
  late SDUIForm _form;
  bool _isLoading = true;
  String? _error;
  final formManager = FormManager();
  final provider = FormProvider.instance;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() async {
    try {
      setState(() => _isLoading = true);
      if (widget.formJson != null) {
        _form = SDUIForm.fromJson(widget.formJson!);
      } else if (widget.formId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final jsonString = await provider.fetchFormJsonString(widget.formId!);
          if (jsonString != null) {
            final formJson = jsonDecode(jsonString) as Map<String, dynamic>;
            _form = SDUIForm.fromJson(formJson);
          }
        });
      }
      setState(() => _isLoading = false);
    } catch (e, s) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load form: ${e.toString()}, stack: ${s.toString()}';
      });
    }
  }

  @override
  void dispose() {
    formManager.disposeForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SDUIRenderer(
      form: _form,
      formManager: formManager,
      onSubmit: widget.onSubmit,
      onFieldChanged: widget.onFieldChanged,
      showNavigationButtons: widget.showNavigationButtons,
      navigationBuilder: widget.navigationBuilder,
    );
  }
}
