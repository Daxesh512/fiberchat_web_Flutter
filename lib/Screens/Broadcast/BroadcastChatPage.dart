//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'package:fiberchat_web/Screens/homepage/homepage.dart';
import 'package:fiberchat_web/Utils/file_selector_uploader.dart';
import 'package:fiberchat_web/widgets/CustomDialog/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Screens/Broadcast/BroadcastDetails.dart';
import 'package:fiberchat_web/Screens/Groups/widget/groupChatBubble.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/custom_url_launcher.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/emoji_detect.dart';
import 'package:fiberchat_web/Utils/mime_type.dart';
import 'package:fiberchat_web/Utils/setStatusBarColor.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/DownloadManager/download_all_file_type.dart';
import 'package:fiberchat_web/widgets/InfiniteList/InfiniteCOLLECTIONListViewWidget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:provider/provider.dart';
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/photo_view.dart';
import 'package:fiberchat_web/Utils/save.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat_web/Utils/unawaited.dart';
import 'package:path/path.dart' as p;

class BroadcastChatPage extends StatefulWidget {
  final String currentUserno;
  final bool isWideScreenMode;
  final String broadcastID;
  final DataModel model;
  final SharedPreferences prefs;
  BroadcastChatPage({
    Key? key,
    required this.currentUserno,
    required this.broadcastID,
    required this.isWideScreenMode,
    required this.model,
    required this.prefs,
  }) : super(key: key);

  @override
  _BroadcastChatPageState createState() => _BroadcastChatPageState();
}

class _BroadcastChatPageState extends State<BroadcastChatPage>
    with WidgetsBindingObserver {
  bool isgeneratingThumbnail = false;

  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  GlobalKey<State> _keyLoader =
      new GlobalKey<State>(debugLabel: 'qqqeqessaqsseaadqeqe');
  final ScrollController realtime = new ScrollController();
  late Query firestoreChatquery;
  @override
  void initState() {
    super.initState();
    firestoreChatquery = FirebaseFirestore.instance
        .collection(DbPaths.collectionbroadcasts)
        .doc(widget.broadcastID)
        .collection(DbPaths.collectionbroadcastsChats)
        .orderBy(Dbkeys.broadcastmsgTIME, descending: true)
        .limit(maxChatMessageDocsLoadAtOnceForGroupChatAndBroadcastLazyLoading);
    setLastSeen(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var firestoreProvider =
          Provider.of<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>(
              this.context,
              listen: false);

      firestoreProvider.reset();
      Future.delayed(const Duration(milliseconds: 1000), () {
        loadMessagesAndListen();
      });
    });
  }

  loadMessagesAndListen() async {
    firestoreChatquery.snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>(
                  this.context,
                  listen: false);
          DocumentSnapshot newDoc = change.doc;
          if (chatprovider.datalistSnapshot.length == 0) {
          } else if ((chatprovider.checkIfDocAlreadyExits(
                newDoc: newDoc,
              ) ==
              false)) {
            chatprovider.addDoc(newDoc);
            // unawaited(realtime.animateTo(0.0,
            //     duration: Duration(milliseconds: 300), curve: Curves.easeOut));
          }
        } else if (change.type == DocumentChangeType.modified) {
          var chatprovider =
              Provider.of<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>(
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
              Provider.of<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>(
                  this.context,
                  listen: false);
          DocumentSnapshot deletedDoc = change.doc;
          if (chatprovider.checkIfDocAlreadyExits(
                  newDoc: deletedDoc,
                  timestamp: deletedDoc[Dbkeys.timestamp]) ==
              true) {
            chatprovider.deleteparticulardocinProvider(deletedDoc: deletedDoc);
          }
        }
      });
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  setLastSeen(bool iswillpop) {
    setStatusBarColor();
    if (iswillpop == true) {
      Navigator.of(this.context).pop();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen(false);
  }

  File? thumbnailFile;

  getFileData(File image) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    // ignore: unnecessary_null_comparison
    if (image != null) {
      setStateIfMounted(() {
        imageFile = image;
      });
    }
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(false)
        : uploadFile(false);
  }

  getpickedFileName(broadcastID, timestamp) {
    return "${widget.currentUserno}-$timestamp";
  }

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingThumbnail = true;
    });
    //IsRequirefocus
    // String? path = await VideoThumbnail.thumbnailFile(
    //     video: url,
    //     thumbnailPath: (await getTemporaryDirectory()).path,
    //     imageFormat: ImageFormat.PNG,
    //     // maxHeight: 150,
    //     // maxWidth:300,
    //     // timeMs: r.timeMs,
    //     quality: 30);

    // thumbnailFile = File(path!);
    setStateIfMounted(() {
      isgeneratingThumbnail = false;
    });
    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  String? videometadata;
  int? uploadTimestamp;
  int? thumnailtimestamp;
  Future uploadFile(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = getpickedFileName(
        widget.broadcastID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
        .child(fileName);

    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(imageFile!.path) == true) {
      fileToCompress = File(imageFile!.path);

      imageFile = fileToCompress;
    } else if (isthumbnail == false && isImage(imageFile!.path) == true) {
      compressedImage = imageFile;
    } else {}
    TaskSnapshot uploading = await reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(imageFile!.path) == true
            ? compressedImage!
            : imageFile!);

    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
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

  Future uploadFileWithProgressIndicator(bool isthumbnail) async {
    uploadTimestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = getpickedFileName(
        widget.broadcastID,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
        .child(fileName);

    // ignore: unused_local_variable
    File fileToCompress;
    File? compressedImage;

    if (isthumbnail == false && isVideo(imageFile!.path) == true) {
      fileToCompress = File(imageFile!.path);

      imageFile = imageFile;
    } else if (isthumbnail == false && isImage(imageFile!.path) == true) {
      compressedImage = imageFile;
      //IsRequirefocus
      //  await FlutterImageCompress.compressAndGetFile(
      //   imageFile!.absolute.path,
      //   targetPath,
      //   quality: ImageQualityCompress,
      //   rotate: 0,
      // );
    } else {}
    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile!
        : isImage(imageFile!.path) == true
            ? compressedImage!
            : imageFile!);

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
                                    : getTranslated(context, 'uploading'),
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
                                      : getTranslated(context, 'uploading'),
                                  subtitle: '');
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
      //IsRequirefocus
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

  void onSendMessage({
    required BuildContext context,
    required String content,
    required MessageType type,
    required List<dynamic> recipientList,
  }) async {
    textEditingController.clear();
    await FirebaseBroadcastServices().sendMessageToBroadcastRecipients(
        recipientList: recipientList,
        context: context,
        content: content,
        currentUserNo: widget.currentUserno,
        broadcastId: widget.broadcastID,
        type: type,
        cachedModel: widget.model);

    unawaited(realtime.animateTo(0.0,
        duration: Duration(milliseconds: 300), curve: Curves.easeOut));
    Fiberchat.toast(
        '${getTranslated(context, 'senttorecp')} ${recipientList.length}');
    setStatusBarColor();
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
    // String fileName = getpickedFileName(widget.broadcastID,
    //     isthumbnail == false ? '$timeEpoch' : '${timeEpoch}Thumbnail');
    Reference reference = FirebaseStorage.instance
        .ref("+00_BROADCAST_MEDIA/${widget.broadcastID}/")
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
      //IsRequirefocus
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
  Widget buildInputTextBox(
      BuildContext context,
      bool isemojiShowing,
      Function toggleEmojiKeyboard,
      bool keyboardVisible,
      List<BroadcastModel> broadcastList) {
    final observer = Provider.of<Observer>(context, listen: true);

    return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                                    refreshInput();
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
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    icon: Icon(
                                                      Icons.close,
                                                      size: 25,
                                                      color: fiberchatGrey
                                                          .withOpacity(0.78),
                                                    ))
                                              ],
                                            ),
                                          ),
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
                                                  hidekeyboard(context);

                                                  String firebasePath =
                                                      "+00_BROADCAST_MEDIA/${widget.broadcastID}/";
//---
                                                  ///--
                                                  await FileSelectorUploader
                                                      .uploadToFirebase(
                                                          isShowProgress: true,
                                                          context: this.context,
                                                          totalFilesToSelect:
                                                              observer
                                                                  .maxNoOfFilesInMultiSharing,
                                                          isMultiple: true,
                                                          onUploadFirebaseComplete:
                                                              (url, filename,
                                                                  islast) async {
                                                            String finalUrl =
                                                                url +
                                                                    '-BREAK-' +
                                                                    filename;
                                                            onSendMessage(
                                                                context: this
                                                                    .context,
                                                                content: filename.toLowerCase().endsWith('.png') ||
                                                                        filename
                                                                            .toLowerCase()
                                                                            .endsWith(
                                                                                '.jpg') ||
                                                                        filename
                                                                            .toLowerCase()
                                                                            .endsWith(
                                                                                '.jpeg')
                                                                    ? url
                                                                    : finalUrl,
                                                                type: filename.toLowerCase().endsWith('.png') ||
                                                                        filename
                                                                            .toLowerCase()
                                                                            .endsWith(
                                                                                '.jpg') ||
                                                                        filename
                                                                            .toLowerCase()
                                                                            .endsWith(
                                                                                '.jpeg')
                                                                    ? MessageType
                                                                        .image
                                                                    : filename.toLowerCase().endsWith(
                                                                            '.mp3')
                                                                        ? MessageType
                                                                            .audio
                                                                        : MessageType
                                                                            .doc,
                                                                recipientList: broadcastList
                                                                    .toList()
                                                                    .firstWhere(
                                                                        (element) =>
                                                                            element.docmap[Dbkeys.broadcastID] ==
                                                                            widget.broadcastID)
                                                                    .docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                                                              Fiberchat.toast(
                                                                  e);
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
                                                          type:
                                                              MessageType.image,
                                                          recipientList: broadcastList
                                                              .toList()
                                                              .firstWhere((element) =>
                                                                  element.docmap[
                                                                      Dbkeys
                                                                          .broadcastID] ==
                                                                  widget
                                                                      .broadcastID)
                                                              .docmap[Dbkeys.broadcastMEMBERSLIST]);
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
                  margin: EdgeInsets.only(left: 6, right: 10),
                  decoration: BoxDecoration(
                      color: fiberchatSECONDARYolor,
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
                                  hidekeyboard(context);
                                  String firebasePath =
                                      "+00_BROADCAST_MEDIA/${widget.broadcastID}/";
                                  void onUploaded(String finalUrl) {
                                    onSendMessage(
                                        context: this.context,
                                        content: finalUrl,
                                        type: MessageType.audio,
                                        recipientList: broadcastList
                                                .toList()
                                                .firstWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.broadcastID] ==
                                                    widget.broadcastID)
                                                .docmap[
                                            Dbkeys.broadcastMEMBERSLIST]);
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
                                                Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: IconButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        icon: Icon(
                                                          Icons.close_outlined,
                                                          size: 17,
                                                          color: fiberchatGrey
                                                              .withOpacity(0.7),
                                                        )))
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) => AudioRecord(
                                  //               title: getTranslated(
                                  //                   this.context, 'record'),
                                  //               callback: getFileData,
                                  //             ))).then((url) {
                                  //   if (url != null) {
                                  //     onSendMessage(
                                  //         context: context,
                                  //         content: url +
                                  //             '-BREAK-' +
                                  //             uploadTimestamp.toString(),
                                  //         type: MessageType.audio,
                                  //         recipientList: broadcastList
                                  //                 .toList()
                                  //                 .firstWhere((element) =>
                                  //                     element.docmap[
                                  //                         Dbkeys.broadcastID] ==
                                  //                     widget.broadcastID)
                                  //                 .docmap[
                                  //             Dbkeys.broadcastMEMBERSLIST]);
                                  //   } else {}
                                  // });
                                }
                              : observer.istextmessagingallowed == false
                                  ? () {
                                      Fiberchat.showRationale(getTranslated(
                                          this.context, 'textmssgnotallowed'));
                                    }
                                  : () => onSendMessage(
                                      context: context,
                                      content: textEditingController.value.text
                                          .trim(),
                                      type: MessageType.text,
                                      recipientList: broadcastList
                                          .toList()
                                          .firstWhere((element) =>
                                              element
                                                  .docmap[Dbkeys.broadcastID] ==
                                              widget.broadcastID)
                                          .docmap[Dbkeys.broadcastMEMBERSLIST])
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
              // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
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

  buildEachMessage(Map<String, dynamic> doc, BroadcastModel broadcastData) {
    if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationCreatedbroadcast) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  '${getTranslated(this.context, 'createdbroadcast')} ${doc[Dbkeys.broadcastmsgLISToptional].length} ${getTranslated(this.context, 'recipients')}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationAddedUser) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  doc[Dbkeys.broadcastmsgLISToptional].length > 1
                      ? '${getTranslated(this.context, 'uhaveadded')} ${doc[Dbkeys.broadcastmsgLISToptional].length} ${getTranslated(this.context, 'recipients')}'
                      : '${getTranslated(this.context, 'uhaveadded')} ${doc[Dbkeys.broadcastmsgLISToptional][0]} ',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationUpdatedbroadcastDetails) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  getTranslated(this.context, 'uhaveupdatedbroadcast'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationUpdatedbroadcasticon) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  getTranslated(this.context, 'broadcasticonupdtd'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationDeletedbroadcasticon) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  getTranslated(this.context, 'broadcasticondlted'),
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.broadcastmsgTYPE] ==
        Dbkeys.broadcastmsgTYPEnotificationRemovedUser) {
      return Center(
          child: Padding(
              padding: EdgeInsets.all(widget.isWideScreenMode ? 13 : 8.0),
              child: Chip(
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                backgroundColor: Colors.blueGrey[50],
                label: Text(
                  '${getTranslated(this.context, 'youhaveremoved')} ${doc[Dbkeys.broadcastmsgLISToptional][0]}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                ),
              )));
    } else if (doc[Dbkeys.broadcastmsgTYPE] == MessageType.image.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.doc.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.text.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.video.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.audio.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.contact.index ||
        doc[Dbkeys.broadcastmsgTYPE] == MessageType.location.index) {
      return buildMediaMessages(doc, broadcastData);
    }

    return Text(doc[Dbkeys.broadcastmsgCONTENT]);
  }

  contextMenu(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);

    if (doc[Dbkeys.broadcastmsgSENDBY] == widget.currentUserno) {
      tiles.add(Builder(
          builder: (BuildContext popable) => ListTile(
              dense: true,
              leading: Icon(Icons.delete),
              title: Text(
                (doc[Dbkeys.messageType] == MessageType.image.index &&
                            !doc[Dbkeys.broadcastmsgCONTENT]
                                .contains('giphy')) ||
                        (doc[Dbkeys.messageType] == MessageType.doc.index) ||
                        (doc[Dbkeys.messageType] == MessageType.audio.index) ||
                        (doc[Dbkeys.messageType] == MessageType.video.index)
                    ? getTranslated(popable, 'dltforeveryone')
                    : getTranslated(popable, 'dltforme'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(popable).pop();
                if (doc[Dbkeys.messageType] == MessageType.image.index &&
                    !doc[Dbkeys.broadcastmsgCONTENT].contains('giphy')) {
                  await FirebaseStorage.instance
                      .refFromURL(doc[Dbkeys.broadcastmsgCONTENT])
                      .delete();
                } else if (doc[Dbkeys.messageType] == MessageType.doc.index) {
                  await FirebaseStorage.instance
                      .refFromURL(
                          doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[0])
                      .delete();
                } else if (doc[Dbkeys.messageType] == MessageType.audio.index) {
                  await FirebaseStorage.instance
                      .refFromURL(
                          doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[0])
                      .delete();
                } else if (doc[Dbkeys.messageType] == MessageType.video.index) {
                  await FirebaseStorage.instance
                      .refFromURL(
                          doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[0])
                      .delete();
                  await FirebaseStorage.instance
                      .refFromURL(
                          doc[Dbkeys.broadcastmsgCONTENT].split('-BREAK-')[1])
                      .delete();
                }

                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionbroadcasts)
                    .doc(widget.broadcastID)
                    .collection(DbPaths.collectionbroadcastsChats)
                    .doc(
                        '${doc[Dbkeys.broadcastmsgTIME]}--${doc[Dbkeys.broadcastmsgSENDBY]}')
                    .delete();
                Fiberchat.toast(getTranslated(this.context, 'deleted'));
              })));
    }

    showDialog(
        context: this.context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  Widget buildMediaMessages(
      Map<String, dynamic> doc, BroadcastModel broadcastData) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    bool isMe = widget.currentUserno == doc[Dbkeys.broadcastmsgSENDBY];
    bool saved = false;
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
              onLongPress: () {
                contextMenu(context, doc);
                hidekeyboard(context);
              },
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
                                element.phone ==
                                doc[Dbkeys.broadcastmsgSENDBY]) >=
                        0
                    ? contactsProvider
                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                        .toList()[contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .toList()
                            .indexWhere((element) =>
                                element.phone ==
                                doc[Dbkeys.broadcastmsgSENDBY])]
                        .name
                    : null,
                postedbyname: contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer
                            .indexWhere((element) =>
                                element.phone ==
                                doc[Dbkeys.broadcastmsgSENDBY]) >=
                        0
                    ? contactsProvider
                            .alreadyJoinedSavedUsersPhoneNameAsInServer[
                                contactsProvider
                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                    .indexWhere((element) =>
                                        element.phone ==
                                        doc[Dbkeys.broadcastmsgSENDBY])]
                            .name ??
                        ''
                    : '',
                postedbyphone: doc[Dbkeys.broadcastmsgSENDBY],
                messagetype: doc[Dbkeys.broadcastmsgISDELETED] == true
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
                child: doc[Dbkeys.broadcastmsgISDELETED] == true
                    ? getTextMessage(isMe, doc, saved)
                    : doc[Dbkeys.messageType] == MessageType.text.index
                        ? getTextMessage(isMe, doc, saved)
                        : doc[Dbkeys.messageType] == MessageType.location.index
                            ? getLocationMessage(doc[Dbkeys.content],
                                saved: false)
                            : doc[Dbkeys.messageType] == MessageType.doc.index
                                ? getDocmessage(context, doc[Dbkeys.content],
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.audio.index
                                    ? getAudiomessage(
                                        context, doc[Dbkeys.content],
                                        isMe: isMe, saved: false)
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.video.index
                                        ? getVideoMessage(
                                            context, doc[Dbkeys.content],
                                            saved: false)
                                        : doc[Dbkeys.messageType] ==
                                                MessageType.contact.index
                                            ? getContactMessage(
                                                context, doc[Dbkeys.content],
                                                saved: false)
                                            : getImageMessage(
                                                doc,
                                                saved: saved,
                                              ),
                isMe: isMe,
                delivered: true,
                isContinuing: true,
                timestamp: doc[Dbkeys.broadcastmsgTIME],
              ),
            ));
  }

  Widget getVideoMessage(BuildContext context, String message,
      {bool saved = false}) {
    return InkWell(
      onTap: () async {
        try {
          await WebDownloadService().downloadusingBrowser(
            url: message.split('-BREAK-')[0],
            fileName: "Video_${DateTime.now().millisecondsSinceEpoch}.mp4",
          );
        } catch (e) {
          Fiberchat.toast("failed to Download !\n $e");
        }
      },
      child: Container(
        color: Colors.blueGrey,
        width: 230.0,
        height: 230.0,
        child: Stack(
          children: [
            Image.network(
              message.split('-BREAK-')[1],
              width: 230.0,
              height: 230.0,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.4),
              width: 230.0,
              height: 230.0,
            ),
            Center(
              child: Icon(Icons.play_circle, color: Colors.white70, size: 65),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Center(
                child: Icon(Icons.download, color: Colors.white70, size: 25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getContactMessage(BuildContext context, String message,
      {bool saved = false}) {
    return SizedBox(
      width: 210,
      height: 75,
      child: Column(
        children: [
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
    return selectablelinkify(
        doc[Dbkeys.broadcastmsgISDELETED] == true
            ? 'Message is deleted'
            : doc[Dbkeys.content],
        15.5,
        isMe ? TextAlign.right : TextAlign.left);
  }

  Widget getLocationMessage(String? message, {bool saved = false}) {
    return InkWell(
      onTap: () {
        custom_url_launcher(message!);
      },
      child: Image.asset(
        'assets/images/mapview.jpg',
        width:
            getContentScreenWidth(MediaQuery.of(this.context).size.width) / 1.7,
        height: (getContentScreenWidth(MediaQuery.of(this.context).size.width) /
                1.7) *
            0.6,
      ),
    );
  }

  Widget getAudiomessage(BuildContext context, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        children: [
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

  Widget getDocmessage(BuildContext context, String message,
      {bool saved = false}) {
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        children: [
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
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              onPressed: () async {
                await WebDownloadService().downloadusingBrowser(
                  url: message.split('-BREAK-')[0],
                  fileName: message.split('-BREAK-')[1],
                );
              },
              child: Text(getTranslated(this.context, 'download'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.blue[400]))),
        ],
      ),
    );
  }

  Widget getImageMessage(Map<String, dynamic> doc, {bool saved = false}) {
    return Container(
      child: saved
          ? Material(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: Save.getImageFromBase64(doc[Dbkeys.content]).image,
                      fit: BoxFit.cover),
                ),
                width: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                height: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
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
                      tag: doc[Dbkeys.broadcastmsgTIME].toString(),
                    ),
                  )),
              child: Image.network(
                doc[Dbkeys.content],
                width: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                height: doc[Dbkeys.content].contains('giphy') ? 140 : 230.0,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Future<bool> checkIfLocationEnabled() async {
    //IsRequirefocus
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
    return Consumer<List<BroadcastModel>>(
        builder: (context, broadcastList, _child) =>
            Consumer<FirestoreDataProviderMESSAGESforBROADCASTCHATPAGE>(
                builder: (context, firestoreDataProvider, _) =>
                    InfiniteCOLLECTIONListViewWidget(
                      scrollController: realtime,
                      isreverse: true,
                      firestoreDataProviderMESSAGESforBROADCASTCHATPAGE:
                          firestoreDataProvider,
                      datatype: Dbkeys.datatypeBROADCASTCMSGS,
                      refdata: firestoreChatquery,
                      list: ListView.builder(
                          reverse: true,
                          padding: EdgeInsets.all(0),
                          physics: BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: firestoreDataProvider.recievedDocs.length,
                          itemBuilder: (BuildContext context, int i) {
                            var dc = firestoreDataProvider.recievedDocs[i];

                            return buildEachMessage(
                                dc,
                                broadcastList.lastWhere((element) =>
                                    element.docmap[Dbkeys.groupID] ==
                                    widget.broadcastID));
                          }),
                    )));
  }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingThumbnail
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

  File? imageFile;

  bool isemojiShowing = false;
  Future<bool> onWillPop() {
    if (isemojiShowing == true) {
      setState(() {
        isemojiShowing = false;
      });
      Future.value(false);
    } else {
      Navigator.of(this.context).pop();
      return Future.value(true);
    }
    return Future.value(false);
  }

  refreshInput() {
    setStateIfMounted(() {
      if (isemojiShowing == false) {
        // hidekeyboard(this.context);
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
        scaffold: Fiberchat.getNTPWrappedWidget(Consumer<List<BroadcastModel>>(
            builder: (context, broadcastList, _child) => WillPopScope(
                  onWillPop: isgeneratingThumbnail == true
                      ? () async {
                          return Future.value(false);
                        }
                      : isemojiShowing == true
                          ? () {
                              setState(() {
                                isemojiShowing = false;
                                keyboardFocusNode.unfocus();
                              });
                              return Future.value(false);
                            }
                          : () async {
                              setLastSeen(
                                false,
                              );

                              return Future.value(true);
                            },
                  child: Stack(
                    children: [
                      Scaffold(
                          backgroundColor: fiberchatChatbackground,
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
                                        Icons.arrow_back,
                                        size: 24,
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
                                        builder: (context) => BroadcastDetails(
                                            model: widget.model,
                                            prefs: widget.prefs,
                                            currentUserno: widget.currentUserno,
                                            broadcastID: widget.broadcastID)));
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 7, 0, 7),
                                      child: customCircleAvatarBroadcast(
                                          radius: 42,
                                          url: broadcastList
                                                  .lastWhere((element) =>
                                                      element.docmap[
                                                          Dbkeys.broadcastID] ==
                                                      widget.broadcastID)
                                                  .docmap[
                                              Dbkeys.broadcastPHOTOURL])),
                                  SizedBox(
                                    width: 17,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          broadcastList
                                              .lastWhere((element) =>
                                                  element.docmap[
                                                      Dbkeys.broadcastID] ==
                                                  widget.broadcastID)
                                              .docmap[Dbkeys.broadcastNAME],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: fiberchatBlack,
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ),
                                        SizedBox(
                                          width: getContentScreenWidth(
                                                  MediaQuery.of(this.context)
                                                      .size
                                                      .width) /
                                              1.3,
                                          child: Text(
                                            getTranslated(this.context,
                                                'tapforbroadcastinfo'),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                                color: fiberchatGrey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                    broadcastList
                                                .lastWhere((element) =>
                                                    element.docmap[
                                                        Dbkeys.broadcastID] ==
                                                    widget.broadcastID)
                                                .docmap[
                                                    Dbkeys.broadcastMEMBERSLIST]
                                                .length >
                                            0
                                        ? buildInputTextBox(
                                            context,
                                            isemojiShowing,
                                            refreshInput,
                                            _keyboardVisible,
                                            broadcastList)
                                        : Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.fromLTRB(
                                                14, 7, 14, 7),
                                            color: Colors.white,
                                            height: 70,
                                            width: getContentScreenWidth(
                                                MediaQuery.of(this.context)
                                                    .size
                                                    .width),
                                            child: Text(
                                              getTranslated(
                                                  this.context, 'norecp'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(height: 1.3),
                                            ),
                                          ),
                                  ])
                            ]),
                          ])),
                      buildLoadingThumbnail(),
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
      setLastSeen(false);
    else
      setLastSeen(false);
  }
}

deletedGroupWidget() {
  return Scaffold(
    backgroundColor: fiberchatChatbackground,
    appBar: AppBar(),
    body: Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            'This Broadcast Has been deleted by Admin OR you have been removed from this group.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );
}
