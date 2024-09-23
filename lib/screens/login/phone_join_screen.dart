import 'package:flutter/material.dart';
import 'package:music_dabang/components/birth_gender_input.dart';
import 'package:music_dabang/components/common_layout.dart';
import 'package:music_dabang/components/input_field.dart';
import 'package:music_dabang/components/title_description_text.dart';
import 'package:music_dabang/components/wide_button.dart';
import 'package:music_dabang/models/user/gender.dart';

class PhoneJoinScreen extends StatefulWidget {
  static const routeName = 'phone-join';

  const PhoneJoinScreen({super.key});

  @override
  State<PhoneJoinScreen> createState() => _PhoneJoinScreenState();
}

class _PhoneJoinScreenState extends State<PhoneJoinScreen> {
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
    Gender? parsedGender = parseGender(gender);
    if (parsedGender != null) {}
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
              const InputField(label: "전화번호"),
              h32,
              const InputField(label: "닉네임"),
              h32,
              birthGenderPageItem,
              h32,
              const InputField(
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
