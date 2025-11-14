//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';

import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/homepage/Setupdata.dart';
import 'package:fiberchat_web/Screens/notifications/AllNotifications.dart';
import 'package:fiberchat_web/Services/Providers/Observer.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/custom_url_launcher.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/CustomDialog/custom_dialog.dart';
import 'package:fiberchat_web/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsOption extends StatefulWidget {
  final bool biometricEnabled;
  final AuthenticationType type;
  final String currentUserNo;
  final Function onTapEditProfile;
  final SharedPreferences prefs;
  final Function onTapLogout;
  const SettingsOption(
      {Key? key,
      required this.biometricEnabled,
      required this.currentUserNo,
      required this.onTapEditProfile,
      required this.onTapLogout,
      required this.prefs,
      required this.type})
      : super(key: key);

  @override
  _SettingsOptionState createState() => _SettingsOptionState();
}

class _SettingsOptionState extends State<SettingsOption> {
  late Stream myDocStream;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    myDocStream = FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(widget.currentUserNo)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    final observer = Provider.of<Observer>(context, listen: false);
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(Scaffold(
          backgroundColor: fiberchatScaffold,
          appBar: AppBar(
            centerTitle: true,
            elevation: 0.4,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 24,
                color: fiberchatBlack,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            backgroundColor: fiberchatWhite,
            title: Text(
              getTranslated(context, 'settingsoption'),
              style: TextStyle(color: fiberchatBlack, fontSize: 18.5),
            ),
          ),
          body: Center(
            child: Container(
              margin: EdgeInsets.only(top: 20, bottom: 20),
              color: Colors.white,
              alignment: Alignment.center,
              width: getContentScreenWidth(MediaQuery.of(context).size.width),
              child: ListView(
                children: [
                  Container(
                    width: w,
                    child: StreamBuilder(
                        stream: myDocStream,
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData && snapshot.data.exists) {
                            var myDoc = snapshot.data;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                    padding: EdgeInsets.fromLTRB(10, 19, 0, 10),
                                    child: ListTile(
                                        leading: customCircleAvatar(
                                            radius: 44,
                                            url: myDoc[Dbkeys.photoUrl]),
                                        title: Text(
                                          myDoc[Dbkeys.nickname] ??
                                              widget.currentUserNo,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 19,
                                              fontWeight: FontWeight.bold,
                                              color: fiberchatBlack),
                                        ),
                                        subtitle: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 7),
                                          child: Text(
                                            myDoc[Dbkeys.aboutMe] == null ||
                                                    myDoc[Dbkeys.aboutMe] == ''
                                                ? myDoc[Dbkeys.phone]
                                                : myDoc[Dbkeys.aboutMe],
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: fiberchatBlack
                                                    .withOpacity(0.56)),
                                          ),
                                        ),
                                        trailing: IconButton(
                                            onPressed: () {
                                              widget.onTapEditProfile();
                                            },
                                            icon: Icon(
                                              Icons.edit,
                                              color: fiberchatSECONDARYolor,
                                            )))),
                              ],
                            );
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  padding: EdgeInsets.fromLTRB(10, 19, 0, 10),
                                  child: ListTile(
                                      leading: customCircleAvatar(radius: 44),
                                      title: Text(
                                        widget.currentUserNo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.bold,
                                            color: fiberchatBlack),
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 7),
                                        child: Text(
                                          getTranslated(context, 'myprofile'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: fiberchatBlack
                                                  .withOpacity(0.56)),
                                        ),
                                      ),
                                      trailing: IconButton(
                                          onPressed: () {
                                            widget.onTapEditProfile();
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: fiberchatSECONDARYolor,
                                          )))),
                            ],
                          );
                        }),
                  ),
                  // Divider(),

                  // Divider(),
                  ListTile(
                    onTap: () {
                      widget.onTapEditProfile();
                    },
                    contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.account_circle_rounded,
                        color: fiberchatPRIMARYcolor.withOpacity(0.75),
                        size: 26,
                      ),
                    ),
                    title: Text(
                      getTranslated(context, 'editprofile'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: fiberchatBlack),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        getTranslated(context, 'changednp'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: fiberchatBlack.withOpacity(0.56)),
                      ),
                    ),
                  ),

                  observer.feedbackEmail == ''
                      ? SizedBox()
                      : Builder(
                          builder: (BuildContext context) => ListTile(
                            onTap: () {
                              var width = MediaQuery.of(context).size.width;
                              var w = width / 1.4;
                              isWideScreen(w) == true
                                  ? showCustomDialog(
                                      context: context,
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
                                                    color: fiberchatGrey
                                                        .withOpacity(0.78),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Icon(Icons.email,
                                              color: Colors.purple[400],
                                              size: 45),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                              width: w / 1.6,
                                              child: SelectableText(
                                                observer.feedbackEmail,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    height: 1.3,
                                                    color: fiberchatGrey),
                                              )),
                                          SizedBox(
                                            height: 12,
                                          ),
                                        ])
                                  : showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25.0)),
                                      ),
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 220,
                                          child: Padding(
                                            padding: const EdgeInsets.all(28.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.email,
                                                    color: Colors.purple[400],
                                                    size: 45),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                SelectableText(
                                                  observer.feedbackEmail,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      height: 1.3,
                                                      color: fiberchatGrey),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                            },
                            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.rate_review_outlined,
                                color: fiberchatPRIMARYcolor.withOpacity(0.75),
                                size: 25,
                              ),
                            ),
                            title: Text(
                              getTranslated(context, 'feedback'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: fiberchatBlack),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                getTranslated(context, 'givesuggestions'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: fiberchatBlack.withOpacity(0.56)),
                              ),
                            ),
                          ),
                        ),

                  Builder(
                      builder: (BuildContext context) => ListTile(
                            onTap: () {
                              var width = MediaQuery.of(context).size.width;
                              var w = width / 1.4;
                              isWideScreen(w) == true
                                  ? showCustomDialog(
                                      context: context,
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
                                                    color: fiberchatGrey
                                                        .withOpacity(0.78),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              color: Colors.green[400],
                                              size: 45),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          SizedBox(
                                            width: w / 1.6,
                                            child: Text(
                                              getTranslated(
                                                  context, 'backupdesc'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  height: 1.3,
                                                  color: fiberchatGrey),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                        ])
                                  : showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25.0)),
                                      ),
                                      builder: (BuildContext context) {
                                        return Container(
                                          height: 220,
                                          child: Padding(
                                            padding: const EdgeInsets.all(28.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                    Icons
                                                        .check_circle_outline_rounded,
                                                    color: Colors.green[400],
                                                    size: 45),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  getTranslated(
                                                      context, 'backupdesc'),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      height: 1.3,
                                                      color: fiberchatGrey),
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                            },
                            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                color: fiberchatPRIMARYcolor.withOpacity(0.75),
                                size: 25,
                              ),
                            ),
                            title: Text(
                              getTranslated(context, 'backup'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: fiberchatBlack),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                getTranslated(context, 'backupshort'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: fiberchatBlack.withOpacity(0.56)),
                              ),
                            ),
                          )),
                  ListTile(
                    onTap: () {
                      Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) => AllNotifications(
                                    prefs: widget.prefs,
                                  )));
                    },
                    contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Icon(
                        Icons.notifications_none,
                        color: fiberchatPRIMARYcolor.withOpacity(0.75),
                        size: 29,
                      ),
                    ),
                    title: Text(
                      getTranslated(context, 'pmtevents'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: fiberchatBlack),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        getTranslated(context, 'allnotifications'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: fiberchatBlack.withOpacity(0.56)),
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      if (observer.tnc == null) {
                        custom_url_launcher(TERMS_CONDITION_URL);
                      } else {
                        custom_url_launcher(observer.tnc!);
                      }
                    },
                    contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.help_outline,
                        color: fiberchatPRIMARYcolor.withOpacity(0.75),
                        size: 26,
                      ),
                    ),
                    title: Text(
                      getTranslated(context, 'tnc'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: fiberchatBlack),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        getTranslated(context, 'abiderules'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: fiberchatBlack.withOpacity(0.56)),
                      ),
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      if (observer.privacypolicy == null) {
                        custom_url_launcher(PRIVACY_POLICY_URL);
                      } else {
                        custom_url_launcher(observer.privacypolicy!);
                      }
                    },
                    contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: fiberchatPRIMARYcolor.withOpacity(0.75),
                        size: 26,
                      ),
                    ),
                    title: Text(
                      getTranslated(context, 'pp'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: fiberchatBlack),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        getTranslated(context, 'processdata'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            color: fiberchatBlack.withOpacity(0.56)),
                      ),
                    ),
                  ),

                  Builder(
                      builder: (BuildContext context) => ListTile(
                            onTap: () {
                              var width = MediaQuery.of(context).size.width;
                              var w = width / 1.4;
                              isWideScreen(w) == true
                                  ? showCustomDialog(
                                      context: context,
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
                                                    color: fiberchatGrey
                                                        .withOpacity(0.78),
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                            height: 22,
                                          ),
                                          SizedBox(
                                            height: 3,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, right: 12),
                                            child: Text(
                                              getTranslated(this.context,
                                                  'raiserequestdesc'),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16.5),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          myElevatedButton(
                                              color: fiberchatPRIMARYcolor,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        30, 15, 30, 15),
                                                child: Text(
                                                  getTranslated(
                                                      context, 'submit'),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              onPressed: () async {
                                                Navigator.of(context).pop();

                                                DateTime time = DateTime.now();

                                                Map<String, dynamic> mapdata = {
                                                  'title':
                                                      'Account Deletion Request by User',
                                                  'desc':
                                                      'User ${widget.currentUserNo} has requested to Delete account. Delete it from User Profile page. User Personal Chat, Profile Details will be deleted.',
                                                  'phone':
                                                      '${widget.currentUserNo}',
                                                  'type': 'Account',
                                                  'time': time
                                                      .millisecondsSinceEpoch,
                                                  'id': widget.currentUserNo
                                                };

                                                await FirebaseFirestore.instance
                                                    .collection('reports')
                                                    .doc(time
                                                        .millisecondsSinceEpoch
                                                        .toString())
                                                    .set(mapdata)
                                                    .then((value) async {
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
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        size:
                                                                            25,
                                                                        color: fiberchatGrey
                                                                            .withOpacity(0.78),
                                                                      ))
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 22,
                                                              ),
                                                              Icon(Icons.check,
                                                                  color: Colors
                                                                          .green[
                                                                      400],
                                                                  size: 40),
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Text(
                                                                getTranslated(
                                                                    context,
                                                                    'requestsubmitted'),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              SizedBox(
                                                                height: 22,
                                                              ),
                                                            ])
                                                      : showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          context: context,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            25.0)),
                                                          ),
                                                          builder: (BuildContext
                                                              context) {
                                                            return Container(
                                                              height: 220,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        28.0),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors.green[
                                                                            400],
                                                                        size:
                                                                            40),
                                                                    SizedBox(
                                                                      height:
                                                                          30,
                                                                    ),
                                                                    Text(
                                                                      getTranslated(
                                                                          context,
                                                                          'requestsubmitted'),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });

                                                  //----
                                                }).catchError((err) {
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
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .close,
                                                                        size:
                                                                            25,
                                                                        color: fiberchatGrey
                                                                            .withOpacity(0.78),
                                                                      ))
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 22,
                                                              ),
                                                              Icon(Icons.check,
                                                                  color: Colors
                                                                          .green[
                                                                      400],
                                                                  size: 40),
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Text(
                                                                getTranslated(
                                                                    context,
                                                                    'requestsubmitted'),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                              SizedBox(
                                                                height: 22,
                                                              ),
                                                            ])
                                                      : showModalBottomSheet(
                                                          isScrollControlled:
                                                              true,
                                                          context: this.context,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            25.0)),
                                                          ),
                                                          builder: (BuildContext
                                                              context) {
                                                            return Container(
                                                              height: 220,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .all(
                                                                        28.0),
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors.green[
                                                                            400],
                                                                        size:
                                                                            40),
                                                                    SizedBox(
                                                                      height:
                                                                          30,
                                                                    ),
                                                                    Text(
                                                                      getTranslated(
                                                                          context,
                                                                          'requestsubmitted'),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          });
                                                });
                                              }),
                                          SizedBox(
                                            height: 12,
                                          ),
                                        ])
                                  : showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(25.0)),
                                      ),
                                      builder: (BuildContext context) {
                                        // return your layout
                                        var w =
                                            MediaQuery.of(context).size.width;
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          child: Container(
                                              padding: EdgeInsets.all(16),
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.6,
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    SizedBox(
                                                      height: 12,
                                                    ),
                                                    SizedBox(
                                                      height: 3,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 12,
                                                              right: 12),
                                                      child: Text(
                                                        getTranslated(
                                                            this.context,
                                                            'raiserequestdesc'),
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontSize: 16.5),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    SizedBox(
                                                      height: w / 10,
                                                    ),
                                                    myElevatedButton(
                                                        color:
                                                            fiberchatPRIMARYcolor,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  10,
                                                                  15,
                                                                  10,
                                                                  15),
                                                          child: Text(
                                                            getTranslated(
                                                                context,
                                                                'submit'),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 18),
                                                          ),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                              .pop();

                                                          DateTime time =
                                                              DateTime.now();

                                                          Map<String, dynamic>
                                                              mapdata = {
                                                            'title':
                                                                'Account Deletion Request by User',
                                                            'desc':
                                                                'User ${widget.currentUserNo} has requested to Delete account. Delete it from User Profile page. User Personal Chat, Profile Details will be deleted.',
                                                            'phone':
                                                                '${widget.currentUserNo}',
                                                            'type': 'Account',
                                                            'time': time
                                                                .millisecondsSinceEpoch,
                                                            'id': widget
                                                                .currentUserNo
                                                          };

                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'reports')
                                                              .doc(time
                                                                  .millisecondsSinceEpoch
                                                                  .toString())
                                                              .set(mapdata)
                                                              .then(
                                                                  (value) async {
                                                            showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                context:
                                                                    context,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              25.0)),
                                                                ),
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Container(
                                                                    height: 220,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          28.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                              Icons.check,
                                                                              color: Colors.green[400],
                                                                              size: 40),
                                                                          SizedBox(
                                                                            height:
                                                                                30,
                                                                          ),
                                                                          Text(
                                                                            getTranslated(context,
                                                                                'requestsubmitted'),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                });

                                                            //----
                                                          }).catchError((err) {
                                                            showModalBottomSheet(
                                                                isScrollControlled:
                                                                    true,
                                                                context: this
                                                                    .context,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.vertical(
                                                                          top: Radius.circular(
                                                                              25.0)),
                                                                ),
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Container(
                                                                    height: 220,
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .all(
                                                                          28.0),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                              Icons.check,
                                                                              color: Colors.green[400],
                                                                              size: 40),
                                                                          SizedBox(
                                                                            height:
                                                                                30,
                                                                          ),
                                                                          Text(
                                                                            getTranslated(context,
                                                                                'requestsubmitted'),
                                                                            textAlign:
                                                                                TextAlign.center,
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
                            },
                            contentPadding: EdgeInsets.fromLTRB(30, 3, 10, 3),
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(
                                Icons.delete_outlined,
                                color: fiberchatPRIMARYcolor.withOpacity(0.75),
                                size: 26,
                              ),
                            ),
                            title: Text(
                              getTranslated(context, 'deleteaccount'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 16, color: fiberchatBlack),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                getTranslated(context, 'raiserequest'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: fiberchatBlack.withOpacity(0.56)),
                              ),
                            ),
                          )),

                  observer.isLogoutButtonShowInSettingsPage == true
                      ? Divider()
                      : SizedBox(),
                  observer.isLogoutButtonShowInSettingsPage == true
                      ? ListTile(
                          onTap: () async {
                            widget.onTapLogout();
                          },
                          contentPadding: EdgeInsets.fromLTRB(30, 0, 10, 6),
                          leading: Icon(
                            Icons.logout_rounded,
                            color: Colors.red,
                            size: 26,
                          ),
                          title: Text(
                            getTranslated(context, 'logout'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 16,
                                color: fiberchatBlack,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      : SizedBox(),

                  Padding(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      'v ${widget.prefs.getString('app_version') ?? ""}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: fiberchatGrey, fontSize: 12),
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  )
                ],
              ),
            ),
          ),
        )));
  }

  onTapRateApp() {
    final observer = Provider.of<Observer>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            children: <Widget>[
              ListTile(
                  contentPadding: EdgeInsets.only(top: 20),
                  subtitle: Padding(padding: EdgeInsets.only(top: 10.0)),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          size: 40,
                          color: fiberchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: fiberchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: fiberchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: fiberchatBlack.withOpacity(0.56),
                        ),
                        Icon(
                          Icons.star,
                          size: 40,
                          color: fiberchatBlack.withOpacity(0.56),
                        ),
                      ]),
                  onTap: () {
                    Navigator.of(context).pop();
                    //   IsRequirefocus
                    custom_url_launcher(ConnectWithAdminApp == true
                        ? observer.userAppSettingsDoc!
                            .data()![Dbkeys.newapplinkweb]
                        : RateAppUrlWeb);
                  }),
              Divider(),
              Padding(
                  child: Text(
                    getTranslated(context, 'loved'),
                    style: TextStyle(fontSize: 14, color: fiberchatBlack),
                    textAlign: TextAlign.center,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              Center(
                  child: myElevatedButton(
                      color: fiberchatPRIMARYcolor,
                      child: Text(
                        getTranslated(context, 'rate'),
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        custom_url_launcher(observer.userAppSettingsDoc!
                            .data()![Dbkeys.newapplinkweb]);
                      }))
            ],
          );
        });
  }
}
