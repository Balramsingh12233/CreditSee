import 'package:get/get.dart';
import '../core/network/api_client.dart';
import '../core/services/storage_service.dart';

class CreditScoreController extends GetxController {
  final score = 785.obs;
  final maxScore = 900;
  final minScore = 300;
  final category = 'Excellent'.obs;
  final onTimePayments = '98%'.obs;
  final creditUtilization = '18%'.obs;
  final activeLoansCount = 1.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchScore();
  }

  Future<void> fetchScore() async {
    isLoading.value = true;
    try {
      final user = StorageService.getUser();
      final res = await ApiClient.dio.get(
        '/user/credit-score',
        queryParameters: {'phone': user?.phone ?? '8800642354'},
      );
      if (res.statusCode == 200 && res.data['data'] != null) {
        final d = res.data['data'];
        score.value = d['score'] ?? 785;
        category.value = d['category'] ?? 'Excellent';
        onTimePayments.value = d['onTimePayments'] ?? '98%';
        creditUtilization.value = d['creditUtilization'] ?? '18%';
      }
    } catch (_) {}
    isLoading.value = false;
  }
}
