//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/auth_screens/login.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Screens/contact_screens/syncedContacts.dart';
import 'package:fiberchat_web/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/CustomDialog/custom_dialog.dart';
import 'package:fiberchat_web/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddContactsToBroadcast extends StatefulWidget {
  const AddContactsToBroadcast({
    this.blacklistedUsers,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.isAddingWhileCreatingBroadcast,
    this.broadcastID,
  });

  final List? blacklistedUsers;
  final String? broadcastID;
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  final bool biometricEnabled;
  final bool isAddingWhileCreatingBroadcast;

  @override
  _AddContactsToBroadcastState createState() =>
      new _AddContactsToBroadcastState();
}

class _AddContactsToBroadcastState extends State<AddContactsToBroadcast>
    with AutomaticKeepAliveClientMixin {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey<ScaffoldState>();
  Map<String?, String?>? contacts;
  List<LocalUserData> _selectedList = [];
  TextEditingController _tc = new TextEditingController();
  List<DeviceContactIdAndName> searchresult = [];
  @override
  void dispose() {
    super.dispose();
    _tc.dispose();
    _filter.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();
  final TextEditingController broadcastname = new TextEditingController();
  final TextEditingController broadcastdesc = new TextEditingController();
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatSECONDARYolor),
        )),
      )
    ]);
  }

  bool iscreatingbroadcast = false;
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<SmartContactProviderWithLocalStoreData>(
                  builder:
                      (context, contactsProvider, _child) =>
                          Consumer<List<BroadcastModel>>(
                              builder: (context, broadcastList, _child) =>
                                  Scaffold(
                                      backgroundColor: fiberchatScaffold,
                                      key: _scaffold,
                                      appBar: AppBar(
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
                                        backgroundColor: fiberchatWhite,
                                        centerTitle: true,
                                        title: _selectedList.length == 0
                                            ? Text(
                                                getTranslated(this.context,
                                                    'selectcontacts'),
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: fiberchatBlack,
                                                ),
                                                textAlign: TextAlign.left,
                                              )
                                            : Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    getTranslated(this.context,
                                                        'selectcontacts'),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: fiberchatBlack,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  SizedBox(
                                                    height: 4,
                                                  ),
                                                  Text(
                                                    widget.isAddingWhileCreatingBroadcast ==
                                                            true
                                                        ? '${_selectedList.length} / ${contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.length}'
                                                        : '${_selectedList.length} ${getTranslated(this.context, 'selected')}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: fiberchatBlack,
                                                    ),
                                                    textAlign: TextAlign.left,
                                                  ),
                                                ],
                                              ),
                                        actions: <Widget>[
                                          _selectedList.length == 0
                                              ? SizedBox()
                                              : IconButton(
                                                  icon: Icon(
                                                    Icons.check,
                                                    color: fiberchatBlack,
                                                  ),
                                                  onPressed:
                                                      widget.isAddingWhileCreatingBroadcast ==
                                                              true
                                                          ? () async {
                                                              broadcastdesc
                                                                  .clear();
                                                              broadcastname
                                                                  .clear();

                                                              var width =
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width;
                                                              var w =
                                                                  width / 1.4;
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
                                                                                3,
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 7),
                                                                            child:
                                                                                Text(
                                                                              getTranslated(this.context, 'setbroadcastdetails'),
                                                                              textAlign: TextAlign.left,
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.5),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: 10),
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            // height: 63,
                                                                            height:
                                                                                83,
                                                                            width:
                                                                                w / 1.24,
                                                                            child:
                                                                                InpuTextBox(
                                                                              controller: broadcastname,
                                                                              leftrightmargin: 0,
                                                                              showIconboundary: false,
                                                                              boxcornerradius: 5.5,
                                                                              boxheight: 50,
                                                                              hinttext: getTranslated(this.context, 'broadcastname'),
                                                                              prefixIconbutton: Icon(
                                                                                Icons.edit,
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(top: 5),
                                                                            padding: EdgeInsets.fromLTRB(
                                                                                0,
                                                                                0,
                                                                                0,
                                                                                0),
                                                                            // height: 63,
                                                                            height:
                                                                                83,
                                                                            width:
                                                                                w / 1.24,
                                                                            child:
                                                                                InpuTextBox(
                                                                              maxLines: 1,
                                                                              controller: broadcastdesc,
                                                                              leftrightmargin: 0,
                                                                              showIconboundary: false,
                                                                              boxcornerradius: 5.5,
                                                                              boxheight: 50,
                                                                              hinttext: getTranslated(this.context, 'broadcastdesc'),
                                                                              prefixIconbutton: Icon(
                                                                                Icons.message,
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                3,
                                                                          ),
                                                                          myElevatedButton(
                                                                              color: fiberchatPRIMARYcolor,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                                                                                child: Text(
                                                                                  getTranslated(context, 'createbroadcast'),
                                                                                  style: TextStyle(color: Colors.white, fontSize: 18),
                                                                                ),
                                                                              ),
                                                                              onPressed: () async {
                                                                                Navigator.of(_scaffold.currentContext!).pop();
                                                                                List<String> listusers = [];
                                                                                List<String> listmembers = [];
                                                                                _selectedList.forEach((element) {
                                                                                  listusers.add(element.id);
                                                                                  listmembers.add(element.id);
                                                                                });

                                                                                DateTime time = DateTime.now();
                                                                                DateTime time2 = DateTime.now().add(Duration(seconds: 1));
                                                                                Map<String, dynamic> broadcastdata = {
                                                                                  Dbkeys.broadcastDESCRIPTION: broadcastdesc.text.isEmpty ? '' : broadcastdesc.text.trim(),
                                                                                  Dbkeys.broadcastCREATEDON: time,
                                                                                  Dbkeys.broadcastCREATEDBY: widget.currentUserNo,
                                                                                  Dbkeys.broadcastNAME: broadcastname.text.isEmpty ? 'Unnamed BroadCast' : broadcastname.text.trim(),
                                                                                  Dbkeys.broadcastADMINLIST: [
                                                                                    widget.currentUserNo
                                                                                  ],
                                                                                  Dbkeys.broadcastID: widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString(),
                                                                                  Dbkeys.broadcastMEMBERSLIST: listmembers,
                                                                                  Dbkeys.broadcastLATESTMESSAGETIME: time.millisecondsSinceEpoch,
                                                                                  Dbkeys.broadcastBLACKLISTED: [],
                                                                                };

                                                                                listmembers.forEach((element) {
                                                                                  broadcastdata.putIfAbsent(element.toString(), () => time.millisecondsSinceEpoch);

                                                                                  broadcastdata.putIfAbsent('$element-joinedOn', () => time.millisecondsSinceEpoch);
                                                                                });
                                                                                setStateIfMounted(() {
                                                                                  iscreatingbroadcast = true;
                                                                                });
                                                                                await FirebaseFirestore.instance.collection(DbPaths.collectionbroadcasts).doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString()).set(broadcastdata).then((value) async {
                                                                                  await FirebaseFirestore.instance.collection(DbPaths.collectionbroadcasts).doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString()).collection(DbPaths.collectionbroadcastsChats).doc(time2.millisecondsSinceEpoch.toString() + '--' + widget.currentUserNo!.toString()).set({
                                                                                    Dbkeys.broadcastmsgCONTENT: '',
                                                                                    Dbkeys.broadcastmsgLISToptional: listmembers,
                                                                                    Dbkeys.broadcastmsgTIME: time2.millisecondsSinceEpoch,
                                                                                    Dbkeys.broadcastmsgSENDBY: widget.currentUserNo,
                                                                                    Dbkeys.broadcastmsgISDELETED: false,
                                                                                    Dbkeys.broadcastmsgTYPE: Dbkeys.broadcastmsgTYPEnotificationAddedUser,
                                                                                  }).then((value) async {
                                                                                    Navigator.of(_scaffold.currentContext!).pop();
                                                                                  }).catchError((err) {
                                                                                    setStateIfMounted(() {
                                                                                      iscreatingbroadcast = false;
                                                                                    });

                                                                                    Fiberchat.toast('Error Creating Broadcast. $err');
                                                                                    // print('Error Creating Broadcast. $err');
                                                                                  });
                                                                                });
                                                                              }),
                                                                          SizedBox(
                                                                            height:
                                                                                12,
                                                                          ),
                                                                        ])
                                                                  : showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      context:
                                                                          context,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                      ),
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        // return your layout
                                                                        var w = MediaQuery.of(context)
                                                                            .size
                                                                            .width;
                                                                        return Padding(
                                                                          padding:
                                                                              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                                          child: Container(
                                                                              padding: EdgeInsets.all(16),
                                                                              height: MediaQuery.of(context).size.height / 2.2,
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
                                                                                    getTranslated(this.context, 'setbroadcastdetails'),
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
                                                                                  height: 83,
                                                                                  width: w / 1.24,
                                                                                  child: InpuTextBox(
                                                                                    controller: broadcastname,
                                                                                    leftrightmargin: 0,
                                                                                    showIconboundary: false,
                                                                                    boxcornerradius: 5.5,
                                                                                    boxheight: 50,
                                                                                    hinttext: getTranslated(this.context, 'broadcastname'),
                                                                                    prefixIconbutton: Icon(
                                                                                      Icons.edit,
                                                                                      color: Colors.grey.withOpacity(0.5),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  margin: EdgeInsets.only(top: 10),
                                                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                  // height: 63,
                                                                                  height: 83,
                                                                                  width: w / 1.24,
                                                                                  child: InpuTextBox(
                                                                                    maxLines: 1,
                                                                                    controller: broadcastdesc,
                                                                                    leftrightmargin: 0,
                                                                                    showIconboundary: false,
                                                                                    boxcornerradius: 5.5,
                                                                                    boxheight: 50,
                                                                                    hinttext: getTranslated(this.context, 'broadcastdesc'),
                                                                                    prefixIconbutton: Icon(
                                                                                      Icons.message,
                                                                                      color: Colors.grey.withOpacity(0.5),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 6,
                                                                                ),
                                                                                myElevatedButton(
                                                                                    color: fiberchatPRIMARYcolor,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                                                                                      child: Text(
                                                                                        getTranslated(context, 'createbroadcast'),
                                                                                        style: TextStyle(color: Colors.white, fontSize: 18),
                                                                                      ),
                                                                                    ),
                                                                                    onPressed: () async {
                                                                                      Navigator.of(_scaffold.currentContext!).pop();
                                                                                      List<String> listusers = [];
                                                                                      List<String> listmembers = [];
                                                                                      _selectedList.forEach((element) {
                                                                                        listusers.add(element.id);
                                                                                        listmembers.add(element.id);
                                                                                      });

                                                                                      DateTime time = DateTime.now();
                                                                                      DateTime time2 = DateTime.now().add(Duration(seconds: 1));
                                                                                      Map<String, dynamic> broadcastdata = {
                                                                                        Dbkeys.broadcastDESCRIPTION: broadcastdesc.text.isEmpty ? '' : broadcastdesc.text.trim(),
                                                                                        Dbkeys.broadcastCREATEDON: time,
                                                                                        Dbkeys.broadcastCREATEDBY: widget.currentUserNo,
                                                                                        Dbkeys.broadcastNAME: broadcastname.text.isEmpty ? 'Unnamed BroadCast' : broadcastname.text.trim(),
                                                                                        Dbkeys.broadcastADMINLIST: [
                                                                                          widget.currentUserNo
                                                                                        ],
                                                                                        Dbkeys.broadcastID: widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString(),
                                                                                        Dbkeys.broadcastMEMBERSLIST: listmembers,
                                                                                        Dbkeys.broadcastLATESTMESSAGETIME: time.millisecondsSinceEpoch,
                                                                                        Dbkeys.broadcastBLACKLISTED: [],
                                                                                      };

                                                                                      listmembers.forEach((element) {
                                                                                        broadcastdata.putIfAbsent(element.toString(), () => time.millisecondsSinceEpoch);

                                                                                        broadcastdata.putIfAbsent('$element-joinedOn', () => time.millisecondsSinceEpoch);
                                                                                      });
                                                                                      setStateIfMounted(() {
                                                                                        iscreatingbroadcast = true;
                                                                                      });
                                                                                      await FirebaseFirestore.instance.collection(DbPaths.collectionbroadcasts).doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString()).set(broadcastdata).then((value) async {
                                                                                        await FirebaseFirestore.instance.collection(DbPaths.collectionbroadcasts).doc(widget.currentUserNo!.toString() + '--' + time.millisecondsSinceEpoch.toString()).collection(DbPaths.collectionbroadcastsChats).doc(time2.millisecondsSinceEpoch.toString() + '--' + widget.currentUserNo!.toString()).set({
                                                                                          Dbkeys.broadcastmsgCONTENT: '',
                                                                                          Dbkeys.broadcastmsgLISToptional: listmembers,
                                                                                          Dbkeys.broadcastmsgTIME: time2.millisecondsSinceEpoch,
                                                                                          Dbkeys.broadcastmsgSENDBY: widget.currentUserNo,
                                                                                          Dbkeys.broadcastmsgISDELETED: false,
                                                                                          Dbkeys.broadcastmsgTYPE: Dbkeys.broadcastmsgTYPEnotificationAddedUser,
                                                                                        }).then((value) async {
                                                                                          Navigator.of(_scaffold.currentContext!).pop();
                                                                                        }).catchError((err) {
                                                                                          setStateIfMounted(() {
                                                                                            iscreatingbroadcast = false;
                                                                                          });

                                                                                          Fiberchat.toast('Error Creating Broadcast. $err');
                                                                                          // print('Error Creating Broadcast. $err');
                                                                                        });
                                                                                      });
                                                                                    }),
                                                                              ])),
                                                                        );
                                                                      });
                                                            }
                                                          : () async {
                                                              // List<String> listusers = [];
                                                              List<String>
                                                                  listmembers =
                                                                  [];
                                                              _selectedList
                                                                  .forEach(
                                                                      (element) {
                                                                // listusers.add(element[Dbkeys.phone]);
                                                                listmembers.add(
                                                                    element.id);
                                                                // listmembers
                                                                //     .add(widget.currentUserNo!);
                                                              });
                                                              DateTime time =
                                                                  DateTime
                                                                      .now();

                                                              setStateIfMounted(
                                                                  () {
                                                                iscreatingbroadcast =
                                                                    true;
                                                              });

                                                              Map<String,
                                                                      dynamic>
                                                                  docmap = {
                                                                Dbkeys.broadcastMEMBERSLIST:
                                                                    FieldValue
                                                                        .arrayUnion(
                                                                            listmembers)
                                                              };

                                                              _selectedList.forEach(
                                                                  (element) async {
                                                                docmap.putIfAbsent(
                                                                    '${element.id}-joinedOn',
                                                                    () => time
                                                                        .millisecondsSinceEpoch);
                                                              });
                                                              setStateIfMounted(
                                                                  () {});
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      DbPaths
                                                                          .collectionbroadcasts)
                                                                  .doc(widget
                                                                      .broadcastID)
                                                                  .set(
                                                                      docmap,SetOptions(merge: true))
                                                                  .then(
                                                                      (value) async {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        DbPaths
                                                                            .collectionbroadcasts)
                                                                    .doc(widget
                                                                            .currentUserNo!
                                                                            .toString() +
                                                                        '--' +
                                                                        time.millisecondsSinceEpoch
                                                                            .toString())
                                                                    .collection(
                                                                        DbPaths
                                                                            .collectionbroadcastsChats)
                                                                    .doc(time
                                                                            .millisecondsSinceEpoch
                                                                            .toString() +
                                                                        '--' +
                                                                        widget
                                                                            .currentUserNo!
                                                                            .toString())
                                                                    .set({
                                                                  Dbkeys.broadcastmsgCONTENT:
                                                                      '',
                                                                  Dbkeys.broadcastmsgLISToptional:
                                                                      listmembers,
                                                                  Dbkeys.broadcastmsgTIME:
                                                                      time.millisecondsSinceEpoch,
                                                                  Dbkeys.broadcastmsgSENDBY:
                                                                      widget
                                                                          .currentUserNo,
                                                                  Dbkeys.broadcastmsgISDELETED:
                                                                      false,
                                                                  Dbkeys.broadcastmsgTYPE:
                                                                      Dbkeys
                                                                          .broadcastmsgTYPEnotificationAddedUser,
                                                                }).then(
                                                                        (value) async {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                }).catchError(
                                                                        (err) {
                                                                  setStateIfMounted(
                                                                      () {
                                                                    iscreatingbroadcast =
                                                                        false;
                                                                  });

                                                                  Fiberchat
                                                                      .toast(
                                                                    getTranslated(
                                                                        context,
                                                                        'erroraddingbroadcast'),
                                                                  );
                                                                });
                                                              });
                                                            },
                                                )
                                        ],
                                      ),
                                      bottomSheet: _selectedList.length == 0
                                          ? SizedBox(
                                              height: 0,
                                              width: 0,
                                            )
                                          : Container(
                                              padding: EdgeInsets.only(top: 6),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              height: 97,
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _selectedList
                                                      .reversed
                                                      .toList()
                                                      .length,
                                                  itemBuilder:
                                                      (context, int i) {
                                                    return Stack(
                                                      children: [
                                                        Container(
                                                          width: 80,
                                                          padding:
                                                              const EdgeInsets
                                                                      .fromLTRB(
                                                                  11,
                                                                  10,
                                                                  12,
                                                                  10),
                                                          child: Column(
                                                            children: [
                                                              customCircleAvatar(
                                                                  url: _selectedList
                                                                      .reversed
                                                                      .toList()[
                                                                          i]
                                                                      .photoURL,
                                                                  radius: 42),
                                                              SizedBox(
                                                                height: 7,
                                                              ),
                                                              Text(
                                                                _selectedList
                                                                    .reversed
                                                                    .toList()[i]
                                                                    .name,
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Positioned(
                                                          right: 17,
                                                          top: 5,
                                                          child: new InkWell(
                                                            onTap: () {
                                                              setStateIfMounted(
                                                                  () {
                                                                _selectedList.remove(
                                                                    _selectedList
                                                                        .reversed
                                                                        .toList()[i]);
                                                              });
                                                            },
                                                            child:
                                                                new Container(
                                                              width: 20.0,
                                                              height: 20.0,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2.0),
                                                              decoration:
                                                                  new BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              child: Icon(
                                                                Icons.close,
                                                                size: 14,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ), //............
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  }),
                                            ),
                                      body: iscreatingbroadcast == true
                                          ? loading()
                                          : contactsProvider
                                                      .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                      .length ==
                                                  0
                                              ? SingleChildScrollView(
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                      child: Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 20,
                                                                  bottom: 20),
                                                          color: Colors.white,
                                                          width: getContentScreenWidth(
                                                              MediaQuery.of(context)
                                                                  .size
                                                                  .width),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children:
                                                                  noContactsWidget(context)))))
                                              : Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: _selectedList
                                                                  .length ==
                                                              0
                                                          ? 0
                                                          : 80),
                                                  child: SingleChildScrollView(
                                                      physics:
                                                          BouncingScrollPhysics(),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                          child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      top: 20,
                                                                      bottom:
                                                                          20),
                                                              color:
                                                                  Colors.white,
                                                              width: getContentScreenWidth(
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Container(
                                                                      margin: EdgeInsets
                                                                          .fromLTRB(
                                                                              10,
                                                                              15,
                                                                              10,
                                                                              15),
                                                                      height:
                                                                          47,
                                                                      padding:
                                                                          const EdgeInsets.fromLTRB(
                                                                              10,
                                                                              0,
                                                                              10,
                                                                              0),
                                                                      child:
                                                                          TextField(
                                                                        onChanged:
                                                                            (value) {
                                                                          if (value
                                                                              .isEmpty) {
                                                                            setState(() {
                                                                              searchresult = [];
                                                                            });
                                                                          } else {
                                                                            var results =
                                                                                contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.where((element) => element.name!.toLowerCase().contains(value.toLowerCase()) || element.phone.contains(value.toLowerCase())).toList();
                                                                            setState(() {
                                                                              searchresult = results.toList();
                                                                            });
                                                                          }
                                                                        },
                                                                        autocorrect:
                                                                            true,
                                                                        textCapitalization:
                                                                            TextCapitalization.sentences,
                                                                        controller:
                                                                            _tc,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          contentPadding: EdgeInsets.fromLTRB(
                                                                              20,
                                                                              15,
                                                                              20,
                                                                              15),
                                                                          hintText: getTranslated(
                                                                              context,
                                                                              'search'),
                                                                          hintStyle:
                                                                              TextStyle(color: Colors.grey),
                                                                          filled:
                                                                              true,
                                                                          fillColor:
                                                                              Colors.grey[100],
                                                                          enabledBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(30.0)),
                                                                            borderSide:
                                                                                BorderSide(color: Colors.grey[100]!, width: 2),
                                                                          ),
                                                                          focusedBorder:
                                                                              OutlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(30.0)),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: Colors.grey[100]!,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )),
                                                                  (contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.length != 0 &&
                                                                              searchresult.isNotEmpty) ||
                                                                          _tc.text.trim().length != 0
                                                                      ? ListView.builder(
                                                                          shrinkWrap: true,
                                                                          physics: NeverScrollableScrollPhysics(),
                                                                          itemCount: searchresult.length,
                                                                          itemBuilder: (BuildContext context, int i) {
                                                                            var user =
                                                                                searchresult[i];
                                                                            var phone =
                                                                                user.phone;
                                                                            Widget? alreadyAddedUser = widget.isAddingWhileCreatingBroadcast == true
                                                                                ? null
                                                                                : broadcastList.lastWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST].contains(phone)
                                                                                    ? SizedBox()
                                                                                    : null;
                                                                            return alreadyAddedUser ??
                                                                                FutureBuilder<LocalUserData?>(
                                                                                    future: contactsProvider.fetchUserDataFromnLocalOrServer(widget.prefs, phone),
                                                                                    builder: (BuildContext context, AsyncSnapshot<LocalUserData?> snapshot) {
                                                                                      if (snapshot.hasData) {
                                                                                        LocalUserData user = snapshot.data!;
                                                                                        return Container(
                                                                                          color: Colors.white,
                                                                                          child: Column(
                                                                                            children: [
                                                                                              ListTile(
                                                                                                leading: customCircleAvatar(
                                                                                                  url: user.photoURL,
                                                                                                  radius: 42,
                                                                                                ),
                                                                                                trailing: Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(color: fiberchatGrey, width: 1),
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                  ),
                                                                                                  child: _selectedList.lastIndexWhere((element) => element.id == phone) >= 0
                                                                                                      ? Icon(
                                                                                                          Icons.check,
                                                                                                          size: 19.0,
                                                                                                          color: fiberchatPRIMARYcolor,
                                                                                                        )
                                                                                                      : Icon(
                                                                                                          Icons.check,
                                                                                                          color: Colors.transparent,
                                                                                                          size: 19.0,
                                                                                                        ),
                                                                                                ),
                                                                                                title: Text(user.name, style: TextStyle(color: fiberchatBlack)),
                                                                                                subtitle: Text(phone, style: TextStyle(color: fiberchatGrey)),
                                                                                                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                                                                                                onTap: () {
                                                                                                  if (_selectedList.indexWhere((element) => element.id == phone) >= 0) {
                                                                                                    _selectedList.removeAt(_selectedList.indexWhere((element) => element.id == phone));
                                                                                                    setStateIfMounted(() {});
                                                                                                  } else {
                                                                                                    _selectedList.add(snapshot.data!);
                                                                                                    setStateIfMounted(() {});
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                              i == searchresult.length - 1
                                                                                                  ? SizedBox(
                                                                                                      height: 20,
                                                                                                    )
                                                                                                  : Divider(
                                                                                                      height: 7,
                                                                                                    )
                                                                                            ],
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                      return SizedBox();
                                                                                    });
                                                                          })
                                                                      : ListView.builder(
                                                                          shrinkWrap:
                                                                              true,
                                                                          physics:
                                                                              NeverScrollableScrollPhysics(),
                                                                          padding:
                                                                              EdgeInsets.all(10),
                                                                          itemCount: contactsProvider
                                                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                                              .length,
                                                                          itemBuilder:
                                                                              (context, idx) {
                                                                            String
                                                                                phone =
                                                                                contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer[idx].phone;
                                                                            Widget? alreadyAddedUser = widget.isAddingWhileCreatingBroadcast == true
                                                                                ? null
                                                                                : broadcastList.lastWhere((element) => element.docmap[Dbkeys.broadcastID] == widget.broadcastID).docmap[Dbkeys.broadcastMEMBERSLIST].contains(phone)
                                                                                    ? SizedBox()
                                                                                    : null;
                                                                            return alreadyAddedUser ??
                                                                                FutureBuilder<LocalUserData?>(
                                                                                    future: contactsProvider.fetchUserDataFromnLocalOrServer(widget.prefs, phone),
                                                                                    builder: (BuildContext context, AsyncSnapshot<LocalUserData?> snapshot) {
                                                                                      if (snapshot.hasData) {
                                                                                        LocalUserData user = snapshot.data!;
                                                                                        return Container(
                                                                                          color: Colors.white,
                                                                                          child: Column(
                                                                                            children: [
                                                                                              ListTile(
                                                                                                leading: customCircleAvatar(
                                                                                                  url: user.photoURL,
                                                                                                  radius: 42,
                                                                                                ),
                                                                                                trailing: Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(color: fiberchatGrey, width: 1),
                                                                                                    borderRadius: BorderRadius.circular(5),
                                                                                                  ),
                                                                                                  child: _selectedList.lastIndexWhere((element) => element.id == phone) >= 0
                                                                                                      ? Icon(
                                                                                                          Icons.check,
                                                                                                          size: 19.0,
                                                                                                          color: fiberchatPRIMARYcolor,
                                                                                                        )
                                                                                                      : Icon(
                                                                                                          Icons.check,
                                                                                                          color: Colors.transparent,
                                                                                                          size: 19.0,
                                                                                                        ),
                                                                                                ),
                                                                                                title: Text(user.name, style: TextStyle(color: fiberchatBlack)),
                                                                                                subtitle: Text(phone, style: TextStyle(color: fiberchatGrey)),
                                                                                                contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                                                                                                onTap: () {
                                                                                                  if (_selectedList.indexWhere((element) => element.id == phone) >= 0) {
                                                                                                    _selectedList.removeAt(_selectedList.indexWhere((element) => element.id == phone));
                                                                                                    setStateIfMounted(() {});
                                                                                                  } else {
                                                                                                    _selectedList.add(snapshot.data!);
                                                                                                    setStateIfMounted(() {});
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                              idx == contactsProvider.alreadyJoinedSavedUsersPhoneNameAsInServer.length - 1
                                                                                                  ? SizedBox(
                                                                                                      height: 20,
                                                                                                    )
                                                                                                  : Divider(
                                                                                                      height: 7,
                                                                                                    )
                                                                                            ],
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                      return SizedBox();
                                                                                    });
                                                                          },
                                                                        ),
                                                                ],
                                                              )))),
                                                ))));
            }))));
  }
}
