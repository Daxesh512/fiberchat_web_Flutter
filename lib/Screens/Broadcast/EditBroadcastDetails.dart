//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';

import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditBroadcastDetails extends StatefulWidget {
  final String? broadcastName;
  final String? broadcastDesc;
  final String? broadcastID;
  final String currentUserNo;
  final SharedPreferences prefs;
  final bool isadmin;
  EditBroadcastDetails(
      {this.broadcastName,
      this.broadcastDesc,
      required this.isadmin,
      required this.prefs,
      this.broadcastID,
      required this.currentUserNo});
  @override
  State createState() => new EditBroadcastDetailsState();
}

class EditBroadcastDetailsState extends State<EditBroadcastDetails> {
  TextEditingController? controllerName = new TextEditingController();
  TextEditingController? controllerDesc = new TextEditingController();

  bool isLoading = false;

  final FocusNode focusNodeName = new FocusNode();
  final FocusNode focusNodeDesc = new FocusNode();

  String? broadcastTitle;
  String? broadcastDesc;

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
    broadcastDesc = widget.broadcastDesc;
    broadcastTitle = widget.broadcastName;
    controllerName!.text = broadcastTitle!;
    controllerDesc!.text = broadcastDesc!;
  }

  void handleUpdateData() {
    focusNodeName.unfocus();
    focusNodeDesc.unfocus();

    setState(() {
      isLoading = true;
    });
    broadcastTitle =
        controllerName!.text.isEmpty ? broadcastTitle : controllerName!.text;
    broadcastDesc = controllerDesc!.text.isEmpty ? '' : controllerDesc!.text;
    setState(() {});
    FirebaseFirestore.instance
        .collection(DbPaths.collectionbroadcasts)
        .doc(widget.broadcastID)
        .set({
      Dbkeys.broadcastNAME: broadcastTitle,
      Dbkeys.broadcastDESCRIPTION: broadcastDesc,
    }, SetOptions(merge: true)).then((value) async {
      DateTime time = DateTime.now();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectionbroadcasts)
          .doc(widget.broadcastID)
          .collection(DbPaths.collectionbroadcastsChats)
          .doc(time.millisecondsSinceEpoch.toString() +
              '--' +
              widget.currentUserNo)
          .set({
        Dbkeys.broadcastmsgCONTENT: widget.isadmin
            ? getTranslated(context, 'broadcastupdatedbyadmin')
            : '${widget.currentUserNo} ${getTranslated(context, 'updatedbroadcast')}',
        Dbkeys.broadcastmsgLISToptional: [],
        Dbkeys.broadcastmsgTIME: time.millisecondsSinceEpoch,
        Dbkeys.broadcastmsgSENDBY: widget.currentUserNo,
        Dbkeys.broadcastmsgISDELETED: false,
        Dbkeys.broadcastmsgTYPE:
            Dbkeys.broadcastmsgTYPEnotificationUpdatedbroadcastDetails,
      });
      Navigator.of(context).pop();
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
                getTranslated(context, 'editbroadcast'),
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
                    width: getContentScreenWidth(
                        MediaQuery.of(context).size.width),
                    child: Stack(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 25,
                              ),
                              ListTile(
                                  title: TextFormField(
                                autovalidateMode: AutovalidateMode.always,
                                controller: controllerName,
                                validator: (v) {
                                  return v!.isEmpty
                                      ? getTranslated(context, 'validdetails')
                                      : null;
                                },
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(6),
                                  labelStyle: TextStyle(height: 0.8),
                                  labelText:
                                      getTranslated(context, 'broadcastname'),
                                ),
                              )),
                              SizedBox(
                                height: 30,
                              ),
                              ListTile(
                                  title: TextFormField(
                                minLines: 1,
                                maxLines: 10,
                                controller: controllerDesc,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(6),
                                  labelStyle: TextStyle(height: 0.8),
                                  labelText:
                                      getTranslated(context, 'broadcastdesc'),
                                ),
                              )),
                              SizedBox(
                                height: 85,
                              ),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                fiberchatSECONDARYolor)),
                                  ),
                                  color: fiberchatWhite.withOpacity(0.8))
                              : Container(),
                        ),
                      ],
                    ))))));
  }
}
