import 'package:intl/intl.dart';

/// utils.dart -> datetime_utils.dart 분리
/// DateTime, Durtaion 관련 utils 집합
/// 함수를 추가하기 전에 DateUtils 참조

List<String> weekdayToKor = ['', '월', '화', '수', '목', '금', '토', '일'];
List<String> month3eng = [
  // 0은 해당 없음
  "NON",
  // 1부터 시작
  "JAN",
  "FEB",
  "MAR",
  "APR",
  "MAY",
  "JUN",
  "JUL",
  "AUG",
  "SEP",
  "OCT",
  "NOV",
  "DEC",
];

String mdw(DateTime dateTime) =>
    '${dateTime.month}월 ${dateTime.day}일 (${weekdayToKor[dateTime.weekday]})';

String ymdw(DateTime dateTime) => "${dateTime.year}년 ${mdw(dateTime)}";

String mdw2(DateTime dateTime) =>
    '${dateTime.month}월 ${dateTime.day}일, ${weekdayToKor[dateTime.weekday]}요일';

String hm(DateTime dateTime) =>
    '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

String hms(DateTime dateTime) =>
    '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';

String time12(DateTime dateTime) {
  return DateFormat.jm().format(dateTime);
}

String month3str(int month) {
  return month3eng[month];
}

String elapsedTime(DateTime dateTime) {
  DateTime now = DateTime.now();
  final diff = now.difference(dateTime);
  if (diff.inMinutes < 5) {
    return "방금 전";
  } else if (diff.inHours < 1) {
    return "${diff.inMinutes}분 전";
  } else if (diff.inDays < 1) {
    return "${diff.inHours}시간 전";
  } else if (diff.inDays < 31) {
    return "${diff.inDays}일 전";
  } else {
    return mdw(dateTime);
  }
}

String elapsedDay(DateTime dateTime) {
  DateTime now = DateTime.now();
  final duration = now.difference(dateTime);
  if (duration.inDays < 1) {
    return "오늘";
  } else if (duration.inDays == 1) {
    return "어제";
  } else {
    return mdw(dateTime);
  }
}

/// 70m => 1시간 10분 or 1시간
/// 60m => 1시간 or 1시간 00분
String durationKor(
  Duration duration, {
  bool showMinute = true,
  bool showZeroMinute = false,
}) {
  int m = duration.inMinutes ~/ duration.inHours;
  int h = duration.inHours;
  String hStr = h == 0 ? "" : "$h시간 ";

  if (showMinute) {
    String mStr = "${m.toString().padLeft(2, '0')}분";
    if (m % 60 == 0) {
      return "$hStr${showZeroMinute ? mStr : ""}";
    } else {
      return "$hStr$mStr";
    }
  }
  return hStr;
}

String dateTimeKor(DateTime t) {
  return "${t.year}년 ${mdw(t)} ${hms(t)}";
}

String secondsToString(int s) =>
    '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
