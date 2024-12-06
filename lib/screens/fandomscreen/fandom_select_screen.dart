import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data.dart';
import 'package:go_router/go_router.dart';

class FandomSelectScreen extends ConsumerStatefulWidget {
  static const routeName = 'fandom-select';

  const FandomSelectScreen({super.key});

  @override
  ConsumerState<FandomSelectScreen> createState() => _FandomSelectScreen();
}

class _FandomSelectScreen extends ConsumerState<FandomSelectScreen> {
  Widget _buildFandomSelect({
    required List<String> fandomNames,
    bool isLoading = false,
    required Function(String) onFandomHomeTap,
  }) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
          itemCount: fandomNames.length,
          itemBuilder: (context, index) {
            final fandomName = fandomNames[index];
            return ListTile(
              title: Text(fandomName),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onFandomHomeTap(fandomName),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '팬덤 선택',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      body: _buildFandomSelect(
        fandomNames: fandomList,
        onFandomHomeTap: (fandomList) {
          context.goNamed('fandom-home');
        },
      ),
    );
  }
}
