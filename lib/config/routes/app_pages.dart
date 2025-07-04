import 'package:get/get.dart';
import 'package:gesturetalk1/views/screen/auth/loginscreen.dart';
import 'package:gesturetalk1/views/screen/auth/signupscreen.dart';
import 'package:gesturetalk1/views/screen/home/dashboardscreen.dart';
import 'package:gesturetalk1/views/screen/home/entertainment_screen.dart';
import 'package:gesturetalk1/views/screen/home/flashlight_alarm_screen.dart';
import 'package:gesturetalk1/views/screen/home/gesture_load.dart';
import 'package:gesturetalk1/views/screen/home/image_to_gesture_screen.dart';
import 'package:gesturetalk1/views/screen/home/offline_mode_screen.dart';
import 'package:gesturetalk1/views/screen/home/offline_select.dart';
import 'package:gesturetalk1/views/screen/home/profilescreen.dart';
import 'package:gesturetalk1/views/screen/home/sos_system_screen.dart';
import 'package:gesturetalk1/views/screen/home/settings_sos_screen.dart';
import 'package:gesturetalk1/views/screen/home/talk_screen.dart';
import 'package:gesturetalk1/views/screen/home/videoplayer_screen.dart';
import 'package:gesturetalk1/views/screen/launch/splashscreen.dart';
import 'package:gesturetalk1/config/routes/app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.splash, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.signup, page: () => const SignupScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => DashboardScreen()),
    GetPage(name: AppRoutes.talk, page: () => GestureTalkScreen()),
    GetPage(
      name: AppRoutes.imageToGesture,
      page: () => const ImageToGestureScreen(),
    ),
    GetPage(name: AppRoutes.offlineMode, page: () => OfflineModeScreen()),
    GetPage(
      name: AppRoutes.entertainment,
      page: () => const EntertainmentScreen(),
    ),
    GetPage(name: AppRoutes.sosSystem, page: () => const SosScreen()),
    GetPage(
      name: AppRoutes.flashlightAlarm,
      page: () => const FlashlightAlarmScreen(),
    ),
    GetPage(name: AppRoutes.offlineSelect, page: () => OfflineSelectScreen()),
    GetPage(name: AppRoutes.gestureLoad, page: () => GestureLoadScreen()),
    GetPage(
      name: AppRoutes.settingsSos,
      page: () => const Settings_Sos_Screen(),
    ),

    // Add parameters for the video player screen
    GetPage(
      name: AppRoutes.videoPlayer,
      page:
          () => VideoPlayerScreen(
            videoId: 'sample_video_id', // Pass actual videoId here
            title: 'Sample Video Title', // Pass actual title here
            relatedVideos: [
              {'videoId': 'related_video_1', 'title': 'Related Video 1'},
              {'videoId': 'related_video_2', 'title': 'Related Video 2'},
            ],
          ),
    ),
    GetPage(name: AppRoutes.profile, page: () => ProfileScreen()),
  ];
}
