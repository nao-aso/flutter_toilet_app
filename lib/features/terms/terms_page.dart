// import 'package:flutter/material.dart';
// import '../../l10n/app_localizations.dart';
// import '../../shared/widgets/bottom_nav_scaffold.dart';
//
// class TermsPage extends StatefulWidget {
//   const TermsPage({super.key});
//
//   @override
//   State<TermsPage> createState() => _TermsPageState();
// }
//
// class _TermsPageState extends State<TermsPage> {
//   bool isAgreed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final loc = AppLocalizations.of(context)!;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(loc.termsTitle),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 利用規約本文
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Text(
//                   loc.termsBody,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//
//             // 同意チェック
//             Row(
//               children: [
//                 Checkbox(
//                   value: isAgreed,
//                   onChanged: (value) {
//                     setState(() {
//                       isAgreed = value!;
//                     });
//                   },
//                 ),
//                 Expanded(child: Text(loc.agreeTerms)),
//               ],
//             ),
//
//             // 続けるボタン
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isAgreed
//                     ? () {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const BottomNavScaffold(),
//                     ),
//                   );
//                 }
//                     : null,
//                 child: Text(loc.continueLabel),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ★追加
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/bottom_nav_scaffold.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  bool isAgreed = false;
  // ★追加: 同意フラグを保存するキーを定義
  static const String _termsAgreedKey = 'terms_agreed';

  // ★追加: 同意フラグを保存し、ホーム画面へ遷移するメソッド
  Future<void> _agreeAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    // フラグを true で保存
    await prefs.setBool(_termsAgreedKey, true);

    if (mounted) {
      // ホーム画面へ遷移（TermsPageはナビゲーションスタックから削除）
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BottomNavScaffold(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        // ★修正: 自動で表示される戻るボタン（X/<-）を非表示にする
        automaticallyImplyLeading: false,
        title: Text(loc.termsTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ... (利用規約本文、同意チェックのRowは変更なし)
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
                  // ★修正: _agreeAndNavigate メソッドを呼び出す
                  _agreeAndNavigate();
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