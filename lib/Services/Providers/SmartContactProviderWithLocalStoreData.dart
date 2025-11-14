import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/Dbpaths.dart';
import 'package:fiberchat_web/Screens/chat_screen/utils/aes_encryption.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUserData {
  final lastUpdated, userType;
  final Int8List? photoBytes;
  final String id, name, photoURL, aboutUser;
  final List<dynamic> idVariants;

  LocalUserData({
    required this.id,
    required this.idVariants,
    required this.userType,
    required this.aboutUser,
    required this.lastUpdated,
    required this.name,
    required this.photoURL,
    this.photoBytes,
  });

  factory LocalUserData.fromJson(Map<String, dynamic> jsonData) {
    return LocalUserData(
      id: jsonData['id'],
      aboutUser: jsonData['about'],
      idVariants: jsonData['idVars'],
      name: jsonData['name'],
      photoURL: jsonData['url'],
      photoBytes: jsonData['bytes'],
      userType: jsonData['type'],
      lastUpdated: jsonData['time'],
    );
  }

  Map<String, dynamic> toMapp(LocalUserData user) {
    return {
      'id': user.id,
      'about': user.aboutUser,
      'idVars': user.idVariants,
      'name': user.name,
      'url': user.photoURL,
      'bytes': user.photoBytes,
      'type': user.userType,
      'time': user.lastUpdated,
    };
  }

  static Map<String, dynamic> toMap(LocalUserData user) => {
        'id': user.id,
        'about': user.aboutUser,
        'idVars': user.idVariants,
        'name': user.name,
        'url': user.photoURL,
        'bytes': user.photoBytes,
        'type': user.userType,
        'time': user.lastUpdated,
      };

  static String encode(List<LocalUserData> users) => json.encode(
        users
            .map<Map<String, dynamic>>((user) => LocalUserData.toMap(user))
            .toList(),
      );

  static List<LocalUserData> decode(String users) =>
      (json.decode(users) as List<dynamic>)
          .map<LocalUserData>((item) => LocalUserData.fromJson(item))
          .toList();
}

class SmartContactProviderWithLocalStoreData with ChangeNotifier {
  //********---LOCAL STORE USER DATA PREVIUSLY FETCHED IN PREFS::::::::-----
  int daysToUpdateCache = 7;
  var usersDocsRefinServer =
      FirebaseFirestore.instance.collection(DbPaths.collectionusers);
  List<LocalUserData> localUsersLIST = [];
  String localUsersSTRING = "";
  List<dynamic> currentUserPhoneNumberVariants = [];
  int? lastSyncedTime;
  syncContactsFromCloud(
    BuildContext context,
    String currentuserid,
    SharedPreferences prefs,
  ) async {
    String? sharedSecret;

    await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(currentuserid)
        .get()
        .then((doc) async {
      if (doc.exists) {
        if (!doc.data()!.containsKey(Dbkeys.lastSyncedID)) {
          lastSyncedTime = null;
          alreadyJoinedSavedUsersPhoneNameAsInServer = [];
          notifyListeners();
          // Fiberchat.toast(getTranslated(context, 'nocontactsavailable'));
        } else {
          try {
            sharedSecret = doc.data()![Dbkeys.lastSyncedID];
          } catch (e) {
            sharedSecret = null;
          }
          if (sharedSecret == null) {
            Fiberchat.toast(
                "${getTranslated(context, 'failedtosync')}. Failed to de-encrpyt");
          } else {
            await FirebaseFirestore.instance
                .collection(DbPaths.collectionusers)
                .doc(currentuserid)
                .collection(Dbkeys.lastSyncedContacts)
                .doc(Dbkeys.lastSyncedContacts)
                .get()
                .then((v) async {
              if (v.exists) {
                lastSyncedTime = v.data()![Dbkeys.lastSyncedTime];
                var deencrpted = await AESEncryptData.decryptAES(
                    v.data()![Dbkeys.lastSyncedContacts],
                    doc[Dbkeys.lastSyncedID]!);
                alreadyJoinedSavedUsersPhoneNameAsInServer =
                    DeviceContactIdAndName.decode(deencrpted!);
                // alreadyJoinedSavedUsersPhoneNameAsInServer
                //     .sort((a, b) => a.name!.compareTo(b.name!));
                List<DeviceContactIdAndName> list = [];
                for (var user in alreadyJoinedSavedUsersPhoneNameAsInServer) {
                  var b =
                      await fetchUserDataFromnLocalOrServer(prefs, user.phone);
                  if (b == null) {
                    list.add(user);
                  } else {
                    list.add(DeviceContactIdAndName(
                        phone: user.phone, name: b.name));
                  }
                }
                alreadyJoinedSavedUsersPhoneNameAsInServer = list;
                alreadyJoinedSavedUsersPhoneNameAsInServer
                    .sort((a, b) => a.name!.compareTo(b.name!));
                notifyListeners();
              } else {
                alreadyJoinedSavedUsersPhoneNameAsInServer = [];
                lastSyncedTime = null;
                notifyListeners();
                Fiberchat.toast(getTranslated(context, 'nocontactsavailable'));
              }
            });
          }
        }
      }
    }).catchError((e) {
      alreadyJoinedSavedUsersPhoneNameAsInServer = [];
      lastSyncedTime = null;
      notifyListeners();
      Fiberchat.toast("${getTranslated(context, 'failedtosync')} $e");
    });
  }

  addORUpdateLocalUserDataMANUALLY(
      {required SharedPreferences prefs,
      required LocalUserData localUserData,
      required bool isNotifyListener}) {
    int ind =
        localUsersLIST.indexWhere((element) => element.id == localUserData.id);
    if (ind >= 0) {
      if (localUsersLIST[ind].name.toString() !=
              localUserData.name.toString() ||
          localUsersLIST[ind].photoURL.toString() !=
              localUserData.photoURL.toString()) {
        localUsersLIST.removeAt(ind);
        localUsersLIST.insert(ind, localUserData);
        localUsersLIST.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        if (isNotifyListener == true) {
          notifyListeners();
        }
        saveFetchedLocalUsersInPrefs(prefs);
      }
    } else {
      localUsersLIST.add(localUserData);
      localUsersLIST
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      if (isNotifyListener == true) {
        notifyListeners();
      }
      saveFetchedLocalUsersInPrefs(prefs);
    }
  }

  Future<LocalUserData?> fetchUserDataFromnLocalOrServer(
      SharedPreferences prefs, String userid) async {
    int ind = localUsersLIST.indexWhere((element) => element.id == userid);
    if (ind >= 0) {
      // print ("LOADED ${localUsersLIST[ind].id} LOCALLY ");
      LocalUserData localUser = localUsersLIST[ind];
      if (DateTime.now()
              .difference(
                  DateTime.fromMillisecondsSinceEpoch(localUser.lastUpdated))
              .inDays >
          daysToUpdateCache) {
        DocumentSnapshot<Map<String, dynamic>> doc =
            await usersDocsRefinServer.doc(localUser.id).get();
        if (doc.exists) {
          var updatedUserData = LocalUserData(
              aboutUser: doc.data()![Dbkeys.aboutMe] ?? "",
              idVariants: doc.data()![Dbkeys.phonenumbervariants] ?? [userid],
              id: localUser.id,
              userType: 0,
              lastUpdated: DateTime.now().millisecondsSinceEpoch,
              name: doc.data()![Dbkeys.nickname],
              photoURL: doc.data()![Dbkeys.photoUrl] ?? "");
          // print ("UPDATED ${localUser.id} LOCALLY AFTER EXPIRED");
          addORUpdateLocalUserDataMANUALLY(
              prefs: prefs,
              isNotifyListener: false,
              localUserData: updatedUserData);
          return Future.value(updatedUserData);
        } else {
          return Future.value(localUser);
        }
      } else {
        return Future.value(localUser);
      }
    } else {
      DocumentSnapshot<Map<String, dynamic>> doc =
          await usersDocsRefinServer.doc(userid).get();
      if (doc.exists) {
        // print ("LOADED ${doc.data()![Dbkeys.phone]} SERVER ");
        var updatedUserData = LocalUserData(
            aboutUser: doc.data()![Dbkeys.aboutMe] ?? "",
            idVariants: doc.data()![Dbkeys.phonenumbervariants] ?? [userid],
            id: doc.data()![Dbkeys.phone],
            userType: 0,
            lastUpdated: DateTime.now().millisecondsSinceEpoch,
            name: doc.data()![Dbkeys.nickname],
            photoURL: doc.data()![Dbkeys.photoUrl] ?? "");

        addORUpdateLocalUserDataMANUALLY(
            prefs: prefs,
            isNotifyListener: false,
            localUserData: updatedUserData);
        return Future.value(updatedUserData);
      } else {
        return Future.value(null);
      }
    }
  }

  fetchFromFiretsoreAndReturnData(SharedPreferences prefs, String userid,
      Function(DocumentSnapshot<Map<String, dynamic>> doc) onReturnData) async {
    var doc = await usersDocsRefinServer.doc(userid).get();
    if (doc.exists && doc.data() != null) {
      onReturnData(doc);
      addORUpdateLocalUserDataMANUALLY(
          isNotifyListener: true,
          prefs: prefs,
          localUserData: LocalUserData(
              id: userid,
              idVariants: doc.data()![Dbkeys.phonenumbervariants],
              userType: 0,
              aboutUser: doc.data()![Dbkeys.aboutMe],
              lastUpdated: DateTime.now().millisecondsSinceEpoch,
              name: doc.data()![Dbkeys.nickname],
              photoURL: doc.data()![Dbkeys.photoUrl] ?? ""));
    }
  }

  fetchLocalUsersFromPrefs(SharedPreferences prefs, BuildContext context,
      String currentuserid) async {
    localUsersSTRING = prefs.getString('localUsersSTRING') ?? "";
    // String? localUsersDEVICECONTACT =
    //     prefs.getString('localUsersDEVICECONTACT') ?? "";

    if (localUsersSTRING != "") {
      localUsersLIST = LocalUserData.decode(localUsersSTRING);
      localUsersLIST
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      // for (var user in localUsersLIST) {
      //   alreadyJoinedSavedUsersPhoneNameAsInServer = [];
      //   if (user.id != phone) {
      //     alreadyJoinedSavedUsersPhoneNameAsInServer
      //         .add(DeviceContactIdAndName(phone: phone, name: user.name));
      //   }
      // }
      await syncContactsFromCloud(context, currentuserid, prefs);
      // print ("FOUND ${localUsersLIST.length} LOCAL USERS STORED - at start");
      searchingcontactsindatabase = false;
      notifyListeners();
    } else {
      await syncContactsFromCloud(context, currentuserid, prefs);
      searchingcontactsindatabase = false;
      notifyListeners();
    }

    // if (localUsersDEVICECONTACT != "") {
    //   alreadyJoinedSavedUsersPhoneNameAsInServer =
    //       DeviceContactIdAndName.decode(localUsersDEVICECONTACT);
    //   alreadyJoinedSavedUsersPhoneNameAsInServer.sort((a, b) =>
    //       (a.name ?? "").toLowerCase().compareTo((b.name ?? "").toLowerCase()));
    // }
  }

  saveFetchedLocalUsersInPrefs(SharedPreferences prefs) async {
    if (searchingcontactsindatabase == false) {
      localUsersSTRING = LocalUserData.encode(localUsersLIST);
      await prefs.setString('localUsersSTRING', localUsersSTRING);
      // List<DeviceContactIdAndName> list = [];
      // list = localUsersLIST
      //     .map((e) => DeviceContactIdAndName(phone: e.id, name: e.name))
      //     .toList();
      // String? localUsersDEVICECONTACT = DeviceContactIdAndName.encode(list);
      // await prefs.setString('localUsersDEVICECONTACT', localUsersDEVICECONTACT);
      // print ("SAVED ${localUsersLIST.length} LOCAL USERS - at end");
    }
  }

  //********---DEVICE CONTACT FETCH STARTS BELOW::::::::-----

  List<DeviceContactIdAndName> previouslyFetchedKEYPhoneInSharedPrefs = [];
  List<DeviceContactIdAndName> alreadyJoinedSavedUsersPhoneNameAsInServer = [];

//-------
  Map<String?, String?>? contactsBookContactList = new Map<String, String>();
  bool searchingcontactsindatabase = true;

  String getUserNameOrIdQuickly(String userid) {
    if (localUsersLIST.indexWhere((element) => element.id == userid) >= 0) {
      return localUsersLIST[
              localUsersLIST.indexWhere((element) => element.id == userid)]
          .name;
    } else {
      return 'User';
    }
  }
}

class DeviceContactIdAndName {
  final String phone;
  final String? name;

  DeviceContactIdAndName({
    required this.phone,
    this.name,
  });

  factory DeviceContactIdAndName.fromJson(Map<String, dynamic> jsonData) {
    return DeviceContactIdAndName(
      phone: jsonData['id'],
      name: jsonData['name'],
    );
  }

  static Map<String, dynamic> toMap(DeviceContactIdAndName contact) => {
        'id': contact.phone,
        'name': contact.name,
      };

  static String encode(List<DeviceContactIdAndName> contacts) => json.encode(
        contacts
            .map<Map<String, dynamic>>(
                (contact) => DeviceContactIdAndName.toMap(contact))
            .toList(),
      );

  static List<DeviceContactIdAndName> decode(String contacts) =>
      (json.decode(contacts) as List<dynamic>)
          .map<DeviceContactIdAndName>(
              (item) => DeviceContactIdAndName.fromJson(item))
          .toList();
}
