//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fiberchat_web/Configs/Enum.dart';

class ProfileSetting extends StatefulWidget {
  final bool? biometricEnabled;
  final AuthenticationType? type;
  final SharedPreferences prefs;
  ProfileSetting({this.biometricEnabled, this.type, required this.prefs});
  @override
  State createState() => new ProfileSettingState();
}

class ProfileSettingState extends State<ProfileSetting> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;
  TextEditingController? controllerMobilenumber;

  String phone = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  Uint8List? avatarImageFile;

  final FocusNode focusNodeNickname = new FocusNode();
  final FocusNode focusNodeAboutMe = new FocusNode();
  AuthenticationType? _type;

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
    readLocal();
    _type = widget.type;
  }

  void readLocal() async {
    phone = widget.prefs.getString(Dbkeys.phone) ?? '';
    nickname = widget.prefs.getString(Dbkeys.nickname) ?? '';
    aboutMe = widget.prefs.getString(Dbkeys.aboutMe) ?? '';
    photoUrl = widget.prefs.getString(Dbkeys.photoUrl) ?? '';

    controllerNickname = new TextEditingController(text: nickname);
    controllerAboutMe = new TextEditingController(text: aboutMe);
    controllerMobilenumber = new TextEditingController(text: phone);
    // Force refresh input
    setState(() {});
  }

  Future uploadFile(Uint8List avatarImageFile) async {
    String fileName = phone;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);

    TaskSnapshot uploading = await reference.putData(avatarImageFile);

    return uploading.ref.getDownloadURL();
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });
    nickname =
        controllerNickname!.text.isEmpty ? nickname : controllerNickname!.text;
    aboutMe =
        controllerAboutMe!.text.isEmpty ? aboutMe : controllerAboutMe!.text;
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(phone)
        .set({
      Dbkeys.nickname: nickname,
      Dbkeys.aboutMe: aboutMe,
      Dbkeys.authenticationType: _type!.index,
      Dbkeys.searchKey: nickname.trim().substring(0, 1).toUpperCase(),
    }, SetOptions(merge: true)).then((data) {
      widget.prefs.setString(Dbkeys.nickname, nickname);
      widget.prefs.setString(Dbkeys.aboutMe, aboutMe);
      setState(() {
        isLoading = false;
      });
      Fiberchat.toast(getTranslated(this.context, 'saved'));
      Navigator.of(this.context).pop();
      Navigator.of(this.context).pop();
    }).catchError((err) {
      setState(() {
        isLoading = false;
      });

      Fiberchat.toast(err.toString());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(context, listen: false);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
            backgroundColor: fiberchatScaffold,
            appBar: new AppBar(
              centerTitle: true,
              elevation: 0.4,
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
              titleSpacing: 0,
              backgroundColor: fiberchatWhite,
              title: new Text(
                getTranslated(this.context, 'editprofile'),
                style: TextStyle(
                  fontSize: 20.0,
                  color: fiberchatBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: handleUpdateData,
                  child: Text(
                    getTranslated(this.context, 'save'),
                    style: TextStyle(
                      fontSize: 16,
                      color: fiberchatPRIMARYcolor,
                    ),
                  ),
                )
              ],
            ),
            body: Center(
              child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                color: Colors.white,
                alignment: Alignment.center,
                width: getContentScreenWidth(MediaQuery.of(context).size.width),
                child: Stack(
                  children: <Widget>[
                    SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          // Avatar
                          Container(
                            child: Center(
                              child: Stack(
                                children: <Widget>[
                                  (avatarImageFile == null)
                                      ? (photoUrl != ''
                                          ? Material(
                                              child: Image.network(
                                                photoUrl,
                                                width: 150.0,
                                                height: 150.0,
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(75.0)),
                                              clipBehavior: Clip.hardEdge,
                                            )
                                          : Icon(
                                              Icons.account_circle,
                                              size: 150.0,
                                              color: Colors.grey,
                                            ))
                                      : Material(
                                          child: Image.memory(
                                            avatarImageFile!,
                                            width: 150.0,
                                            height: 150.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(75.0)),
                                          clipBehavior: Clip.hardEdge,
                                        ),
                                  Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: FloatingActionButton(
                                          heroTag: "112233e8t4yt834",
                                          backgroundColor:
                                              fiberchatSECONDARYolor,
                                          child: Icon(Icons.camera_alt,
                                              color: fiberchatWhite),
                                          onPressed: () async {
                                            try {
                                              FilePickerResult? result;

                                              result = await FilePicker.platform
                                                  .pickFiles(
                                                type: FileType.custom,
                                                allowedExtensions: [
                                                  'jpg',
                                                  'png',
                                                  'jpeg',
                                                ],
                                              );

                                              if (result != null) {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                Uint8List uploadfile =
                                                    result.files.single.bytes!;
                                                avatarImageFile = uploadfile;
                                                setState(() {});
                                                // String filename = basename(
                                                //     result.files.single.name);

                                                if ((result.files.single.bytes!
                                                            .length /
                                                        1000000) >
                                                    observer
                                                        .maxFileSizeAllowedInMB) {
                                                  Fiberchat.toast(
                                                      'File size should be less than ${observer.maxFileSizeAllowedInMB}MB. The current file size is ${(result.files.single.bytes!.lengthInBytes / 1000000)}MB');
                                                } else {
                                                  var url = await uploadFile(
                                                      uploadfile);
                                                  if (url != null) {
                                                    photoUrl = url.toString();
                                                    FirebaseFirestore.instance
                                                        .collection(DbPaths
                                                            .collectionusers)
                                                        .doc(phone)
                                                        .set(
                                                            {
                                                          Dbkeys.photoUrl:
                                                              photoUrl
                                                        },
                                                            SetOptions(
                                                                merge:
                                                                    true)).then(
                                                            (data) async {
                                                      await widget.prefs
                                                          .setString(
                                                              Dbkeys.photoUrl,
                                                              photoUrl);
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    }).catchError((err) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });

                                                      Fiberchat.toast(
                                                          err.toString());
                                                    });
                                                  } else {}
                                                }
                                              }
                                            } catch (e) {
                                              Fiberchat.toast(e.toString());
                                            }
                                          })),
                                ],
                              ),
                            ),
                            width: double.infinity,
                            margin: EdgeInsets.all(20.0),
                          ),
                          ListTile(
                              title: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            autovalidateMode: AutovalidateMode.always,
                            controller: controllerNickname,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(25),
                            ],
                            validator: (v) {
                              return v!.isEmpty
                                  ? getTranslated(this.context, 'validdetails')
                                  : null;
                            },
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(6),
                                labelStyle: TextStyle(height: 0.8),
                                labelText: getTranslated(
                                    this.context, 'enter_fullname')),
                          )),
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                              title: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            controller: controllerAboutMe,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(6),
                                labelStyle: TextStyle(height: 0.8),
                                labelText:
                                    getTranslated(this.context, 'status')),
                          )),
                          SizedBox(
                            height: 15,
                          ),
                          ListTile(
                              title: TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            readOnly: true,
                            controller: controllerMobilenumber,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(6),
                                labelStyle: TextStyle(height: 0.8),
                                labelText: getTranslated(
                                    this.context, 'enter_mobilenumber')),
                          )),
                        ],
                      ),
                      padding: EdgeInsets.only(left: 15.0, right: 15.0),
                    ),
                    // Loading
                    Positioned(
                      child: isLoading
                          ? Container(
                              child: Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        fiberchatSECONDARYolor)),
                              ),
                              color: fiberchatWhite.withOpacity(0.8))
                          : Container(),
                    ),
                  ],
                ),
              ),
            ))));
  }
}
