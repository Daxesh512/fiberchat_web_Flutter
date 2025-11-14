//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:core';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/auth_screens/login.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';

import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/MyElevatedButton/MyElevatedButton.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddunsavedNumber extends StatefulWidget {
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences prefs;
  const AddunsavedNumber(
      {required this.currentUserNo, required this.model, required this.prefs});

  @override
  _AddunsavedNumberState createState() => _AddunsavedNumberState();
}

class _AddunsavedNumberState extends State<AddunsavedNumber> {
  bool? isLoading, isUser = true;
  bool istyping = true;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  getUser(String searchphone) {
    // Fiberchat.toast(searchphone);
    FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .where(Dbkeys.phonenumbervariants, arrayContains: searchphone)
        .get()
        .then((user) {
      if (user.docs.isNotEmpty) {
        setState(() {
          isLoading = false;
          istyping = false;
          isUser = true;

          if (isUser!) {
            // var peer = user;
            widget.model!.addUser(user.docs[0]);
            Navigator.pushReplacement(
                context,
                new MaterialPageRoute(
                    builder: (context) => new ChatScreen(
                        isWideScreenMode: false,
                        isSharingIntentForwarded: false,
                        prefs: widget.prefs,
                        unread: 0,
                        currentUserNo: widget.currentUserNo,
                        model: widget.model!,
                        peerNo: searchphone)));
          }
        });
      } else {
        _phoneNo.clear();
        setState(() {
          isLoading = false;
          isUser = false;
          istyping = false;
        });
        Fiberchat.toast(getTranslated(context, 'usernotjoined'));
      }
    }).catchError((err) {});
  }

  final _phoneNo = TextEditingController();

  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  Widget buildWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(17, 52, 17, 8),
          child: Container(
            margin: EdgeInsets.only(top: 0),

            // padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            // height: 63,
            height: 63,
            // width: w / 1.18,
            child: Form(
              // key: _enterNumberFormKey,
              child: MobileInputWithOutline(
                buttonhintTextColor: fiberchatGrey,
                borderColor: fiberchatGrey.withOpacity(0.2),
                controller: _phoneNo,
                initialCountryCode: DEFAULT_COUNTTRYCODE_ISO,
                onSaved: (phone) {
                  setState(() {
                    phoneCode = phone!.countryCode;
                    istyping = true;
                  });
                },
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(13, 22, 13, 8),
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          fiberchatSECONDARYolor)),
                )
              : MySimpleButton(
                  buttoncolor: fiberchatSECONDARYolor.withOpacity(0.99),
                  buttontext: getTranslated(context, 'searchuser'),
                  onpressed: () {
                    // RegExp e164 = new RegExp(r'^\+[1-9]\d{1,14}$');

                    String _phone = _phoneNo.text.toString().trim();
                    if ((_phone.isNotEmpty) &&
                        widget.currentUserNo != phoneCode! + _phone) {
                      setState(() {
                        isLoading = true;
                      });

                      getUser(phoneCode! + _phone);
                    } else {
                      Fiberchat.toast(
                          widget.currentUserNo != phoneCode! + _phone
                              ? getTranslated(context, 'validnum')
                              : getTranslated(context, 'validnum'));
                    }
                  },
                ),
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
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
          appBar: AppBar(
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
              backgroundColor: fiberchatWhite,
              title: Text(
                getTranslated(
                  context,
                  'chatws',
                ),
                style: TextStyle(
                  fontSize: 17,
                  color: fiberchatBlack,
                ),
              )),
          body: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Container(
                margin: EdgeInsets.only(top: 20, bottom: 20),
                color: Colors.white,
                width: getContentScreenWidth(MediaQuery.of(context).size.width),
                child: Stack(children: <Widget>[
                  Container(
                      child: Center(
                    child: !isUser!
                        ? istyping == true
                            ? SizedBox()
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    SizedBox(
                                      height: 140,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: Text(
                                          phoneCode! +
                                              '-' +
                                              _phoneNo.text.trim() +
                                              ' ' +
                                              getTranslated(
                                                  context, 'notexist') +
                                              Appname,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: fiberchatBlack,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 20.0)),
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    myElevatedButton(
                                      color: Colors.blueGrey,
                                      child: Text(
                                        getTranslated(context, 'invite'),
                                        style: TextStyle(color: fiberchatWhite),
                                      ),
                                      onPressed: () {
                                        Fiberchat.invite(context);
                                      },
                                    ),
                                    SizedBox(
                                      height: 30.0,
                                    ),
                                  ])
                        : Container(),
                  )),
                  // Loading
                  buildWidget()
                ]),
              ))),
          backgroundColor: fiberchatScaffold,
        )));
  }
}
