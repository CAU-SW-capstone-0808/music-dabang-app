import 'package:flutter/material.dart';
import 'package:music_dabang/common/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final void Function()? onTap;
  final bool autofocus;
  final bool readOnly;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48, // 높이 설정
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFEFEFEF), // 배경색 설정
        borderRadius: BorderRadius.circular(24), // 라운드 보더 반경
      ),
      child: TextField(
        controller: controller,
        autofocus: autofocus,
        onTap: onTap,
        readOnly: readOnly,
        style: const TextStyle(
          fontSize: 22,
          height: 1.25,
          color: Color(0xFF121212), // 글자색 설정
        ),
        decoration: InputDecoration(
          hintText: '찾으시는 노래가 있나요?',
          hintStyle: TextStyle(
            fontSize: 22,
            height: 1.25,
            color: const Color(0xFF121212).withOpacity(0.8), // 힌트 글자색
          ),
          focusColor: ColorTable.kPrimaryColor,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24), // 테두리 둥근 설정
            borderSide: const BorderSide(color: ColorTable.kPrimaryColor),
          ),
          suffixIcon: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Color(0xFF121212)),
          ), // 아이콘 색상
          filled: true,
          fillColor: const Color(0xFFEFEFEF), // 필드 배경색
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24), // 테두리 둥근 설정
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
