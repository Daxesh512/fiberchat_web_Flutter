import 'dart:typed_data';

import 'package:fiberchat_web/Screens/chat_screen/utils/uploadMediaWithProgress.dart';
import 'package:fiberchat_web/Services/localization/language_constants.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FileSelectorUploader {
  static uploadToFirebase(
      {List<String>? fileExt = const [],
      bool? isMultiple = false,
      required Function(
        String url,
        String fileName,
        bool islast,
      )
          onUploadFirebaseComplete,
      required Function onStartUploading,
      required int maxSizeInMB,
      required bool isShowProgress,
      required BuildContext context,
      required int totalFilesToSelect,
      required String firebaseBucketpath,
      required Function(String err) onError}) async {
    try {
      final List<GlobalObjectKey<FormState>> formKeyList = List.generate(
          totalFilesToSelect, (index) => GlobalObjectKey<FormState>(index));

      FilePickerResult? result;

      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: fileExt!.isEmpty ? FileType.any : FileType.custom,
        allowedExtensions: fileExt.isEmpty ? null : fileExt,
      );
      if (result != null) {
        if (result.files.length < totalFilesToSelect) {
          for (var file in result.files) {
            int i = result.files.indexWhere((element) => element == file);
            if (i == 0) {
              onStartUploading();
            }
            Uint8List uploadfile = file.bytes!;

            String filename = basename(file.name);
            if ((file.bytes!.length / 1000000) > maxSizeInMB) {
              Fiberchat.toast(
                  "$filename ${getTranslated(context, 'maxfilesize')} $maxSizeInMB MB");
            } else {
              Reference reference = FirebaseStorage.instance
                  .ref("$firebaseBucketpath")
                  .child(filename);
              UploadTask uploading = reference.putData(uploadfile);
              showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return new WillPopScope(
                        onWillPop: () async => false,
                        child: SimpleDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                            // side: BorderSide(width: 5, color: Colors.green)),
                            key: formKeyList[i],
                            backgroundColor: Colors.white,
                            children: <Widget>[
                              Center(
                                child: StreamBuilder(
                                    stream: uploading.snapshotEvents,
                                    builder: (BuildContext context, snapshot) {
                                      if (snapshot.hasData) {
                                        final TaskSnapshot snap =
                                            uploading.snapshot;

                                        return isShowProgress == true
                                            ? openUploadDialog(
                                                context: context,
                                                percent:
                                                    bytesTransferred(snap) /
                                                        100,
                                                title: "$filename " +
                                                    getTranslated(
                                                        context, 'sending'),
                                                subtitle:
                                                    "${((((snap.bytesTransferred / 1024) / 1000) * 100).roundToDouble()) / 100}/${((((snap.totalBytes / 1024) / 1000) * 100).roundToDouble()) / 100} MB",
                                              )
                                            : CircularProgressIndicator();
                                      } else {
                                        return isShowProgress == true
                                            ? openUploadDialog(
                                                context: context,
                                                percent: 0.0,
                                                title: getTranslated(
                                                    context, 'sending'),
                                                subtitle: '',
                                              )
                                            : CircularProgressIndicator();
                                      }
                                    }),
                              ),
                            ]));
                  });

              TaskSnapshot downloadTask = await uploading;
              var _url = await downloadTask.ref.getDownloadURL();

              await onUploadFirebaseComplete(
                  _url, filename, i == (result.files.length - 1));
              Navigator.of(formKeyList[i].currentContext!, rootNavigator: true)
                  .pop(); //
            }
          }
        } else {
          onError(
              "${getTranslated(context, 'maxnooffiles')} $totalFilesToSelect");
        }
      }
    } catch (e) {
      // print(e.toString());
      onError("Failed to Send file !");
    }
  }
}
