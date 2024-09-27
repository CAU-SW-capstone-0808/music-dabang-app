import 'package:music_dabang/common/colors.dart';
import 'package:music_dabang/common/consts.dart';
import 'package:music_dabang/components/outlined_round_button.dart';
import 'package:music_dabang/components/wide_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 취소/확인이 있는 바텀 다이얼로그. returns true if confirmed, false if canceled.
Future<bool?> showConfirmDialog(
  BuildContext context, {
  String? title,
  String? content,
  String? infoText,
  String cancelText = '취소',
  String confirmText = '확인',
  bool closingOnConfirm = true,
  void Function()? onConfirm,
  void Function()? onCancel,
}) {
  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15.0,
                  color: ColorTable.enabledColor,
                ),
              ),
            ),
          if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 15.0,
                color: Color(0xFF6B6B6B),
              ),
            ),
          if (infoText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16.0,
                    color: ColorTable.textInfoColor,
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    infoText,
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: ColorTable.textInfoColor,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14.0),
          Row(
            children: [
              Expanded(
                child: WideButton(
                  width: double.infinity,
                  height: 42.0,
                  onPressed: () {
                    onConfirm?.call();
                    if (closingOnConfirm) {
                      context.pop(true);
                    }
                  },
                  child: Text(confirmText),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: SizedBox(
                  height: 42.0,
                  child: OutlinedRoundButton(
                    onPressed: () {
                      onCancel?.call();
                      context.pop(false);
                    },
                    child: Text(cancelText),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
