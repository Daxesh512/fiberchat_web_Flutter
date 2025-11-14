//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Screens/Groups/GroupDetails.dart';
import 'package:fiberchat_web/Screens/Groups/widget/groupChatBubble.dart';
import 'package:fiberchat_web/Screens/auth_screens/login.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat_web/Screens/contact_screens/SelectContactsToForward.dart';
import 'package:fiberchat_web/Screens/homepage/homepage.dart';
//androidIosBarrier
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/chat_controller.dart';
import 'package:fiberchat_web/Utils/custom_url_launcher.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/emoji_detect.dart';
import 'package:fiberchat_web/Utils/file_selector_uploader.dart';
import 'package:fiberchat_web/Utils/mime_type.dart';
import 'package:fiberchat_web/Utils/setStatusBarColor.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/CustomDialog/custom_dialog.dart';
import 'package:fiberchat_web/widgets/DownloadManager/download_all_file_type.dart';
import 'package:fiberchat_web/widgets/InfiniteList/InfiniteCOLLECTIONListViewWidget.dart';
import 'package:fiberchat_web/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:link_preview_generator/link_preview_generator.dart';

import 'package:provider/provider.dart';
import 'dart:async';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'dart:io';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/photo_view.dart';
import 'package:fiberchat_web/Utils/save.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:record/record.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:fiberchat_web/Utils/unawaited.dart';
import 'package:fiberchat_web/Models/E2EE/e2ee.dart' as e2ee;
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:path/path.dart' as p;

class GroupChatPage extends StatefulWidget {
  final String currentUserno;
  final String groupID;
  final int joinedTime;
  final DataModel model;
  final SharedPreferences prefs;
  final bool isWideScreenMode;
  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  final bool isCurrentUserMuted;
  GroupChatPage({
    Key? key,
    required this.currentUserno,
    required this.groupID,
    required this.isWideScreenMode,
    required this.joinedTime,
    required this.model,
    required this.prefs,
    required this.isSharingIntentForwarded,
    required this.isCurrentUserMuted,
    this.sharedFilestype,
    this.sharedText,
  }) : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage>
    with WidgetsBindingObserver {
  bool isgeneratingSomethingLoader = false;
  // int tempSendIndex = 0;
  late String messageReplyOwnerName;
  late Stream<QuerySnapshot> groupChatMessages;
  final TextEditingController reportEditingController =
      new TextEditingController();
  late Query firestoreChatquery;
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsssaadqeqe');
  final ScrollController realtime = new ScrollController();
  Map<String, dynamic>? replyDoc;
  bool isReplyKeyboard = false;

  bool isCurrentUserMuted = false;
  @override
  void initState() {
    super.initState();
    isCurrentUserMuted = widget.isCurrentUserMuted;
    firestoreChatquery = FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .doc(widget.groupID)
        .collection(DbPaths.collectiongroupChats)
        .where(Dbkeys.groupmsgTIME, isGreaterThanOrEqualTo: widget.joinedTime)
        .orderBy(Dbkeys.groupmsgTIME, descending: true)
        .limit(maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      var firestoreProvider =
          Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(this.context,
              listen: false);
      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1700), () {
        loadMessagesAndListen();

        currentpeer.setpeer(
            newgroupChatId: widget.groupID
                .replaceAll(RegExp('-'), '')
                .substring(
                    1,
                    widget.groupID
                        .replaceAll(RegExp('-'), '')
                        .toString()
                        .length));
      });
    });
    setStatusBarColor();
  }

  // ignore: cancel_subscriptions
  StreamSubscription<QuerySnapshot>? subscription;
  loadMessagesAndListen() async {
    subscription = firestoreChatquery.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot newDoc = change.doc;
          // if (chatprovider.datalistSnapshot.length == 0) {
          // } else if ((chatprovider.checkIfDocAlreadyExits(
          //       newDoc: newDoc,
          //     ) ==
          //     false)) {

          // if (newDoc[Dbkeys.groupmsgSENDBY] != widget.currentUserno) {
          chatprovider.addDoc(newDoc);
          // unawaited(realtime.animateTo(0.0,
          //     duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          // }
          // }
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot updatedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: updatedDoc,
                  timestamp: updatedDoc[Dbkeys.timestamp]) ==
              true) {
            chatprovider.updateparticulardocinProvider(updatedDoc: updatedDoc);
          }
        } else if (change.type == DocumentChangeType.removed) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                  this.context,
                  listen: false);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.groupmsgTIME]) ==
              true) {
            chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      });
    });

    setStateIfMounted(() {});

//       //----sharing intent action:
    // IsRequirefocus;
    // if (widget.isSharingIntentForwarded == true) {
    //   if (widget.sharedText != null) {
    //     onSendMessage(
    //         context: this.context,
    //         content: widget.sharedText!,
    //         type: MessageType.text,
    //         timestamp: DateTime.now().millisecondsSinceEpoch);
    //   } else if (widget.sharedFiles != null) {
    //     setStateIfMounted(() {
    //       isgeneratingSomethingLoader = true;
    //     });
    //     uploadEach(0);
    //   }
    // }
  }

  int currentUploadingIndex = 0;

  // uploadEach(
  //   int index,
  // ) async {
  //   File file = new File(widget.sharedFiles![index].path);
  //   String fileName = file.path.split('/').last.toLowerCase();

  //   if (index >= widget.sharedFiles!.length) {
  //     setStateIfMounted(() {
  //       isgeneratingSomethingLoader = false;
  //     });
  //   } else {
  //     int messagetime = DateTime.now().millisecondsSinceEpoch;
  //     setState(() {
  //       currentUploadingIndex = index;
  //     });
  //     await getFileData(File(widget.sharedFiles![index].path),
  //             timestamp: messagetime, totalFiles: widget.sharedFiles!.length)
  //         .then((imageUrl) async {
  //       if (imageUrl != null) {
  //         MessageType type = fileName.contains('.png') ||
  //                 fileName.contains('.gif') ||
  //                 fileName.contains('.jpg') ||
  //                 fileName.contains('.jpeg') ||
  //                 fileName.contains('giphy')
  //             ? MessageType.image
  //             : fileName.contains('.mp4') || fileName.contains('.mov')
  //                 ? MessageType.video
  //                 : fileName.contains('.mp3') || fileName.contains('.aac')
  //                     ? MessageType.audio
  //                     : MessageType.doc;
  //         String? thumbnailurl;
  //         if (type == MessageType.video) {
  //           thumbnailurl = await getThumbnail(imageUrl);
  //           print('THUMNBNAIL URL::::: ' + thumbnailurl!);
  //           setStateIfMounted(() {});
  //         }

  //         String finalUrl = fileName.contains('.png') ||
  //                 fileName.contains('.gif') ||
  //                 fileName.contains('.jpg') ||
  //                 fileName.contains('.jpeg') ||
  //                 fileName.contains('giphy')
  //             ? imageUrl
  //             : fileName.contains('.mp4') || fileName.contains('.mov')
  //                 ? imageUrl +
  //                     '-BREAK-' +
  //                     thumbnailurl +
  //                     '-BREAK-' +
  //                     videometadata
  //                 : fileName.contains('.mp3') || fileName.contains('.aac')
  //                     ? imageUrl + '-BREAK-' + uploadTimestamp.toString()
  //                     : imageUrl +
  //                         '-BREAK-' +
  //                         basename(pickedFile!.path).toString();
  //         onSendMessage(
  //             context: this.context,
  //             content: finalUrl,
  //             type: type,
  //             timestamp: messagetime);
  //       }
  //     }).then((value) {
  //       if (widget.sharedFiles!.last == widget.sharedFiles![index]) {
  //         setStateIfMounted(() {
  //           isgeneratingSomethingLoader = false;
  //         });
  //       } else {
  //         uploadEach(currentUploadingIndex + 1);
  //       }
  //     });
  //   }
  // }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop, isemojikeyboardopen) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectiongroups)
        .doc(widget.groupID)
        .set({
      widget.currentUserno: DateTime.now().millisecondsSinceEpoch,
    }, SetOptions(merge: true));
    setStatusBarColor();
    if (iswillpop == true && isemojikeyboardopen == false) {
      Navigator.of(this.context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false, isemojiShowing);
    subscription!.cancel();
  }

  File? pickedFile;
  File? thumbnailFile;

  getFileData(File image, {int? timestamp, int? totalFiles}) {
    final observer = Provider.of<Observer>(this.context, listen: false);

    setStateIfMounted(() {
      pickedFile = image;
    });

    return observer.isPercentProgressShowWhileUploading
        ? (totalFiles == null
            ? uploadFileWithProgressIndicator(
                false,
                timestamp: timestamp,
              )
            : totalFiles == 1
                ? uploadFileWithProgressIndicator(
                    false,
                    timestamp: timestamp,
                  )
                : uploadFile(false, timestamp: timestamp))
        : uploadFile(false, timestamp: timestamp);
  }

  getFileName(groupid, timestamp) {
    return "${widget.currentUserno}-$timestamp";
  }

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });
    // IsRequirefocus;
    // String? path = await VideoThumbnail.thumbnailFile(
    //     video: url,
    //     thumbnailPath: (await getTemporaryDirectory()).path,
    //     imageFormat: ImageFormat.PNG,
    //     quality: 20);
    // thumbnailFile = File(path!);
    // setStateIfMounted(() {
    //   isgeneratingSomethingLoader = false;
    // });
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        widget.groupID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile! : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      // IsRequirefocus;
      // MediaInfo _mediaInfo = MediaInfo();
      // await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
      //   setStateIfMounted(() {
      //     videometadata = jsonEncode({
      //       "width": mediaInfo['width'],
      //       "height": mediaInfo['height'],
      //       "orientation": null,
      //       "duration": mediaInfo['durationMs'],
      //       "filesize": null,
      //       "author": null,
      //       "date": null,
      //       "framerate": null,
      //       "location": null,
      //       "path": null,
      //       "title": '',
      //       "mimetype": mediaInfo['mimeType'],
      //     }).toString();
      //   });
      // }).catchError((onError) {
      //   Fiberchat.toast('Sending failed !');
      //   print('ERROR SENDING MEDIA: $onError');
      // });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    return uploading.ref.getDownloadURL();
  }

  Future uploadFileWithProgressIndicator(
    bool isthumbnail, {
    int? timestamp,
  }) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

    String fileName = getFileName(
        widget.currentUserno,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    File? compressedImage;

    if (isthumbnail == false && isVideo(pickedFile!.path) == true) {
      // IsRequirefocus;
      // await compress.VideoCompress.setLogLevel(0);

      // final compress.MediaInfo? info =
      //     await compress.VideoCompress.compressVideo(
      //   fileToCompress.path,
      //   quality: IsVideoQualityCompress == true
      //       ? compress.VideoQuality.MediumQuality
      //       : compress.VideoQuality.HighestQuality,
      //   deleteOrigin: false,
      //   includeAudio: true,
      // );
      pickedFile = pickedFile;
    } else if (isthumbnail == false && isImage(pickedFile!.path) == true) {
      // IsRequirefocus;
      // compressedImage = await FlutterImageCompress.compressAndGetFile(
      //   pickedFile!.absolute.path,
      //   targetPath,
      //   quality: ImageQualityCompress,
      //   rotate: 0,
      // );
    } else {}

    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(pickedFile!.path) == true
            ? compressedImage!
            : pickedFile!);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // side: BorderSide(width: 5, color: Colors.green)),
                  key: _keyLoader,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      // IsRequirefocus;
      // MediaInfo _mediaInfo = MediaInfo();

      // await _mediaInfo.getMediaInfo(thumbnailFile!.path).then((mediaInfo) {
      //   setStateIfMounted(() {
      //     videometadata = jsonEncode({
      //       "width": mediaInfo['width'],
      //       "height": mediaInfo['height'],
      //       "orientation": null,
      //       "duration": mediaInfo['durationMs'],
      //       "filesize": null,
      //       "author": null,
      //       "date": null,
      //       "framerate": null,
      //       "location": null,
      //       "path": null,
      //       "title": '',
      //       "mimetype": mediaInfo['mimeType'],
      //     }).toString();
      //   });
      // }).catchError((onError) {
      //   Fiberchat.toast('Sending failed !');
      //   print('ERROR SENDING FILE: $onError');
      // });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  Future uploadSelectedLocalFileWithProgressIndicator(
      File selectedFile, bool isVideo, bool isthumbnail, int timeEpoch,
      {String? filenameoptional}) async {
    String ext = p.extension(selectedFile.path);
    String fileName = filenameoptional != null
        ? filenameoptional
        : isthumbnail == true
            ? 'Thumbnail-$timeEpoch$ext'
            : isVideo
                ? 'Video-$timeEpoch$ext'
                : 'IMG-$timeEpoch$ext';
    // String fileName = getFileName(widget.currentUserno,
    //     isthumbnail == false ? '$timeEpoch' : '${timeEpoch}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_GROUP_MEDIA/${widget.groupID}/")
        .child(fileName);

    UploadTask uploading = reference.putFile(selectedFile);

    showDialog<void>(
        context: this.context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  // side: BorderSide(width: 5, color: Colors.green)),
                  key: _keyLoader,
                  backgroundColor: Colors.white,
                  children: <Widget>[
                    Center(
                      child: StreamBuilder(
                          stream: uploading.snapshotEvents,
                          builder: (BuildContext context, snapshot) {
                            if (snapshot.hasData) {
                              final TaskSnapshot snap = uploading.snapshot;

                              return openUploadDialog(
                                context: context,
                                percent: bytesTransferred(snap) / 100,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle:
                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                              );
                            } else {
                              return openUploadDialog(
                                context: context,
                                percent: 0.0,
                                title: isthumbnail == true
                                    ? getTranslated(
                                        context, 'generatingthumbnail')
                                    : getTranslated(context, 'sending'),
                                subtitle: '',
                              );
                            }
                          }),
                    ),
                  ]));
        });

    TaskSnapshot downloadTask = await uploading;
    String downloadedurl = await downloadTask.ref.getDownloadURL();

    if (isthumbnail == true) {
      // IsRequirefocus;
      // MediaInfo _mediaInfo = MediaInfo();

      // await _mediaInfo.getMediaInfo(selectedFile.path).then((mediaInfo) {
      //   setStateIfMounted(() {
      //     videometadata = jsonEncode({
      //       "width": mediaInfo['width'],
      //       "height": mediaInfo['height'],
      //       "orientation": null,
      //       "duration": mediaInfo['durationMs'],
      //       "filesize": null,
      //       "author": null,
      //       "date": null,
      //       "framerate": null,
      //       "location": null,
      //       "path": null,
      //       "title": '',
      //       "mimetype": mediaInfo['mimeType'],
      //     }).toString();
      //   });
      // }).catchError((onError) {
      //   Fiberchat.toast('Sending failed !');
      //   print('ERROR SENDING FILE: $onError');
      // });
    } else {
      FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .doc(widget.currentUserno)
          .set({
        Dbkeys.mssgSent: FieldValue.increment(1),
      }, SetOptions(merge: true));
      FirebaseFirestore.instance
          .collection(DbPaths.collectiondashboard)
          .doc(DbPaths.docchatdata)
          .set({
        Dbkeys.mediamessagessent: FieldValue.increment(1),
      }, SetOptions(merge: true));
    }
    Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  void onSendMessage(
      {required BuildContext context,
      required String content,
      required MessageType type,
      int? timestamp,
      bool? isForward = false}) async {
    final List<GroupModel> groupList =
        Provider.of<List<GroupModel>>(context, listen: false);
    // var chatprovider = Provider.of<FirestoreDataProviderMESSAGESforGROUPCHAT>(
    //     this.context,
    //     listen: false);
    Map<dynamic, dynamic> groupDoc = groupList.indexWhere(
                (element) => element.docmap[Dbkeys.groupID] == widget.groupID) <
            0
        ? {}
        : groupList
            .lastWhere(
                (element) => element.docmap[Dbkeys.groupID] == widget.groupID)
            .docmap;
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    if (content.trim() != '') {
      content = content.trim();
      textEditingController.clear();
      FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .doc(widget.groupID)
          .collection(DbPaths.collectiongroupChats)
          .doc(timestamp.toString() + '--' + widget.currentUserno)
          .set({
        Dbkeys.groupmsgCONTENT: content,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgLISToptional: [],
        Dbkeys.groupmsgTIME: timestamp,
        Dbkeys.groupmsgSENDBY: widget.currentUserno,
        Dbkeys.groupmsgISDELETED: false,
        Dbkeys.groupmsgTYPE: type.index,
        Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
        Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
        Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
        Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
        Dbkeys.isReply: isReplyKeyboard,
        Dbkeys.replyToMsgDoc: replyDoc,
        Dbkeys.isForward: isForward
      }, SetOptions(merge: true));

      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));

      FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .doc(widget.groupID)
          .set({Dbkeys.groupLATESTMESSAGETIME: timestamp},
              SetOptions(merge: true));
      setStateIfMounted(() {
        isReplyKeyboard = false;
        replyDoc = null;
      });
      setStatusBarColor();
      unawaited(realtime.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut));
    }
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
    if (textEditingController.text.isNotEmpty &&
        textEditingController.text.length == 1) {
      setStateIfMounted(() {});
    }
    if (textEditingController.text.isEmpty) {
      setStateIfMounted(() {});
    }
  }

  final TextEditingController textEditingController =
      new TextEditingController();
  FocusNode keyboardFocusNode = new FocusNode();
  Widget buildInputTextBox(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    final observer = Provider.of<Observer>(context, listen: true);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          isReplyKeyboard == true
              ? buildReplyMessageForInput(
                  context,
                )
              : SizedBox(),
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10,
                    ),
                    decoration: BoxDecoration(
                        color: fiberchatWhite,
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: IconButton(
                            onPressed: !isWideScreen(
                                    MediaQuery.of(this.context).size.width)
                                ? () {
                                    refreshThisInput();
                                  }
                                : () {
                                    hidekeyboard(context);
                                    showCustomDialog(
                                        context: this.context,
                                        listWidgets: [
                                          Builder(
                                              builder: (BuildContext context) =>
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          icon: Icon(
                                                            Icons.close,
                                                            size: 25,
                                                            color: fiberchatGrey
                                                                .withOpacity(
                                                                    0.78),
                                                          ))
                                                    ],
                                                  )),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                1.7,
                                            width: getContentScreenWidth(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                1.7,
                                            child: EmojiPicker(
                                              onEmojiSelected:
                                                  (Category? category,
                                                      Emoji emoji) {
                                                setState(() {});
                                              },
                                              onBackspacePressed: () {
                                                // Do something when the user taps the backspace button (optional)
                                                // Set it to null to hide the Backspace-Button
                                              },
                                              textEditingController:
                                                  textEditingController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                                              config: Config(
                                                columns: 7,
                                                emojiSizeMax: 32 *
                                                    (1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                                                verticalSpacing: 0,
                                                horizontalSpacing: 0,
                                                gridPadding: EdgeInsets.zero,
                                                initCategory: Category.RECENT,
                                                bgColor: Color(0xFFF2F2F2),
                                                indicatorColor: Colors.blue,
                                                iconColor: Colors.grey,
                                                iconColorSelected: Colors.blue,
                                                backspaceColor: Colors.blue,
                                                skinToneDialogBgColor:
                                                    Colors.white,
                                                skinToneIndicatorColor:
                                                    Colors.grey,
                                                enableSkinTones: true,
                                                showRecentsTab: true,
                                                recentsLimit: 28,
                                                noRecents: const Text(
                                                  '',
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.black26),
                                                  textAlign: TextAlign.center,
                                                ), // Needs to be const Widget
                                                // Needs to be const Widget
                                                tabIndicatorAnimDuration:
                                                    kTabScrollDuration,
                                                categoryIcons:
                                                    const CategoryIcons(),
                                                buttonMode: ButtonMode.MATERIAL,
                                              ),
                                            ),
                                          )
                                        ]);
                                  },
                            icon: Icon(
                              Icons.emoji_emotions,
                              size: 23,
                              color: fiberchatGrey,
                            ),
                          ),
                        ),
                        Flexible(
                          child: TextField(
                            onTap: () {
                              if (isemojiShowing == true) {
                              } else {
                                keyboardFocusNode.requestFocus();
                                setStateIfMounted(() {});
                              }
                            },
                            onChanged: (f) {
                              if (textEditingController.text.isNotEmpty &&
                                  textEditingController.text.length == 1) {
                                setStateIfMounted(() {});
                              }
                              setStateIfMounted(() {});
                            },
                            showCursor: true,
                            focusNode: keyboardFocusNode,
                            maxLines: 10,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            style: TextStyle(
                                fontSize: 16.0, color: fiberchatBlack),
                            controller: textEditingController,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              hoverColor: Colors.transparent,
                              focusedBorder: OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderRadius: BorderRadius.circular(1),
                                borderSide: BorderSide(
                                    color: Colors.transparent, width: 1.5),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(1),
                                  borderSide:
                                      BorderSide(color: Colors.transparent)),
                              contentPadding: EdgeInsets.fromLTRB(
                                  isWideScreen(MediaQuery.of(this.context)
                                          .size
                                          .width)
                                      ? 20
                                      : 6,
                                  4,
                                  7,
                                  4),
                              hintText: getTranslated(this.context, 'msg'),
                              hintStyle:
                                  TextStyle(color: Colors.grey, fontSize: 15),
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            width: textEditingController.text.isNotEmpty
                                ? 10
                                : IsShowGIFsenderButtonByGIPHY == false
                                    ? 40
                                    : 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                textEditingController.text.isNotEmpty
                                    ? SizedBox()
                                    : SizedBox(
                                        width: 30,
                                        child: IconButton(
                                          icon: new Icon(
                                            Icons.attachment_outlined,
                                            color: fiberchatGrey,
                                          ),
                                          padding: EdgeInsets.all(0.0),
                                          onPressed:
                                              observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Fiberchat.showRationale(
                                                          getTranslated(
                                                              this.context,
                                                              'mediamssgnotallowed'));
                                                    }
                                                  : () async {
                                                      String firebasePath =
                                                          '+00_GROUP_MEDIA/${widget.groupID}/';
//---

                                                      await FileSelectorUploader
                                                          .uploadToFirebase(
                                                              isShowProgress:
                                                                  true,
                                                              context:
                                                                  this.context,
                                                              totalFilesToSelect:
                                                                  observer
                                                                      .maxNoOfFilesInMultiSharing,
                                                              isMultiple: true,
                                                              onUploadFirebaseComplete:
                                                                  (url,
                                                                      filename,
                                                                      islast) async {
                                                                String
                                                                    finalUrl =
                                                                    url +
                                                                        '-BREAK-' +
                                                                        filename;
                                                                onSendMessage(
                                                                    context: this
                                                                        .context,
                                                                    content: filename.toLowerCase().endsWith('.png') ||
                                                                            filename.toLowerCase().endsWith(
                                                                                '.jpg') ||
                                                                            filename.toLowerCase().endsWith(
                                                                                '.jpeg')
                                                                        ? url
                                                                        : finalUrl,
                                                                    type: filename.toLowerCase().endsWith('.png') ||
                                                                            filename.toLowerCase().endsWith(
                                                                                '.jpg') ||
                                                                            filename.toLowerCase().endsWith(
                                                                                '.jpeg')
                                                                        ? MessageType
                                                                            .image
                                                                        : filename.toLowerCase().endsWith(
                                                                                '.mp3')
                                                                            ? MessageType
                                                                                .audio
                                                                            : MessageType
                                                                                .doc,
                                                                    timestamp: DateTime
                                                                            .now()
                                                                        .millisecondsSinceEpoch);
                                                                if (islast ==
                                                                    true) {}
                                                              },
                                                              onStartUploading:
                                                                  () {},
                                                              maxSizeInMB: observer
                                                                  .maxFileSizeAllowedInMB,
                                                              firebaseBucketpath:
                                                                  firebasePath,
                                                              onError: (e) {
                                                                if (e != '') {
                                                                  Fiberchat
                                                                      .toast(e);
                                                                }
                                                              });
                                                    },
                                          color: fiberchatWhite,
                                        ),
                                      ),
                                textEditingController.text.length != 0 ||
                                        IsShowGIFsenderButtonByGIPHY == false
                                    ? SizedBox(
                                        width: 0,
                                      )
                                    : Container(
                                        margin: EdgeInsets.only(bottom: 5),
                                        height: 35,
                                        alignment: Alignment.topLeft,
                                        width: 40,
                                        child: IconButton(
                                            color: fiberchatWhite,
                                            padding: EdgeInsets.all(0.0),
                                            icon: Icon(
                                              Icons.gif_rounded,
                                              size: 40,
                                              color: fiberchatGrey,
                                            ),
                                            onPressed: observer
                                                        .ismediamessagingallowed ==
                                                    false
                                                ? () {
                                                    Fiberchat.showRationale(
                                                        getTranslated(
                                                            this.context,
                                                            'mediamssgnotallowed'));
                                                  }
                                                : () async {
                                                    GiphyGif? gif =
                                                        await GiphyGet.getGif(
                                                      tabColor:
                                                          fiberchatPRIMARYcolor,
                                                      context: context,
                                                      apiKey:
                                                          GiphyAPIKey, //YOUR API KEY HERE
                                                      lang:
                                                          GiphyLanguage.english,
                                                    );
                                                    if (gif != null &&
                                                        mounted) {
                                                      onSendMessage(
                                                        context: context,
                                                        content: gif.images!
                                                            .original!.url,
                                                        type: MessageType.image,
                                                      );
                                                      hidekeyboard(context);
                                                      setStateIfMounted(() {});
                                                    }
                                                  }),
                                      ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 47,
                  width: 47,
                  // alignment: Alignment.center,
                  margin: EdgeInsets.only(left: 6, right: 10),
                  decoration: BoxDecoration(
                      color: fiberchatSECONDARYolor,
                      // border: Border.all(
                      //   color: Colors.red[500],
                      // ),
                      borderRadius: BorderRadius.all(Radius.circular(30))),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: IconButton(
                      icon: textInSendButton == ""
                          ? new Icon(
                              textEditingController.text.length == 0
                                  ? Icons.mic
                                  : Icons.send,
                              color: fiberchatWhite.withOpacity(0.99),
                            )
                          : textEditingController.text.length == 0
                              ? new Icon(
                                  Icons.mic,
                                  color: fiberchatWhite.withOpacity(0.99),
                                )
                              : Text(
                                  textInSendButton,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: textInSendButton.length > 2
                                          ? 10.7
                                          : 17.5),
                                ),
                      onPressed: observer.ismediamessagingallowed == true
                          ? textEditingController.text.isNotEmpty == false
                              ? () {
                                  hidekeyboard(context);
                                  String firebasePath =
                                      "+00_GROUP_MEDIA/${widget.groupID}/";
                                  void onUploaded(String finalUrl) {
                                    onSendMessage(
                                        context: this.context,
                                        content: finalUrl,
                                        type: MessageType.audio,
                                        timestamp: DateTime.now()
                                            .millisecondsSinceEpoch);
                                  }

                                  ///---common template below for audio recording
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String recording = 'record';
                                      final record = Record();
                                      String? outputPath;
                                      return StatefulBuilder(
                                        builder: (context, setState) {
                                          return AlertDialog(
                                            contentPadding: EdgeInsets.all(7),
                                            content: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 38,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10.0),
                                                      child: recording ==
                                                              'recorderstopped'
                                                          ? Icon(
                                                              Icons.music_note,
                                                              color:
                                                                  Colors.cyan,
                                                              size: 57,
                                                            )
                                                          : Text(getTranslated(
                                                              context,
                                                              recording)),
                                                    ),
                                                    SizedBox(
                                                      height: 18,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          if (recording ==
                                                              'record')
                                                            IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                splashRadius:
                                                                    50,
                                                                onPressed:
                                                                    () async {
                                                                  if (await record
                                                                      .hasPermission()) {
                                                                    setState(
                                                                        () {
                                                                      recording =
                                                                          "recording";
                                                                    });
                                                                    await record
                                                                        .start(
                                                                      encoder:
                                                                          AudioEncoder
                                                                              .aacLc, // by default
                                                                      bitRate:
                                                                          128000, // by default
                                                                      samplingRate:
                                                                          44100, // by default
                                                                    );
                                                                  } else {
                                                                    Fiberchat.toast(
                                                                        getTranslated(
                                                                            context,
                                                                            'pm'));
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .mic_rounded,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 57,
                                                                )),
                                                          if (recording ==
                                                              'recording')
                                                            IconButton(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(0),
                                                                splashRadius:
                                                                    50,
                                                                onPressed:
                                                                    () async {
                                                                  outputPath =
                                                                      await record
                                                                          .stop();
                                                                  if (outputPath !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      recording =
                                                                          "recorderstopped";
                                                                    });
                                                                  } else {
                                                                    Fiberchat.toast(
                                                                        "Recording not saved. Please try again !");
                                                                  }
                                                                },
                                                                icon: Icon(
                                                                  Icons
                                                                      .stop_circle,
                                                                  color: Colors
                                                                      .blueGrey,
                                                                  size: 57,
                                                                )),
                                                          if (recording ==
                                                              'recorderstopped')
                                                            InkWell(
                                                              onTap: () async {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                                if (outputPath !=
                                                                    null) {
                                                                  int timeEpoch =
                                                                      DateTime.now()
                                                                          .millisecondsSinceEpoch;
                                                                  Uri blobUri =
                                                                      Uri.parse(
                                                                          outputPath!);
                                                                  http.Response
                                                                      response =
                                                                      await http
                                                                          .get(
                                                                              blobUri);
                                                                  var filename =
                                                                      '$timeEpoch.mp3';
                                                                  Reference
                                                                      reference =
                                                                      FirebaseStorage
                                                                          .instance
                                                                          .ref(
                                                                              firebasePath)
                                                                          .child(
                                                                              '$filename');
                                                                  UploadTask
                                                                      uploading =
                                                                      reference.putData(
                                                                          response
                                                                              .bodyBytes,
                                                                          SettableMetadata(
                                                                              contentType: 'audio/mp3'));
                                                                  showDialog<
                                                                          void>(
                                                                      context:
                                                                          context,
                                                                      barrierDismissible:
                                                                          false,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return new WillPopScope(
                                                                            onWillPop: () async =>
                                                                                false,
                                                                            child: SimpleDialog(
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: BorderRadius.circular(7),
                                                                                ),
                                                                                // side: BorderSide(width: 5, color: Colors.green)),
                                                                                key: _keyLoader,
                                                                                backgroundColor: Colors.white,
                                                                                children: <Widget>[
                                                                                  Center(
                                                                                    child: StreamBuilder(
                                                                                        stream: uploading.snapshotEvents,
                                                                                        builder: (BuildContext context, snapshot) {
                                                                                          if (snapshot.hasData) {
                                                                                            final TaskSnapshot snap = uploading.snapshot;

                                                                                            return openUploadDialog(
                                                                                              context: context,
                                                                                              percent: bytesTransferred(snap) / 100,
                                                                                              title: getTranslated(context, 'sending'),
                                                                                              subtitle: "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                                                                                            );
                                                                                          } else {
                                                                                            return openUploadDialog(
                                                                                              context: context,
                                                                                              percent: 0.0,
                                                                                              title: getTranslated(context, 'sending'),
                                                                                              subtitle: '',
                                                                                            );
                                                                                          }
                                                                                        }),
                                                                                  ),
                                                                                ]));
                                                                      });

                                                                  TaskSnapshot
                                                                      downloadTask =
                                                                      await uploading;
                                                                  var _url =
                                                                      await downloadTask
                                                                          .ref
                                                                          .getDownloadURL();
                                                                  Navigator.of(
                                                                          _keyLoader
                                                                              .currentContext!,
                                                                          rootNavigator:
                                                                              true)
                                                                      .pop();
                                                                  String
                                                                      finalUrl =
                                                                      _url +
                                                                          '-BREAK-' +
                                                                          filename;
                                                                  onUploaded(
                                                                      finalUrl);
                                                                } else {
                                                                  Fiberchat.toast(
                                                                      "Recording not saved. Please try again !");
                                                                }
                                                              },
                                                              child: Chip(
                                                                  backgroundColor:
                                                                      fiberchatPRIMARYcolor,
                                                                  label: Text(
                                                                    getTranslated(
                                                                        context,
                                                                        'sendrecord'),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                            )
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 38,
                                                    ),
                                                  ],
                                                ),
                                                if (recording != 'recording')
                                                  Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: IconButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .close_outlined,
                                                            size: 17,
                                                            color: fiberchatGrey
                                                                .withOpacity(
                                                                    0.7),
                                                          )))
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                }
                              : observer.istextmessagingallowed == false
                                  ? () {
                                      Fiberchat.showRationale(getTranslated(
                                          this.context, 'textmssgnotallowed'));
                                    }
                                  : () => onSendMessage(
                                        context: context,
                                        content: textEditingController
                                            .value.text
                                            .trim(),
                                        type: MessageType.text,
                                      )
                          : () {
                              Fiberchat.showRationale(getTranslated(
                                  this.context, 'mediamssgnotallowed'));
                            },
                      color: fiberchatWhite,
                    ),
                  ),
                ),
              ],
            ),
            width: double.infinity,
            decoration: new BoxDecoration(
              color: Colors.transparent,
            ),
          ),
          isemojiShowing == true && keyboardVisible == false
              ? Offstage(
                  offstage: !isemojiShowing,
                  child: SizedBox(
                    height: 300,
                    child: EmojiPicker(
                        textEditingController: textEditingController,
                        onEmojiSelected: (Category? category, Emoji emoji) {
                          setState(() {});
                        },
                        onBackspacePressed: _onBackspacePressed,
                        config: Config(
                            columns: 7,
                            emojiSizeMax: 32.0,
                            verticalSpacing: 0,
                            horizontalSpacing: 0,
                            initCategory: emojipic.Category.RECENT,
                            bgColor: Color(0xFFF2F2F2),
                            indicatorColor: fiberchatPRIMARYcolor,
                            iconColor: Colors.grey,
                            iconColorSelected: fiberchatPRIMARYcolor,
                            backspaceColor: fiberchatPRIMARYcolor,
                            showRecentsTab: true,
                            recentsLimit: 28,
                            categoryIcons: CategoryIcons(),
                            buttonMode: ButtonMode.MATERIAL)),
                  ),
                )
              : SizedBox(),
        ]);
  }

  // Widget buildInputTextBox(
  //   BuildContext context,
  //   bool isemojiShowing,
  //   Function refreshThisInput,
  //   bool keyboardVisible,
  // ) {
  //   final observer = Provider.of<Observer>(context, listen: false);

  //   return Column(children: [
  //     Container(
  //       margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
  //       child: Row(
  //         children: <Widget>[
  //           Flexible(
  //             child: Container(
  //               margin: EdgeInsets.only(
  //                 left: 10,
  //               ),
  //               decoration: BoxDecoration(
  //                   color: fiberchatWhite,
  //                   borderRadius: BorderRadius.all(Radius.circular(30))),
  //               child: Row(
  //                 children: [
  //                   isemojiShowing == true && keyboardVisible == false
  //                       ? SizedBox(
  //                           width: 50,
  //                           child: IconButton(
  //                             onPressed: () {
  //                               refreshThisInput();
  //                             },
  //                             icon: Icon(
  //                               Icons.keyboard,
  //                               color: fiberchatGrey,
  //                             ),
  //                           ),
  //                         )
  //                       : SizedBox(
  //                           width: textEditingController.text.isNotEmpty
  //                               ? 50
  //                               : 110,
  //                           child: Row(
  //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                             children: [
  //                               SizedBox(
  //                                 width: 30,
  //                                 child: IconButton(
  //                                   onPressed: () {
  //                                     refreshThisInput();
  //                                   },
  //                                   icon: Icon(
  //                                     Icons.emoji_emotions,
  //                                     color: fiberchatGrey,
  //                                   ),
  //                                 ),
  //                               ),
  //                               textEditingController.text.isNotEmpty == true
  //                                   ? SizedBox(
  //                                       width: 0,
  //                                     )
  //                                   : SizedBox(
  //                                       width: 50,
  //                                       child: IconButton(
  //                                           color: fiberchatWhite,
  //                                           padding: EdgeInsets.all(0.0),
  //                                           icon: Icon(
  //                                             Icons.gif,
  //                                             size: 40,
  //                                             color: fiberchatGrey,
  //                                           ),
  //                                           onPressed: observer
  //                                                       .ismediamessagingallowed ==
  //                                                   false
  //                                               ? () {
  //                                                   Fiberchat.showRationale(
  //                                                       getTranslated(
  //                                                           this.context,
  //                                                           'mediamssgnotallowed'));
  //                                                 }
  //                                               : () async {
  //                                                   GiphyGif? gif =
  //                                                       await GiphyGet.getGif(
  //                                                     tabColor: fiberchatPRIMARYcolor,
  //                                                     context: context,
  //                                                     apiKey:
  //                                                         GiphyAPIKey, //YOUR API KEY HERE
  //                                                     lang:
  //                                                         GiphyLanguage.english,
  //                                                   );
  //                                                   if (gif != null &&
  //                                                       mounted) {
  //                                                     onSendMessage(
  //                                                       context: context,
  //                                                       content: gif.images!
  //                                                           .original!.url,
  //                                                       type: MessageType.image,
  //                                                     );
  //                                                     hidekeyboard(context);
  //                                                     setStateIfMounted(() {});
  //                                                   }
  //                                                 }),
  //                                     ),
  //                               textEditingController.text.isNotEmpty == true
  //                                   ? SizedBox()
  //                                   : SizedBox(
  //                                       width: 30,
  //                                       child: IconButton(
  //                                         icon: new Icon(
  //                                           Icons.attachment_outlined,
  //                                           color: fiberchatGrey,
  //                                         ),
  //                                         padding: EdgeInsets.all(0.0),
  //                                         onPressed:
  //                                             observer.ismediamessagingallowed ==
  //                                                     false
  //                                                 ? () {
  //                                                     Fiberchat.showRationale(
  //                                                         getTranslated(
  //                                                             this.context,
  //                                                             'mediamssgnotallowed'));
  //                                                   }
  //                                                 : () {
  //                                                     hidekeyboard(context);
  //                                                     shareMedia(context);
  //                                                   },
  //                                         color: fiberchatWhite,
  //                                       ),
  //                                     )
  //                             ],
  //                           ),
  //                         ),
  //                   Flexible(
  //                     child: TextField(
  //                       textCapitalization: TextCapitalization.sentences,
  //                       onTap: () {
  //                         if (isemojiShowing == true) {
  //                         } else {
  //                           keyboardFocusNode.requestFocus();
  //                         }
  //                       },
  //                       onChanged: (f) {
  //                         if (textEditingController.text.isNotEmpty &&
  //                             textEditingController.text.length == 1) {
  //                           setStateIfMounted(() {});
  //                         }
  //                         if (textEditingController.text.isEmpty) {
  //                           setStateIfMounted(() {});
  //                         }
  //                       },
  //                       showCursor: true,
  //                       focusNode: keyboardFocusNode,
  //                       maxLines: null,
  //                       style: TextStyle(fontSize: 16.0, color: fiberchatBlack),
  //                       controller: textEditingController,
  //                       decoration: InputDecoration(
  //                         enabledBorder: OutlineInputBorder(
  //                           // width: 0.0 produces a thin "hairline" border
  //                           borderRadius: BorderRadius.circular(1),
  //                           borderSide: BorderSide(
  //                               color: Colors.transparent, width: 1.5),
  //                         ),
  //                         hoverColor: Colors.transparent,
  //                         focusedBorder: OutlineInputBorder(
  //                           // width: 0.0 produces a thin "hairline" border
  //                           borderRadius: BorderRadius.circular(1),
  //                           borderSide: BorderSide(
  //                               color: Colors.transparent, width: 1.5),
  //                         ),
  //                         border: OutlineInputBorder(
  //                             borderRadius: BorderRadius.circular(1),
  //                             borderSide:
  //                                 BorderSide(color: Colors.transparent)),
  //                         contentPadding: EdgeInsets.fromLTRB(10, 4, 7, 4),
  //                         hintText: getTranslated(this.context, 'msg'),
  //                         hintStyle:
  //                             TextStyle(color: Colors.grey, fontSize: 15),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Container(
  //             height: 47,
  //             width: 47,
  //             // alignment: Alignment.center,
  //             margin: EdgeInsets.only(left: 6, right: 10),
  //             decoration: BoxDecoration(
  //                 color: DESIGN_TYPE == Themetype.whatsapp
  //                     ? fiberchatPRIMARYcolor
  //                     : fiberchatPRIMARYcolor,
  //                 // border: Border.all(
  //                 //   color: Colors.red[500],
  //                 // ),
  //                 borderRadius: BorderRadius.all(Radius.circular(30))),
  //             child: Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: IconButton(
  //                 icon: new Icon(
  //                   textEditingController.text.isNotEmpty == true
  //                       ? Icons.send
  //                       : Icons.mic,
  //                   color: fiberchatWhite.withOpacity(0.99),
  //                 ),
  //                 onPressed: observer.ismediamessagingallowed == true
  //                     ? textEditingController.text.isNotEmpty == false
  //                         ? () {
  //                             hidekeyboard(context);

  //                             Navigator.push(
  //                                 context,
  //                                 MaterialPageRoute(
  //                                     builder: (context) => AudioRecord(
  //                                           title: getTranslated(
  //                                               this.context, 'record'),
  //                                           callback: getFileData,
  //                                         ))).then((url) {
  //                               if (url != null) {
  //                                 onSendMessage(
  //                                   context: context,
  //                                   content: url +
  //                                       '-BREAK-' +
  //                                       uploadTimestamp.toString(),
  //                                   type: MessageType.audio,
  //                                 );
  //                               } else {}
  //                             });
  //                           }
  //                         : observer.istextmessagingallowed == false
  //                             ? () {
  //                                 Fiberchat.showRationale(getTranslated(
  //                                     this.context, 'textmssgnotallowed'));
  //                               }
  //                             : () => onSendMessage(
  //                                   context: context,
  //                                   content:
  //                                       textEditingController.value.text.trim(),
  //                                   type: MessageType.text,
  //                                 )
  //                     : () {
  //                         Fiberchat.showRationale(getTranslated(
  //                             this.context, 'mediamssgnotallowed'));
  //                       },
  //                 color: fiberchatWhite,
  //               ),
  //             ),
  //           ),
  //           // Button send message
  //         ],
  //       ),
  //       width: double.infinity,
  //       height: 60.0,
  //       decoration: new BoxDecoration(
  //         // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
  //         color: Colors.transparent,
  //       ),
  //     ),
  //     isemojiShowing == true && keyboardVisible == false
  //         ? Offstage(
  //             offstage: !isemojiShowing,
  //             child: SizedBox(
  //               height: 300,
  //               child: EmojiPicker(
  //                   onEmojiSelected: (emojipic.Category category, Emoji emoji) {
  //                     _onEmojiSelected(emoji);
  //                   },
  //                   onBackspacePressed: _onBackspacePressed,
  //                   config: Config(
  //                       columns: 7,
  //                       emojiSizeMax: 32.0,
  //                       verticalSpacing: 0,
  //                       horizontalSpacing: 0,
  //                       initCategory: emojipic.Category.RECENT,
  //                       bgColor: Color(0xFFF2F2F2),
  //                       indicatorColor: fiberchatPRIMARYcolor,
  //                       iconColor: Colors.grey,
  //                       iconColorSelected: fiberchatPRIMARYcolor,
  //                       progressIndicatorColor: Colors.blue,
  //                       backspaceColor: fiberchatPRIMARYcolor,
  //                       showRecentsTab: true,
  //                       recentsLimit: 28,
  //                       noRecentsText: 'No Recents',
  //                       noRecentsStyle:
  //                           TextStyle(fontSize: 20, color: Colors.black26),
  //                       categoryIcons: CategoryIcons(),
  //                       buttonMode: ButtonMode.MATERIAL)),
  //             ),
  //           )
  //         : SizedBox(),
  //   ]);
  // }

  // Widget buildInputIos(BuildContext context) {
  //   return Consumer<Observer>(
  //       builder: (context, observer, _child) => Container(
  //             margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
  //             child: Row(
  //               children: <Widget>[
  //                 Flexible(
  //                   child: Container(
  //                     margin: EdgeInsets.only(
  //                       left: 10,
  //                     ),
  //                     decoration: BoxDecoration(
  //                         color: fiberchatWhite,
  //                         borderRadius: BorderRadius.all(Radius.circular(30))),
  //                     child: Row(
  //                       children: [
  //                         SizedBox(
  //                           width: 100,
  //                           child: Row(
  //                             children: [
  //                               IconButton(
  //                                   color: fiberchatWhite,
  //                                   padding: EdgeInsets.all(0.0),
  //                                   icon: Icon(
  //                                     Icons.gif,
  //                                     size: 40,
  //                                     color: fiberchatGrey,
  //                                   ),
  //                                   onPressed: observer
  //                                               .ismediamessagingallowed ==
  //                                           false
  //                                       ? () {
  //                                           Fiberchat.showRationale(
  //                                               getTranslated(this.context,
  //                                                   'mediamssgnotallowed'));
  //                                         }
  //                                       : () async {
  //                                           GiphyGif? gif =
  //                                               await GiphyGet.getGif(
  //                                             tabColor: fiberchatPRIMARYcolor,
  //                                             context: context,
  //                                             apiKey:
  //                                                 GiphyAPIKey, //YOUR API KEY HERE
  //                                             lang: GiphyLanguage.english,
  //                                           );
  //                                           if (gif != null && mounted) {
  //                                             onSendMessage(
  //                                               context: context,
  //                                               content:
  //                                                   gif.images!.original!.url,
  //                                               type: MessageType.image,
  //                                             );
  //                                             hidekeyboard(context);
  //                                             setStateIfMounted(() {});
  //                                           }
  //                                         }),
  //                               IconButton(
  //                                 icon: new Icon(
  //                                   Icons.attachment_outlined,
  //                                   color: fiberchatGrey,
  //                                 ),
  //                                 padding: EdgeInsets.all(0.0),
  //                                 onPressed: observer.ismediamessagingallowed ==
  //                                         false
  //                                     ? () {
  //                                         Fiberchat.showRationale(getTranslated(
  //                                             this.context,
  //                                             'mediamssgnotallowed'));
  //                                       }
  //                                     : () {
  //                                         hidekeyboard(context);
  //                                         shareMedia(context);
  //                                       },
  //                                 color: fiberchatWhite,
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                         Flexible(
  //                           child: TextField(
  //                             textCapitalization: TextCapitalization.sentences,
  //                             onChanged: (v) {},
  //                             maxLines: null,
  //                             style: TextStyle(
  //                                 fontSize: 18.0, color: fiberchatBlack),
  //                             controller: textEditingController,
  //                             decoration: InputDecoration(
  //                               enabledBorder: OutlineInputBorder(
  //                                 // width: 0.0 produces a thin "hairline" border
  //                                 borderRadius: BorderRadius.circular(1),
  //                                 borderSide: BorderSide(
  //                                     color: Colors.transparent, width: 1.5),
  //                               ),
  //                               hoverColor: Colors.transparent,
  //                               focusedBorder: OutlineInputBorder(
  //                                 // width: 0.0 produces a thin "hairline" border
  //                                 borderRadius: BorderRadius.circular(1),
  //                                 borderSide: BorderSide(
  //                                     color: Colors.transparent, width: 1.5),
  //                               ),
  //                               border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(1),
  //                                   borderSide:
  //                                       BorderSide(color: Colors.transparent)),
  //                               contentPadding: EdgeInsets.fromLTRB(7, 4, 7, 4),
  //                               hintText: getTranslated(this.context, 'msg'),
  //                               hintStyle:
  //                                   TextStyle(color: Colors.grey, fontSize: 16),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 // Button send message
  //                 Container(
  //                   height: 47,
  //                   width: 47,
  //                   // alignment: Alignment.center,
  //                   margin: EdgeInsets.only(left: 6, right: 10),
  //                   decoration: BoxDecoration(
  //                       color: DESIGN_TYPE == Themetype.whatsapp
  //                           ? fiberchatPRIMARYcolor
  //                           : fiberchatPRIMARYcolor,
  //                       // border: Border.all(
  //                       //   color: Colors.red[500],
  //                       // ),
  //                       borderRadius: BorderRadius.all(Radius.circular(30))),
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(2.0),
  //                     child: IconButton(
  //                       icon: new Icon(
  //                         Icons.send,
  //                         color: fiberchatWhite.withOpacity(0.99),
  //                       ),
  //                       onPressed: observer.istextmessagingallowed == false
  //                           ? () {
  //                               Fiberchat.showRationale(getTranslated(
  //                                   this.context, 'textmssgnotallowed'));
  //                             }
  //                           : () {
  //                               onSendMessage(
  //                                 context: context,
  //                                 content:
  //                                     textEditingController.value.text.trim(),
  //                                 type: MessageType.text,
  //                               );
  //                             },
  //                       color: fiberchatWhite,
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             width: double.infinity,
  //             height: 60.0,
  //             decoration: new BoxDecoration(
  //               // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
  //               color: Colors.transparent,
  //             ),
  //           ));
  // }

  Widget buildReplyMessageForInput(
    BuildContext context,
  ) {
    return Flexible(
      child: Container(
          height: 80,
          margin: EdgeInsets.only(left: 15, right: 70),
          decoration: BoxDecoration(
              color: fiberchatWhite,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Stack(
            children: [
              Container(
                  margin: EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      color: fiberchatGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                widget.currentUserno
                            ? fiberchatPRIMARYcolor
                            : Colors.purple,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(0),
                            bottomRight: Radius.circular(0),
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10)),
                      ),
                      height: 75,
                      width: 3.3,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Container(
                      padding: EdgeInsetsDirectional.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text(
                              replyDoc![Dbkeys.groupmsgSENDBY] ==
                                      widget.currentUserno
                                  ? getTranslated(this.context, 'you')
                                  : messageReplyOwnerName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.groupmsgSENDBY] ==
                                          widget.currentUserno
                                      ? fiberchatPRIMARYcolor
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          replyDoc![Dbkeys.messageType] ==
                                  MessageType.text.index
                              ? Text(
                                  replyDoc![Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                )
                              : replyDoc![Dbkeys.messageType] ==
                                      MessageType.doc.index
                                  ? Container(
                                      width: getContentScreenWidth(
                                              MediaQuery.of(context)
                                                  .size
                                                  .width) -
                                          125,
                                      padding: const EdgeInsets.only(right: 55),
                                      child: Text(
                                        replyDoc![Dbkeys.content]
                                            .split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
                                  : Text(
                                      getTranslated(
                                          this.context,
                                          replyDoc![Dbkeys.messageType] ==
                                                  MessageType.image.index
                                              ? 'nim'
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.video.index
                                                  ? 'nvm'
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'nam'
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'ncm'
                                                          : replyDoc![Dbkeys
                                                                      .messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'nlm'
                                                              : replyDoc![Dbkeys
                                                                          .messageType] ==
                                                                      MessageType
                                                                          .doc
                                                                          .index
                                                                  ? 'ndm'
                                                                  : ''),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                        ],
                      ),
                    ))
                  ])),
              replyDoc![Dbkeys.messageType] == MessageType.text.index
                  ? SizedBox(
                      width: 0,
                      height: 0,
                    )
                  : replyDoc![Dbkeys.messageType] == MessageType.image.index
                      ? Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 84.0,
                            height: 84.0,
                            padding: EdgeInsetsDirectional.all(6),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  bottomRight: Radius.circular(5),
                                  topLeft: Radius.circular(0),
                                  bottomLeft: Radius.circular(0)),
                              child: Image.network(
                                replyDoc![Dbkeys.messageType] ==
                                        MessageType.video.index
                                    ? ''
                                    : replyDoc![Dbkeys.content],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      : replyDoc![Dbkeys.messageType] == MessageType.video.index
                          ? Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                        color: Colors.blueGrey[200],
                                        height: 84,
                                        width: 84,
                                        child: Stack(
                                          children: [
                                            Image.network(
                                              replyDoc![Dbkeys.content]
                                                  .split('-BREAK-')[1],
                                              width: 84,
                                              height: 84,
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              height: 84,
                                              width: 84,
                                            ),
                                            Center(
                                              child: Icon(
                                                  Icons
                                                      .play_circle_fill_outlined,
                                                  color: Colors.white70,
                                                  size: 25),
                                            ),
                                          ],
                                        ),
                                      ))))
                          : Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                  width: 84.0,
                                  height: 84.0,
                                  padding: EdgeInsetsDirectional.all(6),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: replyDoc![
                                                      Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[00]
                                              : replyDoc![Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : replyDoc![Dbkeys
                                                              .messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : replyDoc![Dbkeys
                                                                  .messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 84,
                                          width: 84,
                                          child: Icon(
                                            replyDoc![Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : replyDoc![Dbkeys
                                                            .messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : replyDoc![Dbkeys
                                                                .messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
                                                        : replyDoc![Dbkeys
                                                                    .messageType] ==
                                                                MessageType
                                                                    .contact
                                                                    .index
                                                            ? Icons
                                                                .contact_page_sharp
                                                            : Icons
                                                                .insert_drive_file,
                                            color: Colors.white,
                                            size: 35,
                                          ))))),
              Positioned(
                right: 7,
                top: 7,
                child: InkWell(
                  onTap: () {
                    setStateIfMounted(() {
                      HapticFeedback.heavyImpact();
                      isReplyKeyboard = false;
                      hidekeyboard(context);
                    });
                  },
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: new BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: new Icon(
                      Icons.close,
                      color: Colors.blueGrey,
                      size: 13,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  buildEachMessage(Map<String, dynamic> doc, GroupModel groupData) {
    if (doc[Dbkeys.groupmsgTYPE] == Dbkeys.groupmsgTYPEnotificationAddedUser) {
      return Center(
          child: Padding(
        padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
        child: Chip(
          labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          backgroundColor: Colors.blueGrey[50],
          label: Text(
            doc[Dbkeys.groupmsgLISToptional].contains(widget.currentUserno) &&
                    doc[Dbkeys.groupmsgLISToptional].length > 1
                ? doc[Dbkeys.groupmsgLISToptional]
                        .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                    ? widget.currentUserno ==
                            groupData.docmap[Dbkeys.groupCREATEDBY]
                        ? '${getTranslated(this.context, 'uhaveadded')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslated(this.context, 'users')} '
                        : '${getTranslated(this.context, 'adminahasadded')} ${getTranslated(this.context, 'youandother')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslated(this.context, 'users')}'
                    : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'added')} ${getTranslated(this.context, 'youandother')} ${doc[Dbkeys.groupmsgLISToptional].length - 1} ${getTranslated(this.context, 'users')}'
                : doc[Dbkeys.groupmsgLISToptional]
                            .contains(widget.currentUserno) &&
                        doc[Dbkeys.groupmsgLISToptional].length == 1
                    ? '${getTranslated(this.context, 'youareaddedtothisgrp')}'
                    : !doc[Dbkeys.groupmsgLISToptional]
                                .contains(widget.currentUserno) &&
                            doc[Dbkeys.groupmsgLISToptional].length == 1
                        ? doc[Dbkeys.groupmsgSENDBY] ==
                                groupData.docmap[Dbkeys.groupCREATEDBY]
                            ? widget.currentUserno ==
                                    groupData.docmap[Dbkeys.groupCREATEDBY]
                                ? '${getTranslated(this.context, 'uhaveadded')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                                : '${getTranslated(this.context, 'adminhasadded')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                            : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'adminhasadded')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                        : doc[Dbkeys.groupmsgSENDBY] ==
                                groupData.docmap[Dbkeys.groupCREATEDBY]
                            ? '${getTranslated(this.context, 'adminahasadded')} ${doc[Dbkeys.groupmsgLISToptional].length} ${getTranslated(this.context, 'users')}'
                            : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'added')} ${doc[Dbkeys.groupmsgLISToptional].length} ${getTranslated(this.context, 'users')}',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
          ),
        ),
      ));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationCreatedGroup) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  groupData.docmap[Dbkeys.groupCREATEDBY]
                          .contains(widget.currentUserno)
                      ? getTranslated(this.context, 'youcreatedthisgroup')
                      : '${groupData.docmap[Dbkeys.groupCREATEDBY]} ${getTranslated(this.context, 'hascreatedthisgroup')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupDetails) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
                      ? getTranslated(this.context, 'uhvupdatedgrpdetails')
                      : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasupdatedgrpdetails')}'
                              .contains(groupData.docmap[Dbkeys.groupCREATEDBY])
                          ? getTranslated(
                              this.context, 'grpdetailsupdatebyadmin')
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasupdatedgrpdetails')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserSetAsAdmin) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
                      ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'hasbeensetasadminbyu')}'
                      : doc[Dbkeys.groupmsgLISToptional][0] ==
                              widget.currentUserno
                          ? '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hvsetuasadsmin')}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'set')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'asadmin')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserRemovedAsAdmin) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
                      ? '${getTranslated(this.context, 'youhaveremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'fromadmin')}'
                      : doc[Dbkeys.groupmsgLISToptional][0] ==
                              widget.currentUserno
                          ? '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'theyremoveduasadmin')}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'fromadmin')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUpdatedGroupicon) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
                      ? getTranslated(this.context, 'youupdatedgrpicon')
                      : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasupdatedgrpicon')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationDeletedGroupicon) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno
                      ? getTranslated(this.context, 'youremovedgrpicon')
                      : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasremovedgrpicon')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationRemovedUser) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgCONTENT]
                          .contains('by ' + widget.currentUserno)
                      ? '${getTranslated(this.context, 'youhaveremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]}'
                      : doc[Dbkeys.groupmsgSENDBY] ==
                              groupData.docmap[Dbkeys.groupCREATEDBY]
                          ? '${doc[Dbkeys.groupmsgLISToptional][0]} ${getTranslated(this.context, 'removedbyadmin')}'
                          : '${doc[Dbkeys.groupmsgSENDBY]} ${getTranslated(this.context, 'hasremoved')} ${doc[Dbkeys.groupmsgLISToptional][0]}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] ==
        Dbkeys.groupmsgTYPEnotificationUserLeft) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.groupmsgCONTENT].contains(widget.currentUserno)
                      ? getTranslated(this.context, 'youleftthegroup')
                      : '${doc[Dbkeys.groupmsgCONTENT]}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.groupmsgTYPE] == MessageType.image.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.doc.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.text.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.video.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.audio.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.contact.index ||
        doc[Dbkeys.groupmsgTYPE] == MessageType.location.index) {
      return doc[Dbkeys.content] == null || doc[Dbkeys.content] == ''
          ? buildMediaMessages(doc, groupData)
          : Dismissible(
              direction: DismissDirection.startToEnd,
              key: Key(doc[Dbkeys.groupmsgTIME].toString()),
              confirmDismiss: (direction) {
                onDismiss(doc);
                return Future.value(false);
              },
              child: buildMediaMessages(doc, groupData));
    }

    return Text(doc[Dbkeys.groupmsgCONTENT]);
  }

  onDismiss(Map<String, dynamic> doc) {
    if ((doc[Dbkeys.content] == '' || doc[Dbkeys.content] == null) == false) {
      final contactsProvider =
          Provider.of<SmartContactProviderWithLocalStoreData>(this.context,
              listen: false);
      setStateIfMounted(() {
        isReplyKeyboard = true;
        replyDoc = doc;
        messageReplyOwnerName = contactsProvider
                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                    .indexWhere((element) =>
                        element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                0
            ? contactsProvider
                    .alreadyJoinedSavedUsersPhoneNameAsInServer[contactsProvider
                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                        .indexWhere((element) =>
                            element.phone == doc[Dbkeys.groupmsgSENDBY])]
                    .name ??
                doc[Dbkeys.groupmsgSENDBY].toString()
            : doc[Dbkeys.groupmsgSENDBY].toString();
      });
      HapticFeedback.heavyImpact();
      keyboardFocusNode.requestFocus();
    }
  }

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  contextMenu(BuildContext context, Map<String, dynamic> mssgDoc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);

    if (mssgDoc[Dbkeys.groupmsgSENDBY] == widget.currentUserno) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.delete),
              title: Text(
                getTranslated(popable, 'dltforeveryone'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                if (mssgDoc[Dbkeys.messageType] == MessageType.image.index &&
                    !mssgDoc[Dbkeys.groupmsgCONTENT].contains('giphy')) {
                  FirebaseStorage.instance
                      .refFromURL(mssgDoc[Dbkeys.groupmsgCONTENT])
                      .delete();
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.doc.index) {
                  FirebaseStorage.instance
                      .refFromURL(
                          mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                      .delete();
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.audio.index) {
                  FirebaseStorage.instance
                      .refFromURL(
                          mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                      .delete();
                } else if (mssgDoc[Dbkeys.messageType] ==
                    MessageType.video.index) {
                  FirebaseStorage.instance
                      .refFromURL(
                          mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[0])
                      .delete();
                  FirebaseStorage.instance
                      .refFromURL(
                          mssgDoc[Dbkeys.groupmsgCONTENT].split('-BREAK-')[1])
                      .delete();
                }
                if (deleteMessaqgeForEveryoneDeleteFromServer == true) {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(
                          '${mssgDoc[Dbkeys.groupmsgTIME]}--${mssgDoc[Dbkeys.groupmsgSENDBY]}')
                      .delete();
                } else {
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectiongroups)
                      .doc(widget.groupID)
                      .collection(DbPaths.collectiongroupChats)
                      .doc(
                          '${mssgDoc[Dbkeys.groupmsgTIME]}--${mssgDoc[Dbkeys.groupmsgSENDBY]}')
                      .set({
                    Dbkeys.groupmsgISDELETED: true,
                    Dbkeys.groupmsgCONTENT: '',
                  }, SetOptions(merge: true));
                }
              })));
    }
    if (mssgDoc[Dbkeys.groupmsgISDELETED] == false) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(FontAwesomeIcons.share, size: 22),
              title: Text(
                getTranslated(popable, 'forward'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                Navigator.push(
                    this.context,
                    MaterialPageRoute(
                        builder: (context) => SelectContactsToForward(
                            contentPeerNo: mssgDoc[Dbkeys.from],
                            messageOwnerPhone: widget.currentUserno,
                            currentUserNo: widget.currentUserno,
                            model: widget.model,
                            prefs: widget.prefs,
                            onSelect: (selectedlist) async {
                              if (selectedlist.length > 0) {
                                setStateIfMounted(() {
                                  isgeneratingSomethingLoader = true;
                                  // tempSendIndex = 0;
                                });

                                String? privateKey =
                                    await storage.read(key: Dbkeys.privateKey);

                                await sendForwardMessageEach(
                                    0, selectedlist, privateKey!, mssgDoc);
                              }
                            })));
              })));

      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(FontAwesomeIcons.reply, size: 22),
              title: Text(
                getTranslated(popable, 'reply'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                final contactsProvider =
                    Provider.of<SmartContactProviderWithLocalStoreData>(
                        this.context,
                        listen: false);
                setStateIfMounted(() {
                  isReplyKeyboard = true;
                  replyDoc = mssgDoc;
                  messageReplyOwnerName = contactsProvider
                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                              .indexWhere((element) =>
                                  element.phone ==
                                  mssgDoc[Dbkeys.groupmsgSENDBY]) >=
                          0
                      ? contactsProvider
                              .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                  contactsProvider
                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                      .indexWhere((element) =>
                                          element.phone ==
                                          mssgDoc[Dbkeys.groupmsgSENDBY])]
                              .name ??
                          mssgDoc[Dbkeys.groupmsgSENDBY].toString()
                      : mssgDoc[Dbkeys.groupmsgSENDBY].toString();
                });
                HapticFeedback.heavyImpact();
                keyboardFocusNode.requestFocus();
              })));
    }

    showDialog(
        context: this.context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  sendForwardMessageEach(
      int index, List<dynamic> list, String privateKey, var mssgDoc) async {
    if (index >= list.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
      });
      if (widget.isWideScreenMode == false) {
        Navigator.of(this.context).pop();
      }
    } else {
      // setStateIfMounted(() {
      //   tempSendIndex = index;
      // });
      if (list[index].containsKey(Dbkeys.groupNAME)) {
        try {
          Map<dynamic, dynamic> groupDoc = list[index];
          int timestamp = DateTime.now().millisecondsSinceEpoch;

          FirebaseFirestore.instance
              .collection(DbPaths.collectiongroups)
              .doc(groupDoc[Dbkeys.groupID])
              .collection(DbPaths.collectiongroupChats)
              .doc(timestamp.toString() + '--' + widget.currentUserno)
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserno,
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgTYPE: mssgDoc[Dbkeys.messageType],
            Dbkeys.groupNAME: groupDoc[Dbkeys.groupNAME],
            Dbkeys.groupID: groupDoc[Dbkeys.groupNAME],
            Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
            Dbkeys.groupIDfiltered: groupDoc[Dbkeys.groupIDfiltered],
            Dbkeys.isReply: false,
            Dbkeys.replyToMsgDoc: null,
            Dbkeys.isForward: true
          }, SetOptions(merge: true)).then((value) {
            unawaited(realtime.animateTo(0.0,
                duration: Duration(milliseconds: 300), curve: Curves.easeOut));
            // _playPopSound();
            FirebaseFirestore.instance
                .collection(DbPaths.collectiongroups)
                .doc(groupDoc[Dbkeys.groupID])
                .set({Dbkeys.groupLATESTMESSAGETIME: timestamp},
                    SetOptions(merge: true));
          }).then((value) async {
            if (index >= list.length - 1) {
              Fiberchat.toast(
                getTranslated(this.context, 'sent'),
              );
              setStateIfMounted(() {
                isgeneratingSomethingLoader = false;
              });
              if (widget.isWideScreenMode == false) {
                Navigator.of(this.context).pop();
              }
            } else {
              await sendForwardMessageEach(
                  index + 1, list, privateKey, mssgDoc);
            }
          });
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Fiberchat.toast('Failed to send');
        }
      } else {
        try {
          String? sharedSecret = (await e2ee.X25519().calculateSharedSecret(
                  e2ee.Key.fromBase64(privateKey, false),
                  e2ee.Key.fromBase64(list[index][Dbkeys.publicKey], true)))
              .toBase64();
          final key = encrypt.Key.fromBase64(sharedSecret);
          cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
          String content = mssgDoc[Dbkeys.content];
          final encrypted = AESEncryptData.encryptAES(content, sharedSecret);
          if (encrypted is String) {
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            if (content.trim() != '') {
              Map<String, dynamic>? targetPeer =
                  widget.model.userData[list[index][Dbkeys.phone]];
              if (targetPeer == null) {
                await ChatController.request(
                    widget.currentUserno,
                    list[index][Dbkeys.phone],
                    Fiberchat.getChatId(
                        widget.currentUserno, list[index][Dbkeys.phone]));
              }
              var chatId = Fiberchat.getChatId(
                  widget.currentUserno, list[index][Dbkeys.phone]);
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set({
                widget.currentUserno: true,
                list[index][Dbkeys.phone]: list[index][Dbkeys.lastSeen],
              }, SetOptions(merge: true)).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(list[index][Dbkeys.phone])
                    .collection(Dbkeys.chatsWith)
                    .doc(Dbkeys.chatsWith)
                    .set({
                  widget.currentUserno: 4,
                }, SetOptions(merge: true));
                widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId)
                    .doc('$timestamp2')
                    .set({
                  Dbkeys.from: widget.currentUserno,
                  Dbkeys.to: list[index][Dbkeys.phone],
                  Dbkeys.timestamp: timestamp2,
                  Dbkeys.content: encrypted,
                  Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                  Dbkeys.hasSenderDeleted: false,
                  Dbkeys.hasRecipientDeleted: false,
                  Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                  Dbkeys.isReply: false,
                  Dbkeys.replyToMsgDoc: null,
                  Dbkeys.isForward: true,
                  Dbkeys.latestEncrypted: true,
                  Dbkeys.isMuted: false,
                }, SetOptions(merge: true));
                widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                if (index >= list.length - 1) {
                  Fiberchat.toast(
                    getTranslated(this.context, 'sent'),
                  );
                  setStateIfMounted(() {
                    isgeneratingSomethingLoader = false;
                  });
                  if (widget.isWideScreenMode == false) {
                    Navigator.of(this.context).pop();
                  }
                } else {
                  await sendForwardMessageEach(
                      index + 1, list, privateKey, mssgDoc);
                }
              });
            }
          } else {
            setStateIfMounted(() {
              isgeneratingSomethingLoader = false;
            });
            Fiberchat.toast('Nothing to send');
          }
        } catch (e) {
          setStateIfMounted(() {
            isgeneratingSomethingLoader = false;
          });
          Fiberchat.toast('Failed to Forward message. Error:$e');
        }
      }
    }
  }

  Widget buildMediaMessages(Map<String, dynamic> doc, GroupModel groupData) {
    bool isMe = widget.currentUserno == doc[Dbkeys.groupmsgSENDBY];
    bool saved = false;
    final observer = Provider.of<Observer>(this.context, listen: false);
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return Consumer<SmartContactProviderWithLocalStoreData>(
        builder: (context, contactsProvider, _child) => InkWell(
              onLongPress: doc[Dbkeys.groupmsgISDELETED] == false
                  ? () {
                      contextMenu(
                        context,
                        doc,
                      );
                      hidekeyboard(context);
                    }
                  : null,
              child: GroupChatBubble(
                isWideScreenMode: widget.isWideScreenMode,
                isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                    isContainURL == true,
                is24hrsFormat: observer.is24hrsTimeformat,
                prefs: widget.prefs,
                currentUserNo: widget.currentUserno,
                model: widget.model,
                savednameifavailable: contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .toList()
                            .indexWhere((element) =>
                                element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                        0
                    ? contactsProvider
                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                        .toList()[contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .toList()
                            .indexWhere((element) =>
                                element.phone == doc[Dbkeys.groupmsgSENDBY])]
                        .name
                    : null,
                postedbyname: contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .indexWhere((element) =>
                                element.phone == doc[Dbkeys.groupmsgSENDBY]) >=
                        0
                    ? contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                contactsProvider
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .indexWhere((element) =>
                                        element.phone ==
                                        doc[Dbkeys.groupmsgSENDBY])]
                            .name ??
                        doc[Dbkeys.groupmsgSENDBY]
                    : '',
                postedbyphone: doc[Dbkeys.groupmsgSENDBY],
                messagetype: doc[Dbkeys.groupmsgISDELETED] == true
                    ? MessageType.text
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? MessageType.text
                        : doc[Dbkeys.messageType] == MessageType.contact.index
                            ? MessageType.contact
                            : doc[Dbkeys.messageType] ==
                                    MessageType.location.index
                                ? MessageType.location
                                : doc[Dbkeys.messageType] ==
                                        MessageType.image.index
                                    ? MessageType.image
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? MessageType.video
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.doc.index
                                            ? MessageType.doc
                                            : doc[Dbkeys.messageType] ==
                                                    MessageType.audio.index
                                                ? MessageType.audio
                                                : MessageType.text,
                child: doc[Dbkeys.groupmsgISDELETED] == true
                    ? Text(
                        getTranslated(context, 'msgdeleted'),
                        style: TextStyle(
                            color: fiberchatBlack.withOpacity(0.6),
                            fontSize: 15,
                            fontStyle: FontStyle.italic),
                      )
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? getTextMessage(isMe, doc, saved)
                        : doc[Dbkeys.messageType] == MessageType.location.index
                            ? getLocationMessage(doc[Dbkeys.content], doc,
                                saved: false)
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? getDocmessage(
                                    context, doc[Dbkeys.content], doc,
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.audio.index
                                    ? getAudiomessage(
                                        context, doc[Dbkeys.content], doc,
                                        isMe: isMe, saved: false)
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? getVideoMessage(
                                            context, doc[Dbkeys.content], doc,
                                            saved: false)
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.contact.index
                                            ? getContactMessage(context,
                                                doc[Dbkeys.content], doc,
                                                saved: false)
                                            : getImageMessage(
                                                doc,
                                                saved: saved,
                                              ),
                isMe: isMe,
                delivered: true,
                isContinuing: true,
                timestamp: doc[Dbkeys.groupmsgTIME],
              ),
            ));
  }

  Widget getVideoMessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return Container(
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Row(
                            mainAxisAlignment: isMe == true
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                FontAwesomeIcons.share,
                                size: 12,
                                color: fiberchatGrey.withOpacity(0.5),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(getTranslated(this.context, 'forwarded'),
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: fiberchatGrey.withOpacity(0.7),
                                      fontStyle: FontStyle.italic,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 13))
                            ]))
                    : SizedBox(height: 0, width: 0)
                : SizedBox(height: 0, width: 0),
            InkWell(
              onTap: () async {
                try {
                  await WebDownloadService().downloadusingBrowser(
                    url: message.split('-BREAK-')[0],
                    fileName:
                        "Video_${DateTime.now().millisecondsSinceEpoch}.mp4",
                  );
                } catch (e) {
                  Fiberchat.toast("failed to Download !\n $e");
                }
              },
              child: Container(
                color: Colors.blueGrey,
                width: 245,
                height: 245,
                child: Stack(
                  children: [
                    Image.network(
                      message.split('-BREAK-')[1],
                      width: 245,
                      height: 245,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      width: 245,
                      height: 245,
                    ),
                    Center(
                      child: Icon(Icons.play_arrow,
                          color: Colors.white70, size: 65),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Center(
                        child: Icon(Icons.download,
                            color: Colors.white70, size: 25),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 210,
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          ListTile(
            isThreeLine: false,
            leading: customCircleAvatar(url: null, radius: 20),
            title: Text(
              message.split('-BREAK-')[0],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue[400]),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                message.split('-BREAK-')[1],
                style: TextStyle(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left),
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.start
                            : CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              child: Row(
                                  mainAxisAlignment: isMe == true
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                Icon(
                                  FontAwesomeIcons.share,
                                  size: 12,
                                  color: fiberchatGrey.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(getTranslated(this.context, 'forwarded'),
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: fiberchatGrey.withOpacity(0.7),
                                        fontStyle: FontStyle.italic,
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 13))
                              ])),
                          SizedBox(
                            height: 10,
                          ),
                          selectablelinkify(
                              doc[Dbkeys.content], 15.5, TextAlign.left)
                        ],
                      )
                    : selectablelinkify(
                        doc[Dbkeys.content], 15.5, TextAlign.left)
                : selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left)
        : selectablelinkify(doc[Dbkeys.content], 15.5, TextAlign.left);
  }

  Widget getLocationMessage(String? message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: doc.containsKey(Dbkeys.isForward) == true
          ? doc[Dbkeys.isForward] == true
              ? Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        child: Row(
                            mainAxisAlignment: isMe == true
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                          Icon(
                            FontAwesomeIcons.share,
                            size: 12,
                            color: fiberchatGrey.withOpacity(0.5),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(getTranslated(this.context, 'forwarded'),
                              maxLines: 1,
                              style: TextStyle(
                                  color: fiberchatGrey.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 13))
                        ])),
                    SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      'assets/images/mapview.jpg',
                      width: getContentScreenWidth(
                              MediaQuery.of(this.context).size.width) /
                          1.7,
                      height: (getContentScreenWidth(
                                  MediaQuery.of(this.context).size.width) /
                              1.7) *
                          0.6,
                    ),
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                  width: getContentScreenWidth(
                          MediaQuery.of(this.context).size.width) /
                      1.7,
                  height: (getContentScreenWidth(
                              MediaQuery.of(this.context).size.width) /
                          1.7) *
                      0.6,
                )
          : Image.asset(
              'assets/images/mapview.jpg',
              width: getContentScreenWidth(
                      MediaQuery.of(this.context).size.width) /
                  1.7,
              height: (getContentScreenWidth(
                          MediaQuery.of(this.context).size.width) /
                      1.7) *
                  0.6,
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          SizedBox(
            width: 200,
            height: 80,
            child: MultiPlayback(
              isMe: isMe,
              onTapDownloadFn: () async {
                await WebDownloadService().downloadusingBrowser(
                  url: message.split('-BREAK-')[0],
                  fileName: 'Recording_' + message.split('-BREAK-')[1] + '.mp3',
                );
              },
              url: message.split('-BREAK-')[0],
            ),
          )
        ],
      ),
    );
  }

  Widget getDocmessage(
      BuildContext context, String message, Map<String, dynamic> doc,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return SizedBox(
      width: 220,
      height: 126,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          ListTile(
            contentPadding: EdgeInsets.all(4),
            isThreeLine: false,
            leading: Container(
              decoration: BoxDecoration(
                color: Colors.yellow[800],
                borderRadius: BorderRadius.circular(7.0),
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.insert_drive_file,
                size: 25,
                color: Colors.white,
              ),
            ),
            title: Text(
              message.split('-BREAK-')[1],
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87),
            ),
          ),
          Divider(
            height: 3,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.transparent),
              onPressed: () async {
                await WebDownloadService().downloadusingBrowser(
                  url: message.split('-BREAK-')[0],
                  fileName: message.split('-BREAK-')[1],
                );

// // prepare
              },
              child: Text(getTranslated(context, 'download'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    final bool isMe = doc[Dbkeys.groupmsgSENDBY] == widget.currentUserno;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          doc.containsKey(Dbkeys.isForward) == true
              ? doc[Dbkeys.isForward] == true
                  ? Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                          mainAxisAlignment: isMe == true
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              FontAwesomeIcons.share,
                              size: 12,
                              color: fiberchatGrey.withOpacity(0.5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(getTranslated(this.context, 'forwarded'),
                                maxLines: 1,
                                style: TextStyle(
                                    color: fiberchatGrey.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 13))
                          ]))
                  : SizedBox(height: 0, width: 0)
              : SizedBox(height: 0, width: 0),
          saved
              ? Material(
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                          image: Save.getImageFromBase64(doc[Dbkeys.content])
                              .image,
                          fit: BoxFit.cover),
                    ),
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : InkWell(
                  onTap: () => Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewWrapper(
                          keyloader: _keyLoader,
                          imageUrl: doc[Dbkeys.content],
                          message: doc[Dbkeys.content],
                          tag: doc[Dbkeys.groupmsgTIME].toString(),
                        ),
                      )),
                  child: Image.network(
                    doc[Dbkeys.content],
                    width: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 160 : 245.0,
                    fit: BoxFit.cover,
                  ),
                ),
        ],
      ),
    );
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Consumer<SmartContactProviderWithLocalStoreData>(
        builder: (context, contactsProvider, _child) => Flexible(
              child: Container(
                  // width: 280,
                  height: 70,
                  margin: EdgeInsets.only(left: 0, right: 0),
                  decoration: BoxDecoration(
                      color: fiberchatWhite.withOpacity(0.55),
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Stack(
                    children: [
                      Container(
                          margin: EdgeInsetsDirectional.all(4),
                          decoration: BoxDecoration(
                              color: fiberchatGrey.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8))),
                          child: Row(children: [
                            Container(
                              decoration: BoxDecoration(
                                color: doc[Dbkeys.groupmsgSENDBY] ==
                                        widget.currentUserno
                                    ? fiberchatPRIMARYcolor
                                    : Colors.purple,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(0),
                                    bottomRight: Radius.circular(0),
                                    topLeft: Radius.circular(10),
                                    bottomLeft: Radius.circular(10)),
                              ),
                              height: 75,
                              width: 3.3,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Container(
                              padding: EdgeInsetsDirectional.all(5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 30),
                                    child: Text(
                                      doc[Dbkeys.groupmsgSENDBY] ==
                                              widget.currentUserno
                                          ? getTranslated(this.context, 'you')
                                          : contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                      .indexWhere((element) =>
                                                          element.phone ==
                                                          doc[Dbkeys
                                                              .groupmsgSENDBY]) >=
                                                  0
                                              ? contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                                          contactsProvider
                                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                              .indexWhere((element) =>
                                                                  element
                                                                      .phone ==
                                                                  doc[Dbkeys
                                                                      .groupmsgSENDBY])]
                                                      .name ??
                                                  doc[Dbkeys.groupmsgSENDBY]
                                                      .toString()
                                              : doc[Dbkeys.groupmsgSENDBY]
                                                  .toString(),
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: doc[Dbkeys.groupmsgSENDBY] ==
                                                  widget.currentUserno
                                              ? fiberchatPRIMARYcolor
                                              : Colors.purple),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  doc[Dbkeys.messageType] ==
                                          MessageType.text.index
                                      ? Text(
                                          doc[Dbkeys.content],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )
                                      : doc[Dbkeys.messageType] ==
                                              MessageType.doc.index
                                          ? Container(
                                              padding: const EdgeInsets.only(
                                                  right: 75),
                                              child: Text(
                                                doc[Dbkeys.content]
                                                    .split('-BREAK-')[1],
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            )
                                          : Text(
                                              getTranslated(
                                                  this.context,
                                                  doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .image.index
                                                      ? 'nim'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .video.index
                                                          ? 'nvm'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .audio
                                                                      .index
                                                              ? 'nam'
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType
                                                                          .contact
                                                                          .index
                                                                  ? 'ncm'
                                                                  : doc[Dbkeys.messageType] ==
                                                                          MessageType
                                                                              .location
                                                                              .index
                                                                      ? 'nlm'
                                                                      : doc[Dbkeys.messageType] ==
                                                                              MessageType.doc.index
                                                                          ? 'ndm'
                                                                          : ''),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                ],
                              ),
                            ))
                          ])),
                      doc[Dbkeys.messageType] == MessageType.text.index ||
                              doc[Dbkeys.messageType] ==
                                  MessageType.location.index
                          ? SizedBox(
                              width: 0,
                              height: 0,
                            )
                          : doc[Dbkeys.messageType] == MessageType.image.index
                              ? Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    width: 74.0,
                                    height: 74.0,
                                    padding: EdgeInsetsDirectional.all(6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(5),
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Image.network(
                                        doc[Dbkeys.messageType] ==
                                                MessageType.video.index
                                            ? ''
                                            : doc[Dbkeys.content],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              : doc[Dbkeys.messageType] ==
                                      MessageType.video.index
                                  ? Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                          width: 74.0,
                                          height: 74.0,
                                          padding: EdgeInsetsDirectional.all(6),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                              child: Container(
                                                color: Colors.blueGrey[200],
                                                height: 74,
                                                width: 74,
                                                child: Stack(
                                                  children: [
                                                    Image.network(
                                                      doc[Dbkeys.content]
                                                          .split('-BREAK-')[1],
                                                      width: 74,
                                                      height: 74,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Container(
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                      height: 74,
                                                      width: 74,
                                                    ),
                                                    Center(
                                                      child: Icon(
                                                          Icons
                                                              .play_circle_fill_outlined,
                                                          color: Colors.white70,
                                                          size: 25),
                                                    ),
                                                  ],
                                                ),
                                              ))))
                                  : Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                          width: 74.0,
                                          height: 74.0,
                                          padding: EdgeInsetsDirectional.all(6),
                                          child: ClipRRect(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(0),
                                                  bottomLeft:
                                                      Radius.circular(0)),
                                              child: Container(
                                                  color: doc[Dbkeys.messageType] ==
                                                          MessageType.doc.index
                                                      ? Colors.yellow[800]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .audio.index
                                                          ? Colors.green[400]
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? Colors.red[700]
                                                              : doc[Dbkeys.messageType] ==
                                                                      MessageType
                                                                          .contact
                                                                          .index
                                                                  ? Colors
                                                                      .blue[400]
                                                                  : Colors
                                                                      .cyan[700],
                                                  height: 74,
                                                  width: 74,
                                                  child: Icon(
                                                    doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .doc.index
                                                        ? Icons
                                                            .insert_drive_file
                                                        : doc[Dbkeys.messageType] ==
                                                                MessageType
                                                                    .audio.index
                                                            ? Icons.mic_rounded
                                                            : doc[Dbkeys.messageType] ==
                                                                    MessageType
                                                                        .location
                                                                        .index
                                                                ? Icons
                                                                    .location_on
                                                                : doc[Dbkeys.messageType] ==
                                                                        MessageType
                                                                            .contact
                                                                            .index
                                                                    ? Icons
                                                                        .contact_page_sharp
                                                                    : Icons
                                                                        .insert_drive_file,
                                                    color: Colors.white,
                                                    size: 35,
                                                  ))))),
                    ],
                  )),
            ));
  }

  Future<bool> checkIfLocationEnabled() async {
    // IsRequirefocus;
    // if (await Permission.location.request().isGranted) {
    //   return true;
    // } else if (await Permission.locationAlways.request().isGranted) {
    //   return true;
    // } else if (await Permission.locationWhenInUse.request().isGranted) {
    //   return true;
    // } else {
    //   return false;
    // }
    return false;
  }

  Widget buildMessagesUsingProvider(BuildContext context) {
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) =>
            Consumer<FirestoreDataProviderMESSAGESforGROUPCHAT>(
                builder: (context, firestoreDataProvider, _) =>
                    InfiniteCOLLECTIONListViewWidget(
                      scrollController: realtime,
                      isreverse: true,
                      firestoreDataProviderMESSAGESforGROUPCHAT:
                          firestoreDataProvider,
                      datatype: Dbkeys.datatypeGROUPCHATMSGS,
                      refdata: firestoreChatquery,
                      list: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.all(7),
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: firestoreDataProvider.recievedDocs.length,
                          itemBuilder: (BuildContext context, int i) {
                            var dc = firestoreDataProvider.recievedDocs[i];

                            return buildEachMessage(
                                dc,
                                groupList.lastWhere((element) =>
                                    element.docmap[Dbkeys.groupID] ==
                                    widget.groupID));
                          }),
                    )));
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
              ),
              color: fiberchatWhite.withOpacity(0.2),
            )
          : Container(),
    );
  }

  Future<bool> onWillPop() {
    if (isemojiShowing == true) {
      setStateIfMounted(() {
        isemojiShowing = false;
      });
      Future.value(false);
    } else {
      setLastSeen(true, isemojiShowing);
      return Future.value(true);
    }
    return Future.value(false);
  }

  bool isemojiShowing = false;
  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        keyboardFocusNode.unfocus();
        isemojiShowing = true;
      } else {
        isemojiShowing = false;
        keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Consumer<List<GroupModel>>(
            builder: (context, groupList, _child) => WillPopScope(
                  onWillPop: isgeneratingSomethingLoader == true
                      ? () async {
                          return Future.value(false);
                        }
                      : isemojiShowing == true
                          ? () {
                              setStateIfMounted(() {
                                isemojiShowing = false;
                                keyboardFocusNode.unfocus();
                              });
                              return Future.value(false);
                            }
                          : () async {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((timeStamp) {
                                var currentpeer = Provider.of<CurrentChatPeer>(
                                    this.context,
                                    listen: false);
                                currentpeer.setpeer(newgroupChatId: '');
                              });
                              setLastSeen(false, false);

                              return Future.value(true);
                            },
                  child: Stack(
                    children: [
                      Scaffold(
                          key: _scaffold,
                          appBar: AppBar(
                            elevation: 0.4,
                            titleSpacing: widget.isWideScreenMode ? 14 : 0,
                            leading: widget.isWideScreenMode
                                ? null
                                : Container(
                                    margin: EdgeInsets.only(right: 0),
                                    width: 10,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        size: 20,
                                        color: fiberchatBlack,
                                      ),
                                      onPressed: onWillPop,
                                    ),
                                  ),
                            backgroundColor: appbarColor,
                            title: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (context) => new GroupDetails(
                                            model: widget.model,
                                            prefs: widget.prefs,
                                            currentUserno: widget.currentUserno,
                                            groupID: widget.groupID)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                      child: customCircleAvatarGroup(
                                          radius: 42,
                                          url: groupList
                                              .lastWhere((element) =>
                                                  element
                                                      .docmap[Dbkeys.groupID] ==
                                                  widget.groupID)
                                              .docmap[Dbkeys.groupPHOTOURL])),
                                  SizedBox(
                                    width: 17,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            groupList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupNAME],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: fiberchatBlack,
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          isCurrentUserMuted
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 5.0),
                                                  child: Icon(
                                                    Icons.volume_off,
                                                    color: fiberchatBlack
                                                        .withOpacity(0.5),
                                                    size: 17,
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      SizedBox(
                                        width: getContentScreenWidth(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width) /
                                            1.9,
                                        child: Text(
                                          getTranslated(
                                              context, 'tapherefrgrpinfo'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: fiberchatGrey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              Container(
                                  margin: EdgeInsets.only(right: 15, left: 15),
                                  width: 25,
                                  child: Builder(
                                    builder:
                                        (BuildContext context) =>
                                            PopupMenuButton(
                                                icon: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 0),
                                                  child: Icon(
                                                    Icons.more_vert_outlined,
                                                    color: fiberchatBlack,
                                                  ),
                                                ),
                                                color: fiberchatWhite,
                                                onSelected: (dynamic val) {
                                                  switch (val) {
                                                    case 'report':
                                                      var width =
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width;
                                                      var w = width / 1.4;
                                                      isWideScreen(w) == true
                                                          ? showCustomDialog(
                                                              context: context,
                                                              listWidgets: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      IconButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop();
                                                                          },
                                                                          icon:
                                                                              Icon(
                                                                            Icons.close,
                                                                            size:
                                                                                25,
                                                                            color:
                                                                                fiberchatGrey.withOpacity(0.78),
                                                                          ))
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: 12,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 3,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            7),
                                                                    child: Text(
                                                                      getTranslated(
                                                                          this.context,
                                                                          'reportshort'),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16.5),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Container(
                                                                    margin: EdgeInsets
                                                                        .only(
                                                                            top:
                                                                                10),
                                                                    padding: EdgeInsets
                                                                        .fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                    // height: 63,
                                                                    height: 63,
                                                                    width:
                                                                        w / 1.5,
                                                                    child:
                                                                        InpuTextBox(
                                                                      controller:
                                                                          reportEditingController,
                                                                      leftrightmargin:
                                                                          0,
                                                                      showIconboundary:
                                                                          false,
                                                                      boxcornerradius:
                                                                          5.5,
                                                                      boxheight:
                                                                          50,
                                                                      hinttext: getTranslated(
                                                                          this.context,
                                                                          'reportdesc'),
                                                                      prefixIconbutton:
                                                                          Icon(
                                                                        Icons
                                                                            .message,
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 40,
                                                                  ),
                                                                  myElevatedButton(
                                                                      color:
                                                                          fiberchatPRIMARYcolor,
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            30,
                                                                            15,
                                                                            30,
                                                                            15),
                                                                        child:
                                                                            Text(
                                                                          getTranslated(
                                                                              context,
                                                                              'report'),
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 18),
                                                                        ),
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();

                                                                        DateTime
                                                                            time =
                                                                            DateTime.now();

                                                                        Map<String,
                                                                                dynamic>
                                                                            mapdata =
                                                                            {
                                                                          'title':
                                                                              'New report by User',
                                                                          'desc':
                                                                              '${reportEditingController.text}',
                                                                          'phone':
                                                                              '${widget.currentUserno}',
                                                                          'type':
                                                                              'Group Chat',
                                                                          'time':
                                                                              time.millisecondsSinceEpoch,
                                                                          'id':
                                                                              widget.groupID,
                                                                        };
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection('reports')
                                                                            .doc(time.millisecondsSinceEpoch.toString())
                                                                            .set(mapdata)
                                                                            .then((value) async {
                                                                          showCustomDialog(
                                                                            context:
                                                                                this.context,
                                                                            listWidgets: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  IconButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      icon: Icon(
                                                                                        Icons.close,
                                                                                        size: 25,
                                                                                        color: fiberchatGrey.withOpacity(0.78),
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),
                                                                              Text(
                                                                                getTranslated(context, 'reportsuccess'),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),
                                                                            ],
                                                                          );

                                                                          //----
                                                                        }).catchError((err) {
                                                                          showCustomDialog(
                                                                            context:
                                                                                this.context,
                                                                            listWidgets: [
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                children: [
                                                                                  IconButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(context).pop();
                                                                                      },
                                                                                      icon: Icon(
                                                                                        Icons.close,
                                                                                        size: 25,
                                                                                        color: fiberchatGrey.withOpacity(0.78),
                                                                                      ))
                                                                                ],
                                                                              ),
                                                                              SizedBox(
                                                                                height: 20,
                                                                              ),
                                                                              Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),
                                                                              Text(
                                                                                getTranslated(context, 'reportsuccess'),
                                                                                textAlign: TextAlign.center,
                                                                              ),
                                                                              SizedBox(
                                                                                height: 30,
                                                                              ),
                                                                            ],
                                                                          );
                                                                        });
                                                                      }),
                                                                ])
                                                          : showModalBottomSheet(
                                                              isScrollControlled:
                                                                  true,
                                                              context: context,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .vertical(
                                                                            top:
                                                                                Radius.circular(25.0)),
                                                              ),
                                                              builder:
                                                                  (BuildContext
                                                                      context) {
                                                                // return your layout
                                                                var w = MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width;
                                                                return Padding(
                                                                  padding: EdgeInsets.only(
                                                                      bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom),
                                                                  child:
                                                                      Container(
                                                                          padding: EdgeInsets.all(
                                                                              16),
                                                                          height: MediaQuery.of(context).size.height /
                                                                              2.6,
                                                                          child: Column(
                                                                              mainAxisSize: MainAxisSize.min,
                                                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                              children: [
                                                                                SizedBox(
                                                                                  height: 12,
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 3,
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 7),
                                                                                  child: Text(
                                                                                    getTranslated(this.context, 'reportshort'),
                                                                                    textAlign: TextAlign.left,
                                                                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 10,
                                                                                ),
                                                                                Container(
                                                                                  margin: EdgeInsets.only(top: 10),
                                                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                  // height: 63,
                                                                                  height: 63,
                                                                                  width: w / 1.24,
                                                                                  child: InpuTextBox(
                                                                                    controller: reportEditingController,
                                                                                    leftrightmargin: 0,
                                                                                    showIconboundary: false,
                                                                                    boxcornerradius: 5.5,
                                                                                    boxheight: 50,
                                                                                    hinttext: getTranslated(this.context, 'reportdesc'),
                                                                                    prefixIconbutton: Icon(
                                                                                      Icons.message,
                                                                                      color: Colors.grey.withOpacity(0.5),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: w / 10,
                                                                                ),
                                                                                myElevatedButton(
                                                                                    color: fiberchatPRIMARYcolor,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                                      child: Text(
                                                                                        getTranslated(context, 'report'),
                                                                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                                                                      ),
                                                                                    ),
                                                                                    onPressed: () async {
                                                                                      Navigator.of(context).pop();

                                                                                      DateTime time = DateTime.now();

                                                                                      Map<String, dynamic> mapdata = {
                                                                                        'title': 'New report by User',
                                                                                        'desc': '${reportEditingController.text}',
                                                                                        'phone': '${widget.currentUserno}',
                                                                                        'type': 'Group Chat',
                                                                                        'time': time.millisecondsSinceEpoch,
                                                                                        'id': widget.groupID,
                                                                                      };

                                                                                      await FirebaseFirestore.instance.collection('reports').doc(time.millisecondsSinceEpoch.toString()).set(mapdata).then((value) async {
                                                                                        showModalBottomSheet(
                                                                                            isScrollControlled: true,
                                                                                            context: context,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                            ),
                                                                                            builder: (BuildContext context) {
                                                                                              return Container(
                                                                                                height: 220,
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.all(28.0),
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                                                      SizedBox(
                                                                                                        height: 30,
                                                                                                      ),
                                                                                                      Text(
                                                                                                        getTranslated(context, 'reportsuccess'),
                                                                                                        textAlign: TextAlign.center,
                                                                                                      )
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            });

                                                                                        //----
                                                                                      }).catchError((err) {
                                                                                        showModalBottomSheet(
                                                                                            isScrollControlled: true,
                                                                                            context: this.context,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                                            ),
                                                                                            builder: (BuildContext context) {
                                                                                              return Container(
                                                                                                height: 220,
                                                                                                child: Padding(
                                                                                                  padding: const EdgeInsets.all(28.0),
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Icon(Icons.check, color: Colors.green[400], size: 40),
                                                                                                      SizedBox(
                                                                                                        height: 30,
                                                                                                      ),
                                                                                                      Text(
                                                                                                        getTranslated(context, 'reportsuccess'),
                                                                                                        textAlign: TextAlign.center,
                                                                                                      )
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            });
                                                                                      });
                                                                                    }),
                                                                              ])),
                                                                );
                                                              });
                                                      break;
                                                  }
                                                },
                                                itemBuilder: ((context) =>
                                                    <PopupMenuItem<String>>[
                                                      // PopupMenuItem<String>(
                                                      //   value: isCurrentUserMuted
                                                      //       ? 'unmute'
                                                      //       : 'mute',
                                                      //   child: Text(
                                                      //     isCurrentUserMuted
                                                      //         ? '${getTranslated(this.context, 'unmute')}'
                                                      //         : '${getTranslated(this.context, 'mute')}',
                                                      //   ),
                                                      // ),
                                                      PopupMenuItem<String>(
                                                        value: 'report',
                                                        child: Text(
                                                          '${getTranslated(this.context, 'report')}',
                                                        ),
                                                      ),
                                                      // ignore: unnecessary_null_comparison
                                                    ].toList())),
                                  )),
                            ],
                          ),
                          body: Stack(children: <Widget>[
                            new Container(
                              decoration: new BoxDecoration(
                                color: fiberchatChatbackground,
                                image: new DecorationImage(
                                    image: AssetImage(
                                        "assets/images/background.png"),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            PageView(children: <Widget>[
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                        child: buildMessagesUsingProvider(
                                            context)),
                                    groupList
                                                    .lastWhere((element) =>
                                                        element.docmap[
                                                            Dbkeys.groupID] ==
                                                        widget.groupID)
                                                    .docmap[Dbkeys.groupTYPE] ==
                                                Dbkeys
                                                    .groupTYPEallusersmessageallowed ||
                                            groupList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.groupID] ==
                                                    widget.groupID)
                                                .docmap[Dbkeys.groupADMINLIST]
                                                .contains(widget.currentUserno)
                                        ? buildInputTextBox(
                                            context,
                                            isemojiShowing,
                                            refreshInput,
                                            _keyboardVisible,
                                          )
                                        : Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.fromLTRB(
                                                14, 7, 14, 7),
                                            color: Colors.white,
                                            height: 70,
                                            width: getContentScreenWidth(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width),
                                            child: Text(
                                              getTranslated(
                                                  context, 'onlyadminsend'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(height: 1.3),
                                            ),
                                          ),
                                  ])
                            ]),
                          ])),
                      buildLoadingThumbnail()
                    ],
                  ),
                ))));
  }

  Widget selectablelinkify(
      String? text, double? fontsize, TextAlign? textalign) {
    bool isContainURL = false;
    try {
      isContainURL =
          Uri.tryParse(text!) == null ? false : Uri.tryParse(text)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return isContainURL == false
        ? SelectableLinkify(
            style: TextStyle(
                fontSize: isAllEmoji(text!) ? fontsize! * 2 : fontsize,
                color: Colors.black87),
            text: text,
            onOpen: (link) async {
              custom_url_launcher(link.url);
            },
          )
        : LinkPreviewGenerator(
            removeElevation: true,
            graphicFit: BoxFit.cover,
            borderRadius: 5,
            showDomain: true,
            titleStyle: TextStyle(
                fontSize: 13, height: 1.4, fontWeight: FontWeight.bold),
            showBody: true,
            bodyStyle: TextStyle(fontSize: 11.6, color: Colors.black45),
            placeholderWidget: SelectableLinkify(
              textAlign: textalign,
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text!,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            errorWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text,
              textAlign: textalign,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            link: text,
            linkPreviewStyle: LinkPreviewStyle.large,
          );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setLastSeen(false, false);
    else
      setLastSeen(false, false);
  }
}

deletedGroupWidget(BuildContext context) {
  return Scaffold(
    appBar: AppBar(),
    body: Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            getTranslated(context, 'deletedgroup'),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
