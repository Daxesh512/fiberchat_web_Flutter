//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Utils/formatStatusTime.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/call_utilities.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final DocumentSnapshot<Map<String, dynamic>>? firestoreUserDoc;
  final List<dynamic> mediaMesages;
  ProfileView(
      this.user, this.currentUserNo, this.model, this.prefs, this.mediaMesages,
      {this.firestoreUserDoc});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        prefs: widget.prefs,
        currentuseruid: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: widget.user[Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.user[Dbkeys.phone],
        toFullname: widget.user[Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  StreamSubscription? chatStatusSubscriptionForPeer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      listenToBlock();
    });
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.user[Dbkeys.phone])
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.data()!.containsKey(widget.currentUserNo)) {
        // print('CHANGED');
        if (doc.data()![widget.currentUserNo] == 0) {
          hasPeerBlockedMe = true;
          setState(() {});
        } else if (doc.data()![widget.currentUserNo] == 3) {
          hasPeerBlockedMe = false;
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    chatStatusSubscriptionForPeer?.cancel();
  }

  buildBody(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context, 'enter_mobilenumber'),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fiberchatPRIMARYcolor,
                        fontSize: 16),
                  ),
                ],
              ),
              Divider(),
              SizedBox(
                height: 0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.user[Dbkeys.phone],
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: fiberchatBlack,
                        fontSize: 15.3),
                  ),
                  Container(
                    child: Row(
                      children: [
                        IconButton(
                            onPressed: () {
                              if (widget.firestoreUserDoc != null) {
                                widget.model!.addUser(widget.firestoreUserDoc!);
                              }

                              Navigator.pushAndRemoveUntil(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          isWideScreenMode: false,
                                          isSharingIntentForwarded: false,
                                          prefs: widget.prefs,
                                          model: widget.model!,
                                          currentUserNo: widget.currentUserNo,
                                          peerNo: widget.user[Dbkeys.phone],
                                          unread: 0)),
                                  (Route r) => r.isFirst);
                            },
                            icon: Icon(
                              Icons.message,
                              color: fiberchatSECONDARYolor,
                            )),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 0,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(bottom: 18, top: 8),
          color: Colors.white,
          // height: 30,
          child: ListTile(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text(
                getTranslated(context, 'encryption'),
                style: TextStyle(fontWeight: FontWeight.w600, height: 2),
              ),
            ),
            dense: false,
            subtitle: Text(
              getTranslated(context, 'encryptionshort'),
              style: TextStyle(color: fiberchatGrey, height: 1.3, fontSize: 15),
            ),
            trailing: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Icon(
                Icons.lock,
                color: fiberchatGrey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(widget
                    .user[Dbkeys.accountstatus] ==
                Dbkeys.sTATUSdeleted
            ? Scaffold(
                backgroundColor: fiberchatScaffold,
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: fiberchatPRIMARYcolor,
                  elevation: 0,
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                        size: 40,
                      ),
                      SizedBox(
                        height: 38,
                      ),
                      Text(" User Account Deleted"),
                    ],
                  ),
                ),
              )
            : Scaffold(
                backgroundColor: fiberchatScaffold,
                appBar: AppBar(
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: fiberchatBlack,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: fiberchatWhite,
                  elevation: 0.4,
                  title: Text(
                    getTranslated(context, 'profile'),
                    style: TextStyle(color: fiberchatBlack),
                  ),
                ),
                body: Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    color: Colors.white,
                    alignment: Alignment.center,
                    width: getContentScreenWidth(
                        MediaQuery.of(context).size.width),
                    child: ListView(
                      physics: BouncingScrollPhysics(),
                      children: [
                        Padding(
                          padding: MediaQuery.of(context).size.width >
                                  MediaQuery.of(context).size.height
                              ? EdgeInsets.all(getContentScreenWidth(
                                      MediaQuery.of(context).size.width) /
                                  36.2)
                              : EdgeInsets.all(30),
                          child: Center(
                            child: customCircleAvatarGroup(
                                url: widget.user[Dbkeys.photoUrl],
                                radius: MediaQuery.of(context).size.width >
                                        MediaQuery.of(context).size.height
                                    ? getContentScreenWidth(
                                            MediaQuery.of(context).size.width) /
                                        8
                                    : getContentScreenWidth(
                                            MediaQuery.of(context).size.width) /
                                        3),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: getContentScreenWidth(
                                  MediaQuery.of(context).size.width) /
                              1.3,
                          child: Text(
                            widget.user[Dbkeys.nickname],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: fiberchatBlack,
                                fontSize: 22,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    getTranslated(context, 'about'),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: fiberchatPRIMARYcolor,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              Divider(),
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                widget.user[Dbkeys.aboutMe] == null ||
                                        widget.user[Dbkeys.aboutMe] == ''
                                    ? '${getTranslated(context, 'heyim')} $Appname'
                                    : widget.user[Dbkeys.aboutMe],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: fiberchatBlack,
                                    fontSize: 15.9),
                              ),
                              SizedBox(
                                height: 14,
                              ),
                              Text(
                                getJoinTime(
                                    widget.user[Dbkeys.joinedOn], context),
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    color: fiberchatGrey,
                                    fontSize: 13.3),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        OnlyPeerWhoAreSavedInmyContactCanMessageOrCallMe == true
                            ? widget.user.containsKey(Dbkeys.deviceSavedLeads)
                                ? widget.user[Dbkeys.deviceSavedLeads]
                                        .contains(widget.currentUserNo)
                                    ? buildBody(context)
                                    : SizedBox(
                                        height: 40,
                                      )
                                : SizedBox()
                            : buildBody(context),
                      ],
                    ),
                  ),
                ),
              )));
  }
}
