import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

abstract class AidolUtils {
  static String numberK(int number) {
    if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    }
    return number.toString();
  }

  static String timeDescription(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inDays > 0) {
      return "${diff.inDays}일 전";
    } else if (diff.inHours > 0) {
      return "${diff.inHours}시간 전";
    } else if (diff.inMinutes > 4) {
      return "${diff.inMinutes}분 전";
    } else {
      return "방금 전";
    }
  }

  static Future<void> showToast(String message) async {
    await Fluttertoast.showToast(
      msg: message,
      timeInSecForIosWeb: 3,
    );
  }

  static Future<void> showErrorToast({String? message}) async {
    await Fluttertoast.showToast(
      msg: message ?? "Error occurred",
      webBgColor: "#ff5f6d",
      timeInSecForIosWeb: 3,
    );
  }

  static void d(String debugMessage) {
    debugPrint(debugMessage);
  }

  static String birthdayFormat(DateTime t) {
    return "${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}";
  }

  /// Uint8List -> Int16List로 변환 (2바이트 -> 16비트 PCM)
  static Int16List uint8ToPCM16(Uint8List uint8Array) {
    // print("uint8 -> ${uint8Array.reduce((value, element) => value + element)}");
    final int16Array = Int16List(uint8Array.length ~/ 2); // 2바이트씩 묶음
    final byteData = ByteData.sublistView(uint8Array);

    for (int i = 0; i < int16Array.length; i++) {
      int16Array[i] = byteData.getInt16(i * 2, Endian.little); // 리틀 엔디언으로 변환
    }

    return int16Array;
  }

  /// 발화 시작점을 감지하는 함수
  static int detectSpeechStart(Int16List pcm16Array,
      {double threshold = 0.02, int consecutiveSamples = 5}) {
    int consecutiveAboveThreshold = 0;

    for (int i = 0; i < pcm16Array.length; i++) {
      final sample = pcm16Array[i].abs() / 32767.0; // PCM16을 -1에서 1 범위로 변환

      if (sample > threshold) {
        consecutiveAboveThreshold++;
        if (consecutiveAboveThreshold >= consecutiveSamples) {
          return i; // 발화 시작점 인덱스 반환
        }
      } else {
        consecutiveAboveThreshold = 0; // 임계값 미만이면 카운터 리셋
      }
    }

    return -1; // 발화 시작점이 없으면 -1 반환
  }
}
