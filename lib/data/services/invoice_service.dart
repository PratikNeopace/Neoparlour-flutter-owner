import 'package:dio/dio.dart';
import 'package:neo_parlour_owner/core/api_client.dart';
import 'package:neo_parlour_owner/core/utils/download_helper.dart';

class InvoiceService {
  final ApiClient _apiClient = ApiClient();

  Future<void> downloadInvoice(int appointmentId) async {
    try {
      final response = await _apiClient.dio.get(
        'invoices/appointment/$appointmentId',
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      final contentType = response.headers.value('content-type') ?? 'application/pdf';
      String extension = 'pdf';
      if (contentType.contains('png')) extension = 'png';
      if (contentType.contains('jpeg') || contentType.contains('jpg')) extension = 'jpg';
      if (contentType.contains('json')) extension = 'json';

      await downloadFileBytes(response.data as List<int>, 'invoice_$appointmentId.$extension');
      
    } on DioException catch (e) {
      throw Exception(ApiClient.handleDioError(e));
    } catch (e) {
      throw Exception('Failed to download invoice: $e');
    }
  }
}
