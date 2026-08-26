import 'package:animations/animations.dart';
import 'package:club_fitness/features/export/app_screens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

export 'package:go_router/go_router.dart';

part 'routes.dart';
part 'sub_routes/admin_routes.dart';
part 'sub_routes/generic_routes.dart';
part 'sub_routes/member_routes.dart';
part 'sub_routes/trainer_routes.dart';
part 'sub_routes/auth_routes.dart';

class RoutesClass {
  static final _routerKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => _routerKey.currentContext;

  static GoRouter router = GoRouter(
    initialLocation: Routes.initial,
    navigatorKey: _routerKey,
    debugLogDiagnostics: kDebugMode,
    redirect: redirect,
    routes: routes,
    // errorBuilder: (context, state) => const PageNotFoundScreen(),
    // errorPageBuilder: (context, state) =>
    //     transitionPage(const PageNotFoundScreen()),
  );

  static final List<RouteBase> routes = [
    ...AdminRoutes.routes,
    ...GenericRoutes.routes,
    ...MemberRoutes.routes,
    ...TrainerRoutes.routes,
    ...AuthRoutes.routes,
  ];

  static Page transitionPage(
    Widget child, {
    Object? arguments,
    int milliseconds = 200,
  }) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: Duration(milliseconds: milliseconds),
      reverseTransitionDuration: Duration(milliseconds: milliseconds),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // return SharedAxisTransition(
        //   animation: animation,
        //   secondaryAnimation: secondaryAnimation,
        //   transitionType: SharedAxisTransitionType.horizontal,
        //   child: child,
        // );
        return FadeTransition(opacity: animation, child: child);
      },
      arguments: arguments,
    );
  }

  static Page successTransitionPage(
    Widget child, {
    Object? arguments,
    int milliseconds = 200,
  }) {
    return CustomTransitionPage(
      child: child,
      transitionDuration: Duration(milliseconds: milliseconds),
      reverseTransitionDuration: Duration(milliseconds: milliseconds),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SharedAxisTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.horizontal,
          child: child,
        );
        // return FadeTransition(
        //   opacity: animation,
        //   child: child,
        // );
      },
      arguments: arguments,
    );
  }

  static String? redirect(BuildContext context, GoRouterState state) {
    return null;
  }
}

extension GoRouterExtension on BuildContext {
  GoRouter get router => GoRouter.of(this);
}

extension RouterExtension on String {
  GoRouter get router => GoRouter.of(RoutesClass.context!);

  void push([String? id]) {
    if (id != null) {
      router.push('$this/$id');
      return;
    }
    router.push(this);
  }

  void go([String? id]) {
    if (id != null) {
      router.go('$this/$id');
      return;
    }
    router.go(this);
  }

  void pushReplacement([String? id]) {
    if (id != null) {
      router.pushReplacement('$this/$id');
      return;
    }
    router.pushReplacement(this);
  }
}
