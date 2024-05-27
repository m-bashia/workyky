import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workout/features/common/widgets/di_scope/di_scope.dart';

import 'di/app_scope.dart';

import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class Wrapper extends StatefulWidget {
  final Widget? child;

  const Wrapper({super.key, required this.child});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  late StreamSubscription _subscription;
  @override
  void initState() {
    super.initState();
    _subscription = InternetConnection().onStatusChange.listen((event) {
      if (event == InternetStatus.connected) {
        ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
      } else {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(const SnackBar(
          content: Text('Отсутствует подключение к интернету'),
          duration: Duration(hours: 22321),
        ));
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child ?? Container();
}

class App extends StatefulWidget {
  final AppScope appScope;

  const App(this.appScope, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late IAppScope _scope;

  @override
  void initState() {
    super.initState();
    _scope = widget.appScope..applicationRebuilder = _rebuildApplication;
  }

  void _rebuildApplication() {
    setState(() {
      _scope = widget.appScope..applicationRebuilder = _rebuildApplication;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DiScope<IAppScope>(
      key: ObjectKey(_scope),
      factory: () {
        return _scope;
      },
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'),
        ],
        routeInformationParser: _scope.router.defaultRouteParser(),
        routerDelegate: _scope.router.delegate(),
        builder: (context, child) => Wrapper(child: child),
      ),
    );
  }
}
