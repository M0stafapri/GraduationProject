import 'package:jiffy/jiffy.dart';
import '../layout/layout_screen.dart';
import '../modules/screens/plan/createPlanScreen.dart';
import '../modules/screens/plan/search_about_plan.dart';
import '../modules/screens/edit_profile/edit_profile_screen.dart';
import '../modules/screens/sign_screens/signScreens/login.dart';
import '../modules/screens/sign_screens/signScreens/register.dart';
import 'package:flutter/material.dart';

String? userID;
String? firebase_messaging_token;
final String timeNow = Jiffy(DateTime.now()).yMMMMd;
Map<String, Widget Function(BuildContext)> appRoutes = {
  "login_screen": (context) => LoginScreen(),
  "register_screen": (context) => RegisterScreen(),
  "home_layout_screen": (context) => const HomeLayoutScreen(),
  "update_profile_screen": (context) => EditProfileScreen(),
  "create_plan_screen": (context) => CreateplanScreen(),
  "search_about_plan_screen": (context) => const SearchAboutplanScreen(),
};
