import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/components/input_field.dart';
import 'package:music_dabang/components/outlined_round_button.dart';
import 'package:music_dabang/components/wide_button.dart';

Future showPromptDialog({
  required BuildContext context,
  String infoText = "내용을 입력해주세요.",
  String hintText = "내용을 입력해주세요.",
  required void Function(String) onConfirm,
}) {
  final textController = TextEditingController();
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                infoText,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: ColorTable.enabledColor,
                ),
              ),
            ),
            InputField(
              controller: textController,
              hintText: hintText,
              autofocus: true,
              showClearButton: false,
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0.0),
        actions: [
          SizedBox(
            width: 84.0,
            height: 36.0,
            child: OutlinedRoundButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("취소"),
            ),
          ),
          WideButton(
            onPressed: () {
              onConfirm.call(textController.value.text);
              context.pop();
            },
            width: 84.0,
            height: 36.0,
            child: const Text("확인"),
          ),
        ],
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      );
    },
  );
}
