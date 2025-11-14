//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:io';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Models/DataModel.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'package:fiberchat_web/Configs/Enum.dart';
import 'package:http/http.dart' as http;

class Fiberchat {
  static String? getNickname(Map<String, dynamic> user) =>
      user[Dbkeys.aliasName] ?? user[Dbkeys.nickname];

  static void toast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: fiberchatBlack.withOpacity(0.95),
        textColor: fiberchatWhite);
  }

  static void internetLookUp() async {
    // try {
    //   await InternetAddress.lookup('google.com').catchError((e) {
    //     Fiberchat.toast(
    //         'No internet connection. Please check your Internet Connection.');
    //   });
    // } catch (err) {
    //   Fiberchat.toast(err.toString());
    //   print(err);
    // }
    try {
      final result = await http.get(Uri.parse('https://www.google.co.in/'));
      if (result.statusCode == 200) {
      } else {
        Fiberchat.toast(
            'No internet connection. Please check your Internet Connection.');
      }
    } on SocketException catch (err) {
      Fiberchat.toast(err.toString());
    }
  }

  static void invite(BuildContext context) {
    // final observer = Provider.of<Observer>(context, listen: false);
    // String multilingualtext =
    //     '${getTranslated(context, 'letschat')} $Appname, ${getTranslated(context, 'joinme')} -  ${observer.webapplink}';
  }

  static Widget avatar(Map<String, dynamic>? user,
      {File? image, double radius = 22.5, String? predefinedinitials}) {
    if (image == null) {
      if (user![Dbkeys.aliasAvatar] == null)
        return (user[Dbkeys.photoUrl] ?? '').isNotEmpty
            ? CircleAvatar(
                backgroundColor: Colors.grey[200],
                //IsRequirefocus
                // backgroundImage:
                //     CachedNetworkImageProvider(user[Dbkeys.photoUrl]),
                radius: radius)
            : CircleAvatar(
                backgroundColor: fiberchatPRIMARYcolor,
                foregroundColor: Colors.white,
                child: Text(predefinedinitials ??
                    getInitials(Fiberchat.getNickname(user)!)),
                radius: radius,
              );
      return CircleAvatar(
        backgroundImage: Image.file(File(user[Dbkeys.aliasAvatar])).image,
        radius: radius,
      );
    }
    return CircleAvatar(
        backgroundImage: Image.file(image).image, radius: radius);
  }

  static Widget getNTPWrappedWidget(Widget child) {
    return FutureBuilder(
        future: Future.value(93),
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            if (snapshot.data! > Duration(minutes: 1).inMilliseconds ||
                snapshot.data! < -Duration(minutes: 1).inMilliseconds)
              return Material(
                  color: fiberchatBlack,
                  child: Center(
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            getTranslated(context, 'clocktime'),
                            style:
                                TextStyle(color: fiberchatWhite, fontSize: 18),
                          ))));
          }
          return child;
        });
  }

  static void showRationale(rationale) async {
    Fiberchat.toast(rationale);
    // await Future.delayed(Duration(seconds: 2));
    // Fiberchat.toast(
    //     'If you change your mind, you can grant the permission through App Settings > Permissions');
  }

  static Future<bool> checkAndRequestPermission(permission) {
    Completer<bool> completer = new Completer<bool>();
    // permission.request().then((status) {
    //   if (status != PermissionStatus.granted) {
    //     permission.request().then((_status) {
    //       bool granted = _status == PermissionStatus.granted;
    //       completer.complete(granted);
    //     });
    //   } else//IsRequirefocus
    //     completer.complete(true);
    // });
    return completer.future;
  }

  static String getInitials(String name) {
    try {
      List<String> names = name
          .trim()
          .replaceAll(new RegExp(r'[\W]'), '')
          .toUpperCase()
          .split(' ');
      names.retainWhere((s) => s.trim().isNotEmpty);
      if (names.length >= 2)
        return names.elementAt(0)[0] + names.elementAt(1)[0];
      else if (names.elementAt(0).length >= 2)
        return names.elementAt(0).substring(0, 2);
      else
        return names.elementAt(0)[0];
    } catch (e) {
      return '?';
    }
  }

  static String getChatId(String currentUserNo, String peerNo) {
    if ((int.tryParse(currentUserNo) ?? 0) >= (int.tryParse(peerNo) ?? 0)) {
      return '$currentUserNo-$peerNo';
    }
    return '$peerNo-$currentUserNo';
  }

  static AuthenticationType getAuthenticationType(
      bool biometricEnabled, DataModel? model) {
    if (biometricEnabled && model?.currentUser != null) {
      return AuthenticationType
          .values[model!.currentUser![Dbkeys.authenticationType]];
    }
    return AuthenticationType.passcode;
  }

  static ChatStatus getChatStatus(int index) => ChatStatus.values[index];

  static String normalizePhone(String phone) =>
      phone.replaceAll(new RegExp(r"\s+\b|\b\s"), "");

  static String getHashedAnswer(String answer) {
    answer = answer.toLowerCase().replaceAll(new RegExp(r"[^a-z0-9]"), "");
    var bytes = utf8.encode(answer); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }

  static String getHashedString(String str) {
    var bytes = utf8.encode(str); // data being hashed
    Digest digest = sha1.convert(bytes);
    return digest.toString();
  }
}
