import 'package:flutter/material.dart';
import 'package:lyotrade/providers/asset.dart';
import 'package:lyotrade/providers/auth.dart';
import 'package:lyotrade/providers/public.dart';
import 'package:lyotrade/providers/user.dart';
import 'package:lyotrade/screens/assets/assets.dart';
import 'package:lyotrade/screens/assets/deposit_assets.dart';
import 'package:lyotrade/screens/assets/withdraw_assets.dart';
import 'package:lyotrade/screens/auth/authentication.dart';
import 'package:lyotrade/screens/dashboard.dart';
import 'package:lyotrade/screens/market/market.dart';
import 'package:lyotrade/screens/security/email_change.dart';
import 'package:lyotrade/screens/security/google_auth.dart';
import 'package:lyotrade/screens/security/password.dart';
import 'package:lyotrade/screens/security/security.dart';
import 'package:lyotrade/screens/trade/trade.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Auth>(create: (_) => Auth()),
        ChangeNotifierProvider<Public>(create: (_) => Public()),
        ChangeNotifierProvider<Asset>(create: (_) => Asset()),
        ChangeNotifierProvider<User>(create: (_) => User()),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'LYOTrade',
            theme: ThemeData(
              // This is the theme of your application.
              //
              // Try running your application with "flutter run". You'll see the
              // application has a blue toolbar. Then, without quitting the app, try
              // changing the primarySwatch below to Colors.green and then invoke
              // "hot reload" (press "r" in the console where you ran "flutter run",
              // or simply save your changes to "hot reload" in a Flutter IDE).
              // Notice that the counter didn't reset back to zero; the application
              // is not restarted.
              primarySwatch: Colors.blue,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.dark,
            home: const Dashboard(),
            routes: {
              Dashboard.routeName: (context) => const Dashboard(),
              Authentication.routeName: (context) => const Authentication(),
              Market.routeName: (context) => const Market(),
              Trade.routeName: (context) => const Trade(),
              Assets.routeName: (context) => const Assets(),
              DepositAssets.routeName: (context) => const DepositAssets(),
              WithdrawAssets.routeName: (context) => const WithdrawAssets(),
              Security.routeName: (context) => const Security(),
              Password.routeName: (context) => const Password(),
              GoogleAuth.routeName: (context) => const GoogleAuth(),
              EmailChange.routeName: (context) => const EmailChange(),
            },
          );
        },
      ),
    );
  }
}
