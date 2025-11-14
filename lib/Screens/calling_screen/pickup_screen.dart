//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Services/Providers/call_history_provider.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/calling_screen/audio_call.dart';
import 'package:fiberchat_web/Screens/calling_screen/video_call.dart';
import 'package:fiberchat_web/widgets/Common/cached_image.dart';

import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:fiberchat_web/Models/call.dart';
import 'package:fiberchat_web/Models/call_methods.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html;

// ignore: must_be_immutable
class PickupScreen extends StatelessWidget {
  final Call call;
  final String? currentuseruid;
  final SharedPreferences prefs;
  final CallMethods callMethods = CallMethods();

  PickupScreen({
    required this.call,
    required this.currentuseruid,
    required this.prefs,
  });
  ClientRole _role = ClientRole.Broadcaster;
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return Consumer<FirestoreDataProviderCALLHISTORY>(
        builder: (context, firestoreDataProviderCALLHISTORY, _child) => h > w &&
                ((h / w) > 1.5)
            ? Scaffold(
                backgroundColor: fiberchatPRIMARYcolor,
                body: Container(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top),
                        color: fiberchatPRIMARYcolor,
                        height: h / 4,
                        width: w,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 7,
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  call.isvideocall == true
                                      ? Icons.videocam
                                      : Icons.mic_rounded,
                                  size: 40,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Text(
                                  call.isvideocall == true
                                      ? getTranslated(context, 'incomingvideo')
                                      : getTranslated(context, 'incomingaudio'),
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: h / 9,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(height: 7),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.1,
                                    child: Text(
                                      call.callerName!,
                                      maxLines: 1,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: fiberchatWhite,
                                        fontSize: 27,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 7),
                                  Text(
                                    call.callerId!,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: fiberchatWhite.withOpacity(0.34),
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: h / 25),

                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                      call.callerPic == null || call.callerPic == ''
                          ? Container(
                              height: w + (w / 140),
                              width: w,
                              color: Colors.white12,
                              child: Icon(
                                Icons.person,
                                size: 140,
                                color: fiberchatPRIMARYcolor,
                              ),
                            )
                          : Stack(
                              children: [
                                customCircleAvatar(
                                    radius: w / 6, url: call.callerPic!),
                                Container(
                                  height: w + (w / 140),
                                  width: w,
                                  color: Colors.black.withOpacity(0.18),
                                ),
                              ],
                            ),
                      Container(
                        height: h / 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () async {
                                final currentpeer =
                                    Provider.of<CurrentChatPeer>(context,
                                        listen: false);
                                currentpeer.removeCurrentWidget();
                                await callMethods.endCall(call: call);
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.callerId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .doc(call.timeepoch.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.receiverId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .doc(call.timeepoch.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                //----------
                                // await FirebaseFirestore.instance
                                //     .collection(DbPaths.collectionusers)
                                //     .doc(call.receiverId)
                                //     .collection('recent')
                                //     .doc('callended')
                                //     .delete();

                                // await FirebaseFirestore.instance
                                //     .collection(DbPaths.collectionusers)
                                //     .doc(call.receiverId)
                                //     .collection('recent')
                                //     .doc('callended')
                                //     .set({
                                //   'id': call.receiverId,
                                //   'ENDED': DateTime.now().millisecondsSinceEpoch
                                // });
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.callerId)
                                    .collection('recent')
                                    .doc('callended')
                                    .delete();
                                Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () async {
                                  await FirebaseFirestore.instance
                                      .collection(DbPaths.collectionusers)
                                      .doc(call.callerId)
                                      .collection('recent')
                                      .doc('callended')
                                      .set({
                                    'id': call.callerId,
                                    'ENDED':
                                        DateTime.now().millisecondsSinceEpoch
                                  });
                                });

                                firestoreDataProviderCALLHISTORY.fetchNextData(
                                    'CALLHISTORY',
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionusers)
                                        .doc(call.receiverId)
                                        .collection(
                                            DbPaths.collectioncallhistory)
                                        .orderBy('TIME', descending: true)
                                        .limit(14),
                                    true);
                              },
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.redAccent,
                              padding: const EdgeInsets.all(15.0),
                            ),
                            SizedBox(width: 45),
                            RawMaterialButton(
                              onPressed: () async {
                                final currentpeer =
                                    Provider.of<CurrentChatPeer>(context,
                                        listen: false);
                                currentpeer.removeCurrentWidget();
                                await html.window.navigator
                                    .getUserMedia(audio: true, video: false)
                                    .then((status) async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => call.isvideocall ==
                                              true
                                          ? VideoCall(
                                              prefs: prefs,
                                              currentuseruid: currentuseruid!,
                                              call: call,
                                              channelName: call.channelId!,
                                              role: _role,
                                            )
                                          : AudioCall(
                                              prefs: prefs,
                                              currentuseruid: currentuseruid,
                                              call: call,
                                              channelName: call.channelId,
                                              role: _role,
                                            ),
                                    ),
                                  );
                                }).catchError((onError) {
                                  Fiberchat.showRationale(
                                      getTranslated(context, 'pmc') +
                                          onError.toString());
                                });
                              },
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.green[400],
                              padding: const EdgeInsets.all(15.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ))
            : Scaffold(
                backgroundColor: fiberchatWhite,
                body: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: w > h ? 60 : 100),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        w > h
                            ? SizedBox(
                                height: h / 12,
                              )
                            : Icon(
                                call.isvideocall == true
                                    ? Icons.videocam_outlined
                                    : Icons.mic,
                                size: 80,
                                color: fiberchatBlack.withOpacity(0.3),
                              ),
                        w > h
                            ? SizedBox(
                                height: 10,
                              )
                            : SizedBox(
                                height: 20,
                              ),
                        Text(
                          call.isvideocall == true
                              ? getTranslated(context, 'incomingvideo')
                              : getTranslated(context, 'incomingaudio'),
                          style: TextStyle(
                            fontSize: 19,
                            color: fiberchatBlack.withOpacity(0.54),
                          ),
                        ),
                        SizedBox(height: w > h ? 20 : 50),
                        call.callerPic == null || call.callerPic == ''
                            ? customCircleAvatar(radius: 100)
                            : CachedImage(
                                call.callerPic,
                                isRound: true,
                                height: w > h ? 60 : 110,
                                width: w > h ? 60 : 110,
                                radius: w > h ? 70 : 138,
                              ),
                        SizedBox(height: 45),
                        Text(
                          call.callerName!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: fiberchatBlack,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: w > h ? (h / 10) : 75),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            RawMaterialButton(
                              onPressed: () async {
                                final currentpeer =
                                    Provider.of<CurrentChatPeer>(context,
                                        listen: false);
                                currentpeer.removeCurrentWidget();
                                await callMethods.endCall(call: call);
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.callerId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .doc(call.timeepoch.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.receiverId)
                                    .collection(DbPaths.collectioncallhistory)
                                    .doc(call.timeepoch.toString())
                                    .set({
                                  'STATUS': 'rejected',
                                  'ENDED': DateTime.now(),
                                }, SetOptions(merge: true));
                                //----------
                                await FirebaseFirestore.instance
                                    .collection(DbPaths.collectionusers)
                                    .doc(call.callerId)
                                    .collection('recent')
                                    .doc('callended')
                                    .delete();
                                Future.delayed(
                                    const Duration(milliseconds: 200),
                                    () async {
                                  await FirebaseFirestore.instance
                                      .collection(DbPaths.collectionusers)
                                      .doc(call.callerId)
                                      .collection('recent')
                                      .doc('callended')
                                      .set({
                                    'id': call.callerId,
                                    'ENDED':
                                        DateTime.now().millisecondsSinceEpoch
                                  });
                                });

                                firestoreDataProviderCALLHISTORY.fetchNextData(
                                    'CALLHISTORY',
                                    FirebaseFirestore.instance
                                        .collection(DbPaths.collectionusers)
                                        .doc(call.receiverId)
                                        .collection(
                                            DbPaths.collectioncallhistory)
                                        .orderBy('TIME', descending: true)
                                        .limit(14),
                                    true);
                              },
                              child: Icon(
                                Icons.call_end,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: Colors.redAccent,
                              padding: const EdgeInsets.all(15.0),
                            ),
                            SizedBox(width: 45),
                            RawMaterialButton(
                              onPressed: () async {
                                final currentpeer =
                                    Provider.of<CurrentChatPeer>(context,
                                        listen: false);
                                currentpeer.removeCurrentWidget();
                                await html.window.navigator
                                    .getUserMedia(audio: true, video: false)
                                    .then((status) async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => call.isvideocall ==
                                              true
                                          ? VideoCall(
                                              prefs: prefs,
                                              currentuseruid: currentuseruid!,
                                              call: call,
                                              channelName: call.channelId!,
                                              role: _role,
                                            )
                                          : AudioCall(
                                              prefs: prefs,
                                              currentuseruid: currentuseruid,
                                              call: call,
                                              channelName: call.channelId,
                                              role: _role,
                                            ),
                                    ),
                                  );
                                }).catchError((onError) {
                                  Fiberchat.showRationale(
                                      getTranslated(context, 'pmc') +
                                          onError.toString());
                                });
                              },
                              child: Icon(
                                Icons.call,
                                color: Colors.white,
                                size: 35.0,
                              ),
                              shape: CircleBorder(),
                              elevation: 2.0,
                              fillColor: fiberchatPRIMARYcolor,
                              padding: const EdgeInsets.all(15.0),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ));
  }
}
