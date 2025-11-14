//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
//androidIosBarrier
import 'dart:html' as html;
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Screens/Broadcast/AddContactsToBroadcast.dart';
import 'package:fiberchat_web/Screens/Groups/AddContactsToGroup.dart';
import 'package:fiberchat_web/Screens/SettingsOption/settingsOption.dart';
import 'package:fiberchat_web/Screens/contact_screens/syncedContacts.dart';
import 'package:fiberchat_web/Screens/homepage/Setupdata.dart';
import 'package:fiberchat_web/Screens/notifications/AllNotifications.dart';
import 'package:fiberchat_web/Screens/splash_screen/splash_screen.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/Providers/call_history_provider.dart';
import 'package:fiberchat_web/Services/localization/language.dart';
import 'package:fiberchat_web/Utils/custom_url_launcher.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/error_codes.dart';
import 'package:fiberchat_web/Utils/phonenumberVariantsGenerator.dart';

import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/auth_screens/login.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/profile_settings/profileSettings.dart';
import 'package:fiberchat_web/main.dart';
import 'package:fiberchat_web/Screens/recent_chats/RecentsChats.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Services/Providers/user_provider.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat_web/Utils/unawaited.dart';

class Homepage extends StatefulWidget {
  Homepage(
      {required this.currentUserNo,
      required this.prefs,
      required this.doc,
      this.isShowOnlyCircularSpin = false,
      key})
      : super(key: key);
  final String? currentUserNo;
  final DocumentSnapshot<Map<String, dynamic>> doc;
  final bool? isShowOnlyCircularSpin;
  final SharedPreferences prefs;
  @override
  State createState() => new HomepageState(doc: this.doc);
}

class HomepageState extends State<Homepage>
    with
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin,
        TickerProviderStateMixin {
  HomepageState({Key? key, doc}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }

  TabController? controllerIfcallNotallowed;
  TabController? controllerIfcallAllowed;

  @override
  bool get wantKeepAlive => true;

  bool isFetching = true;
  List phoneNumberVariants = [];
  int _tabTextIndexSelected = 0;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    if (widget.currentUserNo != null)
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.lastSeen: true,
        Dbkeys.lastOnline: DateTime.now().millisecondsSinceEpoch
      }, SetOptions(merge: true));
  }

  void setLastSeen() async {
    if (widget.currentUserNo != null)
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch},
              SetOptions(merge: true));
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  StreamSubscription? spokenSubscription;
  List<StreamSubscription> unreadSubscriptions =
      List.from(<StreamSubscription>[]);

  List<StreamController> controllers = List.from(<StreamController>[]);
  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  String? deviceid;
  var mapDeviceInfo = {};
  String? maintainanceMessage;
  bool isNotAllowEmulator = false;
  bool? isblockNewlogins = false;
  bool? isApprovalNeededbyAdminForNewUser = false;
  String? accountApprovalMessage = 'Account Approved';
  String? accountstatus;
  String? accountactionmessage;
  String? userPhotourl;
  String? userFullname;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getSignedInUserOrRedirect();
      setdeviceinfo();

      controllerIfcallNotallowed = TabController(length: 1, vsync: this);
      controllerIfcallNotallowed!.index = 0;
      controllerIfcallAllowed = TabController(length: 2, vsync: this);
      controllerIfcallAllowed!.index = 0;

      Fiberchat.internetLookUp();
      WidgetsBinding.instance.addObserver(this);

      getModel();
      //androidIosBarrier
      html.window.onBeforeUnload.listen((event) {
        if (widget.currentUserNo != null) {
          removeCurrentPeer();
        }
      });
      final el =
          html.window.document.getElementById('__ff-recaptcha-container');
      if (el != null) {
        el.style.visibility = 'hidden';
      }
    });
  }

  removeCurrentPeer() {
    final currentpeer =
        Provider.of<CurrentChatPeer>(this.context, listen: false);
    setGlobalLastSeen(
      widget.currentUserNo,
    );
    currentpeer.setLastSeenForPersonalChats(widget.currentUserNo);
  }

  // detectLocale() async {
  //   await Devicelocale.currentLocale.then((locale) async {
  //     if (locale == 'ja_JP' &&
  //         (widget.prefs.getBool('islanguageselected') == false ||
  //             widget.prefs.getBool('islanguageselected') == null)) {
  //       Locale _locale = await setLocale('ja');
  //       FiberchatWrapper.setLocale(context, _locale);
  //       setState(() {});
  //     }
  //   }).catchError((onError) {
  //     Fiberchat.toast(
  //       'Error occured while fetching Locale :$onError',
  //     );
  //   });
  // }

  incrementSessionCount(String myphone) async {
    final FirestoreDataProviderCALLHISTORY firestoreDataProviderCALLHISTORY =
        Provider.of<FirestoreDataProviderCALLHISTORY>(context, listen: false);

    await FirebaseFirestore.instance
        .collection(DbPaths.collectiondashboard)
        .doc(DbPaths.docuserscount)
        .set({
      Dbkeys.totalvisitsWEB: FieldValue.increment(1),
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserNo)
        .set({
      Dbkeys.isNotificationStringsMulitilanguageEnabled: true,
      Dbkeys.notificationStringsMap:
          getTranslateNotificationStringsMap(this.context),
      Dbkeys.totalvisitsWEB: FieldValue.increment(1),
    }, SetOptions(merge: true));
    firestoreDataProviderCALLHISTORY.fetchNextData(
        'CALLHISTORY',
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.currentUserNo)
            .collection(DbPaths.collectioncallhistory)
            .orderBy('TIME', descending: true)
            .limit(10),
        true);
    if (OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == false) {}

    //  await statusProvider.searchContactStatus(
    //       myphone, contactsProvider.joinedUserPhoneStringAsInServer);

    // if (_sharedFiles!.length > 0 || _sharedText != null) {
    //   triggerSharing();
    // }
  }
  // IsRequirefocus;
  // triggerSharing() {
  //   final observer = Provider.of<Observer>(this.context, listen: false);
  //   if (_sharedText != null) {
  //     Navigator.push(
  //         context,
  //         new MaterialPageRoute(
  //             builder: (context) => new SelectContactToShare(
  //                 prefs: widget.prefs,
  //                 model: _cachedModel!,
  //                 currentUserNo: widget.currentUserNo,
  //                 sharedFiles: _sharedFiles!,
  //                 sharedText: _sharedText)));
  //   } else if (_sharedFiles != null) {
  //     if (_sharedFiles!.length > observer.maxNoOfFilesInMultiSharing) {
  //       Fiberchat.toast(getTranslated(context, 'maxnooffiles') +
  //           ' ' +
  //           '${observer.maxNoOfFilesInMultiSharing}');
  //     } else {
  //       Navigator.push(
  //           context,
  //           new MaterialPageRoute(
  //               builder: (context) => new SelectContactToShare(
  //                   prefs: widget.prefs,
  //                   model: _cachedModel!,
  //                   currentUserNo: widget.currentUserNo,
  //                   sharedFiles: _sharedFiles!,
  //                   sharedText: _sharedText)));
  //     }
  //   }
  // }
  // IsRequirefocus;
  // listenToSharingintent() {
  //   // For sharing images coming from outside the app while the app is in the memory
  //   _intentDataStreamSubscription = ReceiveSharingIntent.getMediaStream()
  //       .listen((List<SharedMediaFile> value) {
  //     setState(() {
  //       _sharedFiles = value;
  //     });
  //   }, onError: (err) {
  //     print("getIntentDataStream error: $err");
  //   });

  //   // For sharing images coming from outside the app while the app is closed
  //   ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
  //     setState(() {
  //       _sharedFiles = value;
  //     });
  //   });

  //   // For sharing or opening urls/text coming from outside the app while the app is in the memory
  //   _intentDataStreamSubscription =
  //       ReceiveSharingIntent.getTextStream().listen((String value) {
  //     setState(() {
  //       _sharedText = value;
  //     });
  //   }, onError: (err) {
  //     print("getLinkStream error: $err");
  //   });

  //   // For sharing or opening urls/text coming from outside the app while the app is closed
  //   ReceiveSharingIntent.getInitialText().then((String? value) {
  //     setState(() {
  //       _sharedText = value;
  //     });
  //   });
  // }

  unsubscribeToNotification(String? userphone) async {
    // if (userphone != null) {
    //   await FirebaseMessaging.instance.unsubscribeFromTopic(
    //       '${userphone.replaceFirst(new RegExp(r'\+'), '')}');
    // }

    // await FirebaseMessaging.instance
    //     .unsubscribeFromTopic(Dbkeys.topicUSERS)
    //     .catchError((err) {
    //   print(err.toString());
    // });
    // await FirebaseMessaging.instance
    //     .unsubscribeFromTopic(Dbkeys.topicUSERSweb)
    //     .catchError((err) {
    //   print(err.toString());
    // });
  }

  setdeviceinfo() async {
    // IsRequirefocus;
    setState(() {
      deviceid = "xxxx";
      mapDeviceInfo = {
        Dbkeys.deviceInfoMODEL: "web",
        Dbkeys.deviceInfoOS: 'web',
        Dbkeys.deviceInfoISPHYSICAL: true,
        Dbkeys.deviceInfoDEVICEID: "web",
        Dbkeys.deviceInfoOSID: "web",
        Dbkeys.deviceInfoOSVERSION: "web",
        Dbkeys.deviceInfoMANUFACTURER: "web",
        Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
      };
    });
  }

  getuid(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.getUserDetails(widget.currentUserNo);
  }

  logout(BuildContext context) async {
    if (widget.currentUserNo != null) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserNo)
          .set({
        Dbkeys.webLoginTime: FieldValue.delete(),
      }, SetOptions(merge: true));
    }
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    await firebaseAuth.signOut();

    await widget.prefs.clear();

    FlutterSecureStorage storage = new FlutterSecureStorage();
    // ignore: await_only_futures
    await storage.delete;

    await widget.prefs.setBool(Dbkeys.isTokenGenerated, false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (BuildContext context) => FiberchatWrapper(),
      ),
      (Route route) => false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    controllers.forEach((controller) {
      controller.close();
    });
    _filter.dispose();
    spokenSubscription?.cancel();
    _userQuery.close();
    cancelUnreadSubscriptions();
    setLastSeen();
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  void listenToNotification() async {
    //FOR ANDROID & IOS  background notification is handled at the very top of main.dart ------

    //ANDROID & iOS  OnMessage callback
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    //   // ignore: unnecessary_null_comparison
    //   // flutterLocalNotificationsPlugin..cancelAll();
    //   Fiberchat.toast(message.data['title']);
    //   if (message.data['title'] != 'Call Ended' &&
    //       message.data['title'] != 'Missed Call' &&
    //       message.data['title'] != 'You have new message(s)' &&
    //       message.data['title'] != 'Incoming Video Call...' &&
    //       message.data['title'] != 'Incoming Audio Call...' &&
    //       message.data['title'] != 'Incoming Call ended' &&
    //       message.data['title'] != 'New message in Group') {
    //     Fiberchat.toast(getTranslated(this.context, 'newnotifications'));
    //   } else {
    //     if (message.data['title'] == 'New message in Group') {
    //     } else if (message.data['title'] == 'Call Ended') {
    //     } else {
    //       if (message.data['title'] == 'Incoming Audio Call...' ||
    //           message.data['title'] == 'Incoming Video Call...') {
    //         Fiberchat.toast(message.data['title']);
    //       } else if (message.data['title'] == 'You have new message(s)') {
    //         var currentpeer =
    //             Provider.of<CurrentChatPeer>(this.context, listen: false);
    //         if (currentpeer.peerid != message.data['peerid']) {
    //           Fiberchat.toast(message.data['title']);
    //         }
    //       } else {
    //         Fiberchat.toast(message.data['title']);
    //       }
    //     }
    //   }
    // });
    // //ANDROID & iOS  onMessageOpenedApp callback
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    //   // flutterLocalNotificationsPlugin..cancelAll();
    //   Map<String, dynamic> notificationData = message.data;
    //   AndroidNotification? android = message.notification?.android;
    //   if (android != null) {
    //     if (notificationData['title'] == 'Call Ended') {
    //       // flutterLocalNotificationsPlugin..cancelAll();
    //     } else if (notificationData['title'] != 'Call Ended' &&
    //         notificationData['title'] != 'You have new message(s)' &&
    //         notificationData['title'] != 'Missed Call' &&
    //         notificationData['title'] != 'Incoming Video Call...' &&
    //         notificationData['title'] != 'Incoming Audio Call...' &&
    //         notificationData['title'] != 'Incoming Call ended' &&
    //         notificationData['title'] != 'New message in Group') {
    //       // flutterLocalNotificationsPlugin..cancelAll();

    //       Navigator.push(
    //           context,
    //           new MaterialPageRoute(
    //               builder: (context) => AllNotifications(
    //                     prefs: widget.prefs,
    //                   )));
    //     } else {
    //       // flutterLocalNotificationsPlugin..cancelAll();
    //     }
    //   }
    // });
    // FirebaseMessaging.instance.getInitialMessage().then((message) {
    //   if (message != null) {
    //     // flutterLocalNotificationsPlugin..cancelAll();
    //     Map<String, dynamic>? notificationData = message.data;
    //     if (notificationData['title'] != 'Call Ended' &&
    //         notificationData['title'] != 'You have new message(s)' &&
    //         notificationData['title'] != 'Missed Call' &&
    //         notificationData['title'] != 'Incoming Video Call...' &&
    //         notificationData['title'] != 'Incoming Audio Call...' &&
    //         notificationData['title'] != 'Incoming Call ended' &&
    //         notificationData['title'] != 'New message in Group') {
    //       // flutterLocalNotificationsPlugin..cancelAll();

    //       Navigator.push(
    //           context,
    //           new MaterialPageRoute(
    //               builder: (context) => AllNotifications(
    //                     prefs: widget.prefs,
    //                   )));
    //     }
    //   }
    // });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  DataModel? getModel() {
    _cachedModel ??= DataModel(widget.currentUserNo);
    return _cachedModel;
  }

  getSignedInUserOrRedirect() async {
    try {
      setState(() {
        isblockNewlogins = widget.doc.data()![Dbkeys.isblocknewlogins];
        isApprovalNeededbyAdminForNewUser =
            widget.doc[Dbkeys.isaccountapprovalbyadminneeded];
        accountApprovalMessage = widget.doc[Dbkeys.accountapprovalmessage];
      });
      if (widget.doc.data()![Dbkeys.isemulatorallowed] == false &&
          mapDeviceInfo[Dbkeys.deviceInfoISPHYSICAL] == false) {
        setState(() {
          isNotAllowEmulator = true;
        });
      } else {
        if (widget.doc[Dbkeys.isappunderconstructionweb] == true) {
          await unsubscribeToNotification(widget.currentUserNo);
          maintainanceMessage = widget.doc[Dbkeys.maintainancemessage];
          setState(() {});
        } else {
          final PackageInfo info = await PackageInfo.fromPlatform();
          widget.prefs.setString('app_version', info.version);

          int currentAppVersionInPhone = int.tryParse(info.version
                      .trim()
                      .split(".")[0]
                      .toString()
                      .padLeft(3, '0') +
                  info.version.trim().split(".")[1].toString().padLeft(3, '0') +
                  info.version
                      .trim()
                      .split(".")[2]
                      .toString()
                      .padLeft(3, '0')) ??
              0;
          int currentNewAppVersionInServer = int.tryParse(widget
                      .doc[Dbkeys.latestappversionweb]
                      .trim()
                      .split(".")[0]
                      .toString()
                      .padLeft(3, '0') +
                  widget.doc[Dbkeys.latestappversionweb]
                      .trim()
                      .split(".")[1]
                      .toString()
                      .padLeft(3, '0') +
                  widget.doc[Dbkeys.latestappversionweb]
                      .trim()
                      .split(".")[2]
                      .toString()
                      .padLeft(3, '0')) ??
              0;
          if (currentAppVersionInPhone < currentNewAppVersionInServer) {
            showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                String title = getTranslated(context, 'updateavl');
                String message = getTranslated(context, 'updateavlmsg');

                String btnLabel = getTranslated(context, 'updatnow');

                return new WillPopScope(
                    onWillPop: () async => false,
                    child: AlertDialog(
                      title: Text(
                        title,
                        style: TextStyle(color: fiberchatGrey),
                      ),
                      content: Text(message),
                      actions: <Widget>[
                        TextButton(
                            child: Text(
                              btnLabel,
                              style: TextStyle(color: fiberchatSECONDARYolor),
                            ),
                            onPressed: () => custom_url_launcher(
                                widget.doc[Dbkeys.newapplinkweb])),
                      ],
                    ));
              },
            );
          } else {
            final observer = Provider.of<Observer>(this.context, listen: false);

            observer.setObserver(
              getuserAppSettingsDoc: widget.doc,
              getandroidapplink:
                  widget.doc.data()!.containsKey(Dbkeys.newapplinkandroid)
                      ? widget.doc[Dbkeys.newapplinkandroid]
                      : "",
              getiosapplink:
                  widget.doc.data()!.containsKey(Dbkeys.newapplinkios)
                      ? widget.doc[Dbkeys.newapplinkios]
                      : "",
              getwebapplink:
                  widget.doc.data()!.containsKey(Dbkeys.newapplinkweb)
                      ? widget.doc[Dbkeys.newapplinkweb]
                      : "",
              getisadmobshow: widget.doc.data()!.containsKey(Dbkeys.isadmobshow)
                  ? widget.doc[Dbkeys.isadmobshow]
                  : false,
              getismediamessagingallowed:
                  widget.doc.data()!.containsKey(Dbkeys.ismediamessageallowed)
                      ? widget.doc[Dbkeys.ismediamessageallowed]
                      : true,
              getistextmessagingallowed:
                  widget.doc.data()!.containsKey(Dbkeys.istextmessageallowed)
                      ? widget.doc[Dbkeys.istextmessageallowed]
                      : true,
              getiscallsallowed:
                  widget.doc.data()!.containsKey(Dbkeys.iscallsallowed)
                      ? widget.doc[Dbkeys.iscallsallowed]
                      : true,
              gettnc: widget.doc.data()!.containsKey(Dbkeys.tnc)
                  ? widget.doc[Dbkeys.tnc]
                  : "",
              gettncType: widget.doc[Dbkeys.tncTYPE],
              getprivacypolicy:
                  widget.doc.data()!.containsKey(Dbkeys.privacypolicy)
                      ? widget.doc[Dbkeys.privacypolicy]
                      : "",
              getprivacypolicyType: widget.doc[Dbkeys.privacypolicyTYPE],
              getis24hrsTimeformat:
                  widget.doc.data()!.containsKey(Dbkeys.is24hrsTimeformat)
                      ? widget.doc[Dbkeys.is24hrsTimeformat]
                      : false,
              getmaxFileSizeAllowedInMB:
                  widget.doc[Dbkeys.maxFileSizeAllowedInMB],
              getisPercentProgressShowWhileUploading:
                  widget.doc[Dbkeys.isPercentProgressShowWhileUploading],
              getisCallFeatureTotallyHide:
                  widget.doc[Dbkeys.isCallFeatureTotallyHide],
              getgroupMemberslimit: widget.doc[Dbkeys.groupMemberslimit],
              getbroadcastMemberslimit:
                  widget.doc[Dbkeys.broadcastMemberslimit],
              getstatusDeleteAfterInHours:
                  widget.doc[Dbkeys.statusDeleteAfterInHours],
              getfeedbackEmail: widget.doc[Dbkeys.feedbackEmail],
              getisLogoutButtonShowInSettingsPage:
                  widget.doc[Dbkeys.isLogoutButtonShowInSettingsPage],
              getisAllowCreatingGroups:
                  widget.doc[Dbkeys.isAllowCreatingGroups],
              getisAllowCreatingBroadcasts:
                  widget.doc[Dbkeys.isAllowCreatingBroadcasts],
              getisAllowCreatingStatus:
                  widget.doc[Dbkeys.isAllowCreatingStatus],
              getmaxNoOfFilesInMultiSharing:
                  widget.doc[Dbkeys.maxNoOfFilesInMultiSharing],
              getmaxNoOfContactsSelectForForward:
                  widget.doc[Dbkeys.maxNoOfContactsSelectForForward],
              getappShareMessageStringWeb:
                  widget.doc[Dbkeys.appShareMessageStringWeb],
              getappShareMessageStringiOS: widget.doc
                      .data()!
                      .containsKey(Dbkeys.appShareMessageStringiOS)
                  ? widget.doc[Dbkeys.appShareMessageStringiOS]
                  : '',
              getisCustomAppShareLink: widget.doc[Dbkeys.isCustomAppShareLink],
            );

            if (widget.currentUserNo == null || widget.currentUserNo!.isEmpty) {
              unawaited(Navigator.pushReplacement(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new LoginScreen(
                            prefs: widget.prefs,
                            accountApprovalMessage: accountApprovalMessage,
                            isaccountapprovalbyadminneeded:
                                isApprovalNeededbyAdminForNewUser,
                            isblocknewlogins: isblockNewlogins,
                            title: getTranslated(context, 'signin'),
                            doc: widget.doc,
                          ))));
            } else {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionusers)
                  .doc(widget.currentUserNo ?? widget.currentUserNo)
                  .get()
                  .then((userDoc) async {
                // if (deviceid != userDoc[Dbkeys.currentDeviceID] ||
                //     !userDoc.data()!.containsKey(Dbkeys.currentDeviceID)) {
                //   if (ConnectWithAdminApp == true) {
                //     await unsubscribeToNotification(widget.currentUserNo);
                //   }
                //   await logout(context);
                // } else {
                if (!userDoc.data()!.containsKey(Dbkeys.accountstatus) ||
                    !userDoc.data()!.containsKey(Dbkeys.webLoginTime)) {
                  await logout(context);
                } else if (userDoc[Dbkeys.accountstatus] !=
                    Dbkeys.sTATUSallowed) {
                  if (userDoc[Dbkeys.accountstatus] == Dbkeys.sTATUSdeleted) {
                    setState(() {
                      accountstatus = userDoc[Dbkeys.accountstatus];
                      accountactionmessage = userDoc[Dbkeys.actionmessage];
                    });
                  } else {
                    setState(() {
                      accountstatus = userDoc[Dbkeys.accountstatus];
                      accountactionmessage = userDoc[Dbkeys.actionmessage];
                    });
                  }
                } else {
                  final SmartContactProviderWithLocalStoreData
                      contactsProvider =
                      Provider.of<SmartContactProviderWithLocalStoreData>(
                          context,
                          listen: false);

                  await contactsProvider.fetchLocalUsersFromPrefs(
                      widget.prefs, context, widget.currentUserNo!);
                  setState(() {
                    userFullname = userDoc[Dbkeys.nickname];
                    userPhotourl = userDoc[Dbkeys.photoUrl];
                    phoneNumberVariants = phoneNumberVariantsList(
                        countrycode: userDoc[Dbkeys.countryCode],
                        phonenumber: userDoc[Dbkeys.phoneRaw]);
                    isFetching = false;
                  });
                  getuid(context);
                  setIsActive();

                  incrementSessionCount(userDoc[Dbkeys.phone]);
                }
                // }
              });
            }
          }
        }
      }
    } catch (e) {
      showERRORSheet(this.context, "", message: e.toString());
    }
  }

  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();
  void _changeLanguage(Language language) async {
    Locale _locale = await setLocale(language.languageCode);
    FiberchatWrapper.setLocale(context, _locale);
    if (widget.currentUserNo != null) {
      Future.delayed(const Duration(milliseconds: 800), () {
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(widget.currentUserNo)
            .set({
          Dbkeys.notificationStringsMap:
              getTranslateNotificationStringsMap(this.context),
        }, SetOptions(merge: true));
      });
    }
    await widget.prefs.setBool('islanguageselected', true);
    unawaited(Navigator.pushReplacement(this.context,
        new MaterialPageRoute(builder: (context) => FiberchatWrapper())));
  }

  DateTime? currentBackPressTime = DateTime.now();
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime!) > Duration(seconds: 3)) {
      currentBackPressTime = now;
      Fiberchat.toast('Double Tap To Go Back');
      return Future.value(false);
    } else {
      if (!isAuthenticating) setLastSeen();
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    final observer = Provider.of<Observer>(context, listen: true);
    final currentpeer = Provider.of<CurrentChatPeer>(context, listen: true);
    bool isWideScreenMode = w > 820;
    return isNotAllowEmulator == true
        ? errorScreen(
            'Emulator Not Allowed.', ' Please use any real device & Try again.')
        : accountstatus != null
            ? errorScreen(accountstatus, accountactionmessage)
            : ConnectWithAdminApp == true && maintainanceMessage != null
                ? errorScreen('App Under maintainance', maintainanceMessage)
                : ConnectWithAdminApp == true && isFetching == true
                    ? Splashscreen(
                        isShowOnlySpinner: widget.isShowOnlyCircularSpin,
                      )
                    : PickupLayout(
                        prefs: widget.prefs,
                        scaffold: Fiberchat.getNTPWrappedWidget(WillPopScope(
                          onWillPop: () async => false,
                          child: isWideScreenMode
                              ? Scaffold(
                                  body: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Container(
                                        color: Colors.white,
                                        width: w / 3,
                                        child: ListView(
                                          padding: EdgeInsets.all(0),
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: [
                                            Container(
                                                height: AppBar()
                                                        .preferredSize
                                                        .height +
                                                    2.6,
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        width: 4.0,
                                                        color: Colors
                                                            .blueGrey[50]!),
                                                  ),
                                                  color: fiberchatWhite,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          14, 6, 18, 6),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (_cachedModel != null)
                                                        if (_cachedModel!
                                                                .currentUser !=
                                                            null)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    13,
                                                                    0,
                                                                    5,
                                                                    0),
                                                            child: customCircleAvatar(
                                                                url: _cachedModel!
                                                                        .currentUser![
                                                                    Dbkeys
                                                                        .photoUrl],
                                                                radius: 41),
                                                          ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Language.languageList()
                                                                      .length <
                                                                  2
                                                              ? SizedBox()
                                                              : Container(
                                                                  alignment:
                                                                      Alignment
                                                                          .centerRight,
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          top:
                                                                              0),
                                                                  width: 120,
                                                                  child: DropdownButton<
                                                                      Language>(
                                                                    // iconSize: 40,

                                                                    isExpanded:
                                                                        true,
                                                                    underline:
                                                                        SizedBox(),
                                                                    icon:
                                                                        Container(
                                                                      width: 60,
                                                                      height:
                                                                          30,
                                                                      child:
                                                                          Row(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.language_outlined,
                                                                            color:
                                                                                fiberchatPRIMARYcolor,
                                                                            size:
                                                                                22,
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                1,
                                                                          ),
                                                                          Icon(
                                                                            Icons.keyboard_arrow_down,
                                                                            color:
                                                                                fiberchatPRIMARYcolor,
                                                                            size:
                                                                                17,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    onChanged:
                                                                        (Language?
                                                                            language) {
                                                                      _changeLanguage(
                                                                          language!);
                                                                    },
                                                                    items: Language
                                                                            .languageList()
                                                                        .map<
                                                                            DropdownMenuItem<Language>>(
                                                                          (e) =>
                                                                              DropdownMenuItem<Language>(
                                                                            value:
                                                                                e,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  IsShowLanguageNameInNativeLanguage == true ? '' + e.name + '  ' + e.flag + ' ' : ' ' + e.languageNameInEnglish + '  ' + e.flag + ' ',
                                                                                  style: TextStyle(fontSize: 13),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                        .toList(),
                                                                  ),
                                                                ),
                                                          IconButton(
                                                              onPressed: () {
                                                                final currentpeer =
                                                                    Provider.of<
                                                                            CurrentChatPeer>(
                                                                        this
                                                                            .context,
                                                                        listen:
                                                                            false);
                                                                currentpeer
                                                                    .setLastSeenForPersonalChats(
                                                                  widget
                                                                      .currentUserNo,
                                                                );

                                                                setGlobalLastSeen(
                                                                  widget
                                                                      .currentUserNo,
                                                                );
                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder: (context) => new SyncedContacts(
                                                                            onTapCreateGroup: () {
                                                                              if (observer.isAllowCreatingGroups == false) {
                                                                                Fiberchat.showRationale(getTranslated(this.context, 'disabled'));
                                                                              } else {
                                                                                Navigator.pushReplacement(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => AddContactsToGroup(
                                                                                              currentUserNo: widget.currentUserNo,
                                                                                              model: _cachedModel,
                                                                                              biometricEnabled: false,
                                                                                              prefs: widget.prefs,
                                                                                              isAddingWhileCreatingGroup: true,
                                                                                            )));
                                                                              }
                                                                            },
                                                                            onTapCreateBroadcast: () {
                                                                              if (observer.isAllowCreatingBroadcasts == false) {
                                                                                Fiberchat.showRationale(getTranslated(this.context, 'disabled'));
                                                                              } else {
                                                                                Navigator.pushReplacement(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                        builder: (context) => AddContactsToBroadcast(
                                                                                              currentUserNo: widget.currentUserNo,
                                                                                              model: _cachedModel,
                                                                                              biometricEnabled: false,
                                                                                              prefs: widget.prefs,
                                                                                              isAddingWhileCreatingBroadcast: true,
                                                                                            )));
                                                                              }
                                                                            },
                                                                            prefs: widget.prefs,
                                                                            biometricEnabled: biometricEnabled,
                                                                            currentUserNo: widget.currentUserNo!,
                                                                            model: _cachedModel!)));
                                                              },
                                                              icon: Icon(
                                                                Icons.people,
                                                                color:
                                                                    fiberchatPRIMARYcolor,
                                                              )),
                                                          IconButton(
                                                              onPressed: () {
                                                                final currentpeer =
                                                                    Provider.of<
                                                                            CurrentChatPeer>(
                                                                        this
                                                                            .context,
                                                                        listen:
                                                                            false);
                                                                currentpeer
                                                                    .setLastSeenForPersonalChats(
                                                                  widget
                                                                      .currentUserNo,
                                                                );

                                                                setGlobalLastSeen(
                                                                  widget
                                                                      .currentUserNo,
                                                                );

                                                                Navigator.push(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            SettingsOption(
                                                                              prefs: widget.prefs,
                                                                              onTapLogout: () async {
                                                                                await logout(context);
                                                                              },
                                                                              onTapEditProfile: () {
                                                                                Navigator.push(
                                                                                    context,
                                                                                    new MaterialPageRoute(
                                                                                        builder: (context) => ProfileSetting(
                                                                                              prefs: widget.prefs,
                                                                                              biometricEnabled: biometricEnabled,
                                                                                              type: Fiberchat.getAuthenticationType(biometricEnabled, _cachedModel),
                                                                                            )));
                                                                              },
                                                                              currentUserNo: widget.currentUserNo!,
                                                                              biometricEnabled: biometricEnabled,
                                                                              type: Fiberchat.getAuthenticationType(biometricEnabled, _cachedModel),
                                                                            )));
                                                              },
                                                              icon: Icon(
                                                                Icons.settings,
                                                                color:
                                                                    fiberchatPRIMARYcolor,
                                                              )),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                )),
                                            if (observer.iscallsallowed)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        15, 10, 15, 10),
                                                child: Center(
                                                  child: Container(
                                                    width:
                                                        getContentScreenWidth(
                                                                w) /
                                                            1.6,
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: FlutterToggleTab(
                                                        isShadowEnable: false,
                                                        // width in percent
                                                        width: 30,
                                                        borderRadius: 20,
                                                        height: 35,
                                                        unSelectedBackgroundColors: [
                                                          appbarColor
                                                        ],
                                                        selectedIndex:
                                                            _tabTextIndexSelected,
                                                        selectedBackgroundColors: [
                                                          fiberchatSECONDARYolor,
                                                          fiberchatSECONDARYolor
                                                        ],
                                                        selectedTextStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                        unSelectedTextStyle:
                                                            TextStyle(
                                                                color: Colors
                                                                    .black87,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                        labels: [
                                                          getTranslated(
                                                              context, 'chats'),
                                                          getTranslated(
                                                              context, 'calls')
                                                        ],
                                                        selectedLabelIndex:
                                                            (index) {
                                                          setState(() {
                                                            _tabTextIndexSelected =
                                                                index;
                                                          });
                                                          if (index == 1) {
                                                            // final currentpeer =
                                                            //     Provider.of<
                                                            //             CurrentChatPeer>(
                                                            //         this
                                                            //             .context,
                                                            //         listen:
                                                            //             false);
                                                            // currentpeer.setLastSeenForPersonalChats(
                                                            //     widget
                                                            //         .currentUserNo,
                                                            //     currentpeer
                                                            //         .toSetOfflineChatID);

                                                            // setLastSeen();
                                                          } else {
                                                            setIsActive();
                                                          }
                                                        },
                                                        isScroll: false,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            Container(
                                              height: h,
                                              child: _tabTextIndexSelected == 0
                                                  ? RecentChats(
                                                      tileWidth: w / 3,
                                                      isWideScreenMode: true,
                                                      prefs: widget.prefs,
                                                      currentUserNo:
                                                          widget.currentUserNo,
                                                      isSecuritySetupDone:
                                                          false)
                                                  : CallHistory(
                                                      userphone:
                                                          widget.currentUserNo,
                                                      model: _cachedModel,
                                                      prefs: widget.prefs),
                                            ),
                                          ],
                                        )),
                                    currentpeer.currentWidget == null
                                        ? Container(
                                            color: fiberchatScaffold,
                                            width: w - (w / 3),
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.devices,
                                                    color:
                                                        fiberchatSECONDARYolor,
                                                    size: w / 13,
                                                  ),
                                                  SizedBox(height: 30),
                                                  Text(
                                                    Appname,
                                                    style: TextStyle(
                                                        color: fiberchatBlack,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 22,
                                                        height: 1.3),
                                                  ),
                                                  SizedBox(height: 10),
                                                  SizedBox(
                                                    width: (w - (w / 3)) / 1.6,
                                                    child: Text(
                                                      AppTagline == ''
                                                          ? getTranslated(
                                                              context,
                                                              'appdescription')
                                                          : AppTagline,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: fiberchatGrey,
                                                          fontSize: 14,
                                                          height: 1.3),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: w - (w / 3),
                                            child: currentpeer.currentWidget,
                                          ),
                                  ],
                                ))
                              : Scaffold(
                                  backgroundColor: Colors.white,
                                  appBar: AppBar(
                                      elevation: 0.4,
                                      backgroundColor: fiberchatWhite,
                                      title: Row(
                                        children: [
                                          if (_cachedModel != null)
                                            if (_cachedModel!.currentUser !=
                                                null)
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        6, 0, 5, 0),
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        new MaterialPageRoute(
                                                            builder: (context) =>
                                                                SettingsOption(
                                                                  prefs: widget
                                                                      .prefs,
                                                                  onTapLogout:
                                                                      () async {
                                                                    await logout(
                                                                        context);
                                                                  },
                                                                  onTapEditProfile:
                                                                      () {
                                                                    Navigator.push(
                                                                        context,
                                                                        new MaterialPageRoute(
                                                                            builder: (context) => ProfileSetting(
                                                                                  prefs: widget.prefs,
                                                                                  biometricEnabled: biometricEnabled,
                                                                                  type: Fiberchat.getAuthenticationType(biometricEnabled, _cachedModel),
                                                                                )));
                                                                  },
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo!,
                                                                  biometricEnabled:
                                                                      biometricEnabled,
                                                                  type: Fiberchat
                                                                      .getAuthenticationType(
                                                                          biometricEnabled,
                                                                          _cachedModel),
                                                                )));
                                                  },
                                                  child: customCircleAvatar(
                                                      url: _cachedModel!
                                                              .currentUser![
                                                          Dbkeys.photoUrl],
                                                      radius: 35),
                                                ),
                                              ),
                                        ],
                                      ),
                                      titleSpacing: 10,
                                      actions: <Widget>[
//
                                        Language.languageList().length < 2
                                            ? SizedBox()
                                            : Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                margin: EdgeInsets.only(top: 4),
                                                width: 120,
                                                child: DropdownButton<Language>(
                                                  // iconSize: 40,

                                                  isExpanded: true,
                                                  underline: SizedBox(),
                                                  icon: Container(
                                                    width: 60,
                                                    height: 30,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .language_outlined,
                                                          color: fiberchatBlack
                                                              .withOpacity(0.7),
                                                          size: 22,
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Icon(
                                                          Icons
                                                              .keyboard_arrow_down,
                                                          color:
                                                              fiberchatPRIMARYcolor,
                                                          size: 27,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  onChanged:
                                                      (Language? language) {
                                                    _changeLanguage(language!);
                                                  },
                                                  items: Language.languageList()
                                                      .map<
                                                          DropdownMenuItem<
                                                              Language>>(
                                                        (e) => DropdownMenuItem<
                                                            Language>(
                                                          value: e,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: <Widget>[
                                                              Text(
                                                                IsShowLanguageNameInNativeLanguage ==
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
                                                                        ' ',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                                ),
                                              ),
// // //---- All localizations settings----
                                        PopupMenuButton(
                                            padding: EdgeInsets.all(0),
                                            icon: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 1),
                                              child: Icon(
                                                Icons.more_vert_outlined,
                                                color: fiberchatBlack,
                                              ),
                                            ),
                                            color: fiberchatWhite,
                                            onSelected: (dynamic val) async {
                                              switch (val) {
                                                case 'rate':
                                                  break;
                                                case 'tutorials':
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return SimpleDialog(
                                                          contentPadding:
                                                              EdgeInsets.all(
                                                                  20),
                                                          children: <Widget>[
                                                            ListTile(
                                                              title: Text(
                                                                getTranslated(
                                                                    context,
                                                                    'swipeview'),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            ListTile(
                                                                title: Text(
                                                              getTranslated(
                                                                  context,
                                                                  'swipehide'),
                                                            )),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            ListTile(
                                                                title: Text(
                                                              getTranslated(
                                                                  context,
                                                                  'lp_setalias'),
                                                            ))
                                                          ],
                                                        );
                                                      });
                                                  break;
                                                case 'privacy':
                                                  break;
                                                case 'tnc':
                                                  break;
                                                case 'share':
                                                  break;
                                                case 'notifications':
                                                  Navigator.push(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              AllNotifications(
                                                                prefs: widget
                                                                    .prefs,
                                                              )));

                                                  break;
                                                case 'feedback':
                                                  break;
                                                case 'logout':
                                                  break;
                                                case 'settings':
                                                  Navigator.push(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (context) =>
                                                              SettingsOption(
                                                                prefs: widget
                                                                    .prefs,
                                                                onTapLogout:
                                                                    () async {
                                                                  await logout(
                                                                      context);
                                                                },
                                                                onTapEditProfile:
                                                                    () {
                                                                  Navigator.push(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => ProfileSetting(
                                                                                prefs: widget.prefs,
                                                                                biometricEnabled: biometricEnabled,
                                                                                type: Fiberchat.getAuthenticationType(biometricEnabled, _cachedModel),
                                                                              )));
                                                                },
                                                                currentUserNo:
                                                                    widget
                                                                        .currentUserNo!,
                                                                biometricEnabled:
                                                                    biometricEnabled,
                                                                type: Fiberchat
                                                                    .getAuthenticationType(
                                                                        biometricEnabled,
                                                                        _cachedModel),
                                                              )));

                                                  break;
                                                case 'group':
                                                  if (observer
                                                          .isAllowCreatingGroups ==
                                                      false) {
                                                    Fiberchat.showRationale(
                                                        getTranslated(
                                                            this.context,
                                                            'disabled'));
                                                  } else {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddContactsToGroup(
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo,
                                                                  model:
                                                                      _cachedModel,
                                                                  biometricEnabled:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  isAddingWhileCreatingGroup:
                                                                      true,
                                                                )));
                                                  }
                                                  break;

                                                case 'broadcast':
                                                  if (observer
                                                          .isAllowCreatingBroadcasts ==
                                                      false) {
                                                    Fiberchat.showRationale(
                                                        getTranslated(
                                                            this.context,
                                                            'disabled'));
                                                  } else {
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddContactsToBroadcast(
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserNo,
                                                                  model:
                                                                      _cachedModel,
                                                                  biometricEnabled:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  isAddingWhileCreatingBroadcast:
                                                                      true,
                                                                )));
                                                  }
                                                  break;
                                              }
                                            },
                                            itemBuilder: (context) =>
                                                <PopupMenuItem<String>>[
                                                  PopupMenuItem<String>(
                                                      value: 'group',
                                                      child: Text(
                                                        getTranslated(context,
                                                            'newgroup'),
                                                      )),
                                                  PopupMenuItem<String>(
                                                      value: 'broadcast',
                                                      child: Text(
                                                        getTranslated(context,
                                                            'newbroadcast'),
                                                      )),
                                                  PopupMenuItem<String>(
                                                      value: 'settings',
                                                      child: Text(
                                                        getTranslated(context,
                                                            'settingsoption'),
                                                      )),
                                                ]),
                                      ],
                                      bottom: TabBar(
                                        indicator: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                50), // Creates border
                                            color: fiberchatPRIMARYcolor),
                                        isScrollable: IsAdaptiveWidthTab == true
                                            ? true
                                            : DEFAULT_LANGUAGE_FILE_CODE == "en" &&
                                                    (widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            null ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            "en")
                                                ? false
                                                : widget.prefs.getString(LAGUAGE_CODE) == 'pt' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'my' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'nl' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'vi' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'tr' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'id' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'ka' ||
                                                        widget.prefs.getString(
                                                                LAGUAGE_CODE) ==
                                                            'fr' ||
                                                        widget.prefs
                                                                .getString(LAGUAGE_CODE) ==
                                                            'es'
                                                    ? true
                                                    : false,
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FONTFAMILY_NAME == ''
                                              ? null
                                              : FONTFAMILY_NAME,
                                        ),
                                        unselectedLabelStyle: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: FONTFAMILY_NAME,
                                        ),
                                        indicatorPadding: EdgeInsets.all(10),
                                        padding:
                                            EdgeInsets.fromLTRB(10, 2, 10, 2),
                                        labelPadding:
                                            EdgeInsets.fromLTRB(10, 2, 10, 2),
                                        labelColor: fiberchatWhite,
                                        unselectedLabelColor:
                                            fiberchatBlack.withOpacity(0.6),
                                        indicatorWeight: 3,
                                        indicatorColor: fiberchatPRIMARYcolor,
                                        controller: observer.iscallsallowed
                                            ? controllerIfcallAllowed
                                            : controllerIfcallNotallowed,
                                        tabs: observer.iscallsallowed
                                            ? <Widget>[
                                                Tab(
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'chats'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FONTFAMILY_NAME == ''
                                                              ? null
                                                              : FONTFAMILY_NAME,
                                                    ),
                                                  ),
                                                ),
                                                Tab(
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'calls'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FONTFAMILY_NAME == ''
                                                              ? null
                                                              : FONTFAMILY_NAME,
                                                    ),
                                                  ),
                                                ),
                                              ]
                                            : <Widget>[
                                                Tab(
                                                  child: Text(
                                                    getTranslated(
                                                        context, 'chats'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          FONTFAMILY_NAME == ''
                                                              ? null
                                                              : FONTFAMILY_NAME,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                      )),
                                  body: TabBarView(
                                    controller: observer.iscallsallowed
                                        ? controllerIfcallAllowed
                                        : controllerIfcallNotallowed,
                                    children: observer.iscallsallowed
                                        ? <Widget>[
                                            RecentChats(
                                                tileWidth: w,
                                                isWideScreenMode: false,
                                                prefs: widget.prefs,
                                                currentUserNo:
                                                    widget.currentUserNo,
                                                isSecuritySetupDone: false),
                                            CallHistory(
                                                userphone: widget.currentUserNo,
                                                model: _cachedModel,
                                                prefs: widget.prefs)
                                          ]
                                        : <Widget>[
                                            RecentChats(
                                                tileWidth: w,
                                                isWideScreenMode: false,
                                                prefs: widget.prefs,
                                                currentUserNo:
                                                    widget.currentUserNo,
                                                isSecuritySetupDone: false),
                                          ],
                                  )),
                        )));
  }
}

// Future<dynamic> myBackgroundMessageHandlerIos(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (message.data['title'] == 'Call Ended') {
//     final data = message.data;

//     final titleMultilang = data['titleMultilang'];
//     final bodyMultilang = data['bodyMultilang'];
//     flutterLocalNotificationsPlugin..cancelAll();
//     await showNotificationWithDefaultSound(
//         'Missed Call', 'You have Missed a Call', titleMultilang, bodyMultilang);
//   } else {
//     if (message.data['title'] == 'You have new message(s)') {
//     } else if (message.data['title'] == 'Incoming Audio Call...' ||
//         message.data['title'] == 'Incoming Video Call...') {
//       final data = message.data;
//       final title = data['title'];
//       final body = data['body'];
//       final titleMultilang = data['titleMultilang'];
//       final bodyMultilang = data['bodyMultilang'];
//       await showNotificationWithDefaultSound(
//           title, body, titleMultilang, bodyMultilang);
//     }
//   }

//   return Future<void>.value();
// }

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
Future showNotificationWithDefaultSound(String? title, String? message,
    String? titleMultilang, String? bodyMultilang) async {}

Widget errorScreen(String? title, String? subtitle) {
  return Scaffold(
    backgroundColor: fiberchatPRIMARYcolor,
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_outlined,
              size: 60,
              color: Colors.yellowAccent,
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              '$title',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: fiberchatWhite,
                  fontWeight: FontWeight.w700),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              '$subtitle',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  color: fiberchatWhite.withOpacity(0.7),
                  fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
    ),
  );
}

final appbarColor = Color(0xffEEEEEE);
