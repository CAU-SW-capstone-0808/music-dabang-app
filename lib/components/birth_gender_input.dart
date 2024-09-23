import 'package:music_dabang/common/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 생년월일 + 성별을 받는 input field
/// 입력 예시) 010101 - 3
class BirthGenderInput extends StatefulWidget {
  final TextEditingController birthController;
  final TextEditingController genderController;
  final void Function(String)? onBirthChanged;
  final void Function(String)? onGenderChanged;
  final FocusNode? birthFocusNode;
  final void Function(String)? onSubmitted;

  const BirthGenderInput({
    required this.birthController,
    required this.genderController,
    this.onBirthChanged,
    this.onGenderChanged,
    this.birthFocusNode,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  State<BirthGenderInput> createState() => _BirthGenderInputState();
}

class _BirthGenderInputState extends State<BirthGenderInput> {
  FocusNode genderFocusNode = FocusNode();
  bool _genderFilled = false;

  /// 010101 형식
  Widget get birthInput => TextFormField(
        controller: widget.birthController,
        focusNode: widget.birthFocusNode,
        onChanged: widget.onBirthChanged,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(6),
          FilteringTextInputFormatter.digitsOnly,
        ],
        cursorColor: ColorTable.inputCursorColor,
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          labelText: '생년월일',
          hintText: '예시: 700101',
          labelStyle: const TextStyle(
            fontSize: 14.0,
            color: ColorTable.textGrey,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          hintStyle: const TextStyle(
            color: ColorTable.hintTextColor,
          ),
        ),
      );

  /// 숫자 하나만 받음
  Widget get genderInput => TextFormField(
        controller: widget.genderController,
        onChanged: widget.onGenderChanged,
        focusNode: genderFocusNode,
        style: const TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
        keyboardType: TextInputType.number,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        cursorColor: ColorTable.inputCursorColor,
        textAlignVertical: TextAlignVertical.bottom,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(
            MediaQuery.of(context).size.width / 2 - 140,
            // 47,
            12,
            0,
            12,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          hintText: '',
          hintStyle: const TextStyle(
            color: ColorTable.hintTextColor,
          ),
        ),
        onFieldSubmitted: widget.onSubmitted,
      );

  /// 아래쪽 border
  Widget get bottomBorder => const Divider(
        color: ColorTable.inputBorderColor,
        height: 0,
        thickness: 1.0,
      );

  /// 가운데 '-'
  Widget get centerBorder => const SizedBox(
        width: 9,
        child: Divider(
          color: ColorTable.inputBorderColor,
          height: 1.0,
          thickness: 1.0,
        ),
      );

  /// 우측 obscure text
  Widget get obscureText => RichText(
        text: TextSpan(
          text: _genderFilled ? '' : '•',
          style: const TextStyle(
            fontSize: 50.0,
            height: 0.6,
            color: ColorTable.hintTextColor,
          ),
          children: const [
            TextSpan(
              text: '••••••',
              style: TextStyle(
                // fontSize: 50.0,
                // height: 0.6,
                color: Colors.black,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      );

  void _handleBirthEvent() {
    if (widget.birthController.value.text.length == 6) {
      FocusScope.of(context).requestFocus(genderFocusNode);
    }
  }

  void _handleGenderEvent() {
    setState(() {
      _genderFilled = widget.genderController.value.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.birthController.addListener(_handleBirthEvent);
    widget.genderController.addListener(_handleGenderEvent);
  }

  @override
  void dispose() {
    super.dispose();
    widget.birthController.removeListener(_handleBirthEvent);
    widget.genderController.removeListener(_handleGenderEvent);
  }

  InputBorder get border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        borderRadius: BorderRadius.zero,
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Expanded(child: birthInput),
            Expanded(child: genderInput),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: bottomBorder,
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(child: centerBorder),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: obscureText,
        ),
      ],
    );
  }
}
