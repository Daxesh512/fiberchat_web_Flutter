import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:flutter/services.dart';

setStatusBarColor() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: fiberchatPRIMARYcolor,
      statusBarIconBrightness: Brightness.light));
}
