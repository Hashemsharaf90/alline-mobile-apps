import 'package:active_flutter_delivery_app/app_config.dart';
import 'package:active_flutter_delivery_app/helpers/auth_helper.dart';
import 'package:active_flutter_delivery_app/lang_config.dart';
import 'package:active_flutter_delivery_app/presenter/language_presenter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:active_flutter_delivery_app/my_theme.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'package:shared_value/shared_value.dart';
import 'package:active_flutter_delivery_app/screens/splash.dart';
import 'package:active_flutter_delivery_app/helpers/shared_value_helper.dart';
import 'package:active_flutter_delivery_app/repositories/auth_repository.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n/app_localizations.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  fetch_user() async {
    await access_token.load();
    if ((access_token.$ ?? "").isEmpty) {
      AuthHelper().clearUserData();
      return;
    }

    var userByTokenResponse = await AuthRepository().getUserByTokenResponse();

    if (userByTokenResponse.result == true &&
        userByTokenResponse.user != null) {
      is_logged_in.$ = true;
      user_id.$ = userByTokenResponse.user?.id ?? 0;
      user_name.$ = userByTokenResponse.user?.name ?? "";
      user_email.$ = userByTokenResponse.user?.email ?? "";
      user_phone.$ = userByTokenResponse.user?.phone ?? "";
      avatar_original.$ = userByTokenResponse.user?.avatar_original ?? "";
    } else {
      AuthHelper().clearUserData();
    }
  }

  is_logged_in.load();
  // user_id.load();
  // user_name.load();
  // user_email.load();
  // user_phone.load();
  // print('is login ${is_logged_in.$}');
  access_token.load().whenComplete(() {
    fetch_user();
  });
  //set dummy login data -- end

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  runApp(SharedValue.wrapApp(MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguagePresenter()),
      ],
      child: Consumer<LanguagePresenter>(
        builder: (context, provider, snapshot) {
          return MaterialApp(
            title: AppConfig.app_name,
            debugShowCheckedModeBanner: false,
            navigatorKey: OneContext().key,
            builder:
                OneContext().builder, // Ensure OneContext is initialized here
            theme: ThemeData(
              primaryColor: MyTheme.white,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              // textTheme: GoogleFonts.sourceCodeProTextTheme(textTheme).copyWith(
              //   bodyLarge:
              //       GoogleFonts.sourceCodePro(textStyle: textTheme.bodyLarge),
              //   bodyMedium:
              //       GoogleFonts.sourceCodePro(textStyle: textTheme.bodyMedium),
              // ),
            ),
            locale: provider.locale,
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            supportedLocales: LangConfig().supportedLocales(),
            home: Splash(),
          );
        },
      ),
    );
  }
}
