import 'package:flutter/material.dart';
import 'package:sdui/sdui.dart';
import 'package:sdui/src/fields/default_country_field.dart';
import 'package:sdui/src/fields/default_date_field.dart';
import 'package:sdui/src/fields/default_email_field.dart';
import 'package:sdui/src/fields/default_file_field.dart';
import 'package:sdui/src/fields/default_number_field.dart';
import 'package:sdui/src/fields/default_password_field.dart';
import 'package:sdui/src/fields/default_phone_field.dart';
import 'package:sdui/src/fields/default_tag_field.dart';
import 'package:sdui/src/fields/default_textfield.dart';
import 'package:sdui/src/fields/default_url_field.dart';
import 'package:sdui/src/fields/default_boolean_field.dart';
import 'package:sdui/src/fields/default_options_field.dart';
import 'package:sdui/src/fields/unknown.dart';

/// A widget that renders different field types based on the field configuration
/// This is the main entry point for rendering all SDUI fields
class SDUIFieldRenderer extends StatefulWidget {
  final SDUIField field;
  final FormManager formManager;
  final Function(String, dynamic)? onChanged;
  final VoidCallback? onAutofillRequested;
  final bool Function()? isAutofillEnabled;

  const SDUIFieldRenderer({
    super.key,
    required this.field,
    required this.formManager,
    this.onChanged,
    this.onAutofillRequested,
    this.isAutofillEnabled,
  });

  @override
  State<SDUIFieldRenderer> createState() => _SDUIFieldRendererState();
}

class _SDUIFieldRendererState extends State<SDUIFieldRenderer> {
  /// Field types that show general error messages below the field
  final allowedTypesGeneralError = ["boolean"];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.formManager,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFieldWidget(),
              if (widget.onAutofillRequested != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: switch (widget.isAutofillEnabled?.call() ??
                        true) {
                      true => widget.onAutofillRequested,
                      _ => null,
                    },
                    child: const Text('Autofill'),
                  ),
                ),
              ],
              if (widget.formManager.hasError(widget.field.key) &&
                  allowedTypesGeneralError.contains(widget.field.type)) ...[
                const SizedBox(height: 4),
                Text(
                  widget.formManager.getError(widget.field.key) ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFieldWidget() {
    // Check if field should be visible based on conditions

    final isHidden = widget.formManager.isHidden(
      widget.field.key,
      fallback: widget.field.hiddenField,
    );

    if (isHidden) return const SizedBox.shrink();
    final customWidget = SDUIWidgetRegistry.instance.create(
      field: widget.field,
      formManager: widget.formManager,
      onChanged: widget.onChanged,
    );

    // If custom widget exists, use it
    if (customWidget != null) return customWidget;

    switch (widget.field.type) {
      // Text field types
      case 'short-text':
      case 'medium-text':
      case 'long-text':
      case 'text':
        return SDUITextField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Email field
      case 'email':
        return SDUIEmailField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // URL field
      case 'url':
        return SDUIURLField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Number field
      case 'number':
        return SDUINumberField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Password field
      case 'password':
        return SDUIPasswordField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Phone field
      case 'phone':
        return SDUIPhoneField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Country field
      case 'country':
        return SDUICountryField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Boolean/checkbox field
      case 'boolean':
        return SDUIBoolField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Options field (radio, dropdown, multi-select)
      case 'options':
        return SDUIOptionsField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Date and datetime fields
      case 'date':
      case 'time':
      case 'datetime':
        return SDUIDateField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      case 'tag':
        return SDUITagField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );
      case 'rating':
      case 'hidden':
      case 'divider':
      case 'spacing':
        return const SizedBox.shrink();

      // File upload fields
      case 'file':
      case 'image':
      case 'video':
      case 'document':
        return SDUIFileField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );

      // Unknown/unsupported field type
      default:
        return SDUIUnknownField(
          field: widget.field,
          formManager: widget.formManager,
          onChanged: widget.onChanged,
        );
    }
  }
}
