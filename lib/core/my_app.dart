import 'dart:io';
import 'dart:ui';

import 'package:club_fitness/config/navigation/routes_class.dart';
import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:club_fitness/di.dart';
import 'package:club_fitness/features/auth/auth.dart';
import 'package:club_fitness/features/image_cache/image_cache.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/member_manager/member_manager.dart';
import 'constants/constants.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Key _appKey = UniqueKey();

  void restartApp() {
    setState(() {
      _appKey = UniqueKey();
    });
  }

  @override
  initState() {
    if (Platform.isWindows) {
      HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    if (Platform.isWindows) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    }
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      // Example: Alt + Left Arrow
      if (HardwareKeyboard.instance.isAltPressed &&
          event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        debugPrint("Alt + Left Arrow pressed → Going back!");
        if (RoutesClass.context!.canPop()) {
          RoutesClass.context!.pop();
        }
        return true;
      }

      // Example: Escape key
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        debugPrint("Escape pressed → Going back!");
        if (RoutesClass.context!.canPop()) {
          RoutesClass.context!.pop();
        }
        return true;
      }
    }
    return false; // allow other widgets to handle unhandled events
  }

  @override
  Widget build(BuildContext context) {
    return AppStateResetter(
      restartApp: restartApp,
      child: AppRoot(key: _appKey),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => CacheImageCubit(sl(), sl())..getAllImages(),
        ),
        BlocProvider(
          create: (context) => AuthBloc(sl(), sl(), sl(), sl(), sl(), sl(), sl()),
        ),
        BlocProvider(create: (context) => MembersActionsBloc(sl())),
        BlocProvider(
          create: (context) =>
              MembersConfigBloc(sl(), sl())..add(const GetMembershipPlansEvent(true)),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        scrollBehavior: BouncingScrollBehavior(),
        localizationsDelegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          // FlutterQuillLocalizations.delegate,
        ],
        debugShowCheckedModeBanner: false,
        routerConfig: RoutesClass.router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1)),
          child: child!,
        ),
        theme: AppTheme.darkTheme,
      ),
    );
  }
}

class BouncingScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.mouse,
    PointerDeviceKind.touch,
    PointerDeviceKind.trackpad,
  };
}
