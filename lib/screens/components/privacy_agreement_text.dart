import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_dabang/providers/user/privacy_agreement_provider.dart';

class PrivacyAgreementText extends ConsumerWidget {
  const PrivacyAgreementText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(privacyAgreementStateNotifierProvider);
    if (content != null) {
      return SelectableText(content);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
