import 'package:flutter/material.dart';

class AppStateResetter extends InheritedWidget {
  final VoidCallback restartApp;

  const AppStateResetter({
    super.key,
    required super.child,
    required this.restartApp,
  });

  static AppStateResetter of(BuildContext context) {
    final AppStateResetter? result =
        context.dependOnInheritedWidgetOfExactType<AppStateResetter>();
    assert(result != null, 'No AppStateResetter found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppStateResetter old) {
    return false;
  }
}

extension StateResetterExtension on BuildContext {
  /// Returns the [AppStateResetter] instance from the context.
  AppStateResetter get appState => AppStateResetter.of(this);

  /// Restarts the app by calling [AppStateResetter.restartApp].
  ///
  /// This is useful when you want to reset the app state, such as
  /// when a user logs out or when an error occurs.
  ///
  /// This method will call [AppStateResetter.restartApp] which will
  /// reset the entire app state.
  /// Like starting a fresh application.
  void restartApp() {
    AppStateResetter.of(this).restartApp();
  }
}
