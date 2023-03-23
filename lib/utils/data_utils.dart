import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import "package:http/http.dart" as http;

import '../models/pagination/model_with_id.dart';

class DataUtils {
  static String formatTimestamp({required Timestamp timestamp}) {
    DateTime converted = timestamp.toDate();
    final now = DateTime.now();
    if (converted.year == now.year &&
        converted.month == now.month &&
        converted.day == now.day) {
      //해당 날짜가 오늘인 경우
      return "${getNumFormat(num: converted.hour)}:${getNumFormat(num: converted.minute)}:${getNumFormat(num: converted.second)}";
    } else {
      //아닌경우
      return "${converted.year}.${getNumFormat(num: converted.month)}:${getNumFormat(num: converted.day)}";
    }
  }

  static String getNumFormat({required int num}) {
    return num.toString().padLeft(2, "0");
  }

  static String getSubString({required String str}) {
    return str.length > 50 ? str.substring(0, 50) + " ...(더보기)" : str;
  }

  static Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }

}
