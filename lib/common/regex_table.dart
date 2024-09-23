abstract class RegexTable {
  /// 비밀번호 필수 패턴 (영숫자 10자 이상)
  static final passwordRegex = RegExp(r"(?=.*\d)(?=.*[A-Za-z]).{10,}$");

  /// 비밀번호 입력 키보드 문자 (영숫자 + 특수문자)
  static final passwordCharRegex =
      RegExp(r'[A-Za-z\d!\"#\$%&()*+,\-./:;<=>?@\[\\\]^_`{|}~]');

  /// 휴대폰번호 패턴
  static final phoneRegex = RegExp('01\\d{9}');
}
