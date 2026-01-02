import 'package:flutter/material.dart';

/// FormManager class for managing form state and validation
/// Handles different value types: String, List\<String>, DateTime, etc.
class FormManager extends ChangeNotifier {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, FocusNode> focusNodes = {};
  final Map<String, String?> errorMessages = {};
  final Map<String, String?> selectedCountries = {};
  final Map<String, dynamic> fieldValues = {};
  final Map<String, bool> booleanValues = {};
  final Map<String, List<String>> selectedOptions = {};
  final Map<String, DateTime?> dateValues = {};
  final Map<String, DateTime?> datetimeValues = {};
  final Map<String, List<String>> tagValues = {};
  final Map<String, String?> fileValues = {};
  final Map<String, bool> _hiddenByKey = {};

  /// Updates the selected country for a specific field
  ///
  /// This method stores the selected country value for a form field identified by [key].
  /// It automatically notifies all listeners of the change.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [country]: The country string to store for this field
  void updateSelectedCountry(String key, String? country) {
    selectedCountries[key] = country;
    notifyListeners();
  }

  /// Gets or creates a focus node for a specific field
  ///
  /// This method retrieves an existing FocusNode for the given [key] or creates
  /// a new one if it doesn't exist. FocusNodes are used to manage focus state
  /// for form fields in Flutter.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [FocusNode]: The FocusNode associated with the field, creating one if needed
  FocusNode getFocusNode(String key) {
    return focusNodes.putIfAbsent(key, () => FocusNode());
  }

  /// Gets or creates a text editing controller for a specific field
  ///
  /// This method retrieves an existing TextEditingController for the given [key]
  /// or creates a new one if it doesn't exist. TextEditingControllers are used
  /// to manage text input state for form fields.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [TextEditingController]: The TextEditingController associated with the field
  TextEditingController getController(String key) {
    return controllers.putIfAbsent(key, () => TextEditingController());
  }

  /// Adds an error message for a specific field
  ///
  /// This method associates an error message with a form field identified by [key].
  /// The error will be displayed to the user and can be used for form validation.
  /// Pass null to clear the error for the field.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [error]: The error message to display, or null to clear the error
  void addError(String key, String? error) {
    errorMessages[key] = error;
    notifyListeners();
  }

  /// Gets the error message for a specific field
  ///
  /// This method retrieves the current error message associated with a form field.
  /// Returns null if no error is set for the field.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [String?]: The error message for the field, or null if no error is set
  String? getError(String key) {
    return errorMessages[key];
  }

  /// Sets a field value for a specific form field
  ///
  /// This method stores a dynamic value for a form field identified by [key].
  /// The value can be of any type (String, int, double, etc.) and is used for
  /// storing form data that doesn't fit into text controllers.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [value]: The dynamic value to store for this field
  void setFieldValue(String key, dynamic value) {
    fieldValues[key] = value;
    notifyListeners();
  }

  /// Sets a boolean value for a specific form field
  ///
  /// This method stores a boolean value (true/false) for a form field identified
  /// by [key]. This is typically used for checkboxes, switches, and other
  /// boolean form controls.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [value]: The boolean value to store for this field
  void setBooleanValue(String key, bool value) {
    booleanValues[key] = value;
    notifyListeners();
  }

  /// Sets selected options for a specific form field
  ///
  /// This method stores a list of selected string options for a form field
  /// identified by [key]. This is typically used for dropdowns, multi-select
  /// lists, and other selection-based form controls.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [value]: The list of selected string options for this field
  void setSelectedOption(String key, List<String> value) {
    selectedOptions[key] = value;
    notifyListeners();
  }

  /// Sets multiple selected options for a specific form field
  ///
  /// This method stores multiple selected string values for a form field
  /// identified by [key]. This is typically used for multi-select dropdowns
  /// and other controls that allow multiple selections.
  ///
  /// Note: This method is functionally identical to [setSelectedOption] but
  /// provides semantic clarity for multiple selection scenarios.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [values]: The list of selected string values for this field
  void setMultipleSelectedOptions(String key, List<String> values) {
    selectedOptions[key] = values;
    notifyListeners();
  }

  /// Sets a date value for a specific form field
  ///
  /// This method stores a DateTime value for a form field identified by [key].
  /// This is typically used for date pickers and date input fields.
  /// Pass null to clear the date value.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [date]: The DateTime value to store, or null to clear the date
  void setDateValue(String key, DateTime? date) {
    dateValues[key] = date;
    notifyListeners();
  }

  /// Sets a date and time value for a specific form field
  ///
  /// This method stores a DateTime value (including time) for a form field
  /// identified by [key]. This is typically used for date-time pickers and
  /// datetime input fields that include both date and time components.
  /// Pass null to clear the datetime value.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [datetime]: The DateTime value to store, or null to clear the datetime
  void setDateTimeValue(String key, DateTime? datetime) {
    datetimeValues[key] = datetime;
    notifyListeners();
  }

  /// Sets tag values for a specific form field
  ///
  /// This method stores a list of tag strings for a form field identified by [key].
  /// This is typically used for tag input fields, chip selectors, and other
  /// controls that manage collections of tags or labels.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [tags]: The list of tag strings to store for this field
  void setTagValues(String key, List<String> tags) {
    tagValues[key] = tags;
    notifyListeners();
  }

  /// Sets a file path value for a specific form field
  ///
  /// This method stores a file path string for a form field identified by [key].
  /// This is typically used for file pickers, file upload fields, and other
  /// controls that handle file selection.
  /// Pass null to clear the file value.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  /// - [filePath]: The file path string to store, or null to clear the file
  void setFileValue(String key, String? filePath) {
    fileValues[key] = filePath;
    notifyListeners();
  }

  /// Gets the text value for a specific form field
  ///
  /// This method retrieves the current text value from the TextEditingController
  /// associated with the given [key]. Returns an empty string if no controller
  /// exists for the field or if the controller text is null.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [String]: The text value from the controller, or empty string if not found
  String getValue(String key) {
    return controllers[key]?.text ?? "";
  }

  /// Gets the dynamic field value for a specific form field
  ///
  /// This method retrieves the stored dynamic value for a form field identified
  /// by [key]. The value can be of any type (String, int, double, etc.) that
  /// was previously stored using [setFieldValue].
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [dynamic]: The stored value for the field, or null if not found
  dynamic getFieldValue(String key) {
    return fieldValues[key];
  }

  /// Gets the boolean value for a specific form field
  ///
  /// This method retrieves the stored boolean value for a form field identified
  /// by [key]. Returns false if no boolean value is stored for the field.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [bool]: The stored boolean value, or false if not found
  bool getBooleanValue(String key) {
    return booleanValues[key] ?? false;
  }

  /// Gets the selected options for a specific form field
  ///
  /// This method retrieves the stored list of selected string options for a form
  /// field identified by [key]. Returns null if no options are selected or if
  /// the options list is empty.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [List<String>?]: The list of selected options, or null if none selected
  List<String>? getSelectedOption(String key) {
    final options = selectedOptions[key];
    return options?.isNotEmpty == true ? options! : null;
  }

  /// Gets the selected country for a specific form field
  ///
  /// This method retrieves the stored country string for a form field identified
  /// by [key]. This is typically used for country selection dropdowns and
  /// country picker fields.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [String?]: The selected country string, or null if not set
  String? getSelectedCountry(String key) {
    return selectedCountries[key];
  }

  /// Gets multiple selected options for a specific form field
  ///
  /// This method retrieves the stored list of selected string options for a form
  /// field identified by [key]. Returns an empty list if no options are selected
  /// or if the field doesn't exist. This is useful for multi-select scenarios
  /// where you always need a list result.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [List<String>]: The list of selected options, or empty list if none selected
  List<String> getMultipleSelectedOptions(String key) {
    return selectedOptions[key] ?? [];
  }

  /// Gets the date value for a specific form field
  ///
  /// This method retrieves the stored DateTime value for a form field identified
  /// by [key]. This is typically used for date picker fields and date inputs.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [DateTime?]: The stored date value, or null if not set
  DateTime? getDateValue(String key) {
    return dateValues[key];
  }

  /// Gets the date and time value for a specific form field
  ///
  /// This method retrieves the stored DateTime value (including time) for a form
  /// field identified by [key]. This is typically used for date-time picker fields
  /// and datetime inputs that include both date and time components.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [DateTime?]: The stored datetime value, or null if not set
  DateTime? getDateTimeValue(String key) {
    return datetimeValues[key];
  }

  /// Gets the tag values for a specific form field
  ///
  /// This method retrieves the stored list of tag strings for a form field
  /// identified by [key]. This is typically used for tag input fields, chip
  /// selectors, and other controls that manage collections of tags or labels.
  /// Returns an empty list if no tags are set for the field.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [List<String>]: The list of tag strings, or empty list if none set
  List<String> getTagValues(String key) {
    return tagValues[key] ?? [];
  }

  /// Gets the file path value for a specific form field
  ///
  /// This method retrieves the stored file path string for a form field identified
  /// by [key]. This is typically used for file picker fields, file upload inputs,
  /// and other controls that handle file selection.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [String?]: The stored file path, or null if not set
  String? getFileValue(String key) {
    return fileValues[key];
  }

  /// Checks if a specific form field has an error
  ///
  /// This method checks whether a form field identified by [key] has an associated
  /// error message. Returns true if an error exists and is not empty, false otherwise.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  ///
  /// Returns:
  /// - [bool]: True if the field has an error, false otherwise
  bool hasError(String key) {
    return errorMessages[key] != null && errorMessages[key]!.isNotEmpty;
  }

  /// Checks if the form has any errors across all fields
  ///
  /// This getter returns true if any form field has an associated error message,
  /// false if no errors exist. This is useful for determining overall form validity.
  ///
  /// Returns:
  /// - [bool]: True if any field has an error, false if no errors exist
  bool get hasErrors => errorMessages.isNotEmpty;

  /// Clears the error message for a specific form field
  ///
  /// This method removes the error message associated with a form field identified
  /// by [key]. After calling this method, the field will no longer have an error
  /// state, and listeners will be notified of the change.
  ///
  /// Parameters:
  /// - [key]: The unique identifier for the form field
  void clearError(String key) {
    errorMessages.remove(key);
    notifyListeners();
  }

  /// Clears all error messages from all form fields
  ///
  /// This method removes all error messages from all form fields in the manager.
  /// After calling this method, no fields will have error states, and listeners
  /// will be notified of the change.
  void clearAllErrors() {
    errorMessages.clear();
    notifyListeners();
  }

  /// Gets all form data as a unified map
  ///
  /// This method collects all form field values from all storage types (text controllers,
  /// field values, boolean values, selected options, dates, tags, files, etc.) and
  /// returns them as a single map. This is useful for form submission or data export.
  ///
  /// Returns:
  /// - [Map<String, dynamic>]: A map containing all form field values with their keys
  Map<String, dynamic> getAllFormData() {
    final Map<String, dynamic> formData = {};

    controllers.forEach((key, controller) {
      formData[key] = controller.text;
    });

    formData.addAll(fieldValues);
    formData.addAll(booleanValues);
    formData.addAll(selectedOptions);
    formData.addAll(dateValues);
    formData.addAll(datetimeValues);
    formData.addAll(tagValues);
    formData.addAll(fileValues);

    return formData;
  }

  /// Disposes of all form resources to prevent memory leaks
  ///
  /// This method properly disposes of all TextEditingControllers and FocusNodes
  /// that were created by the FormManager. This should be called when the form
  /// is no longer needed to prevent memory leaks.
  ///
  /// Note: This method should be called in the dispose method of the widget
  /// that uses this FormManager.
  void disposeForm() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    for (var focusNode in focusNodes.values) {
      focusNode.dispose();
    }
  }

  bool isHidden(String key, {bool fallback = false}) {
    return _hiddenByKey[key] ?? fallback;
  }

  void setHidden(String key, bool hidden) {
    if (_hiddenByKey[key] == hidden) return;
    _hiddenByKey[key] = hidden;
    notifyListeners();
  }
}
