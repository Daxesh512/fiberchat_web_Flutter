//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';

import 'package:camera/camera.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/homepage/initialize.dart';
import 'package:fiberchat_web/Screens/splash_screen/splash_screen.dart';
import 'package:fiberchat_web/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat_web/Services/Providers/LazyLoadingChatProvider.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/Providers/TimerProvider.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/Providers/seen_provider.dart';
import 'package:fiberchat_web/Services/localization/demo_localization.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Services/Providers/DownloadInfoProvider.dart';
import 'package:fiberchat_web/Services/Providers/call_history_provider.dart';
import 'package:fiberchat_web/Services/Providers/user_provider.dart';
import 'package:fiberchat_web/Utils/setStatusBarColor.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<CameraDescription> cameras = <CameraDescription>[];

void main() async {
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();

  binding.renderView.automaticSystemUiAdjustment = false;

  setStatusBarColor();

  runApp(OverlaySupport(child: FiberchatWrapper()));
}

class FiberchatWrapper extends StatefulWidget {
  const FiberchatWrapper({Key? key}) : super(key: key);
  static void setLocale(BuildContext context, Locale newLocale) {
    _FiberchatWrapperState state =
        context.findAncestorStateOfType<_FiberchatWrapperState>()!;
    state.setLocale(newLocale);
  }

  @override
  _FiberchatWrapperState createState() => _FiberchatWrapperState();
}

class _FiberchatWrapperState extends State<FiberchatWrapper> {
  Locale? _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  final Future<FirebaseApp> _initialization = Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "Paste_apiKey_here",
        authDomain: "Paste_authDomain_here",
        projectId: "Paste_projectId_here",
        storageBucket: "Paste_storageBucket_here",
        messagingSenderId: "Paste_messagingSenderId_here",
        appId: "Paste_appId_here",
        measurementId: "Paste_measurementId_here"),
  );
  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  MaterialColor getMaterialColor(Color color) {
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseGroupServices firebaseGroupServices = FirebaseGroupServices();
    final FirebaseBroadcastServices firebaseBroadcastServices =
        FirebaseBroadcastServices();
    if (this._locale == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Splashscreen(
          isShowOnlySpinner: true,
        ),
      );
    } else {
      return FutureBuilder(
          future: _initialization,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Splashscreen(
                  isShowOnlySpinner: true,
                ),
              );
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return FutureBuilder(
                  future: SharedPreferences.getInstance(),
                  builder:
                      (context, AsyncSnapshot<SharedPreferences> snapshot) {
                    if (snapshot.hasData) {
                      return MultiProvider(
                        providers: [
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE()),
                          //---

                          ChangeNotifierProvider(
                              create: (_) =>
                                  SmartContactProviderWithLocalStoreData()),
                          ChangeNotifierProvider(
                              create: (_) => TimerProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforGROUPCHAT()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderMESSAGESforLAZYLOADINGCHAT()),

                          ChangeNotifierProvider(create: (_) => Observer()),
                          Provider(create: (_) => SeenProvider()),
                          ChangeNotifierProvider(
                              create: (_) => DownloadInfoprovider()),
                          ChangeNotifierProvider(create: (_) => UserProvider()),
                          ChangeNotifierProvider(
                              create: (_) =>
                                  FirestoreDataProviderCALLHISTORY()),
                          ChangeNotifierProvider(
                              create: (_) => CurrentChatPeer()),
                        ],
                        child: StreamProvider<List<BroadcastModel>>(
                          initialData: [],
                          create: (BuildContext context) =>
                              firebaseBroadcastServices.getBroadcastsList(
                                  snapshot.data!.getString(Dbkeys.phone) ?? ''),
                          child: StreamProvider<List<GroupModel>>(
                            initialData: [],
                            create: (BuildContext context) =>
                                firebaseGroupServices.getGroupsList(
                                    snapshot.data!.getString(Dbkeys.phone) ??
                                        ''),
                            child: MaterialApp(
                              builder: (BuildContext? context, Widget? widget) {
                                ErrorWidget.builder =
                                    (FlutterErrorDetails errorDetails) {
                                  return CustomError(
                                      errorDetails: errorDetails);
                                };

                                return widget!;
                              },
                              theme: ThemeData(
                                  primarySwatch:
                                      getMaterialColor(fiberchatPRIMARYcolor),
                                  fontFamily: FONTFAMILY_NAME == ''
                                      ? null
                                      : FONTFAMILY_NAME,
                                  primaryColor: fiberchatPRIMARYcolor,
                                  primaryColorLight: fiberchatPRIMARYcolor,
                                  indicatorColor: fiberchatPRIMARYcolor),
                              title: Appname,
                              debugShowCheckedModeBanner: false,
                              home: Initialize(
                                app: K11,
                                doc: K9,
                                prefs: snapshot.data!,
                                id: snapshot.data!.getString(Dbkeys.phone),
                              ),

                              // ignore: todo
                              //TODO:---- All localizations settings----
                              locale: _locale,
                              supportedLocales: supportedlocale,
                              localizationsDelegates: [
                                DemoLocalization.delegate,
                                GlobalMaterialLocalizations.delegate,
                                GlobalWidgetsLocalizations.delegate,
                                GlobalCupertinoLocalizations.delegate,
                              ],
                              localeResolutionCallback:
                                  (locale, supportedLocales) {
                                for (var supportedLocale in supportedLocales) {
                                  if (supportedLocale.languageCode ==
                                          locale!.languageCode &&
                                      supportedLocale.countryCode ==
                                          locale.countryCode) {
                                    return supportedLocale;
                                  }
                                }
                                return supportedLocales.first;
                              },
                              //--- All localizations settings ended here----
                            ),
                          ),
                        ),
                      );
                    }
                    return MultiProvider(
                      providers: [
                        ChangeNotifierProvider(create: (_) => UserProvider()),
                      ],
                      child: MaterialApp(
                          theme: ThemeData(
                              fontFamily: FONTFAMILY_NAME == ''
                                  ? null
                                  : FONTFAMILY_NAME,
                              primaryColor: fiberchatPRIMARYcolor,
                              primaryColorLight: fiberchatPRIMARYcolor,
                              indicatorColor: fiberchatPRIMARYcolor),
                          debugShowCheckedModeBanner: false,
                          home: Splashscreen()),
                    );
                  });
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Splashscreen(),
            );
          });
    }
  }
}

class CustomError extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomError({
    Key? key,
    required this.errorDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0,
      width: 0,
    );
  }
}

void logError(String code, String? message) {
  if (message != null) {
    // print('Error: $code\nError Message: $message');
  } else {
    // print('Error: $code');
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
