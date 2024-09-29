import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/regex_table.dart';
import 'package:music_dabang/common/utils.dart';
import 'package:music_dabang/components/common_layout.dart';
import 'package:music_dabang/components/input_field.dart';
import 'package:music_dabang/components/title_description_text.dart';
import 'package:music_dabang/components/wide_button.dart';
import 'package:music_dabang/models/user/user_login_model.dart';
import 'package:music_dabang/providers/user/user_provider.dart';
import 'package:music_dabang/screens/login/phone_join_screen.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  static const routeName = "phone-login";

  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  // 1: 휴대폰 번호 입력
  // 2: 비밀번호 입력
  int _phase = 1;
  bool _enabledNext1 = false; // 1 -> 2로 넘어가는 것의 여부
  bool _enabledNext2 = true;
  bool _keyboardUp = false;
  bool _passwordWrong = false;

  bool get enabledNext {
    if (_phase == 1) {
      return _enabledNext1;
    } else if (_phase == 2) {
      return _enabledNext2;
    }
    return false;
  }

  /// 하단 액션 버튼. "다음" 또는 "로그인"
  Widget get bottomActionButton => WideButton(
        height: 42,
        onPressed: enabledNext ? onNextPressed : null,
        child: Text(
          _phase == 2 ? '로그인' : '다음',
          style: TextStyle(
            fontWeight: _enabledNext1 ? FontWeight.w700 : FontWeight.w400,
            fontSize: 16.0,
            fontFamily: 'Raleway',
          ),
        ),
      );

  /// 화면 상단 서술
  Widget get upperTitle {
    switch (_phase) {
      case 1:
        return const TitleDescriptionText('휴대폰 번호를\n입력해주세요.');
      case 2:
        return const TitleDescriptionText('비밀번호를\n입력해주세요.');
      default:
        return const TitleDescriptionText('');
    }
  }

  /// 휴대폰 입력
  Widget get phoneInputBox => InputField(
        controller: phoneController,
        focusNode: phoneFocusNode,
        autofocus: true,
        onSubmitted: (_) => onNextPressed(),
        label: '휴대폰번호',
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        // readOnly: _phase != 1,
      );

  /// 비밀번호 입력
  Widget get passwordInputBox => Column(
        children: [
          InputField(
            controller: passwordController,
            focusNode: passwordFocusNode,
            onSubmitted: (_) => onNextPressed(),
            label: '비밀번호 입력',
            inputFormatters: [
              FilteringTextInputFormatter.deny(
                RegExp('[가-힣ㄱ-ㅎㅏ-ㅣ]'),
              ),
            ],
            obscureText: true,
            readOnly: _phase != 2,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_passwordWrong)
                const Text(
                  '입력하신 비밀번호를 다시 확인해주세요',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Inter',
                    color: ColorTable.red2,
                  ),
                ),
              // TextButton(
              //   onPressed: () {
              //     context.pushNamed(
              //       PasswordFindScreen.routeName,
              //       queryParameters: {
              //         "phone": phoneController.value.text,
              //       },
              //     );
              //   },
              //   style: TextButton.styleFrom(
              //     foregroundColor: ColorTable.enabledColor,
              //     padding: EdgeInsets.zero,
              //   ),
              //   child: const Text(
              //     '비밀번호찾기',
              //     style: TextStyle(
              //       fontSize: 14.0,
              //       fontWeight: FontWeight.w700,
              //       fontFamily: 'Inter',
              //       decoration: TextDecoration.underline,
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      );

  /// 하단 버튼을 눌렀을 때의 콜백
  void onNextPressed() {
    // 페이즈 1: 휴대폰 번호 입력 -> 비밀번호 입력창 띄우기
    if (_phase == 1) {
      setState(() {
        _phase = 2;
      });
      // 버튼에 focus 들어갈 시 씹히는 현상 발생 -> unfocus()로 해결
      FocusManager.instance.primaryFocus?.unfocus();
      passwordFocusNode.requestFocus();
    }
    // 페이즈 2: 비밀번호 입력 -> 로그인
    else if (_phase == 2) {
      loginAndGo();
    }
  }

  /// 로그인 처리. 처리 결과를 반환
  Future<bool> login() async {
    final phone = phoneController.value.text;
    final password = passwordController.value.text;
    try {
      await ref.read(userProvider.notifier).loginWithPhone(
            userLogin: UserLoginModel(
              phone: phone,
              password: password,
            ),
          );
      return true;
    } catch (e) {
      print(e);
      AidolUtils.showToast('로그인에 실패했습니다.');
      return false;
    }
  }

  /// 로그인 이후 상태 처리
  Future<void> loginAndGo() async {
    FocusManager.instance.primaryFocus?.unfocus();
    bool result = await login();
    setState(() => _passwordWrong = !result);
    if (result) {
      context.go('/');
    }
  }

  @override
  void initState() {
    super.initState();

    // phone의 enabledNext 이벤트 등록
    phoneController.addListener(() {
      if (RegexTable.phoneRegex.hasMatch(phoneController.value.text)) {
        setState(() => _enabledNext1 = true);
      } else if (_enabledNext1) {
        setState(() => _enabledNext1 = false);
      }
    });

    // password의 enabledNext 이벤트 등록
    passwordController.addListener(() {
      if (passwordController.value.text.isNotEmpty) {
        setState(() => _enabledNext2 = true);
      } else {
        setState(() => _enabledNext2 = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: bottomActionButton,
      padding: EdgeInsets.zero,
      child: WillPopScope(
        // phase == 2일 때 phase 1로 이동
        onWillPop: () async {
          if (_phase == 2) {
            setState(() => _phase = 1);
            phoneFocusNode.requestFocus();
            passwordController.clear();
            return false;
          }
          return true;
        },
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32.0),
                    upperTitle,
                    const SizedBox(height: 58.0),
                    phoneInputBox,
                    if (_phase == 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.goNamed(PhoneJoinScreen.routeName);
                          },
                          child: const Text('회원가입이 필요하신가요?'),
                        ),
                      ),
                    const SizedBox(height: 32.0),
                    if (_phase >= 2) passwordInputBox,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
    passwordController.dispose();
  }
}
