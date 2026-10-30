import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:creditsea/controllers/auth_controller.dart';
import 'package:creditsea/controllers/loan_controller.dart';
import 'package:creditsea/core/services/storage_service.dart';
import 'package:creditsea/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    Get.put(AuthController(), permanent: true);
    Get.put(LoanController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('CreditSea smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CreditSeaApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(CreditSeaApp), findsOneWidget);
  });
}
