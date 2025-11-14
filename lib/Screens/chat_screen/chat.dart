//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
//androidIosBarrier
import 'dart:html' as html;
import 'package:fiberchat_web/Screens/homepage/homepage.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/widgets/CustomDialog/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Utils/custom_url_launcher.dart';
import 'package:fiberchat_web/Utils/file_selector_uploader.dart';
import 'package:fiberchat_web/Utils/setStatusBarColor.dart';
import 'package:fiberchat_web/widgets/DownloadManager/download_all_file_type.dart';
import 'package:path/path.dart' as p;
import 'package:collection/collection.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Configs/optional_constants.dart';
import 'package:fiberchat_web/Screens/auth_screens/login.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat_web/Screens/contact_screens/SelectContactsToForward.dart';
import 'package:fiberchat_web/Screens/security_screens/security.dart';

import 'package:fiberchat_web/Utils/emoji_detect.dart';
import 'package:fiberchat_web/Utils/mime_type.dart';
import 'package:fiberchat_web/main.dart';
import 'package:fiberchat_web/widgets/CountryPicker/CountryCode.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/deleteChatMedia.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:fiberchat_web/widgets/SoundPlayer/SoundPlayerPro.dart';
import 'package:fiberchat_web/Services/Providers/currentchat_peer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/audioPlayback.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/message.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/photo_view.dart';
import 'package:fiberchat_web/Screens/profile_settings/profile_view.dart';
import 'package:fiberchat_web/Services/Providers/seen_provider.dart';
import 'package:fiberchat_web/Services/Providers/seen_state.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Utils/call_utilities.dart';
import 'package:fiberchat_web/Utils/chat_controller.dart';
import 'package:fiberchat_web/Utils/crc.dart';
import 'package:fiberchat_web/Utils/save.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/Screens/chat_screen/Widget/bubble.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:giphy_get/giphy_get.dart';

import 'package:intl/intl.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';

import 'package:provider/provider.dart';
import 'package:record/record.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat_web/Models/E2EE/e2ee.dart' as e2ee;
import 'package:fiberchat_web/Utils/unawaited.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emojipic;

import 'package:fiberchat_web/Configs/Enum.dart';

hidekeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

class ChatScreen extends StatefulWidget {
  final String? peerNo, currentUserNo;
  final DataModel model;
  final bool isWideScreenMode;
  final int unread;
  final SharedPreferences prefs;

  final MessageType? sharedFilestype;
  final bool isSharingIntentForwarded;
  final String? sharedText;
  ChatScreen({
    Key? key,
    required this.currentUserNo,
    required this.peerNo,
    required this.model,
    required this.isWideScreenMode,
    required this.prefs,
    required this.unread,
    required this.isSharingIntentForwarded,
    this.sharedFilestype,
    this.sharedText,
  });

  @override
  State createState() => new _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  bool isDeleteChatManually = false;
  bool isReplyKeyboard = false;
  bool isPeerMuted = false;
  Map<String, dynamic>? replyDoc;
  String? peerAvatar, peerNo, currentUserNo, privateKey, sharedSecret;
  late bool locked, hidden;
  Map<String, dynamic>? peer, currentUser;
  int? chatStatus, unread;
  GlobalKey<State> _keyLoader34 =
      new GlobalKey<State>(debugLabel: 'qqqeqeqsse xcb h vgcxhvhaadsqeqe');
  bool isCurrentUserMuted = false;
  String? chatId;
  bool isMessageLoading = true;
  bool typing = false;
  late File thumbnailFile;
  File? pickedFile;
  // bool isLoading = true;
  bool isgeneratingSomethingLoader = false;
  // int tempSendIndex = 0;
  String? imageUrl;
  SeenState? seenState;
  List<Message> messages = new List.from(<Message>[]);
  List<Map<String, dynamic>> _savedMessageDocs =
      new List.from(<Map<String, dynamic>>[]);
  bool isDeletedDoc = false;
  int? uploadTimestamp;

  StreamSubscription? seenSubscription,
      msgSubscription,
      deleteUptoSubscription,
      chatStatusSubscriptionForPeer;

  final TextEditingController textEditingController =
      new TextEditingController();
  final TextEditingController reportEditingController =
      new TextEditingController();
  final ScrollController realtime = new ScrollController();
  final ScrollController saved = new ScrollController();
  late DataModel _cachedModel;

  Duration? duration;
  Duration? position;

  // AudioPlayer audioPlayer = AudioPlayer();

  String? localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';

  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  void initState() {
    super.initState();
    _cachedModel = widget.model;
    peerNo = widget.peerNo;
    currentUserNo = widget.currentUserNo;
    unread = widget.unread;
    // initAudioPlayer();
    // _load();
    Fiberchat.internetLookUp();

    updateLocalUserData(_cachedModel);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var currentpeer =
          Provider.of<CurrentChatPeer>(this.context, listen: false);
      currentpeer.setpeer(newpeerid: widget.peerNo);
      seenState = new SeenState(false);
      WidgetsBinding.instance.addObserver(this);
      chatId = '';
      unread = widget.unread;
      // isLoading = false;
      imageUrl = '';
      listenToBlock();
      loadSavedMessages();
      readLocal(this.context);
    });
    setStatusBarColor();
    //androidIosBarrier
    final el = html.window.document.getElementById('__ff-recaptcha-container');
    if (el != null) {
      el.style.visibility = 'hidden';
    }
  }

  bool hasPeerBlockedMe = false;
  listenToBlock() {
    chatStatusSubscriptionForPeer = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.peerNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .snapshots()
        .listen((doc) {
      if (doc.data() != null && doc.data()!.containsKey(widget.currentUserNo)) {
        if (doc.data()![widget.currentUserNo] == 0) {
          hasPeerBlockedMe = true;
          setStateIfMounted(() {});
        } else if (doc.data()![widget.currentUserNo] == 3) {
          hasPeerBlockedMe = false;
          setStateIfMounted(() {});
        }
      } else {
        hasPeerBlockedMe = false;
        setStateIfMounted(() {});
      }
    });
  }

  updateLocalUserData(model) {
    peer = model.userData[peerNo];
    currentUser = _cachedModel.currentUser;
    if (currentUser != null && peer != null) {
      hidden = currentUser![Dbkeys.hidden] != null &&
          currentUser![Dbkeys.hidden].contains(peerNo);
      locked = currentUser![Dbkeys.locked] != null &&
          currentUser![Dbkeys.locked].contains(peerNo);
      chatStatus = peer![Dbkeys.chatStatus];
      peerAvatar = peer![Dbkeys.photoUrl];
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    setLastSeen();
    // audioPlayer.stop();
    msgSubscription?.cancel();

    chatStatusSubscriptionForPeer?.cancel();
    seenSubscription?.cancel();
    deleteUptoSubscription?.cancel();
  }

  void setLastSeen() async {
    if (chatStatus != ChatStatus.blocked.index) {
      if (chatId != null) {
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .set({'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
                SetOptions(merge: true));
        setStatusBarColor();
        if (typing == true) {
          FirebaseFirestore.instance
              .collection(DbPaths.collectionusers)
              .doc(currentUserNo)
              .set({Dbkeys.lastSeen: true}, SetOptions(merge: true));
        }
      }
    }
  }

  dynamic encryptWithCRC(String input) {
    try {
      String encrypted = cryptor.encrypt(input, iv: iv).base64;
      int crc = CRC32.compute(input);
      return '$encrypted${Dbkeys.crcSeperator}$crc';
    } catch (e) {
      Fiberchat.toast(
        getTranslated(this.context, 'waitingpeer'),
      );
      return false;
    }
  }

  String decryptWithCRC(String input) {
    try {
      if (input.contains(Dbkeys.crcSeperator)) {
        int idx = input.lastIndexOf(Dbkeys.crcSeperator);
        String msgPart = input.substring(0, idx);
        String crcPart = input.substring(idx + 1);
        int? crc = int.tryParse(crcPart);

        if (crc != null) {
          msgPart =
              cryptor.decrypt(encrypt.Encrypted.fromBase64(msgPart), iv: iv);
          if (CRC32.compute(msgPart) == crc) return msgPart;
        }
      }
    } catch (e) {
      return '';
    }
    // Fiberchat.toast(getTranslated(this.context, 'msgnotload'));
    return '';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed)
      setIsActive();
    else
      setLastSeen();
  }

  void setIsActive() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .set({
      '$currentUserNo': true,
      '$currentUserNo-lastOnline': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  dynamic lastSeen;

  FlutterSecureStorage storage = new FlutterSecureStorage();
  late encrypt.Encrypter cryptor;
  final iv = encrypt.IV.fromLength(8);

  readLocal(
    BuildContext context,
  ) async {
    try {
      privateKey = await storage.read(key: Dbkeys.privateKey);
      sharedSecret = (await e2ee.X25519().calculateSharedSecret(
              e2ee.Key.fromBase64(privateKey!, false),
              e2ee.Key.fromBase64(peer![Dbkeys.publicKey], true)))
          .toBase64();

      final key = encrypt.Key.fromBase64(sharedSecret!);
      cryptor = new encrypt.Encrypter(encrypt.Salsa20(key));
    } catch (e) {
      sharedSecret = null;
    }
    try {
      seenState!.value = widget.prefs.getInt(getLastSeenKey());
    } catch (e) {
      seenState!.value = false;
    }
    chatId = Fiberchat.getChatId(currentUserNo!, peerNo!);
    textEditingController.addListener(() {
      if (textEditingController.text.isNotEmpty && typing == false) {
        lastSeen = peerNo;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .set({Dbkeys.lastSeen: peerNo}, SetOptions(merge: true));
        typing = true;
      }
      if (textEditingController.text.isEmpty && typing == true) {
        lastSeen = true;
        FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(currentUserNo)
            .set({Dbkeys.lastSeen: true}, SetOptions(merge: true));
        typing = false;
      }
    });
    setIsActive();
    seenSubscription = FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        setStateIfMounted(() {
          isDeletedDoc = false;
          isPeerMuted = doc.data()!.containsKey("$peerNo-muted")
              ? doc.data()!["$peerNo-muted"]
              : false;

          isCurrentUserMuted = doc.data()!.containsKey("$currentUserNo-muted")
              ? doc.data()!["$currentUserNo-muted"]
              : false;
        });

        if (mounted && doc.data()!.containsKey(peerNo)) {
          seenState!.value = doc[peerNo!] ?? false;
          if (seenState!.value is int) {
            widget.prefs.setInt(getLastSeenKey(), seenState!.value);
          }
          if (doc.data()!.containsKey("${peerNo!}-lastOnline")) {
            int lastOnline = doc.data()!["${peerNo!}-lastOnline"];
            if (doc.data()!["${peerNo!}"] == true &&
                DateTime.now()
                        .difference(
                            DateTime.fromMillisecondsSinceEpoch(lastOnline))
                        .inMinutes >
                    20) {
              doc.reference
                  .set({"${peerNo!}": lastOnline}, SetOptions(merge: true));
            }
          }
        }
      } else {
        setStateIfMounted(() {
          isDeletedDoc = true;
        });
      }
    });
    loadMessagesAndListen();
  }

  String getLastSeenKey() {
    return "$peerNo-${Dbkeys.lastSeen}";
  }

  int? thumnailtimestamp;
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

  getThumbnail(String url) async {
    final observer = Provider.of<Observer>(this.context, listen: false);
    // ignore: unnecessary_null_comparison
    setStateIfMounted(() {
      isgeneratingSomethingLoader = true;
    });
    // IsRequirefocus;
    // String? path = await VideoThumbnail.thumbnailFile(
    //     video: url,
    //     thumbnailPath: (await getTemporaryDirectory()).path,
    //     imageFormat: ImageFormat.PNG,
    //     quality: 30);

    // thumbnailFile = File(path!);

    setStateIfMounted(() {
      isgeneratingSomethingLoader = false;
    });

    return observer.isPercentProgressShowWhileUploading
        ? uploadFileWithProgressIndicator(true)
        : uploadFile(true);
  }

  getWallpaper(File image) {
    // ignore: unnecessary_null_comparison
    if (image != null) {
      _cachedModel.setWallpaper(peerNo, image);
    }
    return Future.value(false);
  }

  String? videometadata;
  Future uploadFile(bool isthumbnail, {int? timestamp}) async {
    uploadTimestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    String fileName = getFileName(
        currentUserNo,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    TaskSnapshot uploading = await reference
        .putFile(isthumbnail == true ? thumbnailFile : pickedFile!);
    if (isthumbnail == false) {
      setStateIfMounted(() {
        thumnailtimestamp = uploadTimestamp;
      });
    }
    if (isthumbnail == true) {
      // IsRequirefocus;
      // MediaInfo _mediaInfo = MediaInfo();

      // await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
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
          .doc(widget.currentUserNo)
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
    File fileToCompress;
    File? compressedImage;
    String fileName = getFileName(
        currentUserNo,
        isthumbnail == false
            ? '$uploadTimestamp'
            : '${thumnailtimestamp}Thumbnail');
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);
    if (isthumbnail == false && isVideo(pickedFile!.path) == true) {
      fileToCompress = File(pickedFile!.path);
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
      pickedFile = fileToCompress;
    } else if (isthumbnail == false && isImage(pickedFile!.path) == true) {
      compressedImage = pickedFile;
    } else {}

    UploadTask uploading = reference.putFile(isthumbnail == true
        ? thumbnailFile
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
                  key: _keyLoader34,
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

      // await _mediaInfo.getMediaInfo(thumbnailFile.path).then((mediaInfo) {
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
          .doc(widget.currentUserNo)
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
    Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
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

  void onSendMessage(
      BuildContext context, String content, MessageType type, int? timestamp,
      {bool isForward = false}) async {
    if (content.trim() != '' && chatId != '') {
      String tempcontent = "";
      try {
        content = content.trim();
        tempcontent = content.trim();
        if (chatStatus == null || chatStatus == 4)
          ChatController.request(currentUserNo, peerNo, chatId);
        textEditingController.clear();
        final encrypted = AESEncryptData.encryptAES(content, sharedSecret);

        // final encrypted = encryptWithCRC(content);
        if (encrypted is String) {
          Future messaging = FirebaseFirestore.instance
              .collection(DbPaths.collectionmessages)
              .doc(chatId)
              .collection(chatId!)
              .doc('$timestamp')
              .set({
            Dbkeys.isMuted: isPeerMuted,
            Dbkeys.from: currentUserNo,
            Dbkeys.to: peerNo,
            Dbkeys.timestamp: timestamp,
            Dbkeys.content: encrypted,
            Dbkeys.messageType: type.index,
            Dbkeys.hasSenderDeleted: false,
            Dbkeys.hasRecipientDeleted: false,
            Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
            Dbkeys.isReply: isReplyKeyboard,
            Dbkeys.replyToMsgDoc: replyDoc,
            Dbkeys.isForward: isForward,
            Dbkeys.latestEncrypted: true,
          }, SetOptions(merge: true));

          _cachedModel.addMessage(peerNo, timestamp, messaging);
          var tempDoc = {
            Dbkeys.isMuted: isPeerMuted,
            Dbkeys.from: currentUserNo,
            Dbkeys.to: peerNo,
            Dbkeys.timestamp: timestamp,
            Dbkeys.content: content,
            Dbkeys.messageType: type.index,
            Dbkeys.hasSenderDeleted: false,
            Dbkeys.hasRecipientDeleted: false,
            Dbkeys.sendername: _cachedModel.currentUser![Dbkeys.nickname],
            Dbkeys.isReply: isReplyKeyboard,
            Dbkeys.replyToMsgDoc: replyDoc,
            Dbkeys.isForward: isForward,
            Dbkeys.latestEncrypted: true,
            Dbkeys.tempcontent: tempcontent,
          };
          setStatusBarColor();
          setStateIfMounted(() {
            isReplyKeyboard = false;
            replyDoc = null;
            messages = List.from(messages)
              ..add(Message(
                buildMessage(this.context, tempDoc),
                onTap: (tempDoc[Dbkeys.from] == widget.currentUserNo &&
                            tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                        true
                    ? () {}
                    : type == MessageType.image
                        ? () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhotoViewWrapper(
                                    keyloader: _keyLoader34,
                                    imageUrl: content,
                                    message: content,
                                    tag: timestamp.toString(),
                                  ),
                                ));
                          }
                        : null,
                onDismiss: tempDoc[Dbkeys.content] == '' ||
                        tempDoc[Dbkeys.content] == null
                    ? () {}
                    : () {
                        setStateIfMounted(() {
                          isReplyKeyboard = true;
                          replyDoc = tempDoc;
                        });
                        HapticFeedback.heavyImpact();
                        keyboardFocusNode.requestFocus();
                      },
                onDoubleTap: () {
                  // save(tempDoc);
                },
                onLongPress: () {
                  if (tempDoc.containsKey(Dbkeys.hasRecipientDeleted) &&
                      tempDoc.containsKey(Dbkeys.hasSenderDeleted)) {
                    if ((tempDoc[Dbkeys.from] == widget.currentUserNo &&
                            tempDoc[Dbkeys.hasSenderDeleted] == true) ==
                        false) {
                      //--Show Menu only if message is not deleted by current user already
                      contextMenuNew(tempDoc, true);
                    }
                  } else {
                    contextMenuOld(context, tempDoc);
                  }
                },
                from: currentUserNo,
                timestamp: timestamp,
              ));
          });

          unawaited(realtime.animateTo(0.0,
              duration: Duration(milliseconds: 300), curve: Curves.easeOut));

          // _playPopSound();
        } else {
          Fiberchat.toast('Nothing to encrypt');
        }
      } on Exception catch (_) {
        // print('Exception caught!');
        Fiberchat.toast("Exception: $_");
      }
    }
  }

  delete(int? ts) {
    setStateIfMounted(() {
      messages.removeWhere((msg) => msg.timestamp == ts);
      messages = List.from(messages);
    });
  }

  updateDeleteBySenderField(int? ts, updateDoc, context) {
    setStateIfMounted(() {
      int i = messages.indexWhere((msg) => msg.timestamp == ts);
      var child = buildMessage(context, updateDoc);
      var timestamp = messages[i].timestamp;
      var from = messages[i].from;
      // var onTap = messages[i].onTap;
      var onDoubleTap = messages[i].onDoubleTap;
      var onDismiss = messages[i].onDismiss;
      var onLongPress = () {};
      if (i >= 0) {
        messages.removeWhere((msg) => msg.timestamp == ts);
        messages.insert(
            i,
            Message(child,
                timestamp: timestamp,
                from: from,
                onTap: () {},
                onDoubleTap: onDoubleTap,
                onDismiss: onDismiss,
                onLongPress: onLongPress));
      }
      messages = List.from(messages);
    });
  }

  contextMenuForSavedMessage(
    BuildContext context,
    Map<String, dynamic> doc,
  ) {
    List<Widget> tiles = List.from(<Widget>[]);
    tiles.add(ListTile(
        dense: true,
        leading: Icon(Icons.delete_outline),
        title: Text(
          getTranslated(this.context, 'delete'),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        onTap: () async {
          Save.deleteMessage(peerNo, doc);
          _savedMessageDocs.removeWhere(
              (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
          setStateIfMounted(() {
            _savedMessageDocs = List.from(_savedMessageDocs);
          });
          Navigator.pop(context);
        }));
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  //-- New context menu with Delete for Me & Delete For Everyone feature
  contextMenuNew(Map<String, dynamic> mssgDoc, bool isTemp,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    //####################----------------------- Delete Msgs for SENDER ---------------------------------------------------
    if ((mssgDoc[Dbkeys.from] == currentUserNo &&
            mssgDoc[Dbkeys.hasSenderDeleted] == false) &&
        saved == false) {
      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline),
              title: Text(
                getTranslated(context, 'dltforme'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Fiberchat.toast(getTranslated(context, 'deleting'));
                Navigator.of(
                  context,
                ).pop();
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId!)
                    .doc('${mssgDoc[Dbkeys.timestamp]}')
                    .get()
                    .then((chatDoc) async {
                  if (!chatDoc.exists) {
                    Fiberchat.toast('Please reload this screen !');
                  } else if (chatDoc.exists) {
                    Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                    if (realtimeDoc[Dbkeys.hasRecipientDeleted] == true) {
                      if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                              ? mssgDoc[Dbkeys.isbroadcast]
                              : false) ==
                          true) {
                        // -------Delete broadcast message completely as recipient has already deleted
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs.removeWhere((msg) =>
                            msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });

                        Fiberchat.toast(
                          getTranslated(this.context, 'deleted'),
                        );
                        hidekeyboard(
                          this.context,
                        );
                      } else {
                        // -------Delete message completely as recipient has already deleted
                        await deleteMsgMedia(realtimeDoc, chatId!)
                            .then((isDeleted) async {
                          if (isDeleted == false || isDeleted == null) {
                            Fiberchat.toast(
                                'Could not delete. Please try again!');
                          } else {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${realtimeDoc[Dbkeys.timestamp]}')
                                .delete();
                            delete(realtimeDoc[Dbkeys.timestamp]);
                            Save.deleteMessage(peerNo, realtimeDoc);
                            _savedMessageDocs.removeWhere((msg) =>
                                msg[Dbkeys.timestamp] ==
                                mssgDoc[Dbkeys.timestamp]);
                            setStateIfMounted(() {
                              _savedMessageDocs = List.from(_savedMessageDocs);
                            });

                            Fiberchat.toast(
                              getTranslated(this.context, 'deleted'),
                            );
                            hidekeyboard(this.context);
                          }
                        });
                      }
                    } else {
                      //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${realtimeDoc[Dbkeys.timestamp]}')
                          .set({Dbkeys.hasSenderDeleted: true},
                              SetOptions(merge: true));

                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });

                      Map<String, dynamic> tempDoc = realtimeDoc;
                      setStateIfMounted(() {
                        tempDoc[Dbkeys.hasSenderDeleted] = true;
                      });
                      updateDeleteBySenderField(
                          realtimeDoc[Dbkeys.timestamp], tempDoc, this.context);

                      Fiberchat.toast(
                        getTranslated(this.context, 'deleted'),
                      );
                      hidekeyboard(this.context);
                    }
                  }
                });
              })));

      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(Icons.delete),
              title: Text(
                getTranslated(context, 'dltforeveryone'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                        ? mssgDoc[Dbkeys.isbroadcast]
                        : false) ==
                    true) {
                  // -------Delete broadcast message completely for everyone
                  await FirebaseFirestore.instance
                      .collection(DbPaths.collectionmessages)
                      .doc(chatId)
                      .collection(chatId!)
                      .doc('${mssgDoc[Dbkeys.timestamp]}')
                      .delete();
                  delete(mssgDoc[Dbkeys.timestamp]);
                  Save.deleteMessage(peerNo, mssgDoc);
                  _savedMessageDocs.removeWhere((msg) =>
                      msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                  setStateIfMounted(() {
                    _savedMessageDocs = List.from(_savedMessageDocs);
                  });

                  Fiberchat.toast(
                    getTranslated(this.context, 'deleted'),
                  );
                  hidekeyboard(this.context);
                } else {
                  // -------Delete message completely for everyone
                  Fiberchat.toast(
                    getTranslated(this.context, 'deleting'),
                  );
                  await deleteMsgMedia(mssgDoc, chatId!)
                      .then((isDeleted) async {
                    if (isDeleted == false || isDeleted == null) {
                      Fiberchat.toast('Could not delete. Please try again!');
                    } else {
                      await FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${mssgDoc[Dbkeys.timestamp]}')
                          .delete();
                      delete(mssgDoc[Dbkeys.timestamp]);
                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });

                      Fiberchat.toast(
                        getTranslated(this.context, 'deleted'),
                      );
                      hidekeyboard(this.context);
                    }
                  });
                }
              })));
    }
    //####################-------------------- Delete Msgs for RECIPIENTS---------------------------------------------------
    if ((mssgDoc[Dbkeys.to] == currentUserNo &&
            mssgDoc[Dbkeys.hasRecipientDeleted] == false) &&
        saved == false) {
      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(Icons.delete_outline),
              title: Text(
                getTranslated(context, 'dltforme'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Fiberchat.toast(
                  getTranslated(context, 'deleting'),
                );
                Navigator.of(context).pop();
                await FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId!)
                    .doc('${mssgDoc[Dbkeys.timestamp]}')
                    .get()
                    .then((chatDoc) async {
                  if (!chatDoc.exists) {
                    Fiberchat.toast('Please reload this screen !');
                  } else if (chatDoc.exists) {
                    Map<String, dynamic> realtimeDoc = chatDoc.data()!;
                    if (realtimeDoc[Dbkeys.hasSenderDeleted] == true) {
                      if ((mssgDoc.containsKey(Dbkeys.isbroadcast) == true
                              ? mssgDoc[Dbkeys.isbroadcast]
                              : false) ==
                          true) {
                        // -------Delete broadcast message completely as sender has already deleted
                        await FirebaseFirestore.instance
                            .collection(DbPaths.collectionmessages)
                            .doc(chatId)
                            .collection(chatId!)
                            .doc('${realtimeDoc[Dbkeys.timestamp]}')
                            .delete();
                        delete(realtimeDoc[Dbkeys.timestamp]);
                        Save.deleteMessage(peerNo, realtimeDoc);
                        _savedMessageDocs.removeWhere((msg) =>
                            msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                        setStateIfMounted(() {
                          _savedMessageDocs = List.from(_savedMessageDocs);
                        });

                        Fiberchat.toast(
                          getTranslated(this.context, 'deleted'),
                        );
                        hidekeyboard(this.context);
                      } else {
                        // -------Delete message completely as sender has already deleted
                        await deleteMsgMedia(realtimeDoc, chatId!)
                            .then((isDeleted) async {
                          if (isDeleted == false || isDeleted == null) {
                            Fiberchat.toast(
                                'Could not delete. Please try again!');
                          } else {
                            await FirebaseFirestore.instance
                                .collection(DbPaths.collectionmessages)
                                .doc(chatId)
                                .collection(chatId!)
                                .doc('${realtimeDoc[Dbkeys.timestamp]}')
                                .delete();
                            delete(realtimeDoc[Dbkeys.timestamp]);
                            Save.deleteMessage(peerNo, realtimeDoc);
                            _savedMessageDocs.removeWhere((msg) =>
                                msg[Dbkeys.timestamp] ==
                                mssgDoc[Dbkeys.timestamp]);
                            setStateIfMounted(() {
                              _savedMessageDocs = List.from(_savedMessageDocs);
                            });

                            Fiberchat.toast(
                              getTranslated(this.context, 'deleted'),
                            );
                            hidekeyboard(this.context);
                          }
                        });
                      }
                    } else {
                      //----Don't Delete Media from server, as recipient has not deleted the message from thier message list-----
                      FirebaseFirestore.instance
                          .collection(DbPaths.collectionmessages)
                          .doc(chatId)
                          .collection(chatId!)
                          .doc('${realtimeDoc[Dbkeys.timestamp]}')
                          .set({Dbkeys.hasRecipientDeleted: true},
                              SetOptions(merge: true));

                      Save.deleteMessage(peerNo, mssgDoc);
                      _savedMessageDocs.removeWhere((msg) =>
                          msg[Dbkeys.timestamp] == mssgDoc[Dbkeys.timestamp]);
                      setStateIfMounted(() {
                        _savedMessageDocs = List.from(_savedMessageDocs);
                      });
                      if (isTemp == true) {
                        Map<String, dynamic> tempDoc = realtimeDoc;
                        setStateIfMounted(() {
                          tempDoc[Dbkeys.hasRecipientDeleted] = true;
                        });
                        updateDeleteBySenderField(realtimeDoc[Dbkeys.timestamp],
                            tempDoc, this.context);
                      }

                      Fiberchat.toast(
                        getTranslated(this.context, 'deleted'),
                      );
                      hidekeyboard(this.context);
                    }
                  }
                });
              })));
    }
    if (mssgDoc.containsKey(Dbkeys.broadcastID) &&
        mssgDoc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(Icons.block),
              title: Text(
                getTranslated(context, 'blockbroadcast'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Fiberchat.toast(
                  getTranslated(context, 'plswait'),
                );
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 200), () {
                  FirebaseFirestore.instance
                      .collection(DbPaths.collectionbroadcasts)
                      .doc(mssgDoc[Dbkeys.broadcastID])
                      .set({
                    Dbkeys.broadcastMEMBERSLIST:
                        FieldValue.arrayRemove([widget.currentUserNo]),
                    Dbkeys.broadcastBLACKLISTED:
                        FieldValue.arrayUnion([widget.currentUserNo]),
                  }, SetOptions(merge: true)).then((value) {
                    hidekeyboard(this.context);
                    Fiberchat.toast(
                      getTranslated(this.context, 'blockedbroadcast'),
                    );
                  }).catchError((error) {
                    Fiberchat.toast("Error 45638: $error");
                    hidekeyboard(this.context);
                  });
                });
              })));
    }

    //####################--------------------- ALL BELOW DIALOG TILES FOR COMMON SENDER & RECIPIENT-------------------------###########################------------------------------
    // if (((mssgDoc[Dbkeys.from] == currentUserNo &&
    //             mssgDoc[Dbkeys.hasSenderDeleted] == false) ||
    //         (mssgDoc[Dbkeys.to] == currentUserNo &&
    //             mssgDoc[Dbkeys.hasRecipientDeleted] == false)) &&
    //     saved == false) {
    //   tiles.add(ListTile(
    //       dense: true,
    //       leading: Icon(Icons.save_outlined),
    //       title: Text(
    //         getTranslated(contextForDialog, 'save'),
    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //       ),
    //       onTap: () {
    //         save(mssgDoc);
    //         hidekeyboard(contextForDialog);
    //         Navigator.pop(contextForDialog);
    //       }));
    // }
    if (mssgDoc[Dbkeys.messageType] == MessageType.text.index &&
        !mssgDoc.containsKey(Dbkeys.broadcastID)) {
      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(Icons.content_copy),
              title: Text(
                getTranslated(context, 'copy'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.of(context).pop();

                Clipboard.setData(ClipboardData(text: mssgDoc[Dbkeys.content]));

                hidekeyboard(this.context);
                Fiberchat.toast(
                  getTranslated(this.context, 'copied'),
                );
              })));
    }
    if (((mssgDoc[Dbkeys.from] == currentUserNo &&
                mssgDoc[Dbkeys.hasSenderDeleted] == false) ||
            (mssgDoc[Dbkeys.to] == currentUserNo &&
                mssgDoc[Dbkeys.hasRecipientDeleted] == false)) ==
        true) {
      tiles.add(Builder(
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(FontAwesomeIcons.share, size: 22),
              title: Text(
                getTranslated(context, 'forward'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                Navigator.push(
                    this.context,
                    MaterialPageRoute(
                        builder: (contextForDialog) => SelectContactsToForward(
                            contentPeerNo: peerNo!,
                            messageOwnerPhone: widget.peerNo!,
                            currentUserNo: widget.currentUserNo,
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
          builder: (BuildContext context) => ListTile(
              dense: true,
              leading: Icon(FontAwesomeIcons.reply, size: 22),
              title: Text(
                getTranslated(context, 'reply'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                setStateIfMounted(() {
                  isReplyKeyboard = true;
                  replyDoc = mssgDoc;
                });
                HapticFeedback.heavyImpact();
                keyboardFocusNode.requestFocus();
              })));
    }

    showDialog(
        context: this.context,
        builder: (contextForDialog) {
          return SimpleDialog(children: tiles);
        });
  }

  sendForwardMessageEach(
      int index, List<dynamic> list, String privateKey, var mssgDoc) async {
    if (index >= list.length) {
      setStateIfMounted(() {
        isgeneratingSomethingLoader = false;
        if (widget.isWideScreenMode == false) {
          Navigator.of(this.context).pop();
        }
      });
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
              .doc(timestamp.toString() + '--' + widget.currentUserNo!)
              .set({
            Dbkeys.groupmsgCONTENT: mssgDoc[Dbkeys.content],
            Dbkeys.groupmsgISDELETED: false,
            Dbkeys.groupmsgLISToptional: [],
            Dbkeys.groupmsgTIME: timestamp,
            Dbkeys.groupmsgSENDBY: widget.currentUserNo!,
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
          Fiberchat.toast('Failed to send $e');
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
          // final encrypted = encryptWithCRC(content);
          final encrypted = AESEncryptData.encryptAES(content, sharedSecret);

          if (encrypted is String) {
            int timestamp2 = DateTime.now().millisecondsSinceEpoch;
            var chatId = Fiberchat.getChatId(
                widget.currentUserNo!, list[index][Dbkeys.phone]);
            if (content.trim() != '') {
              Map<String, dynamic>? targetPeer =
                  widget.model.userData[list[index][Dbkeys.phone]];
              if (targetPeer == null) {
                await ChatController.request(
                    currentUserNo,
                    list[index][Dbkeys.phone],
                    Fiberchat.getChatId(
                        widget.currentUserNo!, list[index][Dbkeys.phone]));
              }

              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set({
                widget.currentUserNo!: true,
                list[index][Dbkeys.phone]: list[index][Dbkeys.lastSeen],
              }, SetOptions(merge: true)).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionusers)
                    .doc(list[index][Dbkeys.phone])
                    .collection(Dbkeys.chatsWith)
                    .doc(Dbkeys.chatsWith)
                    .set({
                  widget.currentUserNo!: 4,
                }, SetOptions(merge: true));
                await widget.model.addMessage(
                    list[index][Dbkeys.phone], timestamp2, messaging);
              }).then((value) async {
                Future messaging = FirebaseFirestore.instance
                    .collection(DbPaths.collectionmessages)
                    .doc(chatId)
                    .collection(chatId)
                    .doc('$timestamp2')
                    .set({
                  Dbkeys.isMuted: isPeerMuted,
                  Dbkeys.latestEncrypted: true,
                  Dbkeys.from: widget.currentUserNo!,
                  Dbkeys.to: list[index][Dbkeys.phone],
                  Dbkeys.timestamp: timestamp2,
                  Dbkeys.content: encrypted,
                  Dbkeys.messageType: mssgDoc[Dbkeys.messageType],
                  Dbkeys.hasSenderDeleted: false,
                  Dbkeys.hasRecipientDeleted: false,
                  Dbkeys.sendername: widget.model.currentUser![Dbkeys.nickname],
                  Dbkeys.isReply: false,
                  Dbkeys.replyToMsgDoc: null,
                  Dbkeys.isForward: true
                }, SetOptions(merge: true));
                await widget.model.addMessage(
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

  contextMenuOld(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false}) {
    List<Widget> tiles = List.from(<Widget>[]);
    // if (saved == false && !doc.containsKey(Dbkeys.broadcastID)) {
    //   tiles.add(ListTile(
    //       dense: true,
    //       leading: Icon(Icons.save_outlined),
    //       title: Text(
    //         getTranslated(this.context, 'save'),
    //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    //       ),
    //       onTap: () {
    //         save(doc);
    //         hidekeyboard(context);
    //         Navigator.pop(context);
    //       }));
    // }
    if ((doc[Dbkeys.from] != currentUserNo) && saved == false) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.delete),
          title: Text(
            getTranslated(this.context, 'dltforme'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () async {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionmessages)
                .doc(chatId)
                .collection(chatId!)
                .doc('${doc[Dbkeys.timestamp]}')
                .set({Dbkeys.hasRecipientDeleted: true},
                    SetOptions(merge: true));
            Save.deleteMessage(peerNo, doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });

            Future.delayed(const Duration(milliseconds: 300), () {
              Navigator.maybePop(context);
              Fiberchat.toast(
                getTranslated(this.context, 'deleted'),
              );
            });
          }));
    }

    if (doc[Dbkeys.messageType] == MessageType.text.index) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.content_copy),
          title: Text(
            getTranslated(context, 'copy'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: doc[Dbkeys.content]));
            Navigator.pop(context);
            Fiberchat.toast(
              getTranslated(this.context, 'copied'),
            );
          }));
    }
    if (doc.containsKey(Dbkeys.broadcastID) &&
        doc[Dbkeys.to] == widget.currentUserNo) {
      tiles.add(ListTile(
          dense: true,
          leading: Icon(Icons.block),
          title: Text(
            getTranslated(this.context, 'blockbroadcast'),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Fiberchat.toast(
              getTranslated(this.context, 'plswait'),
            );
            Future.delayed(const Duration(milliseconds: 500), () {
              FirebaseFirestore.instance
                  .collection(DbPaths.collectionbroadcasts)
                  .doc(doc[Dbkeys.broadcastID])
                  .set({
                Dbkeys.broadcastMEMBERSLIST:
                    FieldValue.arrayRemove([widget.currentUserNo]),
                Dbkeys.broadcastBLACKLISTED:
                    FieldValue.arrayUnion([widget.currentUserNo]),
              }, SetOptions(merge: true)).then((value) {
                Fiberchat.toast(
                  getTranslated(this.context, 'blockedbroadcast'),
                );
                hidekeyboard(context);
                Navigator.pop(context);
              }).catchError((error) {
                Fiberchat.toast(
                  getTranslated(this.context, 'blockedbroadcast'),
                );
                Navigator.pop(context);
                hidekeyboard(context);
              });
            });
          }));
    }
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(children: tiles);
        });
  }

  save(Map<String, dynamic> doc) async {
    Fiberchat.toast(
      getTranslated(this.context, 'saved'),
    );
    if (!_savedMessageDocs
        .any((_doc) => _doc[Dbkeys.timestamp] == doc[Dbkeys.timestamp])) {
      String? content;
      if (doc[Dbkeys.messageType] == MessageType.image.index) {
        content = doc[Dbkeys.content].toString().startsWith('http')
            ? await Save.getBase64FromImage(
                imageUrl: doc[Dbkeys.content] as String?)
            : doc[Dbkeys
                .content]; // if not a url, it is a base64 from saved messages
      } else {
        // If text
        content = doc[Dbkeys.content];
      }
      doc[Dbkeys.content] = content;
      Save.saveMessage(peerNo, doc);
      _savedMessageDocs.add(doc);
      setStateIfMounted(() {
        _savedMessageDocs = List.from(_savedMessageDocs);
      });
    }
  }

  Widget selectablelinkify(String? text, double? fontsize) {
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
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text!,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            errorWidget: SelectableLinkify(
              style: TextStyle(fontSize: fontsize, color: Colors.black87),
              text: text,
              onOpen: (link) async {
                custom_url_launcher(link.url);
              },
            ),
            link: text,
            linkPreviewStyle: LinkPreviewStyle.large,
          );
  }
  // Widget selectablelinkify(String? text, double? fontsize) {
  //   return SelectableLinkify(
  //     style: TextStyle(fontSize: fontsize, color: Colors.black87),
  //     text: text ?? "",
  //     onOpen: (link) async {
  //       if (1 == 1) {
  //         await custom_url_launcher(link.url);
  //       } else {
  //         throw 'Could not launch $link';
  //       }
  //     },
  //   );
  // }

  Widget getTextMessage(bool isMe, Map<String, dynamic> doc, bool saved) {
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: isMe == true
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(doc[Dbkeys.content], 16),
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
                          selectablelinkify(doc[Dbkeys.content], 16),
                        ],
                      )
                    : selectablelinkify(doc[Dbkeys.content], 16)
                : selectablelinkify(doc[Dbkeys.content], 16)
        : selectablelinkify(doc[Dbkeys.content], 16);
  }

  Widget getTempTextMessage(
    String message,
    Map<String, dynamic> doc,
  ) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return doc.containsKey(Dbkeys.isReply) == true
        ? doc[Dbkeys.isReply] == true
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  replyAttachedWidget(this.context, doc[Dbkeys.replyToMsgDoc]),
                  SizedBox(
                    height: 10,
                  ),
                  selectablelinkify(message, 16)
                ],
              )
            : doc.containsKey(Dbkeys.isForward) == true
                ? doc[Dbkeys.isForward] == true
                    ? Column(
                        crossAxisAlignment: isMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
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
                          selectablelinkify(message, 16)
                        ],
                      )
                    : selectablelinkify(message, 16)
                : selectablelinkify(message, 16)
        : selectablelinkify(message, 16);
  }

  Widget getLocationMessage(Map<String, dynamic> doc, String? message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
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
                    )
                  ],
                )
              : Image.asset(
                  'assets/images/mapview.jpg',
                )
          : Image.asset(
              'assets/images/mapview.jpg',
            ),
    );
  }

  Widget getAudiomessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false, bool isMe = true}) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // width: 250,
      // height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 220,
      height: 116,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return Container(
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
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
                    width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                    height: doc[Dbkeys.content].contains('giphy') ? 102 : 200.0,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                )
              : Image.network(
                  doc[Dbkeys.content],
                  width: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  height: doc[Dbkeys.content].contains('giphy') ? 120 : 200.0,
                  fit: BoxFit.cover,
                ),
        ],
      ),
    );
  }

  Widget getTempImageMessage({String? url}) {
    return url == null
        ? Container(
            child: Image.file(
              pickedFile!,
              width: url!.contains('giphy') ? 120 : 200.0,
              height: url.contains('giphy') ? 120 : 200.0,
              fit: BoxFit.cover,
            ),
          )
        : getImageMessage({Dbkeys.content: url});
  }

  Widget getVideoMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return InkWell(
      onTap: () {},
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
              height: 197,
              width: 197,
              child: Stack(
                children: [
                  Image.network(
                    message.split('-BREAK-')[1],
                    width: 197,
                    height: 197,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    color: Colors.black.withOpacity(0.4),
                    height: 197,
                    width: 197,
                  ),
                  Center(
                    child: Icon(Icons.play_circle,
                        color: Colors.white70, size: 65),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Center(
                      child:
                          Icon(Icons.download, color: Colors.white70, size: 25),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getContactMessage(
      BuildContext context, Map<String, dynamic> doc, String message,
      {bool saved = false}) {
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    return SizedBox(
      width: 250,
      height: 130,
      child: Column(
        crossAxisAlignment:
            isMe == true ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
            leading: customCircleAvatar(url: null),
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
          Divider(
            height: 7,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              onPressed: () async {
                String peer = message.split('-BREAK-')[1];
                String? peerphone;
                bool issearching = true;
                bool issearchraw = false;
                bool isUser = false;
                String? formattedphone;

                setStateIfMounted(() {
                  peerphone = peer.replaceAll(new RegExp(r'-'), '');
                  peerphone!.trim();
                });

                formattedphone = peerphone;

                if (!peerphone!.startsWith('+')) {
                  if ((peerphone!.length > 11)) {
                    CountryCodes.forEach((code) {
                      if (peerphone!.startsWith(code) && issearching == true) {
                        setStateIfMounted(() {
                          formattedphone = peerphone!
                              .substring(code.length, peerphone!.length);
                          issearchraw = true;
                          issearching = false;
                        });
                      }
                    });
                  } else {
                    setStateIfMounted(() {
                      setStateIfMounted(() {
                        issearchraw = true;
                        formattedphone = peerphone;
                      });
                    });
                  }
                } else {
                  setStateIfMounted(() {
                    issearchraw = false;
                    formattedphone = peerphone;
                  });
                }

                Query<Map<String, dynamic>> query = issearchraw == true
                    ? FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .where(Dbkeys.phoneRaw,
                            isEqualTo: formattedphone ?? peerphone)
                        .limit(1)
                    : FirebaseFirestore.instance
                        .collection(DbPaths.collectionusers)
                        .where(Dbkeys.phone,
                            isEqualTo: formattedphone ?? peerphone)
                        .limit(1);

                await query.get().then((user) {
                  setStateIfMounted(() {
                    isUser = user.docs.length == 0 ? false : true;
                  });
                  if (isUser) {
                    Map<String, dynamic> peer = user.docs[0].data();
                    widget.model.addUser(user.docs[0]);
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new ChatScreen(
                                isWideScreenMode: widget.isWideScreenMode,
                                isSharingIntentForwarded: false,
                                prefs: widget.prefs,
                                unread: 0,
                                currentUserNo: widget.currentUserNo,
                                model: widget.model,
                                peerNo: peer[Dbkeys.phone])));
                  } else {
                    Query<Map<String, dynamic>> queryretrywithoutzero =
                        issearchraw == true
                            ? FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .where(Dbkeys.phoneRaw,
                                    isEqualTo: formattedphone == null
                                        ? peerphone!
                                            .substring(1, peerphone!.length)
                                        : formattedphone!.substring(
                                            1, formattedphone!.length))
                                .limit(1)
                            : FirebaseFirestore.instance
                                .collection(DbPaths.collectionusers)
                                .where(Dbkeys.phoneRaw,
                                    isEqualTo: formattedphone == null
                                        ? peerphone!
                                            .substring(1, peerphone!.length)
                                        : formattedphone!.substring(
                                            1, formattedphone!.length))
                                .limit(1);
                    queryretrywithoutzero.get().then((user) {
                      setStateIfMounted(() {
                        // isLoading = false;
                        isUser = user.docs.length == 0 ? false : true;
                      });
                      if (isUser) {
                        Map<String, dynamic> peer = user.docs[0].data();
                        widget.model.addUser(user.docs[0]);
                        Navigator.pushReplacement(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ChatScreen(
                                    isWideScreenMode: widget.isWideScreenMode,
                                    isSharingIntentForwarded: true,
                                    prefs: widget.prefs,
                                    unread: 0,
                                    currentUserNo: widget.currentUserNo,
                                    model: widget.model,
                                    peerNo: peer[Dbkeys.phone])));
                      }
                    });
                  }
                });

                // ignore: unnecessary_null_comparison
                if (isUser == null || isUser == false) {
                  Fiberchat.toast(getTranslated(this.context, 'usernotjoined') +
                      ' $Appname');
                }
              },
              child: Text(getTranslated(this.context, 'msg'),
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: Colors.blue[400])))
        ],
      ),
    );
  }

  _onBackspacePressed() {
    textEditingController
      ..text = textEditingController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: textEditingController.text.length));
  }

  Widget buildMessage(BuildContext context, Map<String, dynamic> doc,
      {bool saved = false, List<Message>? savedMsgs}) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    final bool isMe = doc[Dbkeys.from] == currentUserNo;
    bool isContinuing;
    if (savedMsgs == null)
      isContinuing =
          messages.isNotEmpty ? messages.last.from == doc[Dbkeys.from] : false;
    else {
      isContinuing = savedMsgs.isNotEmpty
          ? savedMsgs.last.from == doc[Dbkeys.from]
          : false;
    }
    bool isContainURL = false;
    try {
      isContainURL = Uri.tryParse(doc[Dbkeys.content]!) == null
          ? false
          : Uri.tryParse(doc[Dbkeys.content]!)!.isAbsolute;
    } on Exception catch (_) {
      isContainURL = false;
    }
    return SeenProvider(
        timestamp: doc[Dbkeys.timestamp].toString(),
        data: seenState,
        child: Bubble(
            isWideScreenMode: widget.isWideScreenMode,
            isURLtext: doc[Dbkeys.messageType] == MessageType.text.index &&
                isContainURL == true,
            mssgDoc: doc,
            is24hrsFormat: observer.is24hrsTimeformat,
            isMssgDeleted: (doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    doc.containsKey(Dbkeys.hasSenderDeleted))
                ? isMe
                    ? (doc[Dbkeys.from] == widget.currentUserNo
                        ? doc[Dbkeys.hasSenderDeleted]
                        : false)
                    : (doc[Dbkeys.from] != widget.currentUserNo
                        ? doc[Dbkeys.hasRecipientDeleted]
                        : false)
                : false,
            isBroadcastMssg: doc.containsKey(Dbkeys.isbroadcast) == true
                ? doc[Dbkeys.isbroadcast]
                : false,
            messagetype: doc[Dbkeys.messageType] == MessageType.text.index
                ? MessageType.text
                : doc[Dbkeys.messageType] == MessageType.contact.index
                    ? MessageType.contact
                    : doc[Dbkeys.messageType] == MessageType.location.index
                        ? MessageType.location
                        : doc[Dbkeys.messageType] == MessageType.image.index
                            ? MessageType.image
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? MessageType.video
                                : doc[Dbkeys.messageType] ==
                                        MessageType.doc.index
                                    ? MessageType.doc
                                    : doc[Dbkeys.messageType] ==
                                            MessageType.audio.index
                                        ? MessageType.audio
                                        : MessageType.text,
            child: doc[Dbkeys.messageType] == MessageType.text.index
                ? getTextMessage(isMe, doc, saved)
                : doc[Dbkeys.messageType] == MessageType.location.index
                    ? getLocationMessage(doc, doc[Dbkeys.content], saved: false)
                    : doc[Dbkeys.messageType] == MessageType.doc.index
                        ? getDocmessage(context, doc, doc[Dbkeys.content],
                            saved: false)
                        : doc[Dbkeys.messageType] == MessageType.audio.index
                            ? getAudiomessage(context, doc, doc[Dbkeys.content],
                                isMe: isMe, saved: false)
                            : doc[Dbkeys.messageType] == MessageType.video.index
                                ? getVideoMessage(
                                    context, doc, doc[Dbkeys.content],
                                    saved: false)
                                : doc[Dbkeys.messageType] ==
                                        MessageType.contact.index
                                    ? getContactMessage(
                                        context, doc, doc[Dbkeys.content],
                                        saved: false)
                                    : getImageMessage(
                                        doc,
                                        saved: saved,
                                      ),
            isMe: isMe,
            timestamp: doc[Dbkeys.timestamp],
            delivered:
                _cachedModel.getMessageStatus(peerNo, doc[Dbkeys.timestamp]),
            isContinuing: isContinuing));
  }

  replyAttachedWidget(BuildContext context, var doc) {
    return Flexible(
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
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: Row(children: [
                    Container(
                      decoration: BoxDecoration(
                        color: doc[Dbkeys.from] == currentUserNo
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
                              doc[Dbkeys.from] == currentUserNo
                                  ? getTranslated(this.context, 'you')
                                  : Fiberchat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: doc[Dbkeys.from] == currentUserNo
                                      ? fiberchatPRIMARYcolor
                                      : Colors.purple),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          doc[Dbkeys.messageType] == MessageType.text.index
                              ? Text(
                                  doc[Dbkeys.content],
                                  overflow: TextOverflow.ellipsis,
                                  // textAlign:  doc[Dbkeys.from] == currentUserNo? TextAlign.end: TextAlign.start,
                                  maxLines: 1,
                                )
                              : doc[Dbkeys.messageType] == MessageType.doc.index
                                  ? Container(
                                      padding: const EdgeInsets.only(right: 70),
                                      child: Text(
                                        doc[Dbkeys.content].split('-BREAK-')[1],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    )
                                  : Text(
                                      getTranslated(
                                          this.context,
                                          doc[Dbkeys.messageType] ==
                                                  MessageType.image.index
                                              ? 'nim'
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.video.index
                                                  ? 'nvm'
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .audio.index
                                                      ? 'nam'
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? 'ncm'
                                                          : doc[Dbkeys.messageType] ==
                                                                  MessageType
                                                                      .location
                                                                      .index
                                                              ? 'nlm'
                                                              : doc[Dbkeys.messageType] ==
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
              doc[Dbkeys.messageType] == MessageType.text.index ||
                      doc[Dbkeys.messageType] == MessageType.location.index
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
                      : doc[Dbkeys.messageType] == MessageType.video.index
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
                                              color:
                                                  Colors.black.withOpacity(0.4),
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
                                          bottomRight: Radius.circular(5),
                                          topLeft: Radius.circular(0),
                                          bottomLeft: Radius.circular(0)),
                                      child: Container(
                                          color: doc[Dbkeys.messageType] ==
                                                  MessageType.doc.index
                                              ? Colors.yellow[800]
                                              : doc[Dbkeys.messageType] ==
                                                      MessageType.audio.index
                                                  ? Colors.green[400]
                                                  : doc[Dbkeys.messageType] ==
                                                          MessageType
                                                              .location.index
                                                      ? Colors.red[700]
                                                      : doc[Dbkeys.messageType] ==
                                                              MessageType
                                                                  .contact.index
                                                          ? Colors.blue[400]
                                                          : Colors.cyan[700],
                                          height: 74,
                                          width: 74,
                                          child: Icon(
                                            doc[Dbkeys.messageType] ==
                                                    MessageType.doc.index
                                                ? Icons.insert_drive_file
                                                : doc[Dbkeys.messageType] ==
                                                        MessageType.audio.index
                                                    ? Icons.mic_rounded
                                                    : doc[Dbkeys.messageType] ==
                                                            MessageType
                                                                .location.index
                                                        ? Icons.location_on
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
    );
  }

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
                        color: replyDoc![Dbkeys.from] == currentUserNo
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
                              replyDoc![Dbkeys.from] == currentUserNo
                                  ? getTranslated(this.context, 'you')
                                  : Fiberchat.getNickname(peer!)!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: replyDoc![Dbkeys.from] == currentUserNo
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
                                      maxLines: 2,
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
                                              ? Colors.yellow[800]
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

  // Widget buildLoading() {
  //   return Positioned(
  //     child: isgeneratingSomethingLoader
  //         ? Container(
  //             child: Center(
  //               child: CircularProgressIndicator(
  //                   valueColor: AlwaysStoppedAnimation<Color>(fiberchatPRIMARYcolor)),
  //             ),
  //             color: DESIGN_TYPE == Themetype.whatsapp
  //                 ? fiberchatBlack.withOpacity(0.0)
  //                 : fiberchatWhite.withOpacity(0.0),
  //           )
  //         : Container(),
  //   );
  // }

  Widget buildLoadingThumbnail() {
    return Positioned(
      child: isgeneratingSomethingLoader
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor)),
              ),
              color: fiberchatWhite.withOpacity(0.6),
            )
          : Container(),
    );
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
    // isthumbnail == false
    //     ? isVideo == true
    //         ? 'Video-$timeEpoch.mp4'
    //         : '$timeEpoch'
    //     : '${timeEpoch}Thumbnail.png'
    // );
    Reference reference =
        FirebaseStorage.instance.ref("+00_CHAT_MEDIA/$chatId/").child(fileName);

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
                  key: _keyLoader34,
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
          .doc(widget.currentUserNo)
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
    Navigator.of(_keyLoader34.currentContext!, rootNavigator: true).pop(); //
    return downloadedurl;
  }

  FocusNode keyboardFocusNode = new FocusNode();
  Widget buildInputTextBox(BuildContext context, bool isemojiShowing,
      Function refreshThisInput, bool keyboardVisible) {
    final observer = Provider.of<Observer>(context, listen: true);
    if (chatStatus == ChatStatus.requested.index) {
      return AlertDialog(
        backgroundColor: Colors.white,
        elevation: 10.0,
        title: Text(
          getTranslated(this.context, 'accept') + '${peer![Dbkeys.nickname]} ?',
          style: TextStyle(color: fiberchatBlack),
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.white),
              child: Text(
                getTranslated(this.context, 'rjt'),
                style: TextStyle(color: fiberchatBlack),
              ),
              onPressed: () {
                ChatController.block(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.blocked.index;
                });
              }),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 0, backgroundColor: Colors.white),
              child: Text(getTranslated(this.context, 'acpt'),
                  style: TextStyle(color: fiberchatSECONDARYolor)),
              onPressed: () {
                ChatController.accept(currentUserNo, peerNo);
                setStateIfMounted(() {
                  chatStatus = ChatStatus.accepted.index;
                });
              })
        ],
      );
    }
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
                        Builder(
                          builder: (BuildContext context) => SizedBox(
                            width: 40,
                            child: IconButton(
                              onPressed: isMessageLoading == true
                                  ? null
                                  : !isWideScreen(MediaQuery.of(this.context)
                                          .size
                                          .width)
                                      ? () {
                                          refreshThisInput();
                                        }
                                      : () {
                                          hidekeyboard(context);
                                          showCustomDialog(
                                              context: this.context,
                                              listWidgets: [
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
                                                              .withOpacity(
                                                                  0.78),
                                                        ))
                                                  ],
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
                                                      gridPadding:
                                                          EdgeInsets.zero,
                                                      initCategory:
                                                          Category.RECENT,
                                                      bgColor:
                                                          Color(0xFFF2F2F2),
                                                      indicatorColor:
                                                          Colors.blue,
                                                      iconColor: Colors.grey,
                                                      iconColorSelected:
                                                          Colors.blue,
                                                      backspaceColor:
                                                          Colors.blue,
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
                                                            color:
                                                                Colors.black26),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ), // Needs to be const Widget
                                                      // Needs to be const Widget
                                                      tabIndicatorAnimDuration:
                                                          kTabScrollDuration,
                                                      categoryIcons:
                                                          const CategoryIcons(),
                                                      buttonMode:
                                                          ButtonMode.MATERIAL,
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
                        ),
                        Flexible(
                          child: TextField(
                            onTap: isMessageLoading == true
                                ? null
                                : () {
                                    if (isemojiShowing == true) {
                                    } else {
                                      keyboardFocusNode.requestFocus();
                                      setStateIfMounted(() {});
                                    }
                                  },
                            // onChanged: (string) {
                            //   print(string);

                            //   if (string.substring(string.length - 1) == '/') {
                            //     Fiberchat.toast(string);
                            //   }
                            //   //  setStateIfMounted(() {});
                            // },
                            showCursor: true,
                            focusNode: keyboardFocusNode, minLines: 1,
                            maxLines: 10,
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
                                          onPressed: isMessageLoading == true
                                              ? null
                                              : observer.ismediamessagingallowed ==
                                                      false
                                                  ? () {
                                                      Fiberchat.showRationale(
                                                          getTranslated(
                                                              this.context,
                                                              'mediamssgnotallowed'));
                                                    }
                                                  : () async {
                                                      hidekeyboard(context);
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
                                                                    this
                                                                        .context,
                                                                    filename.toLowerCase().endsWith('.png') || filename.toLowerCase().endsWith('.jpg') || filename.toLowerCase().endsWith('.jpeg')
                                                                        ? url
                                                                        : finalUrl,
                                                                    filename.toLowerCase().endsWith('.png') ||
                                                                            filename.toLowerCase().endsWith(
                                                                                '.jpg') ||
                                                                            filename.toLowerCase().endsWith(
                                                                                '.jpeg')
                                                                        ? MessageType
                                                                            .image
                                                                        : filename.toLowerCase().endsWith('.mp3') ||
                                                                                filename.toLowerCase().endsWith(
                                                                                    '.aac')
                                                                            ? MessageType
                                                                                .audio
                                                                            : MessageType
                                                                                .doc,
                                                                    DateTime.now()
                                                                        .millisecondsSinceEpoch);
                                                                if (islast ==
                                                                    true) {}
                                                              },
                                                              onStartUploading:
                                                                  () {},
                                                              maxSizeInMB: observer
                                                                  .maxFileSizeAllowedInMB,
                                                              firebaseBucketpath:
                                                                  '+00_CHAT_MEDIA/$chatId/',
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
                                            onPressed: isMessageLoading == true
                                                ? null
                                                : observer.ismediamessagingallowed ==
                                                        false
                                                    ? () {
                                                        Fiberchat.showRationale(
                                                            getTranslated(
                                                                this.context,
                                                                'mediamssgnotallowed'));
                                                      }
                                                    : () async {
                                                        GiphyGif? gif =
                                                            await GiphyGet
                                                                .getGif(
                                                          tabColor:
                                                              fiberchatPRIMARYcolor,

                                                          context: context,
                                                          apiKey:
                                                              GiphyAPIKey, //YOUR API KEY HERE
                                                          lang: GiphyLanguage
                                                              .english,
                                                        );
                                                        if (gif != null &&
                                                            mounted) {
                                                          onSendMessage(
                                                              context,
                                                              gif
                                                                  .images!
                                                                  .original!
                                                                  .url,
                                                              MessageType.image,
                                                              DateTime.now()
                                                                  .millisecondsSinceEpoch);
                                                          hidekeyboard(context);
                                                          setStateIfMounted(
                                                              () {});
                                                        }
                                                      }),
                                      ),
                              ],
                            ))
                      ],
                    ),
                  ),
                ),
                // Button send message
                Container(
                  height: 47,
                  width: 47,
                  // alignment: Alignment.center,
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: textInSendButton.length > 2
                                          ? 10.7
                                          : 17.5),
                                ),
                      onPressed: isMessageLoading == true
                          ? null
                          : observer.ismediamessagingallowed == true
                              ? textEditingController.text.length == 0
                                  ? () {
                                      hidekeyboard(context);
                                      String firebasePath =
                                          "+00_CHAT_MEDIA/$chatId/";
                                      void onUploaded(String finalUrl) {
                                        onSendMessage(
                                            this.context,
                                            finalUrl,
                                            MessageType.audio,
                                            DateTime.now()
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
                                                contentPadding:
                                                    EdgeInsets.all(7),
                                                content: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          height: 38,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: recording ==
                                                                  'recorderstopped'
                                                              ? Icon(
                                                                  Icons
                                                                      .music_note,
                                                                  color: Colors
                                                                      .cyan,
                                                                  size: 57,
                                                                )
                                                              : Text(
                                                                  getTranslated(
                                                                      context,
                                                                      recording)),
                                                        ),
                                                        SizedBox(
                                                          height: 18,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(7.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              if (recording ==
                                                                  'record')
                                                                IconButton(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(
                                                                                0),
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
                                                                              AudioEncoder.aacLc, // by default
                                                                          bitRate:
                                                                              128000, // by default
                                                                          samplingRate:
                                                                              44100, // by default
                                                                        );
                                                                      } else {
                                                                        Fiberchat.toast(getTranslated(
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
                                                                            .all(
                                                                                0),
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
                                                                  onTap:
                                                                      () async {
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
                                                                              .get(blobUri);
                                                                      var filename =
                                                                          '$timeEpoch.mp3';
                                                                      Reference reference = FirebaseStorage
                                                                          .instance
                                                                          .ref(
                                                                              firebasePath)
                                                                          .child(
                                                                              '$filename');
                                                                      UploadTask
                                                                          uploading =
                                                                          reference.putData(
                                                                              response.bodyBytes,
                                                                              SettableMetadata(contentType: 'audio/mp3'));
                                                                      showDialog<
                                                                              void>(
                                                                          context:
                                                                              context,
                                                                          barrierDismissible:
                                                                              false,
                                                                          builder:
                                                                              (BuildContext context) {
                                                                            return new WillPopScope(
                                                                                onWillPop: () async => false,
                                                                                child: SimpleDialog(
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(7),
                                                                                    ),
                                                                                    // side: BorderSide(width: 5, color: Colors.green)),
                                                                                    key: _keyLoader34,
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
                                                                              _keyLoader34.currentContext!,
                                                                              rootNavigator: true)
                                                                          .pop();
                                                                      String
                                                                          finalUrl =
                                                                          _url +
                                                                              '-BREAK-' +
                                                                              filename;
                                                                      onUploaded(
                                                                          finalUrl);
                                                                    } else {
                                                                      Fiberchat
                                                                          .toast(
                                                                              "Recording not saved. Please try again !");
                                                                    }
                                                                  },
                                                                  child: Chip(
                                                                      backgroundColor:
                                                                          fiberchatPRIMARYcolor,
                                                                      label:
                                                                          Text(
                                                                        getTranslated(
                                                                            context,
                                                                            'sendrecord'),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white),
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
                                              this.context,
                                              'textmssgnotallowed'));
                                        }
                                      : chatStatus == ChatStatus.blocked.index
                                          ? null
                                          : () => onSendMessage(
                                              context,
                                              textEditingController.text,
                                              MessageType.text,
                                              DateTime.now()
                                                  .millisecondsSinceEpoch)
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
                        onEmojiSelected: (Category? category, Emoji emoji) {
                          setState(() {});
                        },
                        onBackspacePressed: _onBackspacePressed,
                        textEditingController: textEditingController,
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

  // Widget buildInputIos(
  //   BuildContext context,
  // ) {
  //   final observer = Provider.of<Observer>(context, listen: true);
  //   if (chatStatus == ChatStatus.requested.index) {
  //     return AlertDialog(
  //       backgroundColor: Colors.white,
  //       elevation: 10.0,
  //       title: Text(
  //         getTranslated(this.context, 'accept') + '${peer![Dbkeys.nickname]} ?',
  //         style: TextStyle(color: fiberchatBlack),
  //       ),
  //       actions: <Widget>[

  //         FlatButton(
  //             child: Text(getTranslated(this.context, 'rjt')),
  //             onPressed: () {
  //               ChatController.block(currentUserNo, peerNo);
  //               setStateIfMounted(() {
  //                 chatStatus = ChatStatus.blocked.index;
  //               });
  //             }),
  //
  //         FlatButton(
  //             child: Text(getTranslated(this.context, 'acpt'),
  //                 style: TextStyle(color: fiberchatPRIMARYcolor)),
  //             onPressed: () {
  //               ChatController.accept(currentUserNo, peerNo);
  //               setStateIfMounted(() {
  //                 chatStatus = ChatStatus.accepted.index;
  //               });
  //             })
  //       ],
  //     );
  //   }
  //   return Container(
  //     margin: EdgeInsets.only(bottom: Platform.isIOS == true ? 20 : 0),
  //     child: Row(
  //       children: <Widget>[
  //         Flexible(
  //           child: Container(
  //             margin: EdgeInsets.only(
  //               left: 10,
  //             ),
  //             decoration: BoxDecoration(
  //                 color: fiberchatWhite,
  //                 // border: Border.all(
  //                 //   color: Colors.red[500],
  //                 // ),
  //                 borderRadius: BorderRadius.all(Radius.circular(30))),
  //             child: Row(
  //               children: [
  //                 SizedBox(
  //                   width: 100,
  //                   child: Row(
  //                     children: [
  //                       IconButton(
  //                           color: fiberchatWhite,
  //                           padding: EdgeInsets.all(0.0),
  //                           icon: Icon(
  //                             Icons.gif,
  //                             size: 40,
  //                             color: fiberchatGrey,
  //                           ),
  //                           onPressed: observer.ismediamessagingallowed == false
  //                               ? () {
  //                                   Fiberchat.showRationale(getTranslated(
  //                                       this.context, 'mediamssgnotallowed'));
  //                                 }
  //                               : () async {
  //                                   GiphyGif? gif = await GiphyGet.getGif(
  //                                     tabColor: fiberchatPRIMARYcolor,
  //                                     context: context,
  //                                     apiKey: GiphyAPIKey, //YOUR API KEY HERE
  //                                     lang: GiphyLanguage.english,
  //                                   );
  //                                   if (gif != null && mounted) {
  //                                     onSendMessage(
  //                                         context,
  //                                         gif.images!.original!.url,
  //                                         MessageType.image,
  //                                         DateTime.now()
  //                                             .millisecondsSinceEpoch);
  //                                     hidekeyboard(context);
  //                                     setStateIfMounted(() {});
  //                                   }
  //                                 }),
  //                       IconButton(
  //                         icon: new Icon(
  //                           Icons.attachment_outlined,
  //                           color: fiberchatGrey,
  //                         ),
  //                         padding: EdgeInsets.all(0.0),
  //                         onPressed: observer.ismediamessagingallowed == false
  //                             ? () {
  //                                 Fiberchat.showRationale(getTranslated(
  //                                     this.context, 'mediamssgnotallowed'));
  //                               }
  //                             : chatStatus == ChatStatus.blocked.index
  //                                 ? () {
  //                                     Fiberchat.toast(
  //                                         getTranslated(this.context, 'unlck'));
  //                                   }
  //                                 : () {
  //                                     hidekeyboard(context);
  //                                     shareMedia(context);
  //                                   },
  //                         color: fiberchatWhite,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Flexible(
  //                   child: TextField(
  //                     textCapitalization: TextCapitalization.sentences,
  //                     maxLines: null,
  //                     style: TextStyle(fontSize: 18.0, color: fiberchatBlack),
  //                     controller: textEditingController,
  //                     decoration: InputDecoration(
  //                       enabledBorder: OutlineInputBorder(
  //                         // width: 0.0 produces a thin "hairline" border
  //                         borderRadius: BorderRadius.circular(1),
  //                         borderSide:
  //                             BorderSide(color: Colors.transparent, width: 1.5),
  //                       ),
  //                       hoverColor: Colors.transparent,
  //                       focusedBorder: OutlineInputBorder(
  //                         // width: 0.0 produces a thin "hairline" border
  //                         borderRadius: BorderRadius.circular(1),
  //                         borderSide:
  //                             BorderSide(color: Colors.transparent, width: 1.5),
  //                       ),
  //                       border: OutlineInputBorder(
  //                           borderRadius: BorderRadius.circular(1),
  //                           borderSide: BorderSide(color: Colors.transparent)),
  //                       contentPadding: EdgeInsets.fromLTRB(7, 4, 7, 4),
  //                       hintText: getTranslated(this.context, 'msg'),
  //                       hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //         // Button send message
  //         Container(
  //           height: 47,
  //           width: 47,
  //           // alignment: Alignment.center,
  //           margin: EdgeInsets.only(left: 6, right: 10),
  //           decoration: BoxDecoration(
  //               color: DESIGN_TYPE == Themetype.whatsapp
  //                   ? fiberchatPRIMARYcolor
  //                   : fiberchatPRIMARYcolor,
  //               // border: Border.all(
  //               //   color: Colors.red[500],
  //               // ),
  //               borderRadius: BorderRadius.all(Radius.circular(30))),
  //           child: Padding(
  //             padding: const EdgeInsets.all(2.0),
  //             child: IconButton(
  //               icon: new Icon(
  //                 textEditingController.text.length == 0 ||
  //                         isMessageLoading == true
  //                     ? Icons.mic
  //                     : Icons.send,
  //                 color: fiberchatWhite.withOpacity(0.99),
  //               ),
  //               onPressed: observer.ismediamessagingallowed == true
  //                   ? textEditingController.text.length == 0 ||
  //                           isMessageLoading == true
  //                       ? () {
  //                           hidekeyboard(context);

  //                           Navigator.push(
  //                               context,
  //                               MaterialPageRoute(
  //                                   builder: (context) => AudioRecord(
  //                                         title: getTranslated(
  //                                             this.context, 'record'),
  //                                         callback: getFileData,
  //                                       ))).then((url) {
  //                             if (url != null) {
  //                               onSendMessage(
  //                                   context,
  //                                   url +
  //                                       '-BREAK-' +
  //                                       uploadTimestamp.toString(),
  //                                   MessageType.audio,
  //                                   uploadTimestamp);
  //                             } else {}
  //                           });
  //                         }
  //                       : observer.istextmessagingallowed == false
  //                           ? () {
  //                               Fiberchat.showRationale(getTranslated(
  //                                   this.context, 'textmssgnotallowed'));
  //                             }
  //                           : chatStatus == ChatStatus.blocked.index
  //                               ? null
  //                               : () => onSendMessage(
  //                                   context,
  //                                   textEditingController.text,
  //                                   MessageType.text,
  //                                   DateTime.now().millisecondsSinceEpoch)
  //                   : () {
  //                       Fiberchat.showRationale(
  //                           getTranslated(this.context, 'mediamssgnotallowed'));
  //                     },
  //               color: fiberchatWhite,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //     width: double.infinity,
  //     height: 60.0,
  //     decoration: new BoxDecoration(
  //       // border: new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
  //       color: Colors.transparent,
  //     ),
  //   );
  // }

  bool empty = true;

  loadMessagesAndListen() async {
    await FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .collection(chatId!)
        .orderBy(Dbkeys.timestamp)
        .get()
        .then((docs) {
      if (docs.docs.isNotEmpty) {
        empty = false;

        for (final doc in docs.docs) {
          Map<String, dynamic> _doc = Map.from(doc.data());
          int? ts = _doc[Dbkeys.timestamp];

          _doc[Dbkeys.content] = _doc.containsKey(Dbkeys.latestEncrypted) ==
                  true
              ? AESEncryptData.decryptAES(_doc[Dbkeys.content], sharedSecret)
              : decryptWithCRC(_doc[Dbkeys.content]);
          messages.add(Message(buildMessage(this.context, _doc),
              onDismiss:
                  _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = _doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : _doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  keyloader: _keyLoader34,
                                  imageUrl: _doc[Dbkeys.content],
                                  message: _doc[Dbkeys.content],
                                  tag: ts.toString(),
                                ),
                              ));
                        }
                      : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID) ? () {} : () {},
              onLongPress: () {
            if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                _doc.containsKey(Dbkeys.hasSenderDeleted)) {
              if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                      _doc[Dbkeys.hasSenderDeleted] == true) ==
                  false) {
                //--Show Menu only if message is not deleted by current user already
                contextMenuNew(_doc, false);
              }
            } else {
              contextMenuOld(this.context, _doc);
            }
          }, from: _doc[Dbkeys.from], timestamp: ts));

          if (doc.data()[Dbkeys.timestamp] ==
              docs.docs.last.data()[Dbkeys.timestamp]) {
            setStateIfMounted(() {
              isMessageLoading = false;
              // print('All message loaded..........');
            });
          }
        }
      } else {
        setStateIfMounted(() {
          isMessageLoading = false;
          // print('All message loaded..........');
        });
      }
      if (mounted) {
        setStateIfMounted(() {
          messages = List.from(messages);
        });
      }
      msgSubscription = FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .collection(chatId!)
          .where(Dbkeys.from, isEqualTo: peerNo)
          .snapshots()
          .listen((query) {
        if (empty == true || query.docs.length != query.docChanges.length) {
          //----below action triggers when peer new message arrives
          query.docChanges.where((doc) {
            return doc.oldIndex <= doc.newIndex &&
                doc.type == DocumentChangeType.added;

            //  &&
            //     query.docs[doc.oldIndex][Dbkeys.timestamp] !=
            //         query.docs[doc.newIndex][Dbkeys.timestamp];
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);
            int? ts = _doc[Dbkeys.timestamp];
            _doc[Dbkeys.content] = _doc.containsKey(Dbkeys.latestEncrypted) ==
                    true
                ? AESEncryptData.decryptAES(_doc[Dbkeys.content], sharedSecret)
                : decryptWithCRC(_doc[Dbkeys.content]);

            messages.add(Message(
              buildMessage(this.context, _doc),
              onDismiss:
                  _doc[Dbkeys.content] == '' || _doc[Dbkeys.content] == null
                      ? () {}
                      : () {
                          setStateIfMounted(() {
                            isReplyKeyboard = true;
                            replyDoc = _doc;
                          });
                          HapticFeedback.heavyImpact();
                          keyboardFocusNode.requestFocus();
                        },
              onLongPress: () {
                if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                    _doc.containsKey(Dbkeys.hasSenderDeleted)) {
                  if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      false) {
                    //--Show Menu only if message is not deleted by current user already
                    contextMenuNew(_doc, false);
                  }
                } else {
                  contextMenuOld(this.context, _doc);
                }
              },
              onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                          _doc[Dbkeys.hasSenderDeleted] == true) ==
                      true
                  ? () {}
                  : _doc[Dbkeys.messageType] == MessageType.image.index
                      ? () {
                          Navigator.push(
                              this.context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewWrapper(
                                  keyloader: _keyLoader34,
                                  imageUrl: _doc[Dbkeys.content],
                                  message: _doc[Dbkeys.content],
                                  tag: ts.toString(),
                                ),
                              ));
                        }
                      : null,
              onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                  ? () {}
                  : () {
                      // save(_doc);
                    },
              from: _doc[Dbkeys.from],
              timestamp: ts,
            ));
          });
          //----below action triggers when peer message get deleted
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.removed;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) messages.removeAt(i);
            Save.deleteMessage(peerNo, _doc);
            _savedMessageDocs.removeWhere(
                (msg) => msg[Dbkeys.timestamp] == _doc[Dbkeys.timestamp]);
            setStateIfMounted(() {
              _savedMessageDocs = List.from(_savedMessageDocs);
            });
          }); //----below action triggers when peer message gets modified
          query.docChanges.where((doc) {
            return doc.type == DocumentChangeType.modified;
          }).forEach((change) {
            Map<String, dynamic> _doc = Map.from(change.doc.data()!);

            int i = messages.indexWhere(
                (element) => element.timestamp == _doc[Dbkeys.timestamp]);
            if (i >= 0) {
              messages.removeAt(i);
              setStateIfMounted(() {});
              int? ts = _doc[Dbkeys.timestamp];
              _doc[Dbkeys.content] =
                  _doc.containsKey(Dbkeys.latestEncrypted) == true
                      ? AESEncryptData.decryptAES(
                          _doc[Dbkeys.content], sharedSecret)
                      : decryptWithCRC(_doc[Dbkeys.content]);
              messages.insert(
                  i,
                  Message(
                    buildMessage(this.context, _doc),
                    onLongPress: () {
                      if (_doc.containsKey(Dbkeys.hasRecipientDeleted) &&
                          _doc.containsKey(Dbkeys.hasSenderDeleted)) {
                        if ((_doc[Dbkeys.from] == widget.currentUserNo &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            false) {
                          //--Show Menu only if message is not deleted by current user already
                          contextMenuNew(_doc, false);
                        }
                      } else {
                        contextMenuOld(this.context, _doc);
                      }
                    },
                    onTap: (_doc[Dbkeys.from] == widget.currentUserNo &&
                                _doc[Dbkeys.hasSenderDeleted] == true) ==
                            true
                        ? () {}
                        : _doc[Dbkeys.messageType] == MessageType.image.index
                            ? () {
                                Navigator.push(
                                    this.context,
                                    MaterialPageRoute(
                                      builder: (context) => PhotoViewWrapper(
                                        keyloader: _keyLoader34,
                                        imageUrl: _doc[Dbkeys.content],
                                        message: _doc[Dbkeys.content],
                                        tag: ts.toString(),
                                      ),
                                    ));
                              }
                            : null,
                    onDoubleTap: _doc.containsKey(Dbkeys.broadcastID)
                        ? () {}
                        : () {
                            // save(_doc);
                          },
                    from: _doc[Dbkeys.from],
                    timestamp: ts,
                    onDismiss: _doc[Dbkeys.content] == '' ||
                            _doc[Dbkeys.content] == null
                        ? () {}
                        : () {
                            setStateIfMounted(() {
                              isReplyKeyboard = true;
                              replyDoc = _doc;
                            });
                            HapticFeedback.heavyImpact();
                            keyboardFocusNode.requestFocus();
                          },
                  ));
            }
          });
          if (mounted) {
            setStateIfMounted(() {
              messages = List.from(messages);
            });
          }
        }
      });

      //----sharing intent action:
      // IsRequirefocus;
      // if (widget.isSharingIntentForwarded == true) {
      //   if (widget.sharedText != null) {
      //     onSendMessage(this.context, widget.sharedText!, MessageType.text,
      //         DateTime.now().millisecondsSinceEpoch);
      //   } else if (widget.sharedFiles != null) {
      //     setStateIfMounted(() {
      //       isgeneratingSomethingLoader = true;
      //     });
      //     uploadEach(0);
      //   }
      // }
    });
  }

  int currentUploadingIndex = 0;
  // IsRequirefocus;
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
  //         onSendMessage(this.context, finalUrl, type, messagetime);
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

  void loadSavedMessages() {
    if (_savedMessageDocs.isEmpty) {
      Save.getSavedMessages(peerNo).then((_msgDocs) {
        // ignore: unnecessary_null_comparison
        if (_msgDocs != null) {
          setStateIfMounted(() {
            _savedMessageDocs = _msgDocs;
          });
        }
      });
    }
  }

//-- GROUP BY DATE ---
  List<Widget> getGroupedMessages() {
    List<Widget> _groupedMessages = new List.from(<Widget>[
      Card(
        elevation: 0.5,
        color: Color(0xffFFF2BE),
        margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
        child: Container(
            padding: EdgeInsets.fromLTRB(8, 10, 8, 10),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2.5, right: 4),
                      child: Icon(
                        Icons.lock,
                        color: Color(0xff78754A),
                        size: 14,
                      ),
                    ),
                  ),
                  TextSpan(
                      text: getTranslated(this.context, 'chatencryption'),
                      style: TextStyle(
                          color: Color(0xff78754A),
                          height: 1.3,
                          fontSize: 13,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            )),
      ),
    ]);
    int count = 0;
    groupBy<Message, String>(messages, (msg) {
      // return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
      return "${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).year}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).month}-${DateTime.fromMillisecondsSinceEpoch(msg.timestamp!).day}";
    }).forEach((when, _actualMessages) {
      // print("whennnnn $when");
      List<String> li = when.split('-');
      var w = getWhen(DateTime(
          int.tryParse(li[0])!, int.tryParse(li[1])!, int.tryParse(li[2])!));
      _groupedMessages.add(Center(
          child: Chip(
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        backgroundColor: Colors.blue[50],
        label: Text(
          w,
          style: TextStyle(
              color: Colors.black54, fontWeight: FontWeight.w400, fontSize: 14),
        ),
      )));
      _actualMessages.forEach((msg) {
        count++;
        if (unread != 0 && (messages.length - count) == unread! - 1) {
          _groupedMessages.add(Center(
              child: Chip(
            backgroundColor: Colors.blueGrey[50],
            label: Text('$unread' + getTranslated(this.context, 'unread')),
          )));
          unread = 0; // reset
        }
        _groupedMessages.add(msg.child);
      });
    });
    return _groupedMessages.reversed.toList();
  }

  //   groupBy<Message, String>(messages, (msg) {
  //     return getWhen(DateTime.fromMillisecondsSinceEpoch(msg.timestamp!));
  //   }).forEach((when, _actualMessages) {
  //     List<dynamic> sortedList =
  //         _groupedMessages.where((element) => element is Message).toList();

  //     if (sortedList.length >= 2) {
  //       if (sortedList.last.timestamp! >
  //           sortedList[sortedList.length - 2].timestamp!) {
  //         _groupedMessages.add(Center(
  //             child: Chip(
  //           labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
  //           backgroundColor: Colors.blue[50],
  //           label: Text(
  //             when,
  //             style: TextStyle(
  //                 color: Colors.black54,
  //                 fontWeight: FontWeight.w400,
  //                 fontSize: 14),
  //           ),
  //         )));
  //       } else {
  //         _groupedMessages.reversed.toList().add(Center(
  //                 child: Chip(
  //               labelStyle:
  //                   TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
  //               backgroundColor: Colors.blue[50],
  //               label: Text(
  //                 when,
  //                 style: TextStyle(
  //                     color: Colors.black54,
  //                     fontWeight: FontWeight.w400,
  //                     fontSize: 14),
  //               ),
  //             )));
  //       }
  //     } else {
  //       _groupedMessages.add(Center(
  //           child: Chip(
  //         labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
  //         backgroundColor: Colors.blue[50],
  //         label: Text(
  //           when,
  //           style: TextStyle(
  //               color: Colors.black54,
  //               fontWeight: FontWeight.w400,
  //               fontSize: 14),
  //         ),
  //       )));
  //     }

  //     _actualMessages.forEach((msg) {
  //       List<Message> sortedList =[];

  //       print("A A${_groupedMessages[_groupedMessages.length-2] is Message}");
  //       count++;
  //       if (unread != 0 && (messages.length - count) == unread! - 1) {
  //         if (sortedList.length >= 1) {
  //           if (msg.timestamp! > sortedList.last.timestamp!) {
  //             _groupedMessages.add(Center(
  //                 child: Chip(
  //               backgroundColor: Colors.blueGrey[50],
  //               label: Text('$unread' + getTranslated(this.context, 'unread')),
  //             )));
  //             unread = 0;
  //           } else {
  //             _groupedMessages.reversed.toList().add(Center(
  //                     child: Chip(
  //                   backgroundColor: Colors.blueGrey[50],
  //                   label:
  //                       Text('$unread' + getTranslated(this.context, 'unread')),
  //                 )));
  //             unread = 0;
  //           }
  //         } else {
  //           _groupedMessages.add(Center(
  //               child: Chip(
  //             backgroundColor: Colors.blueGrey[50],
  //             label: Text('$unread' + getTranslated(this.context, 'unread')),
  //           )));
  //           unread = 0; // reset
  //         }
  //       }

  //       if (sortedList.length >= 1) {
  //         if (msg.timestamp! > sortedList.last.timestamp!) {
  //           _groupedMessages.add(msg.child);
  //         } else {
  //           _groupedMessages.reversed.toList().add(msg.child);
  //         }
  //       } else {
  //         _groupedMessages.add(msg.child);
  //       }
  //     });
  //   });
  //   return _groupedMessages.reversed.toList();
  // }

  Widget buildMessages(
    BuildContext context,
  ) {
    return Flexible(
        child: chatId == '' || messages.isEmpty || sharedSecret == null
            ? ListView(
                children: <Widget>[
                  Card(),
                  Padding(
                      padding: EdgeInsets.only(top: 200.0),
                      child: sharedSecret == null || isMessageLoading == true
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      fiberchatSECONDARYolor)),
                            )
                          : Text(getTranslated(this.context, 'sayhi'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: fiberchatGrey, fontSize: 18))),
                ],
                controller: realtime,
              )
            : ListView(
                padding: EdgeInsets.all(10.0),
                children: getGroupedMessages(),
                controller: realtime,
                reverse: true,
              ));
  }

  getWhen(date) {
    DateTime now = DateTime.now();
    String when;
    if (date.day == now.day)
      when = getTranslated(this.context, 'today');
    else if (date.day == now.subtract(Duration(days: 1)).day)
      when = getTranslated(this.context, 'yesterday');
    else
      when = IsShowNativeTimDate == true
          ? getTranslated(this.context, DateFormat.MMMM().format(date)) +
              ' ' +
              DateFormat.d().format(date)
          : when = DateFormat.MMMd().format(date);
    return when;
  }

  getPeerStatus(val) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    if (val is bool && val == true) {
      return getTranslated(this.context, 'online');
    } else if (val is int) {
      DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
      String at = observer.is24hrsTimeformat == false
              ? DateFormat.jm().format(date)
              : DateFormat('HH:mm').format(date),
          when = getWhen(date);
      return getTranslated(this.context, 'lastseen') + ' $when, $at';
    } else if (val is String) {
      if (val == currentUserNo) return getTranslated(this.context, 'typing');
      return getTranslated(this.context, 'online');
    }
    return getTranslated(this.context, 'loading');
  }

  bool isBlocked() {
    return chatStatus == ChatStatus.blocked.index;
  }

  call(BuildContext context, bool isvideocall) async {
    var mynickname = widget.prefs.getString(Dbkeys.nickname) ?? '';

    var myphotoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    CallUtils.dial(
        prefs: widget.prefs,
        currentuseruid: widget.currentUserNo,
        fromDp: myphotoUrl,
        toDp: peer![Dbkeys.photoUrl],
        fromUID: widget.currentUserNo,
        fromFullname: mynickname,
        toUID: widget.peerNo,
        toFullname: peer![Dbkeys.nickname],
        context: context,
        isvideocall: isvideocall);
  }

  bool isemojiShowing = false;
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

  showDialOptions(BuildContext context) {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          // return your layout
          return Consumer<Observer>(
              builder: (context, observer, _child) => Container(
                  padding: EdgeInsets.all(12),
                  height: 130,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: observer.iscallsallowed == false
                              ? () {
                                  Navigator.of(this.context).pop();
                                  Fiberchat.showRationale(getTranslated(
                                      this.context, 'callnotallowed'));
                                }
                              : hasPeerBlockedMe == true
                                  ? () {
                                      Navigator.of(this.context).pop();
                                      Fiberchat.toast(
                                        getTranslated(
                                            context, 'userhasblocked'),
                                      );
                                    }
                                  : () async {
//androidIosBarrier
                                      await html.window.navigator
                                          .getUserMedia(
                                              audio: true, video: false)
                                          .then((status) {
                                        Navigator.of(this.context).pop();
                                        call(this.context, false);
                                      }).catchError((onError) {
                                        Navigator.of(this.context).pop();
                                        Fiberchat.showRationale(
                                            getTranslated(this.context, 'pm') +
                                                onError.toString());
                                      });
                                    },
                          child: SizedBox(
                            width: getContentScreenWidth(
                                    MediaQuery.of(context).size.width) /
                                4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 13),
                                Icon(
                                  Icons.local_phone,
                                  size: 35,
                                  color: fiberchatPRIMARYcolor,
                                ),
                                SizedBox(height: 13),
                                Text(
                                  getTranslated(context, 'audiocall'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: fiberchatBlack),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                            onTap: observer.iscallsallowed == false
                                ? () {
                                    Navigator.of(this.context).pop();
                                    Fiberchat.showRationale(getTranslated(
                                        this.context, 'callnotallowed'));
                                  }
                                : hasPeerBlockedMe == true
                                    ? () {
                                        Navigator.of(this.context).pop();
                                        Fiberchat.toast(
                                          getTranslated(
                                              context, 'userhasblocked'),
                                        );
                                      }
                                    : () async {
//androidIosBarrier
                                        await html.window.navigator
                                            .getUserMedia(
                                                audio: true, video: true)
                                            .then((status) {
                                          Navigator.of(this.context).pop();
                                          call(this.context, true);
                                        }).catchError((onError) {
                                          Navigator.of(this.context).pop();
                                          Fiberchat.showRationale(getTranslated(
                                                  this.context, 'pmc') +
                                              onError.toString());
                                        });
                                      },
                            child: SizedBox(
                              width: getContentScreenWidth(
                                      MediaQuery.of(context).size.width) /
                                  4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 13),
                                  Icon(
                                    Icons.videocam,
                                    size: 39,
                                    color: fiberchatPRIMARYcolor,
                                  ),
                                  SizedBox(height: 13),
                                  Text(
                                    getTranslated(context, 'videocall'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 14,
                                        color: fiberchatBlack),
                                  ),
                                ],
                              ),
                            ))
                      ])));
        });
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: true);
    var _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;

    return PickupLayout(
      prefs: widget.prefs,
      scaffold: Fiberchat.getNTPWrappedWidget(WillPopScope(
          onWillPop: isgeneratingSomethingLoader == true
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
                      setLastSeen();
                      WidgetsBinding.instance
                          .addPostFrameCallback((timeStamp) async {
                        var currentpeer = Provider.of<CurrentChatPeer>(
                            this.context,
                            listen: false);
                        currentpeer.setpeer(newpeerid: '');
                        if (lastSeen == peerNo)
                          await FirebaseFirestore.instance
                              .collection(DbPaths.collectionusers)
                              .doc(currentUserNo)
                              .set({Dbkeys.lastSeen: true},
                                  SetOptions(merge: true));
                      });

                      return Future.value(true);
                    },
          child: ScopedModel<DataModel>(
              model: _cachedModel,
              child: ScopedModelDescendant<DataModel>(
                  builder: (context, child, _model) {
                _cachedModel = _model;
                updateLocalUserData(_model);
                return peer != null
                    ? peer![Dbkeys.accountstatus] == Dbkeys.sTATUSdeleted
                        ? Scaffold(
                            backgroundColor: fiberchatChatbackground,
                            appBar: AppBar(
                              backgroundColor: appbarColor,
                              elevation: 0.4,
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
                        : Stack(
                            children: [
                              Scaffold(
                                  backgroundColor: fiberchatChatbackground,
                                  key: _scaffold,
                                  appBar: AppBar(
                                    elevation: 0.4,
                                    titleSpacing: -14,
                                    leading: widget.isWideScreenMode
                                        ? SizedBox(
                                            width: 30,
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(right: 0),
                                            width: 10,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.arrow_back_ios,
                                                size: 20,
                                                color: fiberchatBlack,
                                              ),
                                              onPressed: () {
                                                if (isDeletedDoc == true) {
                                                  Navigator.of(context)
                                                      .pushAndRemoveUntil(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          FiberchatWrapper(),
                                                    ),
                                                    (Route route) => false,
                                                  );
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              },
                                            ),
                                          ),
                                    backgroundColor: appbarColor,
                                    title: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder: (context, a1,
                                                        a2) =>
                                                    ProfileView(
                                                        peer!,
                                                        widget.currentUserNo,
                                                        _cachedModel,
                                                        widget.prefs,
                                                        messages)));
                                      },
                                      child: Consumer<
                                              SmartContactProviderWithLocalStoreData>(
                                          builder: (context, availableContacts,
                                              _child) {
                                        // _filtered = availableContacts.filtered;
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 7, 0, 7),
                                              child: FutureBuilder<
                                                      LocalUserData?>(
                                                  future: availableContacts
                                                      .fetchUserDataFromnLocalOrServer(
                                                          widget.prefs,
                                                          widget.peerNo!),
                                                  builder: (BuildContext
                                                          context,
                                                      AsyncSnapshot<
                                                              LocalUserData?>
                                                          snapshot) {
                                                    if (snapshot.hasData &&
                                                        snapshot.data != null) {
                                                      return customCircleAvatar(
                                                          url: snapshot
                                                              .data!.photoURL,
                                                          radius: 42);
                                                    }
                                                    return customCircleAvatar(
                                                        url: "", radius: 42);
                                                  }),
                                            ),
                                            // : Padding(
                                            //     padding: const EdgeInsets
                                            //         .fromLTRB(0, 7, 0, 7),
                                            //     child: customCircleAvatar(
                                            //         url: peer![
                                            //             Dbkeys.photoUrl])),
                                            SizedBox(
                                              width: 7,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  width: getContentScreenWidth(
                                                          MediaQuery.of(
                                                                  this.context)
                                                              .size
                                                              .width) /
                                                      2.3,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      FutureBuilder<
                                                              LocalUserData?>(
                                                          future: availableContacts
                                                              .fetchUserDataFromnLocalOrServer(
                                                                  widget.prefs,
                                                                  widget
                                                                      .peerNo!),
                                                          builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<
                                                                      LocalUserData?>
                                                                  snapshot) {
                                                            if (snapshot
                                                                    .hasData &&
                                                                snapshot.data !=
                                                                    null) {
                                                              return Text(
                                                                snapshot
                                                                    .data!.name,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 1,
                                                                style: TextStyle(
                                                                    color:
                                                                        fiberchatBlack,
                                                                    fontSize:
                                                                        17.0,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500),
                                                              );
                                                            }
                                                            return Text(
                                                              Fiberchat
                                                                  .getNickname(
                                                                      peer!)!,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              maxLines: 1,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatBlack,
                                                                  fontSize:
                                                                      17.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            );
                                                          }),
                                                      // : Text(
                                                      //     Fiberchat
                                                      //         .getNickname(
                                                      //             peer!)!,
                                                      //     overflow:
                                                      //         TextOverflow
                                                      //             .ellipsis,
                                                      //     maxLines: 1,
                                                      //     style: TextStyle(
                                                      //         color:
                                                      //             fiberchatBlack,
                                                      //         fontSize:
                                                      //             17.0,
                                                      //         fontWeight:
                                                      //             FontWeight
                                                      //                 .w500),
                                                      //   ),
                                                      isCurrentUserMuted
                                                          ? Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          5.0),
                                                              child: Icon(
                                                                Icons
                                                                    .volume_off,
                                                                color: fiberchatBlack
                                                                    .withOpacity(
                                                                        0.5),
                                                                size: 17,
                                                              ),
                                                            )
                                                          : SizedBox(),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                chatId != null
                                                    ? Text(
                                                        getPeerStatus(peer![
                                                            Dbkeys.lastSeen]),
                                                        style: TextStyle(
                                                            color:
                                                                fiberchatGrey,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      )
                                                    : Text(
                                                        getTranslated(
                                                            this.context,
                                                            'loading'),
                                                        style: TextStyle(
                                                            color:
                                                                fiberchatGrey,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                    ),
                                    actions: [
                                      observer.iscallsallowed == false ||
                                              observer.isOngoingCall
                                          ? SizedBox()
                                          : widget.isWideScreenMode
                                              ? Row(
                                                  children: [
                                                    SizedBox(
                                                      width: 55,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons.local_phone,
                                                          color:
                                                              fiberchatPRIMARYcolor,
                                                        ),
                                                        onPressed: observer
                                                                    .iscallsallowed ==
                                                                false
                                                            ? () {
                                                                Fiberchat.showRationale(
                                                                    getTranslated(
                                                                        this.context,
                                                                        'callnotallowed'));
                                                              }
                                                            : hasPeerBlockedMe ==
                                                                    true
                                                                ? () {
                                                                    Fiberchat
                                                                        .toast(
                                                                      getTranslated(
                                                                          context,
                                                                          'userhasblocked'),
                                                                    );
                                                                  }
                                                                : () async {
                                                                    //androidIosBarrier
                                                                    await html
                                                                        .window
                                                                        .navigator
                                                                        .getUserMedia(
                                                                            audio:
                                                                                true,
                                                                            video:
                                                                                false)
                                                                        .then(
                                                                            (status) {
                                                                      call(
                                                                          this.context,
                                                                          false);
                                                                    }).catchError(
                                                                            (onError) {
                                                                      Fiberchat.showRationale(getTranslated(
                                                                              this.context,
                                                                              'pm') +
                                                                          onError.toString());
                                                                    });
                                                                  },
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 55,
                                                      child: IconButton(
                                                        icon: Icon(
                                                          Icons
                                                              .videocam_rounded,
                                                          color:
                                                              fiberchatPRIMARYcolor,
                                                        ),
                                                        onPressed: observer
                                                                    .iscallsallowed ==
                                                                false
                                                            ? () {
                                                                Fiberchat.showRationale(
                                                                    getTranslated(
                                                                        this.context,
                                                                        'callnotallowed'));
                                                              }
                                                            : hasPeerBlockedMe ==
                                                                    true
                                                                ? () {
                                                                    Fiberchat
                                                                        .toast(
                                                                      getTranslated(
                                                                          context,
                                                                          'userhasblocked'),
                                                                    );
                                                                  }
                                                                : () async {
                                                                    //androidIosBarrier
                                                                    await html
                                                                        .window
                                                                        .navigator
                                                                        .getUserMedia(
                                                                            audio:
                                                                                true,
                                                                            video:
                                                                                true)
                                                                        .then(
                                                                            (status) {
                                                                      call(
                                                                          this.context,
                                                                          true);
                                                                    }).catchError(
                                                                            (onError) {
                                                                      Fiberchat.showRationale(getTranslated(
                                                                              this.context,
                                                                              'pm') +
                                                                          onError.toString());
                                                                    });
                                                                  },
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : SizedBox(
                                                  width: 55,
                                                  child: IconButton(
                                                      icon: Icon(
                                                        Icons.add_call,
                                                        color:
                                                            fiberchatPRIMARYcolor,
                                                      ),
                                                      onPressed: observer
                                                                  .iscallsallowed ==
                                                              false
                                                          ? () {
                                                              Fiberchat.showRationale(
                                                                  getTranslated(
                                                                      this.context,
                                                                      'callnotallowed'));
                                                            }
                                                          : hasPeerBlockedMe ==
                                                                  true
                                                              ? () {
                                                                  Fiberchat
                                                                      .toast(
                                                                    getTranslated(
                                                                        context,
                                                                        'userhasblocked'),
                                                                  );
                                                                }
                                                              : () async {
                                                                  showDialOptions(
                                                                      this.context);
                                                                }),
                                                ),
                                      SizedBox(
                                        width: 45,
                                        child: Builder(
                                            builder: (BuildContext context) =>
                                                PopupMenuButton(
                                                    padding: EdgeInsets.all(0),
                                                    icon: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Icon(
                                                        Icons
                                                            .more_vert_outlined,
                                                        color: fiberchatBlack,
                                                      ),
                                                    ),
                                                    color: fiberchatWhite,
                                                    onSelected: (dynamic val) {
                                                      switch (val) {
                                                        case 'report':
                                                          var width =
                                                              MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width;
                                                          var w = width / 1.4;
                                                          isWideScreen(w) ==
                                                                  true
                                                              ? showCustomDialog(
                                                                  context:
                                                                      context,
                                                                  listWidgets: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.end,
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
                                                                        height:
                                                                            12,
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            3,
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 7),
                                                                        child:
                                                                            Text(
                                                                          getTranslated(
                                                                              this.context,
                                                                              'reportshort'),
                                                                          textAlign:
                                                                              TextAlign.left,
                                                                          style: TextStyle(
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 16.5),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                10),
                                                                        padding: EdgeInsets.fromLTRB(
                                                                            0,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        // height: 63,
                                                                        height:
                                                                            63,
                                                                        width: w /
                                                                            1.5,
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
                                                                            Icons.message,
                                                                            color:
                                                                                Colors.grey.withOpacity(0.5),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                            40,
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
                                                                              getTranslated(context, 'report'),
                                                                              style: TextStyle(color: Colors.white, fontSize: 18),
                                                                            ),
                                                                          ),
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.of(context).pop();

                                                                            DateTime
                                                                                time =
                                                                                DateTime.now();

                                                                            Map<String, dynamic>
                                                                                mapdata =
                                                                                {
                                                                              'title': 'New report by User',
                                                                              'desc': '${reportEditingController.text}',
                                                                              'phone': '${widget.currentUserNo}',
                                                                              'type': 'Individual Chat',
                                                                              'time': time.millisecondsSinceEpoch,
                                                                              'id': Fiberchat.getChatId(currentUserNo!, peerNo!),
                                                                            };

                                                                            await FirebaseFirestore.instance.collection('reports').doc(time.millisecondsSinceEpoch.toString()).set(mapdata).then((value) async {
                                                                              showCustomDialog(
                                                                                context: this.context,
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
                                                                                context: this.context,
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
                                                                  context:
                                                                      context,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.vertical(
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
                                                                          bottom: MediaQuery.of(context)
                                                                              .viewInsets
                                                                              .bottom),
                                                                      child: Container(
                                                                          padding: EdgeInsets.all(16),
                                                                          height: MediaQuery.of(context).size.height / 2.6,
                                                                          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
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
                                                                                    'phone': '${widget.currentUserNo}',
                                                                                    'type': 'Individual Chat',
                                                                                    'time': time.millisecondsSinceEpoch,
                                                                                    'id': Fiberchat.getChatId(currentUserNo!, peerNo!),
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
                                                        case 'hide':
                                                          final provider = Provider
                                                              .of<CurrentChatPeer>(
                                                                  this.context,
                                                                  listen:
                                                                      false);
                                                          ChatController
                                                              .hideChat(
                                                                  currentUserNo,
                                                                  peerNo);

                                                          provider
                                                              .removeCurrentWidget();
                                                          showDialog(
                                                              context:
                                                                  this.context,
                                                              builder:
                                                                  (context) {
                                                                return SimpleDialog(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              20),
                                                                  children: <
                                                                      Widget>[
                                                                    ListTile(
                                                                      title:
                                                                          Text(
                                                                        getTranslated(
                                                                            this.context,
                                                                            'swipeview'),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    ListTile(
                                                                        title:
                                                                            Text(
                                                                      getTranslated(
                                                                          this.context,
                                                                          'swipehide'),
                                                                    )),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                          break;
                                                        case 'unhide':
                                                          ChatController
                                                              .unhideChat(
                                                                  currentUserNo,
                                                                  peerNo);
                                                          break;
                                                        case 'mute':
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionmessages)
                                                              .doc(Fiberchat
                                                                  .getChatId(
                                                                      currentUserNo!,
                                                                      peerNo!))
                                                              .set(
                                                                  {
                                                                "$currentUserNo-muted":
                                                                    !isCurrentUserMuted,
                                                              },
                                                                  SetOptions(
                                                                      merge:
                                                                          true));
                                                          setStateIfMounted(() {
                                                            isCurrentUserMuted =
                                                                !isCurrentUserMuted;
                                                          });

                                                          break;
                                                        case 'unmute':
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(DbPaths
                                                                  .collectionmessages)
                                                              .doc(Fiberchat
                                                                  .getChatId(
                                                                      currentUserNo!,
                                                                      peerNo!))
                                                              .set(
                                                                  {
                                                                "$currentUserNo-muted":
                                                                    !isCurrentUserMuted,
                                                              },
                                                                  SetOptions(
                                                                      merge:
                                                                          true));
                                                          setStateIfMounted(() {
                                                            isCurrentUserMuted =
                                                                !isCurrentUserMuted;
                                                          });
                                                          break;
                                                        case 'lock':
                                                          if (widget.prefs.getString(
                                                                      Dbkeys
                                                                          .isPINsetDone) !=
                                                                  currentUserNo ||
                                                              widget.prefs.getString(
                                                                      Dbkeys
                                                                          .isPINsetDone) ==
                                                                  null) {
                                                            unawaited(
                                                                Navigator.push(
                                                                    this
                                                                        .context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) =>
                                                                            Security(
                                                                              currentUserNo,
                                                                              prefs: widget.prefs,
                                                                              setPasscode: true,
                                                                              onSuccess: (newContext) async {
                                                                                ChatController.lockChat(currentUserNo, peerNo);
                                                                                Navigator.pop(context);
                                                                                Navigator.pop(context);
                                                                              },
                                                                              title: getTranslated(this.context, 'authh'),
                                                                            ))));
                                                          } else {
                                                            ChatController
                                                                .lockChat(
                                                                    currentUserNo,
                                                                    peerNo);
                                                            Navigator.pop(
                                                                context);
                                                          }
                                                          break;

                                                        case 'deleteall':
                                                          deleteAllChats();
                                                          break;

                                                        case 'unlock':
                                                          ChatController
                                                              .unlockChat(
                                                                  currentUserNo,
                                                                  peerNo);

                                                          break;
                                                        case 'block':
                                                          // if (hasPeerBlockedMe == true) {
                                                          //   Fiberchat.toast(
                                                          //     getTranslated(context,
                                                          //         'userhasblocked'),
                                                          //   );
                                                          // } else {
                                                          ChatController.block(
                                                              currentUserNo,
                                                              peerNo);
                                                          // }
                                                          break;
                                                        case 'unblock':
                                                          // if (hasPeerBlockedMe == true) {
                                                          //   Fiberchat.toast(
                                                          //     getTranslated(context,
                                                          //         'userhasblocked'),
                                                          //   );
                                                          // } else {
                                                          ChatController.accept(
                                                              currentUserNo,
                                                              peerNo);
                                                          Fiberchat.toast(
                                                              getTranslated(
                                                                  this.context,
                                                                  'unblocked'));
                                                          // }

                                                          break;
                                                        case 'tutorials':
                                                          showDialog(
                                                              context:
                                                                  this.context,
                                                              builder:
                                                                  (context) {
                                                                return SimpleDialog(
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              20),
                                                                  children: <
                                                                      Widget>[
                                                                    ListTile(
                                                                      title:
                                                                          Text(
                                                                        getTranslated(
                                                                            this.context,
                                                                            'swipeview'),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                    ListTile(
                                                                        title:
                                                                            Text(
                                                                      getTranslated(
                                                                          this.context,
                                                                          'swipehide'),
                                                                    )),
                                                                    SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  ],
                                                                );
                                                              });

                                                          break;
                                                        case 'remove_wallpaper':
                                                          _cachedModel
                                                              .removeWallpaper(
                                                                  peerNo!);
                                                          // Fiberchat.toast('Wallpaper removed.');
                                                          break;
                                                      }
                                                    },
                                                    itemBuilder: ((context) =>
                                                        <PopupMenuItem<String>>[
                                                          PopupMenuItem<String>(
                                                            value: 'deleteall',
                                                            child: Text(
                                                              '${getTranslated(this.context, 'deleteallchats')}',
                                                            ),
                                                          ),

                                                          PopupMenuItem<String>(
                                                            value: hidden
                                                                ? 'unhide'
                                                                : 'hide',
                                                            child: Text(
                                                              '${hidden ? getTranslated(this.context, 'unhidechat') : getTranslated(this.context, 'hidechat')}',
                                                            ),
                                                          ),
                                                          // PopupMenuItem<String>(
                                                          //   value: 'share',
                                                          //   child: Text(
                                                          //       '${getTranslated(this.context, 'tutorials')}'),
                                                          // ),
                                                          PopupMenuItem<String>(
                                                            value: isBlocked()
                                                                ? 'unblock'
                                                                : 'block',
                                                            child: Text(
                                                                '${isBlocked() ? getTranslated(this.context, 'unblockchat') : getTranslated(this.context, 'blockchat')}'),
                                                          ),

                                                          PopupMenuItem<String>(
                                                            value: 'report',
                                                            child: Text(
                                                              '${getTranslated(this.context, 'report')}',
                                                            ),
                                                          ),
                                                          // ignore: unnecessary_null_comparison
                                                        ].toList()))),
                                      ),
                                    ],
                                  ),
                                  body: Stack(
                                    children: <Widget>[
                                      new Container(
                                        decoration: new BoxDecoration(
                                          color: fiberchatChatbackground,
                                          image: new DecorationImage(
                                              image: peer![Dbkeys.wallpaper] ==
                                                      null
                                                  ? AssetImage(
                                                      "assets/images/background.png")
                                                  : Image.file(File(peer![
                                                          Dbkeys.wallpaper]))
                                                      .image,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      PageView(
                                        children: <Widget>[
                                          isDeletedDoc == true &&
                                                  isDeleteChatManually == false
                                              ? Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .fromLTRB(
                                                        15, 60, 15, 15),
                                                    child: Text(
                                                        getTranslated(
                                                            this.context,
                                                            'chatdeleted'),
                                                        style: TextStyle(
                                                            color:
                                                                fiberchatGrey)),
                                                  ),
                                                )
                                              : Column(
                                                  children: [
                                                    // List of messages

                                                    buildMessages(context),
                                                    // Input content
                                                    isBlocked()
                                                        ? AlertDialog(
                                                            backgroundColor:
                                                                Colors.white,
                                                            elevation: 10.0,
                                                            title: Text(
                                                              getTranslated(
                                                                      this.context,
                                                                      'unblock') +
                                                                  ' ${peer![Dbkeys.nickname]}?',
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatBlack),
                                                            ),
                                                            actions: <Widget>[
                                                              if (isWideScreen(
                                                                      MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width) ==
                                                                  false)
                                                                myElevatedButton(
                                                                    color:
                                                                        fiberchatWhite,
                                                                    child: Text(
                                                                      getTranslated(
                                                                          this.context,
                                                                          'cancel'),
                                                                      style: TextStyle(
                                                                          color:
                                                                              fiberchatBlack),
                                                                    ),
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    }),
                                                              myElevatedButton(
                                                                  color:
                                                                      fiberchatPRIMARYcolor,
                                                                  child: Text(
                                                                    getTranslated(
                                                                        this.context,
                                                                        'unblock'),
                                                                    style: TextStyle(
                                                                        color:
                                                                            fiberchatWhite),
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    ChatController.accept(
                                                                        currentUserNo,
                                                                        peerNo);
                                                                    setStateIfMounted(
                                                                        () {
                                                                      chatStatus = ChatStatus
                                                                          .accepted
                                                                          .index;
                                                                    });
                                                                  })
                                                            ],
                                                          )
                                                        : hasPeerBlockedMe ==
                                                                true
                                                            ? Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                padding:
                                                                    EdgeInsets
                                                                        .fromLTRB(
                                                                            14,
                                                                            7,
                                                                            14,
                                                                            7),
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.3),
                                                                height: 50,
                                                                width: getContentScreenWidth(
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .error_outline_rounded,
                                                                        color: Colors
                                                                            .red),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      getTranslated(
                                                                          context,
                                                                          'userhasblocked'),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          height:
                                                                              1.3),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : buildInputTextBox(
                                                                context,
                                                                isemojiShowing,
                                                                refreshInput,
                                                                _keyboardVisible)
                                                  ],
                                                ),
                                        ],
                                      ),
                                      // buildLoading()
                                    ],
                                  )),
                              buildLoadingThumbnail(),
                            ],
                          )
                    : Container();
              })))),
    );
  }

  deleteAllChats() async {
    if (messages.length > 0) {
      Fiberchat.toast(getTranslated(this.context, 'deleting'));
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionmessages)
          .doc(chatId)
          .get()
          .then((v) async {
        if (v.exists) {
          var c = v;
          isDeleteChatManually = true;
          setStateIfMounted(() {});
          await v.reference.delete().then((value) async {
            messages = [];
            setStateIfMounted(() {});
            Future.delayed(const Duration(milliseconds: 10000), () async {
              await FirebaseFirestore.instance
                  .collection(DbPaths.collectionmessages)
                  .doc(chatId)
                  .set(c.data()!);
            });
          });
        }
      });
    } else {}
  }
}
