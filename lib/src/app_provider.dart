import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



/// 这个需要给MaterialApp提供
///
/// AppProvider(
/// 	child: MaterialApp(
/// 		...
/// 	),
/// )
///
class AppProvider extends Provider<_AppProviderData> {
  AppProvider({
    TransitionBuilder builder,
    Widget child,
  }) : super(
    create: (_) => _AppProviderData(),
    dispose: (_, data) => data.dispose(),
    builder: builder,
    child: child,
  );

  /// 同种类型只能被expose一次。若多次expose, 在[AppProvider.get()]时默认取最早expose的数据
  static expose(BuildContext context, dynamic data) {
    context.read<_AppProviderData>().expose(data);
  }

  static remove(BuildContext context, dynamic data) {
    context.read<_AppProviderData>().remove(data);
  }

  static T get<T>(BuildContext context) {
    return context
        .read<_AppProviderData>()
        .caches
        .firstWhere((element) => element is T, orElse: () => null);
  }

  static T watch<T>(BuildContext context) {
    return context
        .watch<_AppProviderData>()
        .caches
        .firstWhere((element) => element is T, orElse: () => null);
  }
}

class _AppProviderData {
  Set<dynamic> caches = {1};

  expose(dynamic data) => caches.add(data);

  remove(dynamic data) => caches.remove(data);

  T get<T>() {
    return caches.firstWhere((element) => element is T, orElse: () => null);
  }

  dispose() => caches.clear();
}