import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:mychat/models/mMessage.dart';

class FirebaseStorageService {
  static Future<String> uploadFile(
      File imageFile, MMessage message, Function function,
      {String fileName}) async {
    // The ref. to the new url
    String downloadedUrl;

    final String name =
        fileName ?? DateTime.now().millisecondsSinceEpoch.toString();
    final StorageReference reference =
        FirebaseStorage.instance.ref().child(name);
    final StorageUploadTask uploadTask = reference.putFile(imageFile);
    final StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    await storageTaskSnapshot.ref.getDownloadURL().then(
      (downloadUrl) {
        downloadedUrl = downloadUrl;
        function.call(downloadedUrl);
      },
      onError: (err) {
        Fluttertoast.showToast(msg: 'This file is not an image');
      },
    );
    return downloadedUrl;
  }

  static Future<Uint8List> imageDownload(String url) async {
    Fluttertoast.showToast(msg: 'Image downloading. Please wait...');
    final StorageReference ref = await FirebaseStorage.instance.getReferenceFromUrl(url);
    final http.Response downloadData = await http.get(url);
    final Directory systemTmpDir = Directory.systemTemp;
    final File tmpFile = File('${systemTmpDir.path}/tmp.jpg');
    if (tmpFile.existsSync()) {
      tmpFile.delete();
    }
    await tmpFile.create();

    final StorageFileDownloadTask task = ref.writeToFile(tmpFile);
    final int byteCount = (await task.future).totalByteCount;
    return downloadData.bodyBytes;
  }
}
