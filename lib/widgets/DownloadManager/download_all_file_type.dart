import 'package:http/http.dart';
import 'package:path/path.dart' as p;
import 'package:universal_html/html.dart' as html;

abstract class DownloadService {
  Future<void> downloadusingBrowser({
    required String url,
    required String fileName,
  });
}

class WebDownloadService implements DownloadService {
  @override
  Future<void> downloadusingBrowser({
    required String url,
    required String fileName,
  }) async {
// //                     final bytes = utf8.encode(text);
// //                     final blob = html.Blob([bytes]);
// //                     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.document.createElement('a') as html.AnchorElement
//       ..href = url
//       ..style.display = 'none'
//       ..download = fileName;
//     html.document.body!.children.add(anchor);

// // download
//     anchor.click();

// // cleanup
//     html.document.body!.children.remove(anchor);
//     html.Url.revokeObjectUrl(url);

    Response res = await get(
      Uri.parse(url),
    );

    if (res.statusCode == 200) {
      final blob = html.Blob([res.bodyBytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = fileName;
      html.document.body!.children.add(anchor);

      anchor.click();

      html.document.body!.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      throw Exception(res.statusCode);
    }
  }
}

String getDocumentType(fileName) {
  String fileExtension = p.extension(fileName).toLowerCase();
  if (fileExtension == ".3gp") {
    return "video/3gpp";
  } else if (fileExtension == ".torrent") {
    return "application/x-bittorrent";
  } else if (fileExtension == ".kml") {
    return "application/vnd.google-earth.kml+xml";
  } else if (fileExtension == ".gpx") {
    return "application/gpx+xml";
  } else if (fileExtension == ".csv") {
    return "application/vnd.ms-excel";
  } else if (fileExtension == ".apk") {
    return "application/vnd.android.package-archive";
  } else if (fileExtension == ".asf") {
    return "video/x-ms-asf";
  } else if (fileExtension == ".avi") {
    return "video/x-msvideo";
  } else if (fileExtension == ".bin") {
    return "application/octet-stream";
  } else if (fileExtension == ".bmp") {
    return "image/bmp";
  } else if (fileExtension == ".c") {
    return "text/plain";
  } else if (fileExtension == ".class") {
    return "application/octet-stream";
  } else if (fileExtension == ".conf") {
    return "text/plain";
  } else if (fileExtension == ".cpp") {
    return "text/plain";
  } else if (fileExtension == ".doc") {
    return "application/msword";
  } else if (fileExtension == ".docx") {
    return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
  } else if (fileExtension == ".xls") {
    return "application/vnd.ms-excel";
  } else if (fileExtension == ".xslx") {
    return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
  } else if (fileExtension == ".exe") {
    return "application/octet-stream";
  } else if (fileExtension == ".gif") {
    return "image/gif";
  } else if (fileExtension == ".gtar") {
    return "application/x-gtar";
  } else if (fileExtension == ".gz") {
    return "application/x-gzip";
  } else if (fileExtension == ".h") {
    return "text/plain";
  } else if (fileExtension == ".htm") {
    return "text/html";
  } else if (fileExtension == ".html") {
    return "text/html";
  } else if (fileExtension == ".jar") {
    return "application/java-archive";
  } else if (fileExtension == ".java") {
    return "text/plain";
  } else if (fileExtension == ".jpg") {
    return "image/jpeg";
  } else if (fileExtension == ".jpeg") {
    return "image/jpeg";
  } else if (fileExtension == ".js") {
    return "application/x-javascript";
  } else if (fileExtension == ".log") {
    return "text/plain";
  } else if (fileExtension == ".m3u") {
    return "audio/x-mpegurl";
  } else if (fileExtension == ".m4a") {
    return "audio/mp4a-latm";
  } else if (fileExtension == ".m4b") {
    return "audio/mp4a-latm";
  } else if (fileExtension == ".m4p") {
    return "audio/mp4a-latm";
  } else if (fileExtension == ".m4u") {
    return "video/vnd.mpegurl";
  } else if (fileExtension == ".m4v") {
    return "video/x-m4v";
  } else if (fileExtension == ".mov") {
    return "video/quicktime";
  } else if (fileExtension == ".mp2") {
    return "audio/x-mpeg";
  } else if (fileExtension == ".mp3") {
    return "audio/x-mpeg";
  } else if (fileExtension == ".mp4") {
    return "video/mp4";
  } else if (fileExtension == ".mpc") {
    return "application/vnd.mpohun.certificate";
  } else if (fileExtension == ".mpe") {
    return "video/mpeg";
  } else if (fileExtension == ".mpeg") {
    return "video/mpeg";
  } else if (fileExtension == ".mpg") {
    return "video/mpeg";
  } else if (fileExtension == ".mpg4") {
    return "video/mp4";
  } else if (fileExtension == ".mpga") {
    return "audio/mpeg";
  } else if (fileExtension == ".msg") {
    return "application/vnd.ms-outlook";
  } else if (fileExtension == ".ogg") {
    return "audio/ogg";
  } else if (fileExtension == ".pdf") {
    return "application/pdf";
  } else if (fileExtension == ".png") {
    return "image/png";
  } else if (fileExtension == ".pps") {
    return "application/vnd.ms-powerpoint";
  } else if (fileExtension == ".ppt") {
    return "application/vnd.ms-powerpoint";
  } else if (fileExtension == ".pptx") {
    return "application/vnd.openxmlformats-officedocument.presentationml.presentation";
  } else if (fileExtension == ".prop") {
    return "text/plain";
  } else if (fileExtension == ".rc") {
    return "text/plain";
  } else if (fileExtension == ".rmvb") {
    return "audio/x-pn-realaudio";
  } else if (fileExtension == ".rtf") {
    return "application/rtf";
  } else if (fileExtension == ".sh") {
    return "text/plain";
  } else if (fileExtension == ".tar") {
    return "application/x-tar";
  } else if (fileExtension == ".tgz") {
    return "application/x-compressed";
  } else if (fileExtension == ".txt") {
    return "text/plain";
  } else if (fileExtension == ".wav") {
    return "audio/x-wav";
  } else if (fileExtension == ".wma") {
    return "audio/x-ms-wma";
  } else if (fileExtension == ".wmv") {
    return "audio/x-ms-wmv";
  } else if (fileExtension == ".wps") {
    return "application/vnd.ms-works";
  } else if (fileExtension == ".xml") {
    return "text/plain";
  } else if (fileExtension == ".z") {
    return "application/x-compress";
  } else if (fileExtension == ".zip") {
    return "application/x-zip-compressed";
  } else if (fileExtension == "") {
    return "*/*";
  } else {
    return "";
  }
}
