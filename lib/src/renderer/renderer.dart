import 'package:flutter/material.dart';
import 'package:sdui/src/renderer/field_renderer.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/sdui_form_manager.dart';

class SDUIRenderer extends StatefulWidget {
  final SDUIForm form;
  final FormManager formManager;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function(String, dynamic)? onFieldChanged;
  final bool showNavigationButtons;
  final Widget Function(
    BuildContext,
    int,
    int,
    VoidCallback,
    VoidCallback,
    VoidCallback,
  )?
  navigationBuilder;

  const SDUIRenderer({
    super.key,
    required this.form,
    required this.formManager,
    this.onSubmit,
    this.onFieldChanged,
    this.showNavigationButtons = true,
    this.navigationBuilder,
  });

  @override
  State<SDUIRenderer> createState() => _SDUIRendererState();
}

class _SDUIRendererState extends State<SDUIRenderer> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeFormFields();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _initializeFormFields() {
    for (final page in widget.form.form.pages) {
      for (final section in page.sections) {
        for (final field in section.fields) {
          _initializeField(field);
        }
      }
    }
  }

  void _initializeField(SDUIField field) {
    if (_isTextField(field.type)) {
      widget.formManager.getController(field.key);
      widget.formManager.getFocusNode(field.key);
    }

    if (field.type == 'boolean') {
      widget.formManager.setBooleanValue(field.key, false);
    }

    if (field.defaultValue != null) {
      widget.formManager.setFieldValue(field.key, field.defaultValue);
    }
  }

  bool _isTextField(String type) {
    return [
      'short-text',
      'medium-text',
      'long-text',
      'text',
      'number',
      'email',
      'phone',
      'url',
      'password',
    ].contains(type);
  }

  void _onFieldChanged(String key, dynamic value) {
    widget.formManager.setFieldValue(key, value);
    widget.onFieldChanged?.call(key, value);
  }

  void _nextPage() {
    if (_currentPageIndex < widget.form.form.pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitForm() {
    final formData = widget.formManager.getAllFormData();
    widget.onSubmit?.call(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPageIndex = index);
            },
            itemCount: widget.form.form.pages.length,
            itemBuilder: (context, pageIndex) {
              final page = widget.form.form.pages[pageIndex];
              return _buildPage(page);
            },
          ),
        ),
        if (widget.showNavigationButtons) ...[
          const SizedBox(height: 12),
          _buildNavigationButtons(),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    // Use custom navigation builder if provided
    if (widget.navigationBuilder != null) {
      return widget.navigationBuilder!(
        context,
        _currentPageIndex,
        widget.form.form.pages.length,
        _previousPage,
        _nextPage,
        _submitForm,
      );
    }

    // Default navigation buttons
    final isLastPage = _currentPageIndex == widget.form.form.pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_currentPageIndex > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentPageIndex > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: isLastPage ? _submitForm : _nextPage,
              child: Text(isLastPage ? 'Submit' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(SDUIPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [...page.sections.map((section) => _buildSection(section))],
      ),
    );
  }

  Widget _buildSection(SDUISection section) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (section.label != null) ...[
          Text(
            section.label!,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...section.fields.map((field) => _buildField(field)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildField(SDUIField field) {
    return SDUIFieldRenderer(
      field: field,
      formManager: widget.formManager,
      onChanged: _onFieldChanged,
    );
  }
}
