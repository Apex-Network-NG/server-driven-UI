import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sdui/src/config/bottomsheet/bottomsheet_service.dart';
import 'package:sdui/src/fields/field_info_modal.dart';
import 'package:sdui/src/renderer/widget.dart';
import 'package:sdui/src/util/sdui_form.dart';
import 'package:sdui/src/util/validator.dart';

class SDUIFileField extends SDUIBaseStatefulWidget {
  const SDUIFileField({
    super.key,
    required super.field,
    required super.formManager,
    super.onChanged,
  });

  @override
  SDUIBaseState<SDUIFileField> createState() => _SDUIFileFieldState();
}

class _SDUIFileFieldState extends SDUIBaseState<SDUIFileField> {
  final _selectedImages = ValueNotifier<List<PlatformFile>>([]);
  final _picker = FilePicker.platform;
  final _size = ValueNotifier<num>(0);
  bool _isKb = false;
  bool _isMb = false;

  _errorSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: theme.textTheme.bodySmall)),
    );
  }

  _computeSingleFile(PlatformFile file) {
    final path = file.path;
    final maxFileSize = widget.field.constraints?.maxFileSize;
    final maxTotalSize = widget.field.constraints?.maxTotalSize;
    if (path == null) return;
    final s = File(path);
    final l = s.readAsBytesSync().lengthInBytes;
    final kb = l / 1024;
    final mb = kb / 1024;

    final isMaxFileSize = maxFileSize != null && l > maxFileSize;
    final isMaxTotalSize = maxTotalSize != null && l > maxTotalSize;
    if (isMaxFileSize || isMaxTotalSize) {
      _errorSnackBar("File size exceeds the maximum allowed size");
      return;
    }
    _selectedImages.value = [file];
    if (mb > 1) {
      _size.value = (num.tryParse(mb.toStringAsFixed(2)) ?? 0);
      _isMb = true;
      _isKb = false;
    } else {
      _size.value = (num.tryParse(kb.toStringAsFixed(2)) ?? 0);
      _isKb = true;
      _isMb = false;
    }
    if (mounted) setState(() {});
  }

  _computeMultipleFiles(List<PlatformFile> files) {
    final maxFileSize = widget.field.constraints?.maxFileSize;
    final maxTotalSize = widget.field.constraints?.maxTotalSize;
    int totalSize = 0;
    if (files.isEmpty) return;

    for (var file in files) {
      if (file.path == null) continue;
      final s = File(file.path!);
      final l = s.readAsBytesSync().lengthInBytes;
      totalSize += l;
      final isMaxFileSize = maxFileSize != null && l > maxFileSize;
      if (isMaxFileSize) {
        _errorSnackBar("File size exceeds the maximum allowed size");
        return;
      }
    }

    if (maxTotalSize != null && totalSize > maxTotalSize) {
      _errorSnackBar("Total file size exceeds the maximum allowed size");
      return;
    }

    final kb = totalSize / 1024;
    final mb = kb / 1024;

    if (mb > 1) {
      _size.value = (num.tryParse(mb.toStringAsFixed(2)) ?? 0);
      _isMb = true;
      _isKb = false;
    } else {
      _size.value = (num.tryParse(kb.toStringAsFixed(2)) ?? 0);
      _isKb = true;
      _isMb = false;
    }

    final fileMap = List<PlatformFile>.from(_selectedImages.value);
    for (var file in files) {
      final check = fileMap.any((x) => x.name == file.name);
      if (!check) fileMap.add(file);
    }

    _selectedImages.value = fileMap;
    if (mounted) setState(() {});
  }

  _pickImage() async {
    try {
      final allowMultiple = widget.field.constraints?.allowMultiple ?? false;

      final constraints = widget.field.constraints?.accept ?? [];
      final fileTypesExtension = List<String>.from(
        constraints.map((x) {
          return x.split('/').last;
        }).toList(),
      );
      final result = await _picker.pickFiles(
        type: switch (fileTypesExtension.isNotEmpty) {
          true => FileType.custom,
          _ => switch (widget.field.type) {
            "image" => FileType.image,
            "video" => FileType.video,
            "audio" => FileType.audio,
            _ => FileType.any,
          },
        },
        allowMultiple: allowMultiple,
        allowedExtensions: fileTypesExtension,
        withData: true,
      );
      if (result != null) {
        if (allowMultiple) {
          _computeMultipleFiles(result.files);
        } else {
          _computeSingleFile(result.files.first);
        }
      }
    } on PlatformException catch (e) {
      if (!context.mounted || !mounted) return;
      _errorSnackBar(e.message ?? "An error occurred");
    } catch (e) {
      if (!context.mounted || !mounted) return;
      _errorSnackBar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.field.label;
    final helpText = widget.field.helpText;
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (helpText != null) ...[
              SizedBox(width: 5),
              InkWell(
                onTap: () {
                  BottomSheetService.showBottomSheet(
                    context: context,
                    child: FieldInfoModal(text: helpText),
                  );
                },
                child: Icon(
                  Icons.info_rounded,
                  size: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6),
        ValueListenableBuilder(
          valueListenable: _selectedImages,
          builder: (context, value, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  dashPattern: const [7],
                  strokeCap: StrokeCap.round,
                  strokeWidth: 1,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  color: switch (value.isEmpty) {
                    false => theme.colorScheme.primary.withValues(alpha: 0.5),
                    _ => theme.colorScheme.outline.withValues(alpha: 0.5),
                  },
                  radius: const Radius.circular(8),
                ),
                child: switch (value.isEmpty) {
                  true => InkWell(
                    onTap: _pickImage,
                    child: const Center(child: _AddImageComponent()),
                  ),
                  _ => _ImageComponent(
                    image: value,
                    size: _size.value,
                    field: widget.field,
                    type: widget.field.type,
                    isKb: _isKb,
                    isMb: _isMb,
                    onSelectMore: _pickImage,
                  ),
                },
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  String? validateField(value) {
    for (final validation in widget.field.validations ?? []) {
      final result = _validateRule(validation, value);
      if (result != null) {
        widget.formManager.addError(widget.field.key, result);
        return result;
      }
    }
    return null;
  }

  String? _validateRule(SDUIValidation validation, String? value) {
    return FieldValidator.instance.validateRequired(
      validation: validation,
      formManager: widget.formManager,
      textValue: value,
      fieldType: widget.field.type,
    );
  }
}

class _AddImageComponent extends StatefulWidget {
  const _AddImageComponent();

  @override
  State<_AddImageComponent> createState() => __AddImageComponentState();
}

class __AddImageComponentState extends State<_AddImageComponent> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_rounded,
          size: 40,
          color: theme.colorScheme.primary,
        ),

        SizedBox(height: 12),
        Text(
          "Click to upload",
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _ImageComponent extends StatefulWidget {
  final List<PlatformFile> image;
  final num size;
  final bool isKb;
  final bool isMb;
  final String type;
  final SDUIField field;
  final VoidCallback onSelectMore;

  const _ImageComponent({
    required this.image,
    required this.size,
    required this.type,
    required this.isKb,
    required this.isMb,
    required this.field,
    required this.onSelectMore,
  });

  @override
  State<_ImageComponent> createState() => __ImageComponentState();
}

class __ImageComponentState extends State<_ImageComponent> {
  @override
  Widget build(BuildContext context) {
    final allowMultiple = widget.field.constraints?.allowMultiple ?? false;
    final max = widget.field.constraints?.max;
    final canSelectMore =
        allowMultiple && (max == null || widget.image.length < max);
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),

          child: Icon(
            switch (widget.type) {
              ("image") => Icons.image,
              "video" => Icons.video_library,
              _ => Icons.folder,
            },
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                switch (widget.image.length > 1) {
                  true => "${widget.image.length} files",
                  _ => widget.image.first.name,
                },
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
              Text(
                "${widget.size} ${widget.isMb ? "MB" : "KB"}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "100%",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (canSelectMore) ...[
                SizedBox(height: 6),
                InkWell(
                  onTap: widget.onSelectMore,
                  child: Text(
                    "Select more",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(width: 12),
        Icon(
          Icons.check_circle_rounded,
          size: 16,
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}
