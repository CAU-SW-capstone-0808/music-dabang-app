import 'package:music_dabang/common/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_svg/flutter_svg.dart';

class InputField extends StatefulWidget {
  final TextEditingController? controller;
  final double fontSize;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final bool obscureText;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onClear;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool showClearButton;
  final int? minLines;
  final int? maxLines;

  const InputField({
    this.controller,
    this.fontSize = 20.0,
    this.autofocus = false,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.initialValue,
    this.label,
    this.hintText,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.showClearButton = true,
    this.minLines,
    this.maxLines,
    super.key,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _showClearButton = false;
  bool _showObscure = false;
  bool _valid = false;

  InputBorder get border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
          width: 0,
        ),
        borderRadius: BorderRadius.zero,
      );

  void judgeClearButton() {
    if (!widget.showClearButton) {
      return;
    }
    if (widget.controller!.value.text.isNotEmpty && !_showClearButton) {
      setState(() => _showClearButton = true);
    } else if (widget.controller!.value.text.isEmpty) {
      setState(() => _showClearButton = false);
    }
  }

  void judgeValidation() {
    if (widget.validator == null || widget.controller == null) return;
    // validator 통해 validation 진행
    final String? result =
        widget.validator?.call(widget.controller?.value.text);
    // result == null일 경우 valid.
    if (result == null && !_valid) {
      setState(() => _valid = true);
    } else if (result != null && _valid) {
      setState(() => _valid = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // obscureText: true일 경우에는 보임/숨김 토글 버튼이 나타난다
    if (!widget.obscureText) {
      widget.controller?.addListener(judgeClearButton);
    }

    // obscure이고 validator가 있을 경우 validation 피드백(체크 표시)이 suffix icon에 위치
    if (widget.obscureText && widget.validator != null) {
      widget.controller?.addListener(judgeValidation);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (!widget.obscureText) {
      widget.controller?.removeListener(judgeClearButton);
    }
    if (widget.obscureText && widget.validator != null) {
      widget.controller?.removeListener(judgeValidation);
    }
  }

  Widget get clearButton => GestureDetector(
        onTap: () {
          widget.controller?.clear();
          widget.onClear?.call();
        },
        child: const Padding(
          padding: EdgeInsets.only(bottom: 6.0),
          child: Icon(
            CupertinoIcons.xmark_circle_fill,
            size: 18.0,
            color: ColorTable.clearIconColor,
          ),
        ),
      );

  // obscure text를 보이기/숨기기
  // + validator 있을 경우 check 표시(valid한 경우에만)
  Widget get eyeButton => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => setState(() => _showObscure = !_showObscure),
            // child: SvgPicture.asset(
            //   _showObscure
            //       ? 'assets/icons/tabler-icon-eye-filled.svg'
            //       : 'assets/icons/tabler-icon-eye-off.svg',
            // ),
            child: Icon(
              _showObscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 24.0,
              color: ColorTable.hintTextColor,
            ),
          ),
          if (_valid) const SizedBox(width: 8.0),
          AnimatedScale(
            scale: _valid ? 1.0 : 0,
            duration: const Duration(milliseconds: 300),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _valid ? 1.0 : 0,
              child: Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                size: _valid ? 20.0 : 0,
                color: ColorTable.okGreenColor,
              ),
            ),
          ),
        ],
      );

  Widget? get currentSuffixIconButton {
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }
    if (widget.readOnly) {
      return null;
    }
    if (widget.obscureText) {
      return eyeButton;
    }
    return _showClearButton ? clearButton : null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TextFormField(
          controller: widget.controller,
          autofocus: widget.autofocus,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          minLines: widget.minLines ?? 1,
          maxLines: widget.maxLines ?? 1,
          style: widget.obscureText
              ? TextStyle(
                  color: Colors.black,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 14.0,
                )
              : TextStyle(
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F1319),
                  fontFamily: 'Inter',
                ),
          readOnly: widget.readOnly,
          cursorColor: ColorTable.inputCursorColor,
          cursorRadius: const Radius.circular(10.0),
          // cursorHeight: 24.0,
          cursorWidth: 2.0,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.fromLTRB(0, 24, 0, 6),
            border: border,
            hintText: widget.hintText,
            labelText: widget.label,
            floatingLabelStyle: const TextStyle(
              // fontSize: widget.fontSize,
              fontSize: 16.0 / 0.75, // floating label scale factor: 0.75
              color: ColorTable.textGrey,
              letterSpacing: 0,
            ),
            hintStyle: TextStyle(
              fontSize: widget.fontSize,
              color: ColorTable.inputBorderColor,
              letterSpacing: 0,
            ),
            labelStyle: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF87898A),
              letterSpacing: 0,
            ),
            suffixStyle: const TextStyle(
              letterSpacing: 0,
            ),
            focusColor: ColorTable.inputBorderColor,
            fillColor: ColorTable.inputBorderColor,
            hoverColor: ColorTable.inputBorderColor,
            enabledBorder: border,
            focusedBorder: border,
            // suffix: Icon(Icons.check),
            // suffixIcon: currentSuffixIconButton,
            suffixIconColor: ColorTable.clearIconColor,
            floatingLabelBehavior: widget.hintText != null
                ? FloatingLabelBehavior.always
                : null, // hintText가 null일 때, 라벨이 항상 보이게 설정
          ),
          obscureText: widget.obscureText && !_showObscure,
          validator: widget.validator,
          // scrollPadding: const EdgeInsets.only(bottom: 40),
        ),
        const Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Divider(
            color: ColorTable.inputBorderColor,
            height: 0,
            thickness: 1.0,
          ),
        ),
        if (currentSuffixIconButton != null)
          Positioned(
            right: 4.0,
            bottom: 14.0,
            child: currentSuffixIconButton!,
          ),
      ],
    );
  }
}
