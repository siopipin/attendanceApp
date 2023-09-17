// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

class Config {
  final titleApp = "AppTheme";
  themeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      textTheme: Theme.of(context)
          .textTheme
          .copyWith(
            titleSmall:
                Theme.of(context).textTheme.titleSmall?.copyWith(fontSize: 11),
          )
          .apply(
            bodyColor: Colors.black,
            displayColor: Colors.grey,
          ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.all(Config().colorPrimary),
      ),
      listTileTheme: ListTileThemeData(iconColor: Config().colorPrimary),
      appBarTheme: AppBarTheme(
          backgroundColor: Config().colorPrimary,
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white)),
    );
  }

  final baseURL = "https://restapi.neoschool.id/api/";

  final paddingSize = 16.0;
  final radiusSize = 15.0;

  final colorPrimary = const Color(0xffb3d55c);
  final colorSecondary = const Color.fromARGB(255, 35, 61, 83);
  final colorBackground = const Color(0xffeaecee);
  final colorItem = const Color(0xffffffff);

  final colorShimmer = const Color(0xffe0e0e0);

  final fontSizeH1 = 18.0;
  final fontSizeH2 = 16.0;
  final fontSizeH3 = 14.0;
  final fontSizeTINNY = 12.0;

  // message
  final MSG_UNAUTHORISED = "Unauthorised access";
  final MSG_SUCCSEED = "Succeed";
  final MSG_ERROR_CONNECTION = "Error During Communication";
  final MSG_INVALID_REQUEST = "Invalid Request";
}
