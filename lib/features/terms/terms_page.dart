import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/bottom_nav_scaffold.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.termsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 利用規約本文
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  loc.termsBody,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),

            // 同意チェック
            Row(
              children: [
                Checkbox(
                  value: isAgreed,
                  onChanged: (value) {
                    setState(() {
                      isAgreed = value!;
                    });
                  },
                ),
                Expanded(child: Text(loc.agreeTerms)),
              ],
            ),

            // 続けるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isAgreed
                    ? () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BottomNavScaffold(),
                    ),
                  );
                }
                    : null,
                child: Text(loc.continueLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
