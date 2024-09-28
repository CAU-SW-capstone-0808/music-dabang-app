import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onClear;
  final bool autofocus;
  final bool readOnly;
  final bool showClearButton;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.readOnly = false,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: controller,
          autofocus: autofocus,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          readOnly: readOnly,
          style: const TextStyle(
            fontSize: 22,
            height: 1.25,
            color: Color(0xFF121212), // 글자색 설정
          ),
          decoration: InputDecoration(
            hintText: readOnly ? '찾으시는 노래가 있나요?' : null,
            hintStyle: TextStyle(
              fontSize: 22,
              height: 1.25,
              color: const Color(0xFF121212).withOpacity(0.8), // 힌트 글자색
            ),
            focusColor: ColorTable.kPrimaryColor,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24), // 테두리 둥근 설정
              borderSide: const BorderSide(
                color: ColorTable.kPrimaryColor,
                width: 2,
              ),
            ),
            suffixIcon: IconButton(
              onPressed: () {
                if (showClearButton) {
                  onClear?.call();
                } else {
                  onSubmitted?.call(controller?.value.text ?? '');
                }
              },
              icon: Icon(
                showClearButton ? Icons.close_rounded : Icons.search_rounded,
                color: const Color(0xFF121212),
                size: 32,
              ),
            ),
            filled: true,
            fillColor:
                readOnly ? const Color(0xFFEFEFEF) : Colors.white, // 필드 배경색
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24), // 테두리 둥근 설정
              borderSide: const BorderSide(
                color: Color(0xFFEFEFEF),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
