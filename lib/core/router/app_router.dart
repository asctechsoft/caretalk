import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:care_talk/features/splash/splash_screen.dart';
import 'package:care_talk/features/onboarding/onboarding_screen.dart';
import 'package:care_talk/features/auth/login_screen.dart';
import 'package:care_talk/features/auth/register_screen.dart';
import 'package:care_talk/features/chat/chat_screen.dart';
import 'package:care_talk/features/patient_info/patient_info_screen.dart';
import 'package:care_talk/features/patient_list/patient_list_screen.dart';
import 'package:care_talk/features/home/home_screen.dart';
import 'package:care_talk/features/auth/role_selection_screen.dart';
import 'package:care_talk/features/home/patient_home_screen.dart';
import 'package:care_talk/features/chat/patient_chat_screen.dart';
import 'package:care_talk/features/auth/patient_landing_screen.dart';
import 'package:care_talk/features/chat/symptom_assessment_screen.dart';
import 'package:care_talk/features/chat/request_success_screen.dart';
import 'package:care_talk/features/chat/patient_doctor_chat_screen.dart';
import 'package:care_talk/features/doctor_supplement_info/doctor_supplement_info_screen.dart';

/// Quản lý routing cho toàn bộ ứng dụng
class AppRouter {
  AppRouter._();

  // ─── Route Names ───────────────────────────────────────────────────
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String chat = 'chat';
  static const String patientInfo = 'patient-info';
  static const String patientList = 'patient-list';
  static const String roleSelection = 'role-selection';
  static const String patientHome = 'patient-home';
  static const String patientChat = 'patient-chat';
  static const String patientLanding = 'patient-landing';
  static const String symptomAssessment = 'symptom-assessment';
  static const String requestSuccess = 'request-success';
  static const String patientDoctorChat = 'patient-doctor-chat';
  static const String doctorSupplementInfo = 'doctor-supplement-info';

  // ─── Route Paths ───────────────────────────────────────────────────
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/home';
  static const String chatPath = '/chat';
  static const String patientInfoPath = '/patient-info';
  static const String patientListPath = '/patient-list';
  static const String roleSelectionPath = '/role-selection';
  static const String patientHomePath = '/patient-home';
  static const String patientChatPath = '/patient-chat';
  static const String patientLandingPath = '/patient-landing';
  static const String symptomAssessmentPath = '/symptom-assessment';
  static const String requestSuccessPath = '/request-success';
  static const String patientDoctorChatPath = '/patient-doctor-chat';
  static const String doctorSupplementInfoPath = '/doctor-supplement-info';

  // ─── Navigator Key ─────────────────────────────────────────────────
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  // ─── Router Configuration ─────────────────────────────────────────
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: splashPath,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),

    // Redirect logic - xử lý auth guard
    redirect: (context, state) {
      // TODO: Thêm logic kiểm tra auth state ở đây
      // final isLoggedIn = authProvider.isLoggedIn;
      // final isOnSplash = state.matchedLocation == splashPath;
      // final isOnAuth = state.matchedLocation == loginPath ||
      //     state.matchedLocation == registerPath;
      //
      // if (!isLoggedIn && !isOnSplash && !isOnAuth) {
      //   return loginPath;
      // }
      return null;
    },
  );

  // ─── Routes ────────────────────────────────────────────────────────
  static final List<RouteBase> _routes = [
    GoRoute(
      path: splashPath,
      name: splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: onboardingPath,
      name: onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: roleSelectionPath,
      name: roleSelection,
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: loginPath,
      name: login,
      builder: (context, state) {
        final role = state.uri.queryParameters['role'];
        return LoginScreen(role: role);
      },
    ),
    GoRoute(
      path: registerPath,
      name: register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: homePath,
      name: home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: chatPath,
      name: chat,
      builder: (context, state) {
        final sessionId = state.uri.queryParameters['sessionId'];
        return ChatScreen(sessionId: sessionId);
      },
    ),
    GoRoute(
      path: patientInfoPath,
      name: patientInfo,
      builder: (context, state) {
        final patientId = state.uri.queryParameters['patientId'];
        return PatientInfoScreen(patientId: patientId);
      },
    ),
    GoRoute(
      path: patientListPath,
      name: patientList,
      builder: (context, state) => const PatientListScreen(),
    ),
    GoRoute(
      path: patientHomePath,
      name: patientHome,
      builder: (context, state) => const PatientHomeScreen(),
    ),
    GoRoute(
      path: patientChatPath,
      name: patientChat,
      builder: (context, state) => const PatientChatScreen(),
    ),
    GoRoute(
      path: patientLandingPath,
      name: patientLanding,
      builder: (context, state) => const PatientLandingScreen(),
    ),
    GoRoute(
      path: symptomAssessmentPath,
      name: symptomAssessment,
      builder: (context, state) {
        final severityStr = state.uri.queryParameters['severity'] ?? 'low';
        final severity = AssessmentSeverity.values.firstWhere(
          (e) => e.name == severityStr,
          orElse: () => AssessmentSeverity.low,
        );
        return SymptomAssessmentScreen(severity: severity);
      },
    ),
    GoRoute(
      path: requestSuccessPath,
      name: requestSuccess,
      builder: (context, state) => const RequestSuccessScreen(),
    ),
    GoRoute(
      path: patientDoctorChatPath,
      name: patientDoctorChat,
      builder: (context, state) => const PatientDoctorChatScreen(),
    ),
    GoRoute(
      path: doctorSupplementInfoPath,
      name: doctorSupplementInfo,
      builder: (context, state) => const DoctorSupplementInfoScreen(),
    ),
  ];
}

/// Màn hình lỗi khi route không tìm thấy
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Trang không tồn tại',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Đã có lỗi xảy ra',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRouter.homePath),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
