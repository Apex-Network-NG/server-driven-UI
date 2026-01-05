import 'package:sdui/src/core/service/service_locator.dart';
import 'package:sdui/src/util/mixins/request_mixin.dart';

class FormRepo extends ServiceLocator with ApiRequestMixin {
  FormRepo(super.dio);

  Future<ApiResponse> getForm(String formId) async {
    return executeRequest(
      requestKey: 'getForm',
      call: (cancelToken) async => await formService().getForm(formId: formId),
    );
  }

  Future<ApiResponse> getFormFromUrl(String url) async {
    return executeRequest(
      requestKey: 'getFormFromUrl',
      call: (cancelToken) async => await formService().getFormFromUrl(url: url),
    );
  }
}
