//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:io';
import 'package:fiberchat_web/Configs/Dbkeys.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

class Save {
  static final LocalStorage storage = new LocalStorage(Dbkeys.saved);

  static Future<String> getBase64FromImage({String? imageUrl, File? file}) {
    Completer<String> complete = new Completer<String>();
    if (file == null) {
//IsRequirefocus
      // DefaultCacheManager().getFile(imageUrl!).listen((stream) {
      //   stream.file.readAsBytes().then((imageBytes) {
      //     complete.complete(base64Encode(imageBytes));
      //   });
      // });
    } else {
      List<int> imageBytes = file.readAsBytesSync();
      complete.complete(base64Encode(imageBytes));
    }
    return complete.future;
  }

  static Image getImageFromBase64(String encoded) =>
      Image.memory(base64.decode(encoded));

  static saveMessage(String? peerNo, Map<String, dynamic> doc) {
    storage.ready.then((ready) {
      if (ready) {
        List<Map<String, dynamic>> saved =
            storage.getItem(peerNo!)?.cast<Map<String, dynamic>>() ?? [];
        if (!(saved
            .any((_doc) => _doc[Dbkeys.timestamp] == doc[Dbkeys.timestamp]))) {
          // Don't repeat the saved ones
          saved.add(doc);
          storage.setItem(peerNo, saved);
        }
      }
    });
  }

  static deleteMessage(String? peerNo, Map<String, dynamic> doc) {
    storage.ready.then((ready) {
      if (ready) {
        List<Map<String, dynamic>> saved =
            storage.getItem(peerNo!)?.cast<Map<String, dynamic>>() ?? [];
        saved.removeWhere((_d) =>
            _d[Dbkeys.timestamp] == doc[Dbkeys.timestamp] &&
            _d[Dbkeys.content] == doc[Dbkeys.content]);
        storage.setItem(peerNo, saved);
      }
    });
  }

  static Future<List<Map<String, dynamic>>> getSavedMessages(String? peerNo) {
    Completer<List<Map<String, dynamic>>> completer =
        new Completer<List<Map<String, dynamic>>>();
    storage.ready.then((ready) {
      if (ready) {
        completer.complete(
            storage.getItem(peerNo!)?.cast<Map<String, dynamic>>() ?? []);
      }
    });
    return completer.future;
  }

  static void saveToDisk(ImageProvider? provider, String filename) async {
    filename = filename.replaceAll(RegExp(r'[^\d]'), '');

//IsRequirefocus
    // if (provider is CachedNetworkImageProvider) {
    //   CachedNetworkImageProvider _cache = provider;
    //   // ignore: deprecated_member_use
    //   DefaultCacheManager().getFile(_cache.url).listen((stream) {
    //     _save(Directory directory) {
    //       stream.file.readAsBytes().then((bytes) {
    //         // File f = new File(join(directory.path, '$filename.$extension'));
    //         // f.writeAsBytes(bytes);
    //       });
    //     }

    //     save(_save);
    //   });
    // } else {
    //   _save(Directory directory) {
    //     // File f = new File(join(directory.path, '$filename.$extension'));
    //     // f.writeAsBytes(image.bytes);
    //   }

    //   save(_save);
    // }
  }
}
