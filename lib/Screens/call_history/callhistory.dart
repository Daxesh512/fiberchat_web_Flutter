//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/Broadcast/AddContactsToBroadcast.dart';
import 'package:fiberchat_web/Screens/Groups/AddContactsToGroup.dart';
import 'package:fiberchat_web/Screens/contact_screens/syncedContacts.dart';
import 'package:fiberchat_web/Screens/recent_chats/widgets/getPersonalMessageTile.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/call_history/utils/InfiniteListView.dart';
import 'package:fiberchat_web/Services/Providers/call_history_provider.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallHistory extends StatefulWidget {
  final String? userphone;
  final DataModel? model;
  final SharedPreferences prefs;
  CallHistory(
      {required this.userphone, required this.model, required this.prefs});
  @override
  _CallHistoryState createState() => _CallHistoryState();
}

class _CallHistoryState extends State<CallHistory> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: true);
    return Consumer<FirestoreDataProviderCALLHISTORY>(
      builder: (context, firestoreDataProvider, _) => Scaffold(
        key: _scaffold,
        backgroundColor: fiberchatWhite,
        floatingActionButton: firestoreDataProvider.recievedDocs.length == 0
            ? Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: FloatingActionButton(
                    heroTag: "dfsf4e8t4yaddweqewt834",
                    backgroundColor: fiberchatPRIMARYcolor,
                    child: Icon(
                      Icons.add_call,
                      size: 30.0,
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => new SyncedContacts(
                                  onTapCreateGroup: () {
                                    if (observer.isAllowCreatingGroups ==
                                        false) {
                                      Fiberchat.showRationale(getTranslated(
                                          this.context, 'disabled'));
                                    } else {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddContactsToGroup(
                                                    currentUserNo:
                                                        widget.userphone,
                                                    model: widget.model,
                                                    biometricEnabled: false,
                                                    prefs: widget.prefs,
                                                    isAddingWhileCreatingGroup:
                                                        true,
                                                  )));
                                    }
                                  },
                                  onTapCreateBroadcast: () {
                                    if (observer.isAllowCreatingBroadcasts ==
                                        false) {
                                      Fiberchat.showRationale(getTranslated(
                                          this.context, 'disabled'));
                                    } else {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddContactsToBroadcast(
                                                    currentUserNo:
                                                        widget.userphone,
                                                    model: widget.model,
                                                    biometricEnabled: false,
                                                    prefs: widget.prefs,
                                                    isAddingWhileCreatingBroadcast:
                                                        true,
                                                  )));
                                    }
                                  },
                                  prefs: widget.prefs,
                                  biometricEnabled: false,
                                  currentUserNo: widget.userphone!,
                                  model: widget.model!)));
                    }),
              )
            : Padding(
                padding: EdgeInsets.only(bottom: 0),
                child: FloatingActionButton(
                    heroTag: "dfsf4e8t4yt834",
                    backgroundColor: fiberchatWhite,
                    child: Icon(
                      Icons.delete,
                      size: 30.0,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      showDialog(
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: new Text(getTranslated(context, 'clearlog')),
                            content: new Text(
                                getTranslated(context, 'clearloglong')),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  getTranslated(context, 'cancel'),
                                  style: TextStyle(
                                      color: fiberchatSECONDARYolor,
                                      fontSize: 18),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Text(
                                  getTranslated(context, 'delete'),
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 18),
                                ),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  Fiberchat.toast(
                                      getTranslated(context, 'plswait'));
                                  FirebaseFirestore.instance
                                      .collection(DbPaths.collectionusers)
                                      .doc(widget.userphone)
                                      .collection(DbPaths.collectioncallhistory)
                                      .get()
                                      .then((snapshot) {
                                    for (DocumentSnapshot doc
                                        in snapshot.docs) {
                                      doc.reference.delete();
                                    }
                                  }).then((value) {
                                    firestoreDataProvider.clearall();
                                  });
                                },
                              )
                            ],
                          );
                        },
                        context: context,
                      );
                    }),
              ),
        body: Consumer<SmartContactProviderWithLocalStoreData>(
          builder: (context, contactsProvider, _child) => InfiniteListView(
            firestoreDataProviderCALLHISTORY: firestoreDataProvider,
            datatype: 'CALLHISTORY',
            refdata: FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(widget.userphone)
                .collection(DbPaths.collectioncallhistory)
                .orderBy('TIME', descending: true)
                .limit(14),
            list: ListView.builder(
                padding: EdgeInsets.only(bottom: 70),
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: firestoreDataProvider.recievedDocs.length,
                itemBuilder: (BuildContext context, int i) {
                  var dc = firestoreDataProvider.recievedDocs[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        // padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                        margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                        // height: 40,
                        child: FutureBuilder<LocalUserData?>(
                            future: contactsProvider
                                .fetchUserDataFromnLocalOrServer(
                                    widget.prefs, dc['PEER']),
                            builder: (BuildContext context,
                                AsyncSnapshot<LocalUserData?> snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                var user = snapshot.data;
                                return ListTile(
                                  onLongPress: () {
                                    List<Widget> tiles = List.from(<Widget>[]);

                                    tiles.add(ListTile(
                                        dense: true,
                                        leading: Icon(Icons.delete),
                                        title: Text(
                                          getTranslated(context, 'delete'),
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        onTap: () async {
                                          Navigator.of(context).pop();

                                          FirebaseFirestore.instance
                                              .collection(
                                                  DbPaths.collectionusers)
                                              .doc(widget.userphone)
                                              .collection(
                                                  DbPaths.collectioncallhistory)
                                              .doc(dc['TIME'].toString())
                                              .delete();
                                          Fiberchat.toast('Deleted!');
                                          firestoreDataProvider
                                              .deleteSingle(dc);
                                        }));

                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return SimpleDialog(children: tiles);
                                        });
                                  },
                                  isThreeLine: false,
                                  leading: Stack(
                                    children: [
                                      customCircleAvatar(
                                          url: user!.photoURL, radius: 42),
                                      dc['STARTED'] == null ||
                                              dc['ENDED'] == null
                                          ? SizedBox(
                                              height: 0,
                                              width: 0,
                                            )
                                          : Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    6, 2, 6, 2),
                                                decoration: BoxDecoration(
                                                    color:
                                                        fiberchatSECONDARYolor,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20))),
                                                child: Text(
                                                  dc['ENDED']
                                                              .toDate()
                                                              .difference(
                                                                  dc['STARTED']
                                                                      .toDate())
                                                              .inMinutes <
                                                          1
                                                      ? dc['ENDED']
                                                              .toDate()
                                                              .difference(
                                                                  dc['STARTED']
                                                                      .toDate())
                                                              .inSeconds
                                                              .toString() +
                                                          's'
                                                      : dc['ENDED']
                                                              .toDate()
                                                              .difference(
                                                                  dc['STARTED']
                                                                      .toDate())
                                                              .inMinutes
                                                              .toString() +
                                                          'm',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10),
                                                ),
                                              ))
                                    ],
                                  ),
                                  title: Text(
                                    user.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                        height: 1.4,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          dc['TYPE'] == 'INCOMING'
                                              ? (dc['STARTED'] == null
                                                  ? Icons.call_missed
                                                  : Icons.call_received)
                                              : (dc['STARTED'] == null
                                                  ? Icons.call_made_rounded
                                                  : Icons.call_made_rounded),
                                          size: 15,
                                          color: dc['TYPE'] == 'INCOMING'
                                              ? (dc['STARTED'] == null
                                                  ? Colors.redAccent
                                                  : fiberchatPRIMARYcolor)
                                              : (dc['STARTED'] == null
                                                  ? Colors.redAccent
                                                  : fiberchatPRIMARYcolor),
                                        ),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        Icon(
                                            dc['ISVIDEOCALL'] == true
                                                ? Icons.video_call
                                                : Icons.call,
                                            color: fiberchatPRIMARYcolor,
                                            size: 15),
                                        SizedBox(
                                          width: 7,
                                        ),
                                        IsShowNativeTimDate == true
                                            ? Text(getTranslated(
                                                    this.context,
                                                    Jiffy(DateTime.fromMillisecondsSinceEpoch(dc["TIME"]))
                                                        .MMMM
                                                        .toString()) +
                                                ' ' +
                                                Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                        dc["TIME"]))
                                                    .date
                                                    // .Md
                                                    .toString() +
                                                ', ' +
                                                Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                        dc["TIME"]))
                                                    .Hm
                                                    .toString())
                                            : Text(Jiffy(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            dc["TIME"]))
                                                    .MMMMd
                                                    .toString() +
                                                ', ' +
                                                Jiffy(DateTime
                                                        .fromMillisecondsSinceEpoch(
                                                            dc["TIME"]))
                                                    .Hm
                                                    .toString()),
                                        // Text(time)
                                      ],
                                    ),
                                  ),
                                );
                              }
                              return ListTile(
                                onLongPress: () {
                                  List<Widget> tiles = List.from(<Widget>[]);

                                  tiles.add(ListTile(
                                      dense: true,
                                      leading: Icon(Icons.delete),
                                      title: Text(
                                        getTranslated(context, 'delete'),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        Fiberchat.toast(
                                            getTranslated(context, 'plswait'));
                                        FirebaseFirestore.instance
                                            .collection(DbPaths.collectionusers)
                                            .doc(widget.userphone)
                                            .collection(
                                                DbPaths.collectioncallhistory)
                                            .doc(dc['TIME'].toString())
                                            .delete();
                                        Fiberchat.toast('Deleted!');
                                        firestoreDataProvider.deleteSingle(dc);
                                      }));

                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return SimpleDialog(children: tiles);
                                      });
                                },
                                isThreeLine: false,
                                leading: Stack(
                                  children: [
                                    customCircleAvatar(radius: 42),
                                    dc['STARTED'] == null || dc['ENDED'] == null
                                        ? SizedBox(
                                            height: 0,
                                            width: 0,
                                          )
                                        : Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  6, 2, 6, 2),
                                              decoration: BoxDecoration(
                                                  color: fiberchatSECONDARYolor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20))),
                                              child: Text(
                                                dc['ENDED']
                                                            .toDate()
                                                            .difference(
                                                                dc['STARTED']
                                                                    .toDate())
                                                            .inMinutes <
                                                        1
                                                    ? dc['ENDED']
                                                            .toDate()
                                                            .difference(
                                                                dc['STARTED']
                                                                    .toDate())
                                                            .inSeconds
                                                            .toString() +
                                                        's'
                                                    : dc['ENDED']
                                                            .toDate()
                                                            .difference(
                                                                dc['STARTED']
                                                                    .toDate())
                                                            .inMinutes
                                                            .toString() +
                                                        'm',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10),
                                              ),
                                            ))
                                  ],
                                ),
                                title: Text(
                                  contactsProvider
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.phone ==
                                                  dc['PEER']) >=
                                          0
                                      ? contactsProvider
                                          .alreadyJoinedSavedUsersPhoneNameAsInServer
                                          .toList()[contactsProvider
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.phone == dc['PEER'])]
                                          .name
                                      : dc['PEER'],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      height: 1.4, fontWeight: FontWeight.w500),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        dc['TYPE'] == 'INCOMING'
                                            ? (dc['STARTED'] == null
                                                ? Icons.call_missed
                                                : Icons.call_received)
                                            : (dc['STARTED'] == null
                                                ? Icons.call_made_rounded
                                                : Icons.call_made_rounded),
                                        size: 15,
                                        color: dc['TYPE'] == 'INCOMING'
                                            ? (dc['STARTED'] == null
                                                ? Colors.redAccent
                                                : fiberchatPRIMARYcolor)
                                            : (dc['STARTED'] == null
                                                ? Colors.redAccent
                                                : fiberchatPRIMARYcolor),
                                      ),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      Icon(
                                          dc['ISVIDEOCALL'] == true
                                              ? Icons.video_call
                                              : Icons.call,
                                          color: fiberchatPRIMARYcolor,
                                          size: 15),
                                      SizedBox(
                                        width: 7,
                                      ),
                                      IsShowNativeTimDate == true
                                          ? Text(getTranslated(
                                                  this.context,
                                                  Jiffy(DateTime.fromMillisecondsSinceEpoch(dc["TIME"]))
                                                      .MMMM
                                                      .toString()) +
                                              ' ' +
                                              Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                      dc["TIME"]))
                                                  .date
                                                  // .Md
                                                  .toString() +
                                              ', ' +
                                              Jiffy(DateTime.fromMillisecondsSinceEpoch(
                                                      dc["TIME"]))
                                                  .Hm
                                                  .toString())
                                          : Text(Jiffy(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          dc["TIME"]))
                                                  .MMMMd
                                                  .toString() +
                                              ', ' +
                                              Jiffy(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          dc["TIME"]))
                                                  .Hm
                                                  .toString()),
                                      // Text(time)
                                    ],
                                  ),
                                ),
                              );
                            }),
                      ),
                      myDivider()
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}

Widget customCircleAvatar({String? url, double? radius}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(300.0),
      child: url == null || url == ''
          ? Container(
              height: radius ?? 42,
              width: radius ?? 42,
              color: Color(0xffDFE5E7),
              child: Icon(
                Icons.person_rounded,
                size: radius == null ? 27 : radius / 1.5,
                color: Colors.white,
              ),
            )
          : Container(
              color: Color(0xffDFE5E7),
              child: Image.network(
                url,
                height: radius ?? 42,
                width: radius ?? 42,
                fit: BoxFit.cover,
                errorBuilder: (context, child, loadingProgress) {
                  return Container(
                    height: radius ?? 42,
                    width: radius ?? 42,
                    color: Color(0xffDFE5E7),
                    child: Icon(
                      Icons.person_rounded,
                      size: radius == null ? 27 : radius / 1.5,
                      color: Colors.white,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: radius ?? 42,
                    width: radius ?? 42,
                    color: Color(0xffDFE5E7),
                    child: Icon(
                      Icons.person_rounded,
                      size: radius == null ? 27 : radius / 1.5,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ));
}

Widget customCircleAvatarGroup({String? url, double? radius}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(300.0),
      child: url == null || url == ''
          ? Container(
              height: radius ?? 42,
              width: radius ?? 42,
              color: Color(0xffDFE5E7),
              child: Icon(
                Icons.people_rounded,
                size: radius == null ? 27 : radius / 1.5,
                color: Colors.white,
              ),
            )
          : Container(
              color: Color(0xffDFE5E7),
              child: Image.network(url,
                  height: radius ?? 42, width: radius ?? 42, fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: radius ?? 42,
                  width: radius ?? 42,
                  color: Color(0xffDFE5E7),
                  child: Icon(
                    Icons.people_rounded,
                    size: radius == null ? 27 : radius / 1.5,
                    color: Colors.white,
                  ),
                );
              }, errorBuilder: (context, child, loadingProgress) {
                return Container(
                  height: radius ?? 42,
                  width: radius ?? 42,
                  color: Color(0xffDFE5E7),
                  child: Icon(
                    Icons.people_rounded,
                    size: radius == null ? 27 : radius / 1.5,
                    color: Colors.white,
                  ),
                );
              })));
}

Widget customCircleAvatarBroadcast({String? url, double? radius}) {
  return ClipRRect(
      borderRadius: BorderRadius.circular(300.0),
      child: url == null || url == ''
          ? Container(
              height: radius ?? 42,
              width: radius ?? 42,
              color: Color(0xffDFE5E7),
              child: Icon(
                Icons.campaign_rounded,
                size: radius == null ? 27 : radius / 1.5,
                color: Colors.white,
              ),
            )
          : Container(
              color: Color(0xffDFE5E7),
              child: Image.network(
                url,
                height: radius ?? 42,
                width: radius ?? 42,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: radius ?? 42,
                    width: radius ?? 42,
                    color: Color(0xffDFE5E7),
                    child: Icon(
                      Icons.campaign_rounded,
                      size: radius == null ? 27 : radius / 1.5,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, child, loadingProgress) {
                  return Container(
                    height: radius ?? 42,
                    width: radius ?? 42,
                    color: Color(0xffDFE5E7),
                    child: Icon(
                      Icons.campaign_rounded,
                      size: radius == null ? 27 : radius / 1.5,
                      color: Colors.white,
                    ),
                  );
                },
              )));
}
