//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/Broadcast/AddContactsToBroadcast.dart';
import 'package:fiberchat_web/Screens/Broadcast/EditBroadcastDetails.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/profile_settings/profile_view.dart';

import 'package:fiberchat_web/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BroadcastDetails extends StatefulWidget {
  final DataModel? model;
  final SharedPreferences prefs;
  final String currentUserno;
  final String broadcastID;
  const BroadcastDetails(
      {Key? key,
      this.model,
      required this.prefs,
      required this.currentUserno,
      required this.broadcastID})
      : super(key: key);

  @override
  _BroadcastDetailsState createState() => _BroadcastDetailsState();
}

class _BroadcastDetailsState extends State<BroadcastDetails> {
  Uint8List? imageFile;

  bool isloading = false;
  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;

  @override
  void initState() {
    super.initState();
  }

  Future uploadFile(Uint8List imageFile) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = 'BROADCAST_ICON';
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
        .child(fileName);

    TaskSnapshot uploading = await reference.putData(imageFile);

    return uploading.ref.getDownloadURL();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  userAction(
    value,
    String targetPhone,
  ) async {
    if (value == 'Remove from List') {
      showDialog(
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text(
              getTranslated(context, 'removefromlist'),
            ),
            actions: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    getTranslated(context, 'cancel'),
                    style:
                        TextStyle(color: fiberchatSECONDARYolor, fontSize: 18),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                ),
                child: Text(
                  getTranslated(context, 'remove'),
                  style: TextStyle(color: Colors.red, fontSize: 18),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  setStateIfMounted(() {
                    isloading = true;
                  });
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionbroadcasts)
                      .doc(widget.broadcastID)
                      .set({
                    Dbkeys.broadcastMEMBERSLIST:
                        FieldValue.arrayRemove([targetPhone]),
                  }, SetOptions(merge: true)).then((value) async {
                    DateTime time = DateTime.now();
                    await FirebaseFirestore.instance
                        .collection(DbPaths.collectionbroadcasts)
                        .doc(widget.broadcastID)
                        .collection(DbPaths.collectionbroadcastsChats)
                        .doc(time.millisecondsSinceEpoch.toString() +
                            '--' +
                            widget.currentUserno)
                        .set({
                      Dbkeys.broadcastmsgCONTENT:
                          '${getTranslated(context, 'youhaveremoved')} $targetPhone',
                      Dbkeys.broadcastmsgLISToptional: [
                        targetPhone,
                      ],
                      Dbkeys.broadcastmsgTIME: time.millisecondsSinceEpoch,
                      Dbkeys.broadcastmsgSENDBY: widget.currentUserno,
                      Dbkeys.broadcastmsgISDELETED: false,
                      Dbkeys.broadcastmsgTYPE:
                          Dbkeys.broadcastmsgTYPEnotificationRemovedUser,
                    });
                    setStateIfMounted(() {
                      isloading = false;
                    });
                  }).catchError((onError) {
                    setStateIfMounted(() {
                      isloading = false;
                    });
                    // Fiberchat.toast(
                    //     'Failed to remove ! \nError occured -$onError');
                  });
                },
              )
            ],
          );
        },
        context: this.context,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Consumer<List<BroadcastModel>>(
            builder: (context, broadcastList, _child) {
          final observer = Provider.of<Observer>(context, listen: false);
          Map<dynamic, dynamic> broadcastDoc = broadcastList.indexWhere(
                      (element) =>
                          element.docmap[Dbkeys.broadcastID] ==
                          widget.broadcastID) <
                  0
              ? {}
              : broadcastList
                  .lastWhere((element) =>
                      element.docmap[Dbkeys.broadcastID] == widget.broadcastID)
                  .docmap;
          return Consumer<SmartContactProviderWithLocalStoreData>(
              builder: (context, availableContacts, _child) => Scaffold(
                    backgroundColor: fiberchatScaffold,
                    appBar: AppBar(
                      centerTitle: true,
                      elevation: 0.4,
                      titleSpacing: -5,
                      leading: Container(
                        margin: EdgeInsets.only(right: 0),
                        width: 10,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 24,
                            color: fiberchatBlack,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      actions: <Widget>[
                        IconButton(
                            onPressed: () {
                              Navigator.push(
                                  this.context,
                                  new MaterialPageRoute(
                                      builder: (context) =>
                                          new EditBroadcastDetails(
                                            prefs: widget.prefs,
                                            currentUserNo: widget.currentUserno,
                                            isadmin: true,
                                            broadcastDesc: broadcastDoc[
                                                Dbkeys.broadcastDESCRIPTION],
                                            broadcastName: broadcastDoc[
                                                Dbkeys.broadcastNAME],
                                            broadcastID: widget.broadcastID,
                                          )));
                            },
                            icon: Icon(
                              Icons.edit,
                              size: 21,
                              color: fiberchatBlack,
                            ))
                      ],
                      backgroundColor: fiberchatWhite,
                      title: InkWell(
                        onTap: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              broadcastDoc[Dbkeys.broadcastNAME],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: fiberchatBlack,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              '${getTranslated(context, 'createdbyu')}, ${formatDate(broadcastDoc[Dbkeys.broadcastCREATEDON].toDate())}',
                              style: TextStyle(
                                  color: fiberchatGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: getContentScreenWidth(w),
                        padding: EdgeInsets.only(bottom: 0),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ListView(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(w / 41.2),
                                  child: Center(
                                    child: Column(children: [
                                      customCircleAvatarBroadcast(
                                          url: broadcastDoc[
                                              Dbkeys.broadcastPHOTOURL],
                                          radius: w > h ? w / 8 : w / 4),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              try {
                                                FilePickerResult? result;

                                                result = await FilePicker
                                                    .platform
                                                    .pickFiles(
                                                  type: FileType.custom,
                                                  allowedExtensions: [
                                                    'jpg',
                                                    'png',
                                                    'jpeg',
                                                  ],
                                                );

                                                if (result != null) {
                                                  Uint8List uploadfile = result
                                                      .files.single.bytes!;
                                                  setState(() {
                                                    imageFile = uploadfile;
                                                  });

                                                  if ((result.files.single
                                                              .bytes!.length /
                                                          1000000) >
                                                      observer
                                                          .maxFileSizeAllowedInMB) {
                                                    Fiberchat.toast(
                                                        'File size should be less than ${observer.maxFileSizeAllowedInMB}MB. The current file size is ${(result.files.single.bytes!.lengthInBytes / 1000000)}MB');
                                                  } else {
                                                    setState(() {
                                                      isloading = true;
                                                    });
                                                    var url = await uploadFile(
                                                        uploadfile);
                                                    if (url != null) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionbroadcasts)
                                                          .doc(widget
                                                              .broadcastID)
                                                          .set(
                                                              {
                                                            Dbkeys.broadcastPHOTOURL:
                                                                url
                                                          },
                                                              SetOptions(
                                                                  merge:
                                                                      true)).then(
                                                              (value) async {
                                                        DateTime time =
                                                            DateTime.now();
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionbroadcasts)
                                                            .doc(widget
                                                                .broadcastID)
                                                            .collection(DbPaths
                                                                .collectionbroadcastsChats)
                                                            .doc(time
                                                                    .millisecondsSinceEpoch
                                                                    .toString() +
                                                                '--' +
                                                                widget
                                                                    .currentUserno
                                                                    .toString())
                                                            .set({
                                                          Dbkeys.broadcastmsgCONTENT:
                                                              getTranslated(
                                                                  context,
                                                                  'broadcasticonupdtd'),
                                                          Dbkeys.broadcastmsgLISToptional:
                                                              [],
                                                          Dbkeys.broadcastmsgTIME:
                                                              time.millisecondsSinceEpoch,
                                                          Dbkeys.broadcastmsgSENDBY:
                                                              widget
                                                                  .currentUserno,
                                                          Dbkeys.broadcastmsgISDELETED:
                                                              false,
                                                          Dbkeys.broadcastmsgTYPE:
                                                              Dbkeys
                                                                  .broadcastmsgTYPEnotificationUpdatedbroadcasticon,
                                                        });
                                                      });
                                                    } else {}
                                                  }
                                                }
                                              } catch (e) {
                                                Fiberchat.toast(e.toString());
                                              }
                                            },
                                            icon: CircleAvatar(
                                              radius: 45,
                                              backgroundColor:
                                                  fiberchatSECONDARYolor,
                                              child: Icon(Icons.edit,
                                                  color: fiberchatWhite,
                                                  size: 17),
                                            ),
                                          ),
                                          broadcastDoc[Dbkeys
                                                      .broadcastPHOTOURL] ==
                                                  null
                                              ? SizedBox()
                                              : IconButton(
                                                  onPressed: () async {
                                                    Fiberchat.toast(
                                                      getTranslated(
                                                          context, 'plswait'),
                                                    );
                                                    await FirebaseStorage
                                                        .instance
                                                        .refFromURL(
                                                            broadcastDoc[Dbkeys
                                                                .broadcastPHOTOURL])
                                                        .delete()
                                                        .then((d) async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionbroadcasts)
                                                          .doc(widget
                                                              .broadcastID)
                                                          .set(
                                                              {
                                                            Dbkeys.broadcastPHOTOURL:
                                                                null,
                                                          },
                                                              SetOptions(
                                                                  merge: true));
                                                      DateTime time =
                                                          DateTime.now();
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                              .collectionbroadcasts)
                                                          .doc(widget
                                                              .broadcastID)
                                                          .collection(DbPaths
                                                              .collectionbroadcastsChats)
                                                          .doc(time
                                                                  .millisecondsSinceEpoch
                                                                  .toString() +
                                                              '--' +
                                                              widget
                                                                  .currentUserno
                                                                  .toString())
                                                          .set({
                                                        Dbkeys.broadcastmsgCONTENT:
                                                            getTranslated(
                                                                context,
                                                                'broadcasticondlted'),
                                                        Dbkeys.broadcastmsgLISToptional:
                                                            [],
                                                        Dbkeys.broadcastmsgTIME:
                                                            time.millisecondsSinceEpoch,
                                                        Dbkeys.broadcastmsgSENDBY:
                                                            widget
                                                                .currentUserno,
                                                        Dbkeys.broadcastmsgISDELETED:
                                                            false,
                                                        Dbkeys.broadcastmsgTYPE:
                                                            Dbkeys
                                                                .broadcastmsgTYPEnotificationDeletedbroadcasticon,
                                                      });
                                                    }).catchError(
                                                            (error) async {
                                                      if (error.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                                          error
                                                              .toString()
                                                              .contains(Dbkeys
                                                                  .firebaseStorageNoObjectFound2) ||
                                                          error
                                                              .toString()
                                                              .contains(Dbkeys
                                                                  .firebaseStorageNoObjectFound3) ||
                                                          error
                                                              .toString()
                                                              .contains(Dbkeys
                                                                  .firebaseStorageNoObjectFound4)) {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionbroadcasts)
                                                            .doc(widget
                                                                .broadcastID)
                                                            .set(
                                                                {
                                                              Dbkeys.broadcastPHOTOURL:
                                                                  null,
                                                            },
                                                                SetOptions(
                                                                    merge:
                                                                        true));
                                                      }
                                                    });
                                                  },
                                                  icon: Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color:
                                                          fiberchatPRIMARYcolor,
                                                      size: 35),
                                                ),
                                        ],
                                      )
                                    ]),
                                  ),
                                ),
                                // Stack(
                                //   children: [
                                //     Image.network(
                                //       broadcastDoc[Dbkeys.broadcastPHOTOURL] ??
                                //           '',
                                //       width: w,
                                //       height: w / 1.2,
                                //     ),
                                //     Container(
                                //       alignment: Alignment.bottomRight,
                                //       width: w,
                                //       height: w / 1.2,
                                //       decoration: BoxDecoration(
                                //         color: broadcastDoc[
                                //                     Dbkeys.broadcastPHOTOURL] ==
                                //                 null
                                //             ? Colors.black.withOpacity(0.2)
                                //             : Colors.black.withOpacity(0.4),
                                //         shape: BoxShape.rectangle,
                                //       ),
                                //       child: Padding(
                                //         padding: const EdgeInsets.all(18.0),
                                //         child: Row(
                                //           mainAxisSize: MainAxisSize.min,
                                //           children: [
                                //             IconButton(
                                //               onPressed: () {
                                //                 Navigator.push(
                                //                     context,
                                //                     MaterialPageRoute(
                                //                         builder: (context) =>
                                //                             SingleImagePicker(
                                //                               title: getTranslated(
                                //                                   this.context,
                                //                                   'pickimage'),
                                //                               callback:
                                //                                   getImage,
                                //                             ))).then(
                                //                     (url) async {
                                //                   if (url != null) {
                                //                     await FirebaseFirestore
                                //                         .instance
                                //                         .collection(DbPaths
                                //                             .collectionbroadcasts)
                                //                         .doc(widget.broadcastID)
                                //                         .update({
                                //                       Dbkeys.broadcastPHOTOURL:
                                //                           url
                                //                     }).then((value) async {
                                //                       DateTime time =
                                //                           DateTime.now();
                                //                       await FirebaseFirestore
                                //                           .instance
                                //                           .collection(DbPaths
                                //                               .collectionbroadcasts)
                                //                           .doc(widget
                                //                               .broadcastID)
                                //                           .collection(DbPaths
                                //                               .collectionbroadcastsChats)
                                //                           .doc(time
                                //                                   .millisecondsSinceEpoch
                                //                                   .toString() +
                                //                               '--' +
                                //                               widget
                                //                                   .currentUserno
                                //                                   .toString())
                                //                           .set({
                                //                         Dbkeys.broadcastmsgCONTENT:
                                //                             getTranslated(
                                //                                 context,
                                //                                 'broadcasticonupdtd'),
                                //                         Dbkeys.broadcastmsgLISToptional:
                                //                             [],
                                //                         Dbkeys.broadcastmsgTIME:
                                //                             time.millisecondsSinceEpoch,
                                //                         Dbkeys.broadcastmsgSENDBY:
                                //                             widget
                                //                                 .currentUserno,
                                //                         Dbkeys.broadcastmsgISDELETED:
                                //                             false,
                                //                         Dbkeys.broadcastmsgTYPE:
                                //                             Dbkeys
                                //                                 .broadcastmsgTYPEnotificationUpdatedbroadcasticon,
                                //                       });
                                //                     });
                                //                   } else {}
                                //                 });
                                //               },
                                //               icon: Icon(
                                //                   Icons.camera_alt_rounded,
                                //                   color: fiberchatWhite,
                                //                   size: 35),
                                //             ),
                                //             broadcastDoc[Dbkeys
                                //                         .broadcastPHOTOURL] ==
                                //                     null
                                //                 ? SizedBox()
                                //                 : IconButton(
                                //                     onPressed: () async {
                                //                       Fiberchat.toast(
                                //                         getTranslated(
                                //                             context, 'plswait'),
                                //                       );
                                //                       await FirebaseStorage
                                //                           .instance
                                //                           .refFromURL(
                                //                               broadcastDoc[Dbkeys
                                //                                   .broadcastPHOTOURL])
                                //                           .delete()
                                //                           .then((d) async {
                                //                         await FirebaseFirestore
                                //                             .instance
                                //                             .collection(DbPaths
                                //                                 .collectionbroadcasts)
                                //                             .doc(widget
                                //                                 .broadcastID)
                                //                             .update({
                                //                           Dbkeys.broadcastPHOTOURL:
                                //                               null,
                                //                         });
                                //                         DateTime time =
                                //                             DateTime.now();
                                //                         await FirebaseFirestore
                                //                             .instance
                                //                             .collection(DbPaths
                                //                                 .collectionbroadcasts)
                                //                             .doc(widget
                                //                                 .broadcastID)
                                //                             .collection(DbPaths
                                //                                 .collectionbroadcastsChats)
                                //                             .doc(time
                                //                                     .millisecondsSinceEpoch
                                //                                     .toString() +
                                //                                 '--' +
                                //                                 widget
                                //                                     .currentUserno
                                //                                     .toString())
                                //                             .set({
                                //                           Dbkeys.broadcastmsgCONTENT:
                                //                               getTranslated(
                                //                                   context,
                                //                                   'broadcasticondlted'),
                                //                           Dbkeys.broadcastmsgLISToptional:
                                //                               [],
                                //                           Dbkeys.broadcastmsgTIME:
                                //                               time.millisecondsSinceEpoch,
                                //                           Dbkeys.broadcastmsgSENDBY:
                                //                               widget
                                //                                   .currentUserno,
                                //                           Dbkeys.broadcastmsgISDELETED:
                                //                               false,
                                //                           Dbkeys.broadcastmsgTYPE:
                                //                               Dbkeys
                                //                                   .broadcastmsgTYPEnotificationDeletedbroadcasticon,
                                //                         });
                                //                       }).catchError(
                                //                               (error) async {
                                //                         if (error.toString().contains(Dbkeys.firebaseStorageNoObjectFound1) ||
                                //                             error
                                //                                 .toString()
                                //                                 .contains(Dbkeys
                                //                                     .firebaseStorageNoObjectFound2) ||
                                //                             error
                                //                                 .toString()
                                //                                 .contains(Dbkeys
                                //                                     .firebaseStorageNoObjectFound3) ||
                                //                             error
                                //                                 .toString()
                                //                                 .contains(Dbkeys
                                //                                     .firebaseStorageNoObjectFound4)) {
                                //                           await FirebaseFirestore
                                //                               .instance
                                //                               .collection(DbPaths
                                //                                   .collectionbroadcasts)
                                //                               .doc(widget
                                //                                   .broadcastID)
                                //                               .update({
                                //                             Dbkeys.broadcastPHOTOURL:
                                //                                 null,
                                //                           });
                                //                         }
                                //                       });
                                //                     },
                                //                     icon: Icon(
                                //                         Icons
                                //                             .delete_outline_rounded,
                                //                         color: fiberchatWhite,
                                //                         size: 35),
                                //                   ),
                                //           ],
                                //         ),
                                //       ),
                                //     ),
                                //   ],
                                // ),
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            getTranslated(context, 'desc'),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: fiberchatPRIMARYcolor,
                                                fontSize: 16),
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    this.context,
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            new EditBroadcastDetails(
                                                              prefs:
                                                                  widget.prefs,
                                                              currentUserNo: widget
                                                                  .currentUserno,
                                                              isadmin: true,
                                                              broadcastDesc:
                                                                  broadcastDoc[
                                                                      Dbkeys
                                                                          .broadcastDESCRIPTION],
                                                              broadcastName:
                                                                  broadcastDoc[
                                                                      Dbkeys
                                                                          .broadcastNAME],
                                                              broadcastID: widget
                                                                  .broadcastID,
                                                            )));
                                              },
                                              icon: Icon(
                                                Icons.edit,
                                                color: fiberchatGrey,
                                              ))
                                        ],
                                      ),
                                      Divider(),
                                      SizedBox(
                                        height: 7,
                                      ),
                                      Text(
                                        broadcastDoc[Dbkeys
                                                    .broadcastDESCRIPTION] ==
                                                ''
                                            ? getTranslated(context, 'nodesc')
                                            : broadcastList
                                                    .lastWhere((element) =>
                                                        element.docmap[Dbkeys
                                                            .broadcastID] ==
                                                        widget.broadcastID)
                                                    .docmap[
                                                Dbkeys.broadcastDESCRIPTION],
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: fiberchatBlack,
                                            fontSize: 15.3),
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
                                Container(
                                  color: Colors.white,
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 150,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${broadcastList.lastWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST].length} ${getTranslated(context, 'recipients')}  ',
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          fiberchatPRIMARYcolor,
                                                      fontSize: 16),
                                                ),
                                                // Text(
                                                //   '${broadcastList.firstWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.groupMEMBERSLIST].length}',
                                                //   style: TextStyle(
                                                //       fontWeight: FontWeight.bold,
                                                //       fontSize: 16),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          (broadcastDoc[Dbkeys
                                                          .broadcastMEMBERSLIST]
                                                      .length >=
                                                  observer
                                                      .broadcastMemberslimit)
                                              ? SizedBox()
                                              : InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddContactsToBroadcast(
                                                                  currentUserNo:
                                                                      widget
                                                                          .currentUserno,
                                                                  model: widget
                                                                      .model,
                                                                  biometricEnabled:
                                                                      false,
                                                                  prefs: widget
                                                                      .prefs,
                                                                  broadcastID:
                                                                      widget
                                                                          .broadcastID,
                                                                  isAddingWhileCreatingBroadcast:
                                                                      false,
                                                                )));
                                                  },
                                                  child: SizedBox(
                                                    height: 50,
                                                    // width: 70,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 30,
                                                          child: Icon(Icons.add,
                                                              size: 19,
                                                              color:
                                                                  fiberchatPRIMARYcolor),
                                                        ),
                                                        // Text(
                                                        //   'ADD ',
                                                        //   style: TextStyle(
                                                        //       fontWeight:
                                                        //           FontWeight.bold,
                                                        //       color:
                                                        //           fiberchatPRIMARYcolor),
                                                        // ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                        ],
                                      ),
                                      // Divider(),
                                      getUsersList(),
                                    ],
                                  ),
                                ),
                                widget.currentUserno ==
                                        broadcastDoc[Dbkeys.broadcastCREATEDBY]
                                    ? InkWell(
                                        onTap: () {
                                          showDialog(
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: new Text(
                                                  getTranslated(context,
                                                      'deletebroadcast'),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      getTranslated(
                                                          context, 'cancel'),
                                                      style: TextStyle(
                                                          color:
                                                              fiberchatSECONDARYolor,
                                                          fontSize: 18),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                                    child: Text(
                                                      getTranslated(
                                                          context, 'delete'),
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 18),
                                                    ),
                                                    onPressed: () async {
                                                      var currentpeer = Provider
                                                          .of<CurrentChatPeer>(
                                                              context,
                                                              listen: false);
                                                      currentpeer
                                                          .removeCurrentWidget();
                                                      Navigator.of(context)
                                                          .pop();

                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                          () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection(DbPaths
                                                                .collectionbroadcasts)
                                                            .doc(widget
                                                                .broadcastID)
                                                            .get()
                                                            .then((doc) async {
                                                          await doc.reference
                                                              .delete();
                                                          //No need to delete the media data from here as it will be deleted automatically using Cloud functions deployed in Firebase once the .doc is deleted .
                                                        });

                                                        Navigator.of(
                                                                this.context)
                                                            .pop();
                                                        if (!isWideScreen(w)) {
                                                          Navigator.of(
                                                                  this.context)
                                                              .pop();
                                                        }
                                                      });
                                                    },
                                                  )
                                                ],
                                              );
                                            },
                                            context: context,
                                          );
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.fromLTRB(
                                                10, 30, 10, 30),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 48.0,
                                            decoration: new BoxDecoration(
                                              color: Colors.red[700],
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      5.0),
                                            ),
                                            child: Text(
                                              getTranslated(
                                                  context, 'deletebroadcast'),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            )),
                                      )
                                    : SizedBox()
                              ],
                            ),
                            Positioned(
                              child: isloading
                                  ? Container(
                                      child: Center(
                                        child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    fiberchatSECONDARYolor)),
                                      ),
                                      color: fiberchatWhite.withOpacity(0.6))
                                  : Container(),
                            )
                          ],
                        ),
                      ),
                    ),
                  ));
        })));
  }

  getUsersList() {
    return Consumer<List<BroadcastModel>>(
        builder: (context, broadcastList, _child) {
      Map<dynamic, dynamic> broadcastDoc = broadcastList
          .lastWhere((element) =>
              element.docmap[Dbkeys.broadcastID] == widget.broadcastID)
          .docmap;

      return Consumer<SmartContactProviderWithLocalStoreData>(
          builder: (context, availableContacts, _child) {
        List onlyuserslist = broadcastDoc[Dbkeys.broadcastMEMBERSLIST];
        broadcastDoc[Dbkeys.broadcastMEMBERSLIST].toList().forEach((member) {
          if (broadcastDoc[Dbkeys.broadcastADMINLIST].contains(member)) {
            onlyuserslist.remove(member);
          }
        });
        return ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemCount: onlyuserslist.length,
            itemBuilder: (context, int i) {
              List viewerslist = onlyuserslist;
              return FutureBuilder<LocalUserData?>(
                  future: availableContacts.fetchUserDataFromnLocalOrServer(
                      widget.prefs, viewerslist[i]),
                  builder: (context, AsyncSnapshot<LocalUserData?> snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(
                            height: 3,
                          ),
                          Stack(
                            children: [
                              ListTile(
                                trailing: SizedBox(
                                  width: 30,
                                  child: PopupMenuButton<String>(
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'Remove from List',
                                              child: Text(
                                                getTranslated(
                                                    context, 'removefromlist'),
                                              ),
                                            ),
                                          ],
                                      onSelected: (String value) {
                                        userAction(
                                          value,
                                          viewerslist[i],
                                        );
                                      },
                                      child: Icon(
                                        Icons.more_vert_outlined,
                                        size: 20,
                                        color: fiberchatBlack,
                                      )),
                                ),
                                isThreeLine: false,
                                contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                leading: Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: customCircleAvatar(
                                          url: snapshot.data!.photoURL,
                                          radius: 42)),
                                ),
                                title: Text(
                                  availableContacts
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.phone ==
                                                  viewerslist[i]) >
                                          0
                                      ? availableContacts
                                          .alreadyJoinedSavedUsersPhoneNameAsInServer
                                          .elementAt(availableContacts
                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                              .toList()
                                              .indexWhere((element) =>
                                                  element.phone ==
                                                  viewerslist[i]))
                                          .name
                                          .toString()
                                      : snapshot.data!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
                                ),
                                subtitle: Text(
                                  //-- or about me
                                  snapshot.data!.id,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(height: 1.4),
                                ),
                                onTap: widget.currentUserno == snapshot.data!.id
                                    ? () {}
                                    : () async {
                                        await availableContacts
                                            .fetchFromFiretsoreAndReturnData(
                                                widget.prefs, snapshot.data!.id,
                                                (doc) {
                                          Navigator.push(
                                              context,
                                              new MaterialPageRoute(
                                                  builder: (context) =>
                                                      new ProfileView(
                                                          doc.data()!,
                                                          widget.currentUserno,
                                                          widget.model,
                                                          widget.prefs,
                                                          [],
                                                          firestoreUserDoc:
                                                              null)));
                                        });
                                      },
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          height: 3,
                        ),
                        Stack(
                          children: [
                            ListTile(
                              isThreeLine: false,
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              leading: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Image.network(
                                    '',
                                    width: 40.0,
                                    height: 40.0,
                                  ),
                                ),
                              ),
                              title: Text(
                                availableContacts
                                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                                            .toList()
                                            .indexWhere((element) =>
                                                element.phone ==
                                                viewerslist[i]) >
                                        0
                                    ? availableContacts
                                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                                        .elementAt(availableContacts
                                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                                            .toList()
                                            .indexWhere((element) =>
                                                element.phone ==
                                                viewerslist[i]))
                                        .name
                                        .toString()
                                    : viewerslist[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              subtitle: Text(
                                '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  });
            });
      });
    });
  }
}

formatDate(DateTime timeToFormat) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  final String formatted = formatter.format(timeToFormat);
  return formatted;
}
