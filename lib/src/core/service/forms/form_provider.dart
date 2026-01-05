import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sdui/src/core/service/dio_service.dart';
import 'package:sdui/src/core/service/forms/form_repo.dart';
import 'package:sdui/src/util/mixins/request_mixin.dart';

class FormProvider extends ChangeNotifier {
  FormProvider._({FormRepo? repo}) : _repo = repo ?? FormRepo(DioService().dio);

  static final FormProvider instance = FormProvider._();

  final FormRepo _repo;
  bool _isLoading = false;
  String? _errorMessage;
  String? _formJsonString;
  Map<String, dynamic>? _formJson;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get formJsonString => _formJsonString;
  Map<String, dynamic>? get formJson => _formJson;

  Future<String?> fetchFormJsonString(String formId) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      notifyListeners();

      final ApiResponse response = await _repo.getForm(formId);
      if (response.isSuccess == true && response.data != null) {
        final jsonString = _stringifyJson(response.data);
        if (jsonString == null) {
          _errorMessage = 'Invalid form payload';
          _setLoading(false);
          notifyListeners();
          return null;
        }

        _formJsonString = jsonString;
        _formJson = _decodeJsonMap(response.data, jsonString);
        _setLoading(false);
        notifyListeners();
        return _formJsonString;
      }

      _errorMessage = response.message ?? 'Failed to load form';
      _setLoading(false);
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return null;
    }
  }

  Future<String?> fetchFormJsonStringFromUrl(String url) async {
    _setLoading(true);
    _errorMessage = null;
    notifyListeners();

    final ApiResponse response = await _repo.getFormFromUrl(url);
    if (response.isSuccess == true && response.data != null) {
      final jsonString = _stringifyJson(response.data);
      if (jsonString == null) {
        _errorMessage = 'Invalid form payload';
        _setLoading(false);
        notifyListeners();
        return null;
      }

      _formJsonString = jsonString;
      _formJson = _decodeJsonMap(response.data, jsonString);
      _setLoading(false);
      notifyListeners();
      return _formJsonString;
    }

    _errorMessage = response.message ?? 'Failed to load form';
    _setLoading(false);
    notifyListeners();
    return null;
  }

  void clear() {
    _formJsonString = null;
    _formJson = null;
    _errorMessage = null;
    _setLoading(false);
    notifyListeners();
  }

  void cancelFetch() => _repo.cancelRequest('getForm');

  String? _stringifyJson(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return null;
      if (_looksLikeJson(trimmed)) return trimmed;
      return jsonEncode(data);
    }
    try {
      return jsonEncode(data);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic>? _decodeJsonMap(dynamic data, String? jsonString) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      return null;
    }
    return null;
  }

  bool _looksLikeJson(String value) =>
      value.startsWith('{') || value.startsWith('[');

  void _setLoading(bool value) {
    _isLoading = value;
  }
}
