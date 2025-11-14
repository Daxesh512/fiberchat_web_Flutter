//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/homepage/homepage.dart';
import 'package:fiberchat_web/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat_web/Services/Providers/GroupChatProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentChatPeer with ChangeNotifier {
  String? peerid = '';

  String? groupChatId = '';
  String? currentuserno;
  Widget? currentWidget;
  String? toSetOfflineChatID;
  void setLastSeenForPersonalChats(String? currentUserno) {
    if (toSetOfflineChatID != null) {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(toSetOfflineChatID)
          .set({'$currentUserno': DateTime.now().millisecondsSinceEpoch},
              SetOptions(merge: true));
      toSetOfflineChatID = null;
      notifyListeners();
    }
  }

  setCurrentWidget(
    Widget w,
    String currentUserNp,
    String peerID, {
    BuildContext? context,
    String? personalchatID,
  }) {
    currentuserno = currentUserNp;
    setGlobalLastSeenForPersonalChats(currentuserno, toSetOfflineChatID);
    if (personalchatID != null) {
      toSetOfflineChatID = personalchatID;
    }
    if (context != null) {
      var firestoreProviderGROUP =
          Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(context,
              listen: false);
      firestoreProviderGROUP.reset();
      var firestoreProviderBROADCAST =
          Provider.of<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>(
              context,
              listen: false);
      firestoreProviderBROADCAST.reset();
    }

    currentWidget = loadingScaffold;
    toSetOfflineChatID = personalchatID;
    peerid = '';

    notifyListeners();

    Future.delayed(const Duration(milliseconds: 700), () {
      peerid = peerID;
      currentWidget = w;
      notifyListeners();
    });
  }

  removeCurrentWidget() {
    currentWidget = null;
    peerid = null;

    notifyListeners();

    if (toSetOfflineChatID != null) {
      setGlobalLastSeen(currentuserno);
    }
    setGlobalLastSeenForPersonalChats(currentuserno, toSetOfflineChatID);
  }

  setpeer({
    String? newpeerid,
    String? newgroupChatId,
  }) {
    peerid = newpeerid ?? peerid;
    groupChatId = newgroupChatId ?? groupChatId;
    notifyListeners();
  }
}

Scaffold loadingScaffold = Scaffold(
  appBar: AppBar(
    elevation: 0.4,
    backgroundColor: appbarColor,
  ),
  body: Stack(
    children: [
      new Container(
        decoration: new BoxDecoration(
          color: fiberchatChatbackground,
          image: new DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover),
        ),
      ),
      Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
      ),
    ],
  ),
);

void setGlobalLastSeen(String? currentUserno) async {
  if (currentUserno != null)
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentUserno)
        .set({Dbkeys.lastSeen: DateTime.now().millisecondsSinceEpoch},
            SetOptions(merge: true));
}

void setGlobalLastSeenForPersonalChats(
    String? currentUserno, String? chatid) async {
  if (chatid != null)
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatid)
        .set({'$currentUserno': DateTime.now().millisecondsSinceEpoch},
            SetOptions(merge: true));
}
