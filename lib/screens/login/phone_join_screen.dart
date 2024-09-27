import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/components/birth_gender_input.dart';
import 'package:music_dabang/components/common_layout.dart';
import 'package:music_dabang/components/input_field.dart';
import 'package:music_dabang/components/title_description_text.dart';
import 'package:music_dabang/components/wide_button.dart';
import 'package:music_dabang/models/user/gender.dart';
import 'package:music_dabang/models/user/user_join_model.dart';
import 'package:music_dabang/providers/router_provider.dart';
import 'package:music_dabang/providers/user_provider.dart';
import 'package:music_dabang/screens/components/privacy_agreement_text.dart';
import 'package:music_dabang/screens/login/phone_login_screen.dart';
import 'package:music_dabang/screens/main_screen.dart';

class PhoneJoinScreen extends ConsumerStatefulWidget {
  static const routeName = 'phone-join';

  const PhoneJoinScreen({super.key});

  @override
  ConsumerState<PhoneJoinScreen> createState() => _PhoneJoinScreenState();
}

class _PhoneJoinScreenState extends ConsumerState<PhoneJoinScreen> {
  final phoneController = TextEditingController();
  final nicknameController = TextEditingController();
  final birthController = TextEditingController();
  final genderController = TextEditingController();
  final passwordController = TextEditingController();
  String birth = '';
  String gender = '';
  final FocusNode birthFocusNode = FocusNode();

  Gender? parseGender(String x) {
    if (x == '1' || x == '3') {
      return Gender.m;
    } else if (x == '2' || x == '4') {
      return Gender.f;
    }
    return null;
  }

  Widget get birthGenderPageItem => BirthGenderInput(
        birthController: birthController,
        genderController: genderController,
        onBirthChanged: (val) => setState(() => birth = val),
        onGenderChanged: (val) => setState(() => gender = val),
        birthFocusNode: birthFocusNode,
        // onSubmitted: (_) => goNext(),
      );

  Future<void> _onSubmit() async {
    String phone = phoneController.value.text;
    String nickname = nicknameController.value.text;
    String birth = birthController.value.text;
    Gender? gender = parseGender(genderController.value.text);
    String password = passwordController.value.text;
    if (gender == null) {
      Fluttertoast.showToast(msg: '성별을 선택해주세요.');
      return;
    }
    try {
      await ref.read(userProvider.notifier).joinWithPhone(
            userJoinModel: UserJoinModel(
              phone: phone,
              nickname: nickname,
              password: password,
              gender: gender,
              birth: birth,
            ),
          );
      Fluttertoast.showToast(msg: '회원가입이 완료되었습니다.');
      context.goNamed(MainScreen.routeName);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: '오류가 발생했습니다.');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("개인정보 처리방침 동의"),
          content: const SingleChildScrollView(child: PrivacyAgreementText()),
          actions: [
            TextButton(
              onPressed: () {
                Fluttertoast.showToast(msg: '동의해야 가입이 가능합니다.');
                context.goNamed(PhoneLoginScreen.routeName);
              },
              child: const Text("동의 안함"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("동의"),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const h32 = SizedBox(height: 32.0);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CommonLayout(
        title: "휴대폰 번호로 가입하기",
        child: SingleChildScrollView(
          child: Column(
            children: [
              h32,
              InputField(
                controller: phoneController,
                label: "전화번호",
              ),
              h32,
              InputField(
                controller: nicknameController,
                label: "닉네임",
              ),
              h32,
              birthGenderPageItem,
              h32,
              InputField(
                controller: passwordController,
                label: "비밀번호",
                obscureText: true,
              ),
              h32,
              WideButton(
                onPressed: _onSubmit,
                child: const Text("회원가입"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
