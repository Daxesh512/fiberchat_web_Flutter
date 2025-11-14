//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat_web/Configs/app_constants.dart';
import 'package:fiberchat_web/Utils/utils.dart';
import 'package:fiberchat_web/widgets/Common/cached_image.dart';
import 'package:flutter/material.dart';
import 'package:image_downloader_web/image_downloader_web.dart';

class PhotoViewWrapper extends StatelessWidget {
  PhotoViewWrapper(
      {this.message,
      this.loadingChild,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      required this.keyloader,
      required this.imageUrl,
      required this.tag});

  final String tag;
  final String? message;
  final GlobalKey keyloader;

  final Widget? loadingChild;
  final Decoration? backgroundDecoration;
  final dynamic minScale;
  final String imageUrl;
  final dynamic maxScale;

  final GlobalKey<ScaffoldState> _scaffoldd = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Fiberchat.getNTPWrappedWidget(Scaffold(
        backgroundColor: Colors.black,
        key: _scaffoldd,
        appBar: AppBar(
          elevation: 0.4,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
              Icons.arrow_back,
              size: 24,
              color: fiberchatWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: "dfs32231t834",
          backgroundColor: fiberchatSECONDARYolor,
          onPressed: () async {
            try {
              await WebImageDownloader.downloadImageFromWeb(
                imageUrl,
                name: '${DateTime.now().millisecondsSinceEpoch}',
                imageType: ImageType.png,
              );
            } catch (e) {
              Fiberchat.toast("Failed to Download ! \n$e");
            }
          },
          child: Icon(
            Icons.file_download,
          ),
        ),
        body: Container(
            margin: EdgeInsets.all(20),
            color: Colors.black,
            constraints: BoxConstraints.expand(
              height: MediaQuery.of(context).size.height,
            ),
            child: CachedImage(
              imageUrl,
              fit: BoxFit.fitHeight,
            ))));
  }
}
