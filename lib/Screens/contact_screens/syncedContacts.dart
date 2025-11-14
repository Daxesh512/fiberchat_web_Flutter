//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Screens/call_history/callhistory.dart';
import 'package:fiberchat_web/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat_web/Utils/formatStatusTime.dart';
import 'package:fiberchat_web/Services/Providers/SmartContactProviderWithLocalStoreData.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Screens/chat_screen/chat.dart';
import 'package:fiberchat_web/Screens/chat_screen/pre_chat.dart';
import 'package:fiberchat_web/Screens/contact_screens/AddunsavedContact.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:fiberchat_web/Utils/chat_controller.dart';
import 'package:fiberchat_web/Utils/determine_screen.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncedContacts extends StatefulWidget {
  final String currentUserNo;
  final DataModel model;
  final bool biometricEnabled;
  final SharedPreferences prefs;
  final Function onTapCreateGroup;
  final Function onTapCreateBroadcast;
  const SyncedContacts({
    Key? key,
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.onTapCreateBroadcast,
    required this.prefs,
    required this.onTapCreateGroup,
  }) : super(key: key);

  @override
  _SyncedContactsState createState() => _SyncedContactsState();
}

class _SyncedContactsState extends State<SyncedContacts>
    with TickerProviderStateMixin {
  TextEditingController _tc = new TextEditingController();
  List<DeviceContactIdAndName> searchresult = [];
  @override
  void dispose() {
    super.dispose();
    _tc.dispose();
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
        prefs: widget.prefs,
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<SmartContactProviderWithLocalStoreData>(
                  builder: (context, availableContacts, _child) {
                // _filtered = availableContacts.filtered;
                return Scaffold(
                    backgroundColor: fiberchatScaffold,
                    appBar: AppBar(
                      elevation: 0.4,
                      titleSpacing: 5,
                      title: Column(
                        children: [
                          new Text(
                            getTranslated(context, 'contacts'),
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: fiberchatBlack,
                            ),
                          ),
                          if (availableContacts.lastSyncedTime != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: new Text(
                                "${getTranslated(context, 'lastsynced')}: ${getStatusTime(availableContacts.lastSyncedTime, context)}",
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w400,
                                  color: fiberchatGrey,
                                ),
                              ),
                            ),
                        ],
                      ),
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
                      actions: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(
                              isWideScreen(MediaQuery.of(context).size.width)
                                  ? 10.0
                                  : 0),
                          child: IconButton(
                            icon: Icon(
                              Icons.sync,
                              color: fiberchatPRIMARYcolor,
                            ),
                            onPressed: () async {
                              final SmartContactProviderWithLocalStoreData
                                  contactsProvider = Provider.of<
                                          SmartContactProviderWithLocalStoreData>(
                                      context,
                                      listen: false);
                              Fiberchat.toast(
                                  getTranslated(context, "loading"));
                              contactsProvider.syncContactsFromCloud(
                                  context, widget.currentUserNo, widget.prefs);
                            },
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.all(
                                isWideScreen(MediaQuery.of(context).size.width)
                                    ? 10.0
                                    : 0),
                            child: IconButton(
                              icon: Icon(
                                Icons.person_add,
                                color: fiberchatPRIMARYcolor,
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(context,
                                    new MaterialPageRoute(builder: (context) {
                                  return new AddunsavedNumber(
                                      prefs: widget.prefs,
                                      model: widget.model,
                                      currentUserNo: widget.currentUserNo);
                                }));
                              },
                            )),
                      ],
                    ),
                    body: availableContacts
                                .alreadyJoinedSavedUsersPhoneNameAsInServer
                                .length ==
                            0
                        ?

                        //  availableContacts.joinedcontactsInSharePref.length ==
                        //             0 ||
                        Center(
                            child: Container(
                            margin: EdgeInsets.only(top: 20, bottom: 20),
                            color: Colors.white,
                            width: getContentScreenWidth(
                                MediaQuery.of(context).size.width),
                            child: Center(
                              child: ListView(
                                  physics: BouncingScrollPhysics(),
                                  children: noContactsWidget(context)),
                            ),
                          ))
                        : SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                                child: Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 20),
                                    color: Colors.white,
                                    width: getContentScreenWidth(
                                        MediaQuery.of(context).size.width),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              margin: EdgeInsets.fromLTRB(
                                                  10, 15, 10, 15),
                                              height: 47,
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 0, 10, 0),
                                              child: TextField(
                                                onChanged: (value) {
                                                  if (value.isEmpty) {
                                                    setState(() {
                                                      searchresult = [];
                                                    });
                                                  } else {
                                                    var results = availableContacts
                                                        .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                        .where((element) =>
                                                            element.name!
                                                                .toLowerCase()
                                                                .contains(value
                                                                    .toLowerCase()) ||
                                                            element.phone
                                                                .contains(value
                                                                    .toLowerCase()))
                                                        .toList();
                                                    setState(() {
                                                      searchresult =
                                                          results.toList();
                                                    });
                                                  }
                                                },
                                                autocorrect: true,
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller: _tc,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.fromLTRB(
                                                          20, 15, 20, 15),
                                                  hintText: getTranslated(
                                                      context, 'search'),
                                                  hintStyle: TextStyle(
                                                      color: Colors.grey),
                                                  filled: true,
                                                  fillColor: Colors.grey[100],
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30.0)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[100]!,
                                                        width: 2),
                                                  ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                30.0)),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[100]!,
                                                    ),
                                                  ),
                                                ),
                                              )),
                                          (availableContacts.alreadyJoinedSavedUsersPhoneNameAsInServer
                                                              .length !=
                                                          0 &&
                                                      searchresult
                                                          .isNotEmpty) ||
                                                  _tc.text.trim().length != 0
                                              ? ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      searchresult.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int i) {
                                                    var user = searchresult[i];
                                                    var name = user.name ?? "";
                                                    var phone = user.phone;
                                                    return FutureBuilder<
                                                        LocalUserData?>(
                                                      future: availableContacts
                                                          .fetchUserDataFromnLocalOrServer(
                                                              widget.prefs,
                                                              phone),
                                                      builder: (BuildContext
                                                              context,
                                                          AsyncSnapshot<
                                                                  LocalUserData?>
                                                              snapshot) {
                                                        if (snapshot.hasData &&
                                                            snapshot.data !=
                                                                null) {
                                                          return ListTile(
                                                            tileColor:
                                                                Colors.white,
                                                            leading:
                                                                customCircleAvatar(
                                                                    url: snapshot
                                                                        .data!
                                                                        .photoURL,
                                                                    radius: 45),
                                                            title: Text(name,
                                                                style: TextStyle(
                                                                    color:
                                                                        fiberchatBlack)),
                                                            subtitle: Text(
                                                                phone,
                                                                style: TextStyle(
                                                                    color:
                                                                        fiberchatGrey)),
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        22.0,
                                                                    vertical:
                                                                        0.0),
                                                            onTap: () {
                                                              hidekeyboard(
                                                                  context);
                                                              dynamic wUser =
                                                                  model.userData[
                                                                      phone];
                                                              if (wUser !=
                                                                      null &&
                                                                  wUser[Dbkeys
                                                                          .chatStatus] !=
                                                                      null) {
                                                                if (model.currentUser![Dbkeys
                                                                            .locked] !=
                                                                        null &&
                                                                    model
                                                                        .currentUser![Dbkeys
                                                                            .locked]
                                                                        .contains(
                                                                            phone)) {
                                                                  ChatController.authenticate(
                                                                      model,
                                                                      getTranslated(
                                                                          context,
                                                                          'auth_neededchat'),
                                                                      prefs: widget
                                                                          .prefs,
                                                                      shouldPop:
                                                                          false,
                                                                      state: Navigator.of(
                                                                          context),
                                                                      type: Fiberchat.getAuthenticationType(
                                                                          widget
                                                                              .biometricEnabled,
                                                                          model),
                                                                      onSuccess:
                                                                          () {
                                                                    Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        new MaterialPageRoute(
                                                                            builder: (context) => new ChatScreen(
                                                                                isWideScreenMode: false,
                                                                                isSharingIntentForwarded: false,
                                                                                prefs: widget.prefs,
                                                                                model: model,
                                                                                currentUserNo: widget.currentUserNo,
                                                                                peerNo: phone,
                                                                                unread: 0)),
                                                                        (Route r) => r.isFirst);
                                                                  });
                                                                } else {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isWideScreenMode: false,
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)));
                                                                }
                                                              } else {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder:
                                                                            (context) {
                                                                  return new PreChat(
                                                                      prefs: widget
                                                                          .prefs,
                                                                      model: widget
                                                                          .model,
                                                                      name:
                                                                          name,
                                                                      phone:
                                                                          phone,
                                                                      currentUserNo:
                                                                          widget
                                                                              .currentUserNo);
                                                                }));
                                                              }
                                                            },
                                                          );
                                                        }
                                                        return ListTile(
                                                          tileColor:
                                                              Colors.white,
                                                          leading:
                                                              customCircleAvatar(
                                                                  radius: 45),
                                                          title: Text(name,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatBlack)),
                                                          subtitle: Text(phone,
                                                              style: TextStyle(
                                                                  color:
                                                                      fiberchatGrey)),
                                                          contentPadding:
                                                              EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          22.0,
                                                                      vertical:
                                                                          0.0),
                                                          onTap: () {
                                                            hidekeyboard(
                                                                context);
                                                            dynamic wUser =
                                                                model.userData[
                                                                    phone];
                                                            if (wUser != null &&
                                                                wUser[Dbkeys
                                                                        .chatStatus] !=
                                                                    null) {
                                                              if (model.currentUser![
                                                                          Dbkeys
                                                                              .locked] !=
                                                                      null &&
                                                                  model
                                                                      .currentUser![
                                                                          Dbkeys
                                                                              .locked]
                                                                      .contains(
                                                                          phone)) {
                                                                ChatController.authenticate(
                                                                    model,
                                                                    getTranslated(
                                                                        context,
                                                                        'auth_neededchat'),
                                                                    prefs: widget
                                                                        .prefs,
                                                                    shouldPop:
                                                                        false,
                                                                    state: Navigator.of(
                                                                        context),
                                                                    type: Fiberchat.getAuthenticationType(
                                                                        widget
                                                                            .biometricEnabled,
                                                                        model),
                                                                    onSuccess:
                                                                        () {
                                                                  Navigator.pushAndRemoveUntil(
                                                                      context,
                                                                      new MaterialPageRoute(
                                                                          builder: (context) => new ChatScreen(
                                                                              isWideScreenMode: false,
                                                                              isSharingIntentForwarded: false,
                                                                              prefs: widget.prefs,
                                                                              model: model,
                                                                              currentUserNo: widget.currentUserNo,
                                                                              peerNo: phone,
                                                                              unread: 0)),
                                                                      (Route r) => r.isFirst);
                                                                });
                                                              } else {
                                                                Navigator.pushReplacement(
                                                                    context,
                                                                    new MaterialPageRoute(
                                                                        builder: (context) => new ChatScreen(
                                                                            isWideScreenMode:
                                                                                false,
                                                                            isSharingIntentForwarded:
                                                                                false,
                                                                            prefs: widget
                                                                                .prefs,
                                                                            model:
                                                                                model,
                                                                            currentUserNo: widget
                                                                                .currentUserNo,
                                                                            peerNo:
                                                                                phone,
                                                                            unread:
                                                                                0)));
                                                              }
                                                            } else {
                                                              Navigator.pushReplacement(
                                                                  context,
                                                                  new MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return new PreChat(
                                                                    prefs: widget
                                                                        .prefs,
                                                                    model: widget
                                                                        .model,
                                                                    name: name,
                                                                    phone:
                                                                        phone,
                                                                    currentUserNo:
                                                                        widget
                                                                            .currentUserNo);
                                                              }));
                                                            }
                                                          },
                                                        );
                                                      },
                                                    );
                                                  })
                                              : Column(children: [
                                                  ListTile(
                                                    tileColor: Colors.white,
                                                    leading: CircleAvatar(
                                                        backgroundColor:
                                                            fiberchatSECONDARYolor,
                                                        radius: 22.5,
                                                        child: Icon(
                                                          Icons.group,
                                                          color: Colors.white,
                                                        )),
                                                    title: Text(
                                                      getTranslated(context,
                                                          'creategroup'),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 22.0,
                                                            vertical: 11.0),
                                                    onTap: () {
                                                      widget.onTapCreateGroup();
                                                    },
                                                  ),
                                                  ListTile(
                                                    tileColor: Colors.white,
                                                    leading: CircleAvatar(
                                                        backgroundColor:
                                                            fiberchatSECONDARYolor,
                                                        radius: 22.5,
                                                        child: Icon(
                                                          Icons.campaign,
                                                          color: Colors.white,
                                                        )),
                                                    title: Text(
                                                      getTranslated(context,
                                                          'newbroadcast'),
                                                    ),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 22.0,
                                                            vertical: 11.0),
                                                    onTap: () {
                                                      widget
                                                          .onTapCreateBroadcast();
                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 14,
                                                  ),
                                                  availableContacts
                                                              .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                              .length ==
                                                          0
                                                      ? SizedBox(
                                                          height: 0,
                                                        )
                                                      : ListView.builder(
                                                          shrinkWrap: true,
                                                          physics:
                                                              NeverScrollableScrollPhysics(),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  00),
                                                          itemCount:
                                                              availableContacts
                                                                  .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                                  .length,
                                                          itemBuilder:
                                                              (context, idx) {
                                                            DeviceContactIdAndName
                                                                user =
                                                                availableContacts
                                                                    .alreadyJoinedSavedUsersPhoneNameAsInServer
                                                                    .elementAt(
                                                                        idx);
                                                            String phone =
                                                                user.phone;
                                                            String name =
                                                                user.name ??
                                                                    user.phone;
                                                            return FutureBuilder<
                                                                LocalUserData?>(
                                                              future: availableContacts
                                                                  .fetchUserDataFromnLocalOrServer(
                                                                      widget
                                                                          .prefs,
                                                                      phone),
                                                              builder: (BuildContext
                                                                      context,
                                                                  AsyncSnapshot<
                                                                          LocalUserData?>
                                                                      snapshot) {
                                                                if (snapshot
                                                                        .hasData &&
                                                                    snapshot.data !=
                                                                        null) {
                                                                  return ListTile(
                                                                    tileColor:
                                                                        Colors
                                                                            .white,
                                                                    leading: customCircleAvatar(
                                                                        url: snapshot
                                                                            .data!
                                                                            .photoURL,
                                                                        radius:
                                                                            45),
                                                                    title: Text(
                                                                        name,
                                                                        style: TextStyle(
                                                                            color:
                                                                                fiberchatBlack)),
                                                                    subtitle: Text(
                                                                        phone,
                                                                        style: TextStyle(
                                                                            color:
                                                                                fiberchatGrey)),
                                                                    contentPadding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            22.0,
                                                                        vertical:
                                                                            0.0),
                                                                    onTap: () {
                                                                      hidekeyboard(
                                                                          context);
                                                                      dynamic
                                                                          wUser =
                                                                          model.userData[
                                                                              phone];
                                                                      if (wUser !=
                                                                              null &&
                                                                          wUser[Dbkeys.chatStatus] !=
                                                                              null) {
                                                                        if (model.currentUser![Dbkeys.locked] !=
                                                                                null &&
                                                                            model.currentUser![Dbkeys.locked].contains(phone)) {
                                                                          ChatController.authenticate(
                                                                              model,
                                                                              getTranslated(context, 'auth_neededchat'),
                                                                              prefs: widget.prefs,
                                                                              shouldPop: false,
                                                                              state: Navigator.of(context),
                                                                              type: Fiberchat.getAuthenticationType(widget.biometricEnabled, model), onSuccess: () {
                                                                            Navigator.pushAndRemoveUntil(
                                                                                context,
                                                                                new MaterialPageRoute(builder: (context) => new ChatScreen(isWideScreenMode: false, isSharingIntentForwarded: false, prefs: widget.prefs, model: model, currentUserNo: widget.currentUserNo, peerNo: phone, unread: 0)),
                                                                                (Route r) => r.isFirst);
                                                                          });
                                                                        } else {
                                                                          Navigator.pushReplacement(
                                                                              context,
                                                                              new MaterialPageRoute(builder: (context) => new ChatScreen(isWideScreenMode: false, isSharingIntentForwarded: false, prefs: widget.prefs, model: model, currentUserNo: widget.currentUserNo, peerNo: phone, unread: 0)));
                                                                        }
                                                                      } else {
                                                                        Navigator.pushReplacement(
                                                                            context,
                                                                            new MaterialPageRoute(builder:
                                                                                (context) {
                                                                          return new PreChat(
                                                                              prefs: widget.prefs,
                                                                              model: widget.model,
                                                                              name: name,
                                                                              phone: phone,
                                                                              currentUserNo: widget.currentUserNo);
                                                                        }));
                                                                      }
                                                                    },
                                                                  );
                                                                }
                                                                return ListTile(
                                                                  tileColor:
                                                                      Colors
                                                                          .white,
                                                                  leading:
                                                                      customCircleAvatar(
                                                                          radius:
                                                                              45),
                                                                  title: Text(
                                                                      name,
                                                                      style: TextStyle(
                                                                          color:
                                                                              fiberchatBlack)),
                                                                  subtitle: Text(
                                                                      phone,
                                                                      style: TextStyle(
                                                                          color:
                                                                              fiberchatGrey)),
                                                                  contentPadding: EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          22.0,
                                                                      vertical:
                                                                          0.0),
                                                                  onTap: () {
                                                                    hidekeyboard(
                                                                        context);
                                                                    dynamic
                                                                        wUser =
                                                                        model.userData[
                                                                            phone];
                                                                    if (wUser !=
                                                                            null &&
                                                                        wUser[Dbkeys.chatStatus] !=
                                                                            null) {
                                                                      if (model.currentUser![Dbkeys.locked] !=
                                                                              null &&
                                                                          model
                                                                              .currentUser![Dbkeys.locked]
                                                                              .contains(phone)) {
                                                                        ChatController.authenticate(
                                                                            model,
                                                                            getTranslated(
                                                                                context, 'auth_neededchat'),
                                                                            prefs: widget
                                                                                .prefs,
                                                                            shouldPop:
                                                                                false,
                                                                            state: Navigator.of(
                                                                                context),
                                                                            type:
                                                                                Fiberchat.getAuthenticationType(widget.biometricEnabled, model),
                                                                            onSuccess:
                                                                                () {
                                                                          Navigator.pushAndRemoveUntil(
                                                                              context,
                                                                              new MaterialPageRoute(builder: (context) => new ChatScreen(isWideScreenMode: false, isSharingIntentForwarded: false, prefs: widget.prefs, model: model, currentUserNo: widget.currentUserNo, peerNo: phone, unread: 0)),
                                                                              (Route r) => r.isFirst);
                                                                        });
                                                                      } else {
                                                                        Navigator.pushReplacement(
                                                                            context,
                                                                            new MaterialPageRoute(builder: (context) => new ChatScreen(isWideScreenMode: false, isSharingIntentForwarded: false, prefs: widget.prefs, model: model, currentUserNo: widget.currentUserNo, peerNo: phone, unread: 0)));
                                                                      }
                                                                    } else {
                                                                      Navigator.pushReplacement(
                                                                          context,
                                                                          new MaterialPageRoute(builder:
                                                                              (context) {
                                                                        return new PreChat(
                                                                            prefs: widget
                                                                                .prefs,
                                                                            model: widget
                                                                                .model,
                                                                            name:
                                                                                name,
                                                                            phone:
                                                                                phone,
                                                                            currentUserNo:
                                                                                widget.currentUserNo);
                                                                      }));
                                                                    }
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          },
                                                        ),
                                                ])
                                        ]))),
                          ));
              });
            }))));
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
}

noContactsWidget(BuildContext context) {
  return [
    Center(
        child: Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).size.height / 9,
          bottom: MediaQuery.of(context).size.height / 18),
      child: Icon(
        Icons.devices,
        color: fiberchatSECONDARYolor,
        size: getContentScreenWidth(MediaQuery.of(context).size.width) / 7,
      ),
    )),
    Center(
        child: Text(
      getTranslated(context, 'nosynced'),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    )),
    Center(
        child: Padding(
      padding: const EdgeInsets.all(28.0),
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            // TextSpan(text: '${getTranslated(context, 'loginto')} '),
            TextSpan(
              text: getTranslated(context, 'androidiosapp'),
              style: TextStyle(
                  color: fiberchatSECONDARYolor, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${getTranslated(context, 'open')} > '),
            TextSpan(
              text: getTranslated(context, 'contacts'),
              style: TextStyle(
                  color: fiberchatPRIMARYcolor, fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' > '),
            TextSpan(
              text: getTranslated(context, 'synctoweb'),
              style: TextStyle(
                  color: fiberchatPRIMARYcolor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    )),
    Center(
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              color: fiberchatGrey.withOpacity(0.6),
              size: 18,
            ),
            SizedBox(
              width: 7,
            ),
            Text(
              getTranslated(context, 'endtoendencryption'),
              style: TextStyle(color: fiberchatGrey),
            ),
          ],
        ),
      ),
    ),
    SizedBox(
      height: 40,
    )
  ];
}
