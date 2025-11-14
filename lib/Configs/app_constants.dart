//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:flutter/material.dart';

//*--App Colors : Replace with your own colours---
//--unique color for your app --------
final fiberchatPRIMARYcolor = Color(0xff009466);
// you may change this as per your theme. This applies to large buttons, tabs, text heading etc.
final fiberchatSECONDARYolor = Color(0xff00b866);
// you may change this as per your theme. This applies to small buttons, icons & highlights

//--other constant colors--------
final splashBackgroundSolidColor = Color(0xffffffff);
final isShowSplashCustomAssetImage = false;
//if this is 'true', then you should place your SplashScreen Image (Size WxH= 1200x630) in the path : assets/images/splash.jpg
final fiberchatScaffold = Color(0xffeff0f5);
final fiberchatWhite = Color(0xffffffff);
final fiberchatBlack = Color(0xff1E1E1E);
final fiberchatGrey = Color(0xff8596a0);
final fiberchatREDbuttonColor = Color(0xffe90b41);
final fiberchatCHATBUBBLEcolor = Color(0xffe9fedf);
final fiberchatChatbackground = Color(0xffe8ded5);

//*--Agora Configurations---
const Agora_APP_ID = 'PASTE_AGORA_APP_ID';
// Grab it from: https://www.agora.io/en/
const Agora_Primary_Certificate = 'PASTE_AGORA_PRIMARY_CERTIFICATE';
// Enable the primary certificate for the project and copy & paste the value here.
// *--Giphy Configurations---
const GiphyAPIKey = 'PASTE_GIPHY_API_KEY';
// Grab it from: https://developers.giphy.com/

//*--App Configurations---
const Appname = 'Fiberchat Web Demo';
//app name shown evrywhere with the app where required

const AppTagline = '';
//optional description for app (by default a string is set in en.json with keyname "appdescription")
const DEFAULT_COUNTTRYCODE_ISO = 'US';
//default country ISO 2 letter for login screen
const DEFAULT_COUNTTRYCODE_NUMBER = '+1';
//default country code number for login screen
const FONTFAMILY_NAME = '';
// make sure you have registered the font in pubspec.yaml

//--WARNING----- PLEASE DONT EDIT THE BELOW LINES UNLESS YOU ARE A DEVELOPER -------

const AppLogoPathLight = 'assets/images/applogo_light.png';
const AppLogoPathDark = 'assets/images/applogo_dark.png';
