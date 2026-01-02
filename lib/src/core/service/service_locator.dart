import 'package:dio/dio.dart';
import 'package:sdui/src/core/service/forms/form_service.dart';

abstract class ServiceLocator {
  final Dio dio;
  ServiceLocator(this.dio);

  FormService formService() => FormService(dio);
}
