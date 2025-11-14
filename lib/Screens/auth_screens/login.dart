//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Screens/homepage/Setupdata.dart';
import 'package:fiberchat_web/Screens/homepage/homepage.dart';
import 'package:fiberchat_web/Screens/privacypolicy&TnC/PdfViewFromCachedUrl.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/Providers/TimerProvider.dart';
import 'package:fiberchat_web/Utils/custom_url_launcher.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/phonenumberVariantsGenerator.dart';
import 'package:fiberchat_web/widgets/PhoneField/intl_phone_field.dart';
import 'package:fiberchat_web/widgets/PhoneField/phone_number.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Services/localization/language.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat_web/Models/E2EE/e2ee.dart' as e2ee;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:fiberchat_web/Utils/unawaited.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen(
      {Key? key,
      this.title,
      required this.isaccountapprovalbyadminneeded,
      required this.accountApprovalMessage,
      required this.prefs,
      required this.doc,
      required this.isblocknewlogins})
      : super(key: key);

  final String? title;

  final bool? isblocknewlogins;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isaccountapprovalbyadminneeded;
  final String? accountApprovalMessage;
  final SharedPreferences prefs;
  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String _code = "";
  final _phoneNo = TextEditingController();
  int currentStatus = 0;
  final _name = TextEditingController();
  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  final storage = new FlutterSecureStorage();

  int attempt = 1;
  String? verificationId;
  bool isShowCompletedLoading = false;
  bool isVerifyingCode = false;
  bool isCodeSent = false;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  @override
  void initState() {
    super.initState();
    setdeviceinfo();
    seletedlanguage = Language.languageList()
        .where((element) => element.languageCode == 'en')
        .toList()[0];
  }

  setdeviceinfo() async {
    setState(() {
      deviceid = "deviceid";
      mapDeviceInfo = {
        Dbkeys.deviceInfoMODEL: "",
        Dbkeys.deviceInfoOS: 'web',
        Dbkeys.deviceInfoISPHYSICAL: true,
        Dbkeys.deviceInfoDEVICEID: "",
        Dbkeys.deviceInfoOSID: "",
        Dbkeys.deviceInfoOSVERSION: "",
        Dbkeys.deviceInfoMANUFACTURER: "",
        Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
      };
    });
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  int currentPinAttemps = 0;

  Future<void> verifyPhoneNumber() async {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      isShowCompletedLoading = true;
      setState(() {});
      handleSignIn(authCredential: phoneAuthCredential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      Fiberchat.toast('Authentication failed - ${authException.message}');

      setState(() {
        currentStatus = LoginStatus.failure.index;
        // _phoneNo.clear();
        // _code = '';
        isCodeSent = false;

        timerProvider.resetTimer();

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });

      print(
          'Authentication failed -ERROR: ${authException.message}. Try again later.');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      timerProvider.startTimer();
      setState(() {
        currentStatus = LoginStatus.sentSMSCode.index;
        isVerifyingCode = false;
        isCodeSent = true;
      });

      this.verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      this.verificationId = verificationId;
      setState(() {
        currentStatus = LoginStatus.failure.index;
        // _phoneNo.clear();
        // _code = '';
        isCodeSent = false;

        timerProvider.resetTimer();

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps = 0;
      });

      Fiberchat.toast('Authentication failed Timeout. please try again.');
    };
    // Fiberchat.toast('Verify phone triggered');
    try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: (phoneCode! + _phoneNo.text).trim(),
          timeout: Duration(seconds: timeOutSeconds),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      Fiberchat.toast('NEW CATCH' + e.toString());
    }
  }

  subscribeToNotification(String currentUserNo, bool isFreshNewAccount) async {
    // await FirebaseMessaging.instance
    //     .subscribeToTopic(
    //         '${currentUserNo.replaceFirst(new RegExp(r'\+'), '')}')
    //     .catchError((err) {
    //   print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    // });
    // await FirebaseMessaging.instance
    //     .subscribeToTopic(Dbkeys.topicUSERS)
    //     .catchError((err) {
    //   print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    // });
    // await FirebaseMessaging.instance
    //     .subscribeToTopic(Dbkeys.topicUSERSweb)
    //     .catchError((err) {
    //   print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    // });

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.length > 0) {
          query.docs.forEach((doc) async {
            if (doc.data().containsKey(Dbkeys.groupMUTEDMEMBERS)) {
              if (doc[Dbkeys.groupMUTEDMEMBERS].contains(currentUserNo)) {
              } else {
                // await FirebaseMessaging.instance
                //     .subscribeToTopic(
                //         "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                //     .catchError((err) {
                //   print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
                // });
              }
            } else {
              // await FirebaseMessaging.instance
              //     .subscribeToTopic(
              //         "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
              //     .catchError((err) {
              //   print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
              // });
            }
          });
        }
      });
    }
  }

  Future<Null> handleSignIn({AuthCredential? authCredential}) async {
    setState(() {
      isShowCompletedLoading = true;
    });

    var phoneNo = (phoneCode! + _phoneNo.text).trim();

    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId!, smsCode: _code);

      UserCredential firebaseUser =
          await firebaseAuth.signInWithCredential(credential);

      // ignore: unnecessary_null_comparison
      if (firebaseUser != null) {
        // Check is already sign up
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .where(Dbkeys.id, isEqualTo: firebaseUser.user!.uid)
            .get();
        final List documents = result.docs;
        final pair = await e2ee.X25519().generateKeyPair();

        if (documents.length == 0) {
          await storage.write(
              key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
          // Update data to server if new user
          await FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(phoneNo)
              .set({
            Dbkeys.publicKey: pair.publicKey.toBase64(),
            Dbkeys.privateKey: pair.secretKey.toBase64(),
            Dbkeys.countryCode: phoneCode,
            Dbkeys.nickname: _name.text.trim(),
            Dbkeys.photoUrl: firebaseUser.user!.photoURL ?? '',
            Dbkeys.id: firebaseUser.user!.uid,
            Dbkeys.phone: phoneNo,
            Dbkeys.phoneRaw: _phoneNo.text,
            Dbkeys.authenticationType: AuthenticationType.passcode.index,
            Dbkeys.aboutMe: '',
            //---Additional fields added for Admin app compatible----
            Dbkeys.accountstatus: widget.isaccountapprovalbyadminneeded == true
                ? Dbkeys.sTATUSpending
                : Dbkeys.sTATUSallowed,
            Dbkeys.actionmessage: widget.accountApprovalMessage,
            Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
            Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,
            Dbkeys.searchKey: _name.text.trim().substring(0, 1).toUpperCase(),
            Dbkeys.videoCallMade: 0,
            Dbkeys.videoCallRecieved: 0,
            Dbkeys.audioCallMade: 0,
            Dbkeys.groupsCreated: 0,
            Dbkeys.blockeduserslist: [],
            Dbkeys.audioCallRecieved: 0,
            Dbkeys.mssgSent: 0,
            Dbkeys.deviceDetails: mapDeviceInfo,
            Dbkeys.currentDeviceID: deviceid,
            Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                countrycode: phoneCode, phonenumber: _phoneNo.text),
            Dbkeys.webLoginTime: DateTime.now().millisecondsSinceEpoch,
          }, SetOptions(merge: true));

          currentUser = firebaseUser.user;
          await FirebaseFirestore.instance
              .collection(DbPaths.collectiondashboard)
              .doc(DbPaths.docuserscount)
              .set(
                  widget.isaccountapprovalbyadminneeded == false
                      ? {
                          Dbkeys.totalapprovedusers: FieldValue.increment(1),
                        }
                      : {
                          Dbkeys.totalpendingusers: FieldValue.increment(1),
                        },
                  SetOptions(merge: true));

          await FirebaseFirestore.instance
              .collection(DbPaths.collectioncountrywiseData)
              .doc(phoneCode)
              .set({
            Dbkeys.totalusers: FieldValue.increment(1),
          }, SetOptions(merge: true));

          await FirebaseFirestore.instance
              .collection(DbPaths.collectionnotifications)
              .doc(DbPaths.adminnotifications)
              .set({
            Dbkeys.nOTIFICATIONxxaction: 'PUSH',
            Dbkeys.nOTIFICATIONxxdesc: widget.isaccountapprovalbyadminneeded ==
                    true
                ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
            Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
            Dbkeys.nOTIFICATIONxximageurl: null,
            Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
            'list': FieldValue.arrayUnion([
              {
                Dbkeys.docid: DateTime.now().millisecondsSinceEpoch.toString(),
                Dbkeys.nOTIFICATIONxxdesc: widget
                            .isaccountapprovalbyadminneeded ==
                        true
                    ? '${_name.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                    : '${_name.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
                Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
                Dbkeys.nOTIFICATIONxximageurl: null,
                Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
                Dbkeys.nOTIFICATIONxxauthor:
                    currentUser!.uid + 'XXX' + 'webapp',
              }
            ])
          }, SetOptions(merge: true));

          // Write data to local

          await widget.prefs.setString(Dbkeys.id, currentUser!.uid);
          await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
          await widget.prefs
              .setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
          await widget.prefs.setString(Dbkeys.phone, phoneNo);
          await widget.prefs.setString(Dbkeys.countryCode, phoneCode!);
          // await FirebaseFirestore.instance
          //     .collection(DbPaths.collectionusers)
          //     .doc(phoneNo)
          //     .set({
          //   Dbkeys.notificationTokens: [fcmTokenn]
          // }, SetOptions(merge: true));
          unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
          await widget.prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
          await subscribeToNotification(phoneNo, true);
          unawaited(Navigator.pushReplacement(
              this.context,
              MaterialPageRoute(
                  builder: (newContext) => Homepage(
                        doc: widget.doc,
                        currentUserNo: phoneNo,
                        prefs: widget.prefs,
                      ))));
        } else {
          await storage.write(
              key: Dbkeys.privateKey, value: documents[0][Dbkeys.privateKey]);

          await FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(phoneNo)
              .set(
                  !documents[0].data().containsKey(Dbkeys.deviceDetails)
                      ? {
                          Dbkeys.authenticationType:
                              AuthenticationType.passcode.index,
                          Dbkeys.accountstatus:
                              widget.isaccountapprovalbyadminneeded == true
                                  ? Dbkeys.sTATUSpending
                                  : Dbkeys.sTATUSallowed,

                          Dbkeys.actionmessage: widget.accountApprovalMessage,
                          Dbkeys.lastLogin:
                              DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.joinedOn:
                              documents[0].data()![Dbkeys.lastSeen] != true
                                  ? documents[0].data()![Dbkeys.lastSeen]
                                  : DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.nickname: _name.text.trim(),
                          Dbkeys.searchKey:
                              _name.text.trim().substring(0, 1).toUpperCase(),
                          Dbkeys.videoCallMade: 0,
                          Dbkeys.videoCallRecieved: 0,
                          Dbkeys.audioCallMade: 0,
                          Dbkeys.audioCallRecieved: 0,
                          Dbkeys.mssgSent: 0,
                          Dbkeys.deviceDetails: mapDeviceInfo,
                          Dbkeys.currentDeviceID: deviceid,
                          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                              countrycode:
                                  documents[0].data()![Dbkeys.countryCode],
                              phonenumber:
                                  documents[0].data()![Dbkeys.phoneRaw]),
                          Dbkeys.webLoginTime:
                              DateTime.now().millisecondsSinceEpoch
                          // Dbkeys.notificationTokens: [fcmToken],
                        }
                      : {
                          Dbkeys.searchKey:
                              _name.text.trim().substring(0, 1).toUpperCase(),
                          Dbkeys.nickname: _name.text.trim(),
                          Dbkeys.authenticationType:
                              AuthenticationType.passcode.index,
                          Dbkeys.lastLogin:
                              DateTime.now().millisecondsSinceEpoch,
                          Dbkeys.deviceDetails: mapDeviceInfo,
                          Dbkeys.currentDeviceID: deviceid,
                          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                              countrycode:
                                  documents[0].data()![Dbkeys.countryCode],
                              phonenumber:
                                  documents[0].data()![Dbkeys.phoneRaw]),
                          Dbkeys.webLoginTime:
                              DateTime.now().millisecondsSinceEpoch
                          // Dbkeys.notificationTokens: [fcmToken],
                        },
                  SetOptions(merge: true));

          // Write data to local
          await widget.prefs.setString(Dbkeys.id, documents[0][Dbkeys.id]);
          await widget.prefs.setString(Dbkeys.nickname, _name.text.trim());
          await widget.prefs
              .setString(Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
          await widget.prefs
              .setString(Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
          await widget.prefs
              .setString(Dbkeys.phone, documents[0][Dbkeys.phone]);

          await subscribeToNotification(documents[0][Dbkeys.phone], false);
          unawaited(Navigator.pushReplacement(this.context,
              new MaterialPageRoute(builder: (context) => FiberchatWrapper())));
        }
      } else {
        Fiberchat.toast(getTranslated(this.context, 'failedlogin'));
      }
    } catch (e) {
      setState(() {
        if (currentPinAttemps >= 4) {
          currentStatus = LoginStatus.failure.index;
          _phoneNo.clear();
          _code = '';
          isCodeSent = false;
        }

        isShowCompletedLoading = false;
        isVerifyingCode = false;
        currentPinAttemps++;
      });
      // print(e.toString());
      if (e.toString().contains('invalid') ||
          e.toString().contains('code') ||
          e.toString().contains('verification')) {
        setState(() {
          currentStatus = LoginStatus.sentSMSCode.index;
          isVerifyingCode = false;
          isCodeSent = true;
          currentPinAttemps++;
          isShowCompletedLoading = false;
        });
        Fiberchat.toast(getTranslated(this.context, 'makesureotp'));
      }
    }
  }

  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    FiberchatWrapper.setLocale(this.context, _locale);
    setState(() {
      seletedlanguage = language;
    });

    await widget.prefs.setBool('islanguageselected', true);
  }

  Language? seletedlanguage;
  customclippath(double w, double h) {
    return ClipPath(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(top: MediaQuery.of(this.context).padding.top),
        height: 400,
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [loginPageTopColor, loginPageBottomColor],
        //   ),
        // ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 0, left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Language.languageList().length < 2
                      ? SizedBox(
                          height: 40,
                        )
                      : Container(
                          alignment: Alignment.centerRight,
                          margin: EdgeInsets.only(top: 4, right: 10),
                          width: 190,
                          padding: EdgeInsets.all(8),
                          child: DropdownButton<Language>(
                            underline: SizedBox(),
                            icon: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.language_outlined,
                                  color: fiberchatWhite.withOpacity(0.8),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                SizedBox(
                                  width: 15,
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    color: fiberchatSECONDARYolor ==
                                            fiberchatPRIMARYcolor
                                        ? Colors.white
                                        : fiberchatSECONDARYolor,
                                    size: 27,
                                  ),
                                )
                              ],
                            ),
                            onChanged: (Language? language) {
                              _changeLanguage(language!);
                            },
                            items: Language.languageList()
                                .map<DropdownMenuItem<Language>>(
                                  (e) => DropdownMenuItem<Language>(
                                    value: e,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text(
                                          '' + e.name + '  ' + e.flag + ' ',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                  //---- All localizations settings----
                ],
              ),
            ),
            SizedBox(
              height: w > h ? 0 : 15,
            ),
            w < h
                ? Image.asset(
                    AppLogoPathLight,
                    width: h / 3,
                  )
                : Image.asset(
                    AppLogoPathLight,
                    height: h / 6,
                  ),
            SizedBox(
              height: 0,
            ),
          ],
        ),
      ),
    );
  }

  buildCurrentWidgetFORMOBILE(double w, double h) {
    if (currentStatus == LoginStatus.sendSMScode.index) {
      return loginWidgetsendSMScodeFORMOBILE(w, h);
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScodeFORMOBILE();
    } else if (currentStatus == LoginStatus.sentSMSCode.index) {
      return loginWidgetsentSMScodeFORMOBILE();
    } else if (currentStatus == LoginStatus.verifyingSMSCode.index) {
      return loginWidgetVerifyingSMScodeFORMOBILE();
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScodeFORMOBILE();
    } else {
      return loginWidgetsendSMScodeFORMOBILE(w, h);
    }
  }

  buildCurrentWidgetFORWEB(double w, double h) {
    if (currentStatus == LoginStatus.sendSMScode.index) {
      return loginWidgetsendSMScodeFOWEB(w, h);
    } else if (currentStatus == LoginStatus.sendingSMScode.index) {
      return loginWidgetsendingSMScodeFORWEB(w, h);
    } else if (currentStatus == LoginStatus.sentSMSCode.index) {
      return loginWidgetsentSMScodeFORWEB(w, h);
    } else if (currentStatus == LoginStatus.verifyingSMSCode.index) {
      return loginWidgetVerifyingSMScodeFORWEB(w, h);
    } else {
      return loginWidgetsendSMScodeFOWEB(w, h);
    }
  }

  loginWidgetsendSMScodeFORMOBILE(double w, double h) {
    var boxWidth = w / 1.1;
    return Consumer<Observer>(
        builder: (context, observer, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 0, left: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Language.languageList().length < 2
                          ? SizedBox(
                              height: 40,
                            )
                          : Container(
                              alignment: Alignment.centerRight,
                              margin: EdgeInsets.only(top: 0, right: 10),
                              // width: 0,
                              padding: EdgeInsets.all(8),
                              child: DropdownButton<Language>(
                                underline: SizedBox(),
                                icon: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language_outlined,
                                      color: fiberchatWhite.withOpacity(0.8),
                                    ),
                                    SizedBox(
                                      width: 2,
                                    ),
                                    SizedBox(
                                      width: 15,
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: fiberchatSECONDARYolor ==
                                                fiberchatPRIMARYcolor
                                            ? Colors.white
                                            : fiberchatSECONDARYolor,
                                        size: 27,
                                      ),
                                    )
                                  ],
                                ),
                                onChanged: (Language? language) {
                                  _changeLanguage(language!);
                                },
                                items: Language.languageList()
                                    .map<DropdownMenuItem<Language>>(
                                      (e) => DropdownMenuItem<Language>(
                                        value: e,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: <Widget>[
                                            Text(IsShowLanguageNameInNativeLanguage ==
                                                    true
                                                ? '' +
                                                    e.name +
                                                    '  ' +
                                                    e.flag +
                                                    ' '
                                                : ' ' +
                                                    e.languageNameInEnglish +
                                                    '  ' +
                                                    e.flag +
                                                    ' '),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),

                      //---- All localizations settings----
                    ],
                  ),
                ),
                SizedBox(
                  height: w > h ? 0 : 10,
                ),
                Center(
                  child: Image.asset(
                    AppLogoPathLight,
                    width: w / 1.4,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                SizedBox(
                  height: observer.iosapplink!.contains('apps.apple.com') ||
                          observer.androidapplink!.contains('play.google.com')
                      ? h / 360
                      : h / 88,
                ),
                Container(
                  width: boxWidth / 1.6,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3.0,
                        color: fiberchatBlack.withOpacity(0.1),
                        spreadRadius: 1.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.fromLTRB(15, 0, 16, 0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 13,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        // height: 63,
                        height: 83,
                        width: boxWidth / 1.14,
                        child: InpuTextBox(
                          inputFormatter: [
                            LengthLimitingTextInputFormatter(25),
                          ],
                          controller: _name,
                          leftrightmargin: 0,
                          showIconboundary: false,
                          boxcornerradius: 5.5,
                          boxheight: 50,
                          hinttext: getTranslated(this.context, 'name_hint'),
                          prefixIconbutton: Icon(
                            Icons.person,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        // height: 63,
                        height: 63,
                        width: boxWidth / 1.14,
                        child: Form(
                          // key: _enterNumberFormKey,
                          child: MobileInputWithOutline(
                            buttonhintTextColor: fiberchatGrey,
                            borderColor: fiberchatGrey.withOpacity(0.2),
                            controller: _phoneNo,
                            initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                            onSaved: (phone) {
                              setState(() {
                                phoneCode = phone!.countryCode;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(17),
                        child: Text(
                          getTranslated(this.context, 'sendsmscode'),
                          // 'Send a SMS Code to verify your number',
                          textAlign: TextAlign.center,
                          // style: TextStyle(color: Mycolors.black),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                        child: MySimpleButton(
                          spacing: 0.3,
                          height: 57,
                          buttoncolor: fiberchatSECONDARYolor,
                          buttontext: getTranslated(this.context, 'sendverf'),
                          onpressed: widget.isblocknewlogins == true
                              ? () {
                                  Fiberchat.toast(
                                    getTranslated(
                                        this.context, 'logindisabled'),
                                  );
                                }
                              : () {
                                  final timerProvider =
                                      Provider.of<TimerProvider>(context,
                                          listen: false);

                                  setState(() {});
                                  RegExp e164 =
                                      new RegExp(r'^\+[1-9]\d{1,14}$');
                                  if (_name.text.trim().isNotEmpty) {
                                    String _phone =
                                        _phoneNo.text.toString().trim();
                                    if (_phone.isNotEmpty &&
                                        e164.hasMatch(phoneCode! + _phone)) {
                                      if (_phone.startsWith('0') &&
                                          phoneCode == '+81') {
                                        timerProvider.resetTimer();
                                        setState(() {
                                          _phone = _phone.substring(1);
                                          _phoneNo.text = _phone;
                                          currentStatus =
                                              LoginStatus.sendingSMScode.index;
                                          isCodeSent = false;
                                        });

                                        verifyPhoneNumber();
                                      } else {
                                        timerProvider.resetTimer();
                                        setState(() {
                                          currentStatus =
                                              LoginStatus.sendingSMScode.index;
                                          isCodeSent = false;
                                        });
                                        verifyPhoneNumber();
                                      }
                                    } else {
                                      Fiberchat.toast(
                                        getTranslated(
                                            this.context, 'entervalidmob'),
                                      );
                                    }
                                  } else {
                                    Fiberchat.toast(
                                        getTranslated(this.context, 'nameem'));
                                  }
                                },
                        ),
                      ),

                      //
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(13),
                  width: w * 0.95,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: '${getTranslated(this.context, 'agree')} \n',
                            style: TextStyle(
                                color: fiberchatWhite.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                fontSize: 14.0,
                                height: 1.7)),
                        TextSpan(
                            text: getTranslated(this.context, 'tnc'),
                            style: TextStyle(
                                height: 1.7,
                                color: fiberchatSECONDARYolor ==
                                        fiberchatPRIMARYcolor
                                    ? Colors.white
                                    : fiberchatSECONDARYolor,
                                fontWeight: FontWeight.w700,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                fontSize: 14.8),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (ConnectWithAdminApp == false) {
                                  custom_url_launcher(TERMS_CONDITION_URL);
                                } else {
                                  final observer = Provider.of<Observer>(
                                      this.context,
                                      listen: false);
                                  if (observer.tncType == 'url') {
                                    if (observer.tnc == null) {
                                      custom_url_launcher(TERMS_CONDITION_URL);
                                    } else {
                                      custom_url_launcher(observer.tnc!);
                                    }
                                  } else if (observer.tncType == 'file') {
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PDFViewerCachedFromUrl(
                                            prefs: widget.prefs,
                                            title: getTranslated(
                                                this.context, 'tnc'),
                                            url: observer.tnc,
                                            isregistered: false,
                                          ),
                                        ));
                                  }
                                }
                              }),
                        TextSpan(
                            text: '  ○  ',
                            style: TextStyle(
                                height: 1.7,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                color: fiberchatWhite.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 11.8)),
                        TextSpan(
                            text: getTranslated(this.context, 'pp'),
                            style: TextStyle(
                                height: 1.7,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                color: fiberchatSECONDARYolor ==
                                        fiberchatPRIMARYcolor
                                    ? Colors.white
                                    : fiberchatSECONDARYolor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.8),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (ConnectWithAdminApp == false) {
                                  custom_url_launcher(PRIVACY_POLICY_URL);
                                } else {
                                  if (observer.privacypolicyType == 'url') {
                                    if (observer.privacypolicy == null) {
                                      custom_url_launcher(PRIVACY_POLICY_URL);
                                    } else {
                                      custom_url_launcher(
                                          observer.privacypolicy!);
                                    }
                                  } else if (observer.privacypolicyType ==
                                      'file') {
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PDFViewerCachedFromUrl(
                                            prefs: widget.prefs,
                                            title: getTranslated(
                                                this.context, 'pp'),
                                            url: observer.privacypolicy,
                                            isregistered: false,
                                          ),
                                        ));
                                  }
                                }
                              }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (observer.iosapplink!.contains('apps.apple.com'))
                        InkWell(
                          onTap: () {
                            custom_url_launcher(observer.iosapplink!);
                          },
                          child: Image.asset(
                            'assets/images/appstore.png',
                            width: boxWidth / 3,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      if (observer.androidapplink!.contains('play.google.com'))
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: InkWell(
                            onTap: () {
                              custom_url_launcher(observer.androidapplink!);
                            },
                            child: Image.asset(
                              'assets/images/playstore.png',
                              width: boxWidth / 3,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ));
  }

  loginWidgetsendSMScodeFOWEB(double w, double h) {
    var boxWidth = w / 1.4;
    return Consumer<Observer>(
        builder: (context, observer, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: !widget.doc.data()!.containsKey(Dbkeys.newapplinkios)
                      ? h / 10
                      : widget.doc
                                  .data()![Dbkeys.newapplinkios]
                                  .contains('apps.apple.com') ||
                              widget.doc
                                  .data()![Dbkeys.newapplinkandroid]
                                  .contains('play.google.com')
                          ? h / 150
                          : h / 10,
                ),
                Text(
                  getTranslated(context, 'logintoyouraccount'),
                  textAlign: TextAlign.left,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: fiberchatWhite),
                ),
                SizedBox(
                  height: h / 20,
                ),
                Container(
                  width: boxWidth,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 3.0,
                        color: fiberchatBlack.withOpacity(0.1),
                        spreadRadius: 1.0,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.fromLTRB(15, 15, 16, 0),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 13,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        // height: 63,
                        height: 83,
                        width: boxWidth / 1.14,
                        child: InpuTextBox(
                          inputFormatter: [
                            LengthLimitingTextInputFormatter(25),
                          ],
                          controller: _name,
                          leftrightmargin: 0,
                          showIconboundary: false,
                          boxcornerradius: 5.5,
                          boxheight: 50,
                          hinttext: getTranslated(this.context, 'name_hint'),
                          prefixIconbutton: Icon(
                            Icons.person,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 0),
                        // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        // height: 63,
                        height: 63,
                        width: boxWidth / 1.14,
                        child: Form(
                          // key: _enterNumberFormKey,
                          child: MobileInputWithOutline(
                            buttonhintTextColor: fiberchatGrey,
                            borderColor: fiberchatGrey.withOpacity(0.2),
                            controller: _phoneNo,
                            initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                            onSaved: (phone) {
                              setState(() {
                                phoneCode = phone!.countryCode;
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(17),
                        child: Text(
                          getTranslated(this.context, 'sendsmscode'),
                          // 'Send a SMS Code to verify your number',
                          textAlign: TextAlign.center,
                          // style: TextStyle(color: Mycolors.black),
                        ),
                      ),
                      Container(
                        width: boxWidth / 1.14,
                        margin: EdgeInsets.fromLTRB(17, 22, 17, 5),
                        child: MySimpleButton(
                          spacing: 0.3,
                          height: 57,
                          buttoncolor: fiberchatSECONDARYolor,
                          buttontext: getTranslated(this.context, 'sendverf'),
                          onpressed: widget.isblocknewlogins == true
                              ? () {
                                  Fiberchat.toast(
                                    getTranslated(
                                        this.context, 'logindisabled'),
                                  );
                                }
                              : () {
                                  final timerProvider =
                                      Provider.of<TimerProvider>(context,
                                          listen: false);

                                  setState(() {});
                                  RegExp e164 =
                                      new RegExp(r'^\+[1-9]\d{1,14}$');
                                  if (_name.text.trim().isNotEmpty) {
                                    String _phone =
                                        _phoneNo.text.toString().trim();
                                    if (_phone.isNotEmpty &&
                                        e164.hasMatch(phoneCode! + _phone)) {
                                      if (_phone.startsWith('0') &&
                                          phoneCode == '+81') {
                                        timerProvider.resetTimer();
                                        setState(() {
                                          _phone = _phone.substring(1);
                                          _phoneNo.text = _phone;
                                          currentStatus =
                                              LoginStatus.sendingSMScode.index;
                                          isCodeSent = false;
                                        });

                                        verifyPhoneNumber();
                                      } else {
                                        timerProvider.resetTimer();
                                        setState(() {
                                          currentStatus =
                                              LoginStatus.sendingSMScode.index;
                                          isCodeSent = false;
                                        });
                                        verifyPhoneNumber();
                                      }
                                    } else {
                                      Fiberchat.toast(
                                        getTranslated(
                                            this.context, 'entervalidmob'),
                                      );
                                    }
                                  } else {
                                    Fiberchat.toast(
                                        getTranslated(this.context, 'nameem'));
                                  }
                                },
                        ),
                      ),

                      //
                      SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  width: w * 0.95,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                            text: '${getTranslated(this.context, 'agree')} \n',
                            style: TextStyle(
                                color: fiberchatWhite.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                fontSize: 13.5,
                                height: 1.7)),
                        TextSpan(
                            text: getTranslated(this.context, 'tnc'),
                            style: TextStyle(
                                height: 1.7,
                                color: fiberchatSECONDARYolor ==
                                        fiberchatPRIMARYcolor
                                    ? Colors.white
                                    : fiberchatSECONDARYolor,
                                fontWeight: FontWeight.w700,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                fontSize: 14.8),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                if (ConnectWithAdminApp == false) {
                                  custom_url_launcher(TERMS_CONDITION_URL);
                                } else {
                                  final observer = Provider.of<Observer>(
                                      this.context,
                                      listen: false);
                                  if (observer.tncType == 'url') {
                                    if (observer.tnc == null) {
                                      custom_url_launcher(TERMS_CONDITION_URL);
                                    } else {
                                      custom_url_launcher(observer.tnc!);
                                    }
                                  } else if (observer.tncType == 'file') {
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PDFViewerCachedFromUrl(
                                            prefs: widget.prefs,
                                            title: getTranslated(
                                                this.context, 'tnc'),
                                            url: observer.tnc,
                                            isregistered: false,
                                          ),
                                        ));
                                  }
                                }
                              }),
                        TextSpan(
                            text: '  ○  ',
                            style: TextStyle(
                                height: 1.7,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                color: fiberchatWhite.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 13.8)),
                        TextSpan(
                            text: getTranslated(this.context, 'pp'),
                            style: TextStyle(
                                height: 1.7,
                                fontFamily: FONTFAMILY_NAME == ''
                                    ? null
                                    : FONTFAMILY_NAME,
                                color: fiberchatSECONDARYolor ==
                                        fiberchatPRIMARYcolor
                                    ? Colors.white
                                    : fiberchatSECONDARYolor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                if (ConnectWithAdminApp == false) {
                                  custom_url_launcher(PRIVACY_POLICY_URL);
                                } else {
                                  if (observer.privacypolicyType == 'url') {
                                    if (observer.privacypolicy == null) {
                                      custom_url_launcher(PRIVACY_POLICY_URL);
                                    } else {
                                      custom_url_launcher(
                                          observer.privacypolicy!);
                                    }
                                  } else if (observer.privacypolicyType ==
                                      'file') {
                                    Navigator.push(
                                        this.context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PDFViewerCachedFromUrl(
                                            prefs: widget.prefs,
                                            title: getTranslated(
                                                this.context, 'pp'),
                                            url: observer.privacypolicy,
                                            isregistered: false,
                                          ),
                                        ));
                                  }
                                }
                              }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!widget.doc.data()!.containsKey(Dbkeys.newapplinkios)
                          ? 1 == 2
                          : widget.doc
                              .data()![Dbkeys.newapplinkios]
                              .contains('apps.apple.com'))
                        InkWell(
                          onTap: () {
                            custom_url_launcher(observer.iosapplink!);
                          },
                          child: Image.asset(
                            'assets/images/appstore.png',
                            width: boxWidth / 3,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      if (!widget.doc
                              .data()!
                              .containsKey(Dbkeys.newapplinkandroid)
                          ? 1 == 2
                          : widget.doc
                              .data()![Dbkeys.newapplinkandroid]
                              .contains('play.google.com'))
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: InkWell(
                            onTap: () {
                              custom_url_launcher(observer.androidapplink!);
                            },
                            child: Image.asset(
                              'assets/images/playstore.png',
                              width: boxWidth / 3,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ));
  }

  loginWidgetsendingSMScodeFORMOBILE() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: fiberchatBlack.withOpacity(0.1),
            spreadRadius: 1.0,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      margin: EdgeInsets.fromLTRB(
          15, MediaQuery.of(this.context).size.height / 2.50, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),
          Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              getTranslated(this.context, 'sending_code') +
                  ' $phoneCode-${_phoneNo.text}',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                fontFamily: FONTFAMILY_NAME == '' ? null : FONTFAMILY_NAME,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
          ),
          SizedBox(
            height: 48,
          ),
        ],
      ),
    );
  }

  loginWidgetsendingSMScodeFORWEB(var w, var h) {
    var boxWidth = w / 1.4;
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: h / 5.1),
        width: boxWidth,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 3.0,
              color: fiberchatBlack.withOpacity(0.1),
              spreadRadius: 1.0,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: h / 15,
            ),
            Padding(
              padding: EdgeInsets.all(17),
              child: Text(
                getTranslated(this.context, 'sending_code') +
                    ' $phoneCode-${_phoneNo.text}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  height: 1.5,
                  fontFamily: FONTFAMILY_NAME == '' ? null : FONTFAMILY_NAME,
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
            ),
            SizedBox(
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  loginWidgetsentSMScodeFORMOBILE() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: fiberchatBlack.withOpacity(0.1),
            spreadRadius: 1.0,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      margin: EdgeInsets.fromLTRB(
          15, MediaQuery.of(this.context).size.height / 2.50, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 13,
          ),

          Container(
            margin: EdgeInsets.all(25),
            // height: 70,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: PinCodeTextField(
                pinBoxHeight: 35,
                pinBoxWidth: 35,
                keyboardType: TextInputType.number,
                pinTextStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white),
                defaultBorderColor: fiberchatGrey,
                highlightColor: fiberchatSECONDARYolor,
                pinBoxBorderWidth: 2,
                hasTextBorderColor: fiberchatSECONDARYolor,
                highlightPinBoxColor: fiberchatSECONDARYolor,
                pinBoxColor: Colors.white,
                pinBoxRadius: 7,
                maxLength: 6,
                onDone: (code) {
                  setState(() {
                    _code = code;
                  });
                  if (code.length == 6) {
                    setState(() {
                      currentStatus = LoginStatus.verifyingSMSCode.index;
                    });
                    handleSignIn();
                  } else {
                    setState(() {});
                    Fiberchat.toast(getTranslated(this.context, 'correctotp'));
                  }
                },
                onTextChanged: (code) {
                  if (code.length == 6) {
                    FocusScope.of(this.context).requestFocus(FocusNode());
                    // setState(() {
                    //   _code = code;
                    // });
                  }
                  setState(() {
                    _code = code;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(17),
            child: Text(
              getTranslated(this.context, 'enter_verfcode') +
                  ' $phoneCode-${_phoneNo.text}',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),

              // style: TextStyle(color: Mycolors.black),
            ),
          ),
          isShowCompletedLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          fiberchatSECONDARYolor)),
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                  child: MySimpleButton(
                    height: 57,
                    buttoncolor: fiberchatPRIMARYcolor,
                    buttontext: getTranslated(this.context, 'verify_otp'),
                    onpressed: () {
                      if (_code.length == 6) {
                        setState(() {
                          isVerifyingCode = true;
                          currentStatus = LoginStatus.verifyingSMSCode.index;
                        });

                        handleSignIn();
                      } else
                        Fiberchat.toast(
                            getTranslated(this.context, 'correctotp'));
                    },
                  ),
                ),
          SizedBox(
            height: 20,
          ),
          isShowCompletedLoading == true
              ? SizedBox(
                  height: 36,
                )
              : Consumer<TimerProvider>(
                  builder: (context, timeProvider, _) => timeProvider.wait ==
                              true &&
                          isCodeSent == true
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                          child: RichText(
                              text: TextSpan(
                            children: [
                              TextSpan(
                                text: getTranslated(this.context, 'resendcode'),
                                style: TextStyle(
                                    fontSize: 14, color: fiberchatGrey),
                              ),
                              TextSpan(
                                text: " 00:${timeProvider.start} ",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: fiberchatPRIMARYcolor,
                                    fontWeight: FontWeight.w700),
                              ),
                              TextSpan(
                                text: getTranslated(this.context, 'seconds'),
                                style: TextStyle(
                                    fontSize: 14, color: fiberchatGrey),
                              ),
                            ],
                          )),
                        )
                      : timeProvider.isActionBarShow == false
                          ? SizedBox(
                              height: 35,
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                    onTap: () {
                                      final timerProvider =
                                          Provider.of<TimerProvider>(context,
                                              listen: false);
                                      timerProvider.resetTimer();
                                      unawaited(Navigator.pushReplacement(
                                          this.context,
                                          MaterialPageRoute(
                                              builder: (newContext) => Homepage(
                                                    doc: widget.doc,
                                                    currentUserNo: null,
                                                    prefs: widget.prefs,
                                                  ))));
                                    },
                                    child: Container(
                                      margin:
                                          EdgeInsets.fromLTRB(23, 12, 10, 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.arrow_back_ios,
                                            color: fiberchatGrey,
                                            size: 16,
                                          ),
                                          Text(
                                            getTranslated(this.context, 'back'),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: fiberchatGrey,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    )),
                                attempt > 1
                                    ? SizedBox(
                                        height: 0,
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            attempt++;

                                            timeProvider.resetTimer();
                                            isCodeSent = false;
                                            currentStatus = LoginStatus
                                                .sendingSMScode.index;
                                          });
                                          verifyPhoneNumber();
                                        },
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(10, 4, 23, 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.restart_alt_outlined,
                                                  color: fiberchatPRIMARYcolor),
                                              Text(
                                                ' ' +
                                                    getTranslated(
                                                        this.context, 'resend'),
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    color:
                                                        fiberchatPRIMARYcolor,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ))
                              ],
                            ),
                ),

          SizedBox(
            height: 27,
          ),
          //
        ],
      ),
    );
  }

  loginWidgetsentSMScodeFORWEB(w, h) {
    var boxWidth = w / 1.4;
    return Center(
      child: Container(
        width: boxWidth,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 3.0,
              color: fiberchatBlack.withOpacity(0.1),
              spreadRadius: 1.0,
            ),
          ],
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        margin: EdgeInsets.fromLTRB(15, h / 8, 16, 0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 13,
            ),

            Container(
              margin: EdgeInsets.all(25),
              // height: 70,
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: PinCodeTextField(
                  pinBoxHeight: 47,
                  pinBoxWidth: 47,
                  keyboardType: TextInputType.number,
                  pinTextStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 25,
                      color: Colors.white),
                  defaultBorderColor: fiberchatGrey,
                  highlightColor: fiberchatSECONDARYolor,
                  pinBoxBorderWidth: 2,
                  hasTextBorderColor: fiberchatSECONDARYolor,
                  highlightPinBoxColor: fiberchatSECONDARYolor,
                  pinBoxColor: Colors.white,
                  pinBoxRadius: 7,
                  maxLength: 6,
                  onDone: (code) {
                    setState(() {
                      _code = code;
                    });
                    if (code.length == 6) {
                      setState(() {
                        currentStatus = LoginStatus.verifyingSMSCode.index;
                      });
                      handleSignIn();
                    } else {
                      setState(() {});
                      Fiberchat.toast(
                          getTranslated(this.context, 'correctotp'));
                    }
                  },
                  onTextChanged: (code) {
                    if (code.length == 6) {
                      FocusScope.of(this.context).requestFocus(FocusNode());
                      // setState(() {
                      //   _code = code;
                      // });
                    }
                    setState(() {
                      _code = code;
                    });
                  },
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(17),
              child: Text(
                getTranslated(this.context, 'enter_verfcode') +
                    ' $phoneCode-${_phoneNo.text}',
                textAlign: TextAlign.center,
                style: TextStyle(height: 1.5),

                // style: TextStyle(color: Mycolors.black),
              ),
            ),
            isShowCompletedLoading == true
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            fiberchatSECONDARYolor)),
                  )
                : _code.length >= 6
                    ? Padding(
                        padding: EdgeInsets.fromLTRB(17, 22, 17, 5),
                        child: MySimpleButton(
                          height: 57,
                          buttoncolor: fiberchatPRIMARYcolor,
                          buttontext: getTranslated(this.context, 'verify_otp'),
                          onpressed: () {
                            if (_code.length == 6) {
                              setState(() {
                                isVerifyingCode = true;
                                currentStatus =
                                    LoginStatus.verifyingSMSCode.index;
                              });

                              handleSignIn();
                            } else
                              Fiberchat.toast(
                                  getTranslated(this.context, 'correctotp'));
                          },
                        ),
                      )
                    : SizedBox(),
            SizedBox(
              height: 20,
            ),
            isShowCompletedLoading == true
                ? SizedBox(
                    height: 36,
                  )
                : Consumer<TimerProvider>(
                    builder: (context, timeProvider, _) => timeProvider.wait ==
                                true &&
                            isCodeSent == true
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(15, 8, 15, 8),
                            child: RichText(
                                text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      getTranslated(this.context, 'resendcode'),
                                  style: TextStyle(
                                      fontSize: 14, color: fiberchatGrey),
                                ),
                                TextSpan(
                                  text: " 00:${timeProvider.start} ",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: fiberchatPRIMARYcolor,
                                      fontWeight: FontWeight.w700),
                                ),
                                TextSpan(
                                  text: getTranslated(this.context, 'seconds'),
                                  style: TextStyle(
                                      fontSize: 14, color: fiberchatGrey),
                                ),
                              ],
                            )),
                          )
                        : timeProvider.isActionBarShow == false
                            ? SizedBox(
                                height: 35,
                              )
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        final timerProvider =
                                            Provider.of<TimerProvider>(context,
                                                listen: false);
                                        timerProvider.resetTimer();
                                        unawaited(Navigator.pushReplacement(
                                            this.context,
                                            MaterialPageRoute(
                                                builder: (newContext) =>
                                                    Homepage(
                                                      doc: widget.doc,
                                                      currentUserNo: null,
                                                      prefs: widget.prefs,
                                                    ))));
                                      },
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(23, 12, 10, 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: fiberchatGrey,
                                              size: 16,
                                            ),
                                            Text(
                                              getTranslated(
                                                  this.context, 'back'),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  color: fiberchatGrey,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      )),
                                  attempt > 1
                                      ? SizedBox(
                                          height: 0,
                                        )
                                      : InkWell(
                                          onTap: () {
                                            setState(() {
                                              attempt++;

                                              timeProvider.resetTimer();
                                              isCodeSent = false;
                                              currentStatus = LoginStatus
                                                  .sendingSMScode.index;
                                            });
                                            verifyPhoneNumber();
                                          },
                                          child: Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 4, 23, 4),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.restart_alt_outlined,
                                                    color:
                                                        fiberchatPRIMARYcolor),
                                                Text(
                                                  ' ' +
                                                      getTranslated(
                                                          this.context,
                                                          'resend'),
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          fiberchatPRIMARYcolor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ))
                                ],
                              ),
                  ),

            SizedBox(
              height: 27,
            ),
            //
          ],
        ),
      ),
    );
  }

  loginWidgetVerifyingSMScodeFORMOBILE() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: fiberchatBlack.withOpacity(0.1),
            spreadRadius: 1.0,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      margin: EdgeInsets.fromLTRB(
          15, MediaQuery.of(this.context).size.height / 2.50, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 43,
          ),

          Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
          ),

          InkWell(
            onTap: () {
              setState(() {
                // isLoading = false;
                currentStatus = LoginStatus.sendSMScode.index;
                // _phoneNo.clear();
                // _code = '';
              });
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(13, 22, 13, 8),
                child: Center(
                  child: Text(
                    getTranslated(this.context, 'Back'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                )),
          ),
          //
          SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }

  loginWidgetVerifyingSMScodeFORWEB(w, h) {
    var boxWidth = w / 1.4;
    return Center(
        child: Container(
      width: boxWidth,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 3.0,
            color: fiberchatBlack.withOpacity(0.1),
            spreadRadius: 1.0,
          ),
        ],
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      margin: EdgeInsets.fromLTRB(15, h / 8, 16, 0),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 43,
          ),

          Center(
            child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
          ),

          InkWell(
            onTap: () {
              setState(() {
                // isLoading = false;
                currentStatus = LoginStatus.sendSMScode.index;
                // _phoneNo.clear();
                // _code = '';
              });
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(13, 22, 13, 8),
                child: Center(
                  child: Text(
                    getTranslated(this.context, 'Back'),
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                )),
          ),
          //
          SizedBox(
            height: 28,
          ),
        ],
      ),
    ));
  }

  Color darken(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var f = 1 - percent / 100;
    return Color.fromARGB(c.alpha, (c.red * f).round(), (c.green * f).round(),
        (c.blue * f).round());
  }

  Color lighten(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha,
        c.red + ((255 - c.red) * p).round(),
        c.green + ((255 - c.green) * p).round(),
        c.blue + ((255 - c.blue) * p).round());
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(this.context).size.width;
    var h = MediaQuery.of(this.context).size.height;

    return Fiberchat.getNTPWrappedWidget(Scaffold(
      backgroundColor: fiberchatPRIMARYcolor,
      body: isWideScreen(w)
          ? SingleChildScrollView(
              child: Row(children: <Widget>[
              Container(
                color: darken(fiberchatPRIMARYcolor, 15),
                height: h,
                width: w / 2.5,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppLogoPathLight,
                        width: (w / 2.5) / 1.5,
                        fit: BoxFit.fitWidth,
                      ),
                      SizedBox(
                        height: 7,
                      ),
                      SizedBox(
                        width: (w / 2.5) / 1.5,
                        child: Text(
                          AppTagline == ''
                              ? getTranslated(context, 'appdescription')
                              : AppTagline,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.1,
                              color: fiberchatPRIMARYcolor ==
                                      fiberchatSECONDARYolor
                                  ? fiberchatWhite.withOpacity(0.7)
                                  : lighten(fiberchatSECONDARYolor),
                              fontSize: 16,
                              height: 1.3),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                color: fiberchatPRIMARYcolor,
                height: h,
                width: w - (w / 2.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Language.languageList().length < 2
                              ? SizedBox(
                                  height: 40,
                                )
                              : Container(
                                  alignment: Alignment.centerRight,
                                  margin: EdgeInsets.only(top: 4, right: 10),
                                  width: 190,
                                  padding: EdgeInsets.all(8),
                                  child: DropdownButton<Language>(
                                    underline: SizedBox(),
                                    icon: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.language_outlined,
                                          color:
                                              fiberchatWhite.withOpacity(0.8),
                                        ),
                                        SizedBox(
                                          width: 2,
                                        ),
                                        SizedBox(
                                          width: 15,
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: fiberchatSECONDARYolor ==
                                                    fiberchatPRIMARYcolor
                                                ? Colors.white
                                                : fiberchatSECONDARYolor,
                                            size: 27,
                                          ),
                                        )
                                      ],
                                    ),
                                    onChanged: (Language? language) {
                                      _changeLanguage(language!);
                                    },
                                    items: Language.languageList()
                                        .map<DropdownMenuItem<Language>>(
                                          (e) => DropdownMenuItem<Language>(
                                            value: e,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  '' +
                                                      e.name +
                                                      '  ' +
                                                      e.flag +
                                                      ' ',
                                                  style:
                                                      TextStyle(fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    buildCurrentWidgetFORWEB(w - (w / 2.5), h)
                  ],
                ),
              )
            ]))
          : SingleChildScrollView(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[buildCurrentWidgetFORMOBILE(w, h)],
            )),
    ));
  }
}

//___CONSTRUCTORS----

class MySimpleButton extends StatefulWidget {
  final Color? buttoncolor;
  final Color? buttontextcolor;
  final Color? shadowcolor;
  final String? buttontext;
  final double? width;
  final double? height;
  final double? spacing;
  final double? borderradius;
  final Function? onpressed;

  MySimpleButton(
      {this.buttontext,
      this.buttoncolor,
      this.height,
      this.spacing,
      this.borderradius,
      this.width,
      this.buttontextcolor,
      // this.icon,
      this.onpressed,
      // this.forcewidget,
      this.shadowcolor});
  @override
  _MySimpleButtonState createState() => _MySimpleButtonState();
}

class _MySimpleButtonState extends State<MySimpleButton> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return GestureDetector(
        onTap: widget.onpressed as void Function()?,
        child: Container(
          alignment: Alignment.center,
          width: widget.width ?? w - 40,
          height: widget.height ?? 50,
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Text(
            widget.buttontext ?? getTranslated(this.context, 'submit'),
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: widget.spacing ?? 2,
              fontSize: 15,
              color: widget.buttontextcolor ?? Colors.white,
            ),
          ),
          decoration: BoxDecoration(
              color: widget.buttoncolor ?? Colors.primaries as Color?,
              //gradient: LinearGradient(colors: [bgColor, whiteColor]),
              boxShadow: [
                BoxShadow(
                    color: widget.shadowcolor ?? Colors.transparent,
                    blurRadius: 10,
                    spreadRadius: 2)
              ],
              border: Border.all(
                color: widget.buttoncolor ?? fiberchatPRIMARYcolor,
              ),
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.borderradius ?? 5))),
        ));
  }
}

class MobileInputWithOutline extends StatefulWidget {
  final String? initialCountryCode;
  final String? hintText;
  final double? height;
  final double? width;
  final TextEditingController? controller;
  final Color? borderColor;
  final Color? buttonTextColor;
  final Color? buttonhintTextColor;
  final TextStyle? hintStyle;
  final String? buttonText;
  final Function(PhoneNumber? phone)? onSaved;

  MobileInputWithOutline(
      {this.height,
      this.width,
      this.borderColor,
      this.buttonhintTextColor,
      this.hintStyle,
      this.buttonTextColor,
      this.onSaved,
      this.hintText,
      this.controller,
      this.initialCountryCode,
      this.buttonText});
  @override
  _MobileInputWithOutlineState createState() => _MobileInputWithOutlineState();
}

class _MobileInputWithOutlineState extends State<MobileInputWithOutline> {
  BoxDecoration boxDecoration(
      {double radius = 5,
      Color bgColor = Colors.white,
      var showShadow = false}) {
    return BoxDecoration(
        color: bgColor,
        boxShadow: showShadow
            ? [
                BoxShadow(
                    color: fiberchatPRIMARYcolor,
                    blurRadius: 10,
                    spreadRadius: 2)
              ]
            : [BoxShadow(color: Colors.transparent)],
        border:
            Border.all(color: widget.borderColor ?? Colors.grey, width: 1.5),
        borderRadius: BorderRadius.all(Radius.circular(radius)));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsetsDirectional.only(bottom: 7, top: 5),
          height: widget.height ?? 50,
          width: widget.width ?? MediaQuery.of(this.context).size.width,
          decoration: boxDecoration(),
          child: IntlPhoneField(
              searchText: "Search by Country / Region Name",
              dropDownArrowColor:
                  widget.buttonhintTextColor ?? Colors.grey[300],
              textAlign: TextAlign.left,
              initialCountryCode: widget.initialCountryCode,
              controller: widget.controller,
              style: TextStyle(
                  height: 1.35,
                  letterSpacing: 1,
                  fontSize: 16.0,
                  color: widget.buttonTextColor ?? Colors.black87,
                  fontWeight: FontWeight.bold),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(3, 15, 8, 0),
                  hintText: widget.hintText ??
                      getTranslated(this.context, 'enter_mobilenumber'),
                  hintStyle: widget.hintStyle ??
                      TextStyle(
                          letterSpacing: 1,
                          height: 0.0,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w400,
                          color: widget.buttonhintTextColor ?? fiberchatGrey),
                  fillColor: Colors.white,
                  filled: true,
                  border: new OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                    borderSide: BorderSide.none,
                  )),
              onChanged: (phone) {
                widget.onSaved!(phone);
              },
              validator: (v) {
                return null;
              },
              onSaved: widget.onSaved),
        ),
        // Positioned(
        //     left: 110,
        //     child: Container(
        //       width: 1.5,
        //       height: widget.height ?? 48,
        //       color: widget.borderColor ?? Colors.grey,
        //     ))
      ],
    );
  }
}

class InpuTextBox extends StatefulWidget {
  final Color? boxbcgcolor;
  final Color? boxbordercolor;
  final double? boxcornerradius;
  final double? fontsize;
  final double? boxwidth;
  final double? boxborderwidth;
  final double? boxheight;
  final EdgeInsets? forcedmargin;
  final double? letterspacing;
  final double? leftrightmargin;
  final TextEditingController? controller;
  final Function(String val)? validator;
  final Function(String? val)? onSaved;
  final Function(String val)? onchanged;
  final TextInputType? keyboardtype;
  final TextCapitalization? textCapitalization;

  final String? title;
  final String? subtitle;
  final String? hinttext;
  final String? placeholder;
  final int? maxLines;
  final int? minLines;
  final int? maxcharacters;
  final bool? isboldinput;
  final bool? obscuretext;
  final bool? autovalidate;
  final bool? disabled;
  final bool? showIconboundary;
  final Widget? sufficIconbutton;
  final List<TextInputFormatter>? inputFormatter;
  final Widget? prefixIconbutton;

  InpuTextBox(
      {this.controller,
      this.boxbordercolor,
      this.boxheight,
      this.fontsize,
      this.leftrightmargin,
      this.letterspacing,
      this.forcedmargin,
      this.boxwidth,
      this.boxcornerradius,
      this.boxbcgcolor,
      this.hinttext,
      this.boxborderwidth,
      this.onSaved,
      this.textCapitalization,
      this.onchanged,
      this.placeholder,
      this.showIconboundary,
      this.subtitle,
      this.disabled,
      this.keyboardtype,
      this.inputFormatter,
      this.validator,
      this.title,
      this.maxLines,
      this.autovalidate,
      this.prefixIconbutton,
      this.maxcharacters,
      this.isboldinput,
      this.obscuretext,
      this.sufficIconbutton,
      this.minLines});
  @override
  _InpuTextBoxState createState() => _InpuTextBoxState();
}

class _InpuTextBoxState extends State<InpuTextBox> {
  bool isobscuretext = false;
  @override
  void initState() {
    super.initState();
    setState(() {
      isobscuretext = widget.obscuretext ?? false;
    });
  }

  changeobscure() {
    setState(() {
      isobscuretext = !isobscuretext;
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(this.context).size.width;
    return Align(
      child: Container(
        margin: EdgeInsets.fromLTRB(
            widget.leftrightmargin ?? 8, 5, widget.leftrightmargin ?? 8, 5),
        width: widget.boxwidth ?? w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              // color: Colors.white,
              height: widget.boxheight ?? 50,
              // decoration: BoxDecoration(
              //     color: widget.boxbcgcolor ?? Colors.white,
              //     border: Border.all(
              //         color:
              //             widget.boxbordercolor ?? Mycolors.grey.withOpacity(0.2),
              //         style: BorderStyle.solid,
              //         width: 1.8),
              //     borderRadius: BorderRadius.all(
              //         Radius.circular(widget.boxcornerradius ?? 5))),
              child: TextFormField(
                minLines: widget.minLines ?? null,
                maxLines: widget.maxLines ?? 1,
                controller: widget.controller ?? null,
                obscureText: isobscuretext,
                onSaved: widget.onSaved ?? (val) {},
                readOnly: widget.disabled ?? false,
                onChanged: widget.onchanged ?? (val) {},
                maxLength: widget.maxcharacters ?? null,
                validator:
                    widget.validator as String? Function(String?)? ?? null,
                keyboardType: widget.keyboardtype ?? null,
                autovalidateMode: widget.autovalidate == true
                    ? AutovalidateMode.always
                    : AutovalidateMode.disabled,
                inputFormatters: widget.inputFormatter ?? [],
                textCapitalization:
                    widget.textCapitalization ?? TextCapitalization.sentences,
                style: TextStyle(
                  letterSpacing: widget.letterspacing ?? null,
                  fontSize: widget.fontsize ?? 15,
                  fontWeight: widget.isboldinput == true
                      ? FontWeight.w600
                      : FontWeight.w400,
                  // fontFamily:
                  //     widget.isboldinput == true ? 'NotoBold' : 'NotoRegular',
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                    prefixIcon: widget.prefixIconbutton != null
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(
                                    width: widget.boxborderwidth ?? 1.5,
                                    color: widget.showIconboundary == true ||
                                            widget.showIconboundary == null
                                        ? Colors.grey.withOpacity(0.3)
                                        : Colors.transparent),
                              ),
                              // color: Colors.white,
                            ),
                            margin: EdgeInsets.only(
                                left: 2, right: 5, top: 2, bottom: 2),
                            // height: 45,
                            alignment: Alignment.center,
                            width: 50,
                            child: widget.prefixIconbutton != null
                                ? widget.prefixIconbutton
                                : null)
                        : null,
                    suffixIcon: widget.sufficIconbutton != null ||
                            widget.obscuretext == true
                        ? Container(
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                    width: widget.boxborderwidth ?? 1.5,
                                    color: widget.showIconboundary == true ||
                                            widget.showIconboundary == null
                                        ? Colors.grey.withOpacity(0.3)
                                        : Colors.transparent),
                              ),
                              // color: Colors.white,
                            ),
                            margin: EdgeInsets.only(
                                left: 2, right: 5, top: 2, bottom: 2),
                            // height: 45,
                            alignment: Alignment.center,
                            width: 50,
                            child: widget.sufficIconbutton != null
                                ? widget.sufficIconbutton
                                : widget.obscuretext == true
                                    ? IconButton(
                                        icon: Icon(
                                            isobscuretext == true
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.blueGrey),
                                        onPressed: () {
                                          changeobscure();
                                        })
                                    : null)
                        : null,
                    filled: true,
                    fillColor: widget.boxbcgcolor ?? Colors.white,
                    enabledBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius:
                          BorderRadius.circular(widget.boxcornerradius ?? 1),
                      borderSide: BorderSide(
                          color: widget.boxbordercolor ??
                              Colors.grey.withOpacity(0.2),
                          width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      // width: 0.0 produces a thin "hairline" border
                      borderRadius:
                          BorderRadius.circular(widget.boxcornerradius ?? 1),
                      borderSide:
                          BorderSide(color: fiberchatPRIMARYcolor, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(widget.boxcornerradius ?? 1),
                        borderSide: BorderSide(color: Colors.grey)),
                    contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    // labelText: 'Password',
                    hintText: widget.hinttext ?? '',
                    // fillColor: widget.boxbcgcolor ?? Colors.white,

                    hintStyle: TextStyle(
                        letterSpacing: widget.letterspacing ?? 1.5,
                        color: fiberchatGrey,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
