import 'package:get/get.dart';
import '../views/splash/splash_view.dart';
import '../views/auth/onboarding_view.dart';
import '../views/auth/otp_view.dart';
import '../views/auth/create_password_view.dart';
import '../views/auth/sign_in_view.dart';
import '../views/registration/personal_details_view.dart';
import '../views/loan/loan_calculator_view.dart';
import '../views/loan/loan_offer_view.dart';
import '../views/loan/application_status_view.dart';
import '../views/dashboard/home_dashboard_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String otp = '/otp';
  static const String createPassword = '/create-password';
  static const String signIn = '/sign-in';
  static const String personalDetails = '/personal-details';
  static const String loanCalculator = '/loan-calculator';
  static const String loanOffer = '/loan-offer';
  static const String applicationStatus = '/application-status';
  static const String homeDashboard = '/dashboard';

  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: otp,
      page: () => const OtpView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: createPassword,
      page: () => const CreatePasswordView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: signIn,
      page: () => const SignInView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: personalDetails,
      page: () => const PersonalDetailsView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: loanCalculator,
      page: () => const LoanCalculatorView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: loanOffer,
      page: () => const LoanOfferView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: applicationStatus,
      page: () => const ApplicationStatusView(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: homeDashboard,
      page: () => const HomeDashboardView(),
      transition: Transition.fadeIn,
    ),
  ];
}
