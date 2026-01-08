import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui/src/core/service/forms/form_provider.dart';
import 'package:sdui/src/renderer/renderer.dart';
import 'package:sdui/src/util/logger.dart';
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

  /// The form configuration hosted at a URL
  final String? formUrl;

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
    this.formUrl,
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
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final check = _warnMultipleSources();
      if (!check) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          setState(() {
            _error =
                'Multiple form sources provided. Using priority: formJson > formUrl > formId.';
          });
          Logger.logWarning(
            'Multiple form sources provided. Using priority: formJson > formUrl > formId.',
            tag: 'SDUIFrame',
          );
        });
      }

      if (widget.formJson != null) {
        _form = SDUIForm.fromJson(widget.formJson!);
      } else if (widget.formUrl != null) {
        await _loadFormFromUrl(widget.formUrl!);
      } else if (widget.formId != null) {
        await _loadFormFromId(widget.formId!);
      } else {
        throw Exception('No form source provided');
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e, s) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load form: ${e.toString()}, stack: ${s.toString()}';
      });
    }
  }

  bool _warnMultipleSources() {
    final sources = <String>[];
    if (widget.formJson != null) sources.add('formJson');
    if (widget.formUrl != null) sources.add('formUrl');
    if (widget.formId != null) sources.add('formId');
    if (sources.length > 1) return false;

    return true;
  }

  Future<void> _loadFormFromId(String formId) async {
    try {
      final jsonString = await provider.fetchFormJsonString(formId);

      final formJson = _resolveFormJson(jsonString);
      if (formJson == null) {
        throw Exception(provider.errorMessage ?? 'Invalid form payload');
      }
      _form = SDUIForm.fromApiJson(formJson);
    } catch (e, s) {
      Logger.logError(
        'Failed to load form from id: $e, stack: $s',
        tag: 'SDUIFrame',
      );
      throw Exception(e.toString());
    }
  }

  Future<void> _loadFormFromUrl(String url) async {
    final jsonString = await provider.fetchFormJsonStringFromUrl(url);
    final formJson = _resolveFormJson(jsonString);
    if (formJson == null) {
      throw Exception(provider.errorMessage ?? 'Invalid form payload');
    }
    _form = SDUIForm.fromJson(formJson);
  }

  Map<String, dynamic>? _resolveFormJson(String? jsonString) {
    if (jsonString == null) return null;
    if (provider.formJson != null) return provider.formJson;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (e, s) {
      Logger.logError(
        'Failed to resolve form json: $e, stack: $s',
        tag: 'SDUIFrame',
      );
      return null;
    }
    return null;
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
