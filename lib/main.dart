import 'package:flutter/material.dart';
import 'package:fluxy/fluxy.dart';
import 'pages/playground_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FluxyPlaygroundApp());
}

final themeMode = flux(ThemeMode.dark);

class FluxyPlaygroundApp extends StatelessWidget {
  const FluxyPlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Fx(() => FluxyApp(
          title: 'Fluxy Playground',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode.value,
          debugShowCheckedModeBanner: false,
          initialRoute: FxRoute(
            path: '/playground',
            builder: (params, args) => const PlaygroundPage(),
          ),
          routes: [
            FxRoute(
              path: '/playground',
              builder: (params, args) {
                final argMap = args as Map<String, dynamic>?;
                return PlaygroundPage(
                  initialSnippetId: argMap?['snippetId'],
                );
              },
            ),
          ],
        ));
  }
}
