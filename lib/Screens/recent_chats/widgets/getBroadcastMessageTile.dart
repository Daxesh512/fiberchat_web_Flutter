import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/Broadcast/BroadcastChatPage.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/recent_chats/RecentsChats.dart';
import 'package:fiberchat_web/Screens/recent_chats/widgets/getLastMessageTime.dart';
import 'package:fiberchat_web/Screens/recent_chats/widgets/getPersonalMessageTile.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/unawaited.dart';
import 'package:fiberchat_web/Utils/late_load.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget broadcastMessageTile(
    {required BuildContext context,
    required isWideScreenMode,
    required List<Map<String, dynamic>> streamDocSnap,
    required int index,
    required String currentUserNo,
    required SharedPreferences prefs,
    required DataModel cachedModel,
    required double tilewidth}) {
  showMenuForBroadcastChat(
    contextForDialog,
    var broadcastDoc,
  ) {
    List<Widget> tiles = List.from(<Widget>[]);

    tiles.add(Builder(
        builder: (BuildContext popable) => ListTile(
            dense: true,
            leading: Icon(Icons.delete, size: 22),
            title: Text(
              getTranslated(popable, 'deletebroadcast'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onTap: () async {
              Navigator.of(popable).pop();
              unawaited(showDialog(
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: new Text(getTranslated(context, 'deletebroadcast')),
                    actions: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0, backgroundColor: Colors.white),
                        child: Text(
                          getTranslated(context, 'cancel'),
                          style: TextStyle(
                              color: fiberchatSECONDARYolor, fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 0, backgroundColor: Colors.white),
                        child: Text(
                          getTranslated(context, 'delete'),
                          style: TextStyle(color: Colors.red, fontSize: 18),
                        ),
                        onPressed: () async {
                          String broadcastID = broadcastDoc[Dbkeys.broadcastID];
                          Navigator.of(context).pop();
                          var currentpeer = Provider.of<CurrentChatPeer>(
                              context,
                              listen: false);
                          currentpeer.removeCurrentWidget();
                          Future.delayed(const Duration(milliseconds: 500),
                              () async {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionbroadcasts)
                                .doc(broadcastID)
                                .get()
                                .then((doc) async {
                              await doc.reference.delete();
                              //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
                            });
                          });
                        },
                      )
                    ],
                  );
                },
                context: context,
              ));
            })));

    showDialog(
        context: contextForDialog,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  return Theme(
      data: ThemeData(
          fontFamily: FONTFAMILY_NAME == '' ? null : FONTFAMILY_NAME,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent),
      child: streamLoadCollections(
          stream: FirebaseFirestore.instance
              .collection(DbPaths.collectionbroadcasts)
              .doc(streamDocSnap[index][Dbkeys.broadcastID])
              .collection(DbPaths.collectionbroadcastsChats)
              .orderBy(Dbkeys.timestamp, descending: true)
              .limit(1)
              .snapshots(),
          placeholder: Column(
            children: [
              ListTile(
                onLongPress: () {
                  showMenuForBroadcastChat(context, streamDocSnap[index]);
                },
                contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                leading: customCircleAvatarBroadcast(
                  url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
                ),
                title: Text(
                  streamDocSnap[index][Dbkeys.broadcastNAME],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fiberchatBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.4,
                  ),
                ),
                subtitle: Text(
                  '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${getTranslated(context, 'recipients')}',
                  style: TextStyle(
                    color: fiberchatGrey,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  if (isWideScreenMode) {
                    final currentpeer =
                        Provider.of<CurrentChatPeer>(context, listen: false);
                    currentpeer.setCurrentWidget(
                        BroadcastChatPage(
                            isWideScreenMode: isWideScreenMode,
                            model: cachedModel,
                            prefs: prefs,
                            currentUserno: currentUserNo,
                            broadcastID: streamDocSnap[index]
                                [Dbkeys.broadcastID]),
                        currentUserNo,
                        streamDocSnap[index][Dbkeys.broadcastID],
                        context: context);
                  } else {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new BroadcastChatPage(
                                isWideScreenMode: isWideScreenMode,
                                model: cachedModel,
                                prefs: prefs,
                                currentUserno: currentUserNo,
                                broadcastID: streamDocSnap[index]
                                    [Dbkeys.broadcastID])));
                  }
                },
              ),
              myDivider()
            ],
          ),
          noDataWidget: Column(
            children: [
              ListTile(
                onLongPress: () {
                  showMenuForBroadcastChat(context, streamDocSnap[index]);
                },
                contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                leading: customCircleAvatarBroadcast(
                  url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
                ),
                title: Text(
                  streamDocSnap[index][Dbkeys.broadcastNAME],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: fiberchatBlack,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.4,
                  ),
                ),
                subtitle: Text(
                  '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${getTranslated(context, 'recipients')}',
                  style: TextStyle(
                    color: fiberchatGrey,
                    fontSize: 12,
                  ),
                ),
                onTap: () {
                  if (isWideScreenMode) {
                    final currentpeer =
                        Provider.of<CurrentChatPeer>(context, listen: false);
                    currentpeer.setCurrentWidget(
                        BroadcastChatPage(
                          isWideScreenMode: isWideScreenMode,
                          model: cachedModel,
                          prefs: prefs,
                          currentUserno: currentUserNo,
                          broadcastID: streamDocSnap[index][Dbkeys.broadcastID],
                        ),
                        currentUserNo,
                        streamDocSnap[index][Dbkeys.broadcastID],
                        context: context);
                  } else {
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new BroadcastChatPage(
                                isWideScreenMode: isWideScreenMode,
                                model: cachedModel,
                                prefs: prefs,
                                currentUserno: currentUserNo,
                                broadcastID: streamDocSnap[index]
                                    [Dbkeys.broadcastID])));
                  }
                },
              ),
              myDivider()
            ],
          ),
          onfetchdone: (events) {
            return Column(
              children: [
                ListTile(
                  onLongPress: () {
                    showMenuForBroadcastChat(context, streamDocSnap[index]);
                  },
                  contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  leading: customCircleAvatarBroadcast(
                    url: streamDocSnap[index][Dbkeys.broadcastPHOTOURL],
                  ),
                  title: Text(
                    streamDocSnap[index][Dbkeys.broadcastNAME],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fiberchatBlack,
                      fontWeight: FontWeight.w500,
                      fontSize: 16.4,
                    ),
                  ),
                  subtitle: Text(
                    '${streamDocSnap[index][Dbkeys.broadcastMEMBERSLIST].length} ${getTranslated(context, 'recipients')}',
                    style: TextStyle(
                      color: lightGrey,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          getLastMessageTime(context, currentUserNo,
                              events.last[Dbkeys.timestamp]),
                          style: TextStyle(
                              color: lightGrey,
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        ),
                      ),
                      SizedBox(
                        height: 23,
                      ),
                    ],
                  ),
                  onTap: () {
                    if (isWideScreenMode) {
                      final currentpeer =
                          Provider.of<CurrentChatPeer>(context, listen: false);
                      currentpeer.setCurrentWidget(
                          BroadcastChatPage(
                              isWideScreenMode: isWideScreenMode,
                              model: cachedModel,
                              prefs: prefs,
                              currentUserno: currentUserNo,
                              broadcastID: streamDocSnap[index]
                                  [Dbkeys.broadcastID]),
                          currentUserNo,
                          streamDocSnap[index][Dbkeys.broadcastID],
                          context: context);
                    } else {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new BroadcastChatPage(
                                  isWideScreenMode: isWideScreenMode,
                                  model: cachedModel,
                                  prefs: prefs,
                                  currentUserno: currentUserNo,
                                  broadcastID: streamDocSnap[index]
                                      [Dbkeys.broadcastID])));
                    }
                  },
                ),
                myDivider()
              ],
            );
          }));
}
