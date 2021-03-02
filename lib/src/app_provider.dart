import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'icontroller.dart';
import 'responsive_level.dart';

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

  static T watch<T extends IController, K extends Level>(
      IController controller) {
    return watchLevel<T, K, PPage>(controller);
  }

  /// T 被监听页面的IController
  /// K 被监听页面的level
  /// J 当前页面Level
  /// 即监听T页面的K Level, 若有变动，处罚当前页面的J刷新
  static T watchLevel<T extends IController, K extends Level, J extends Level>(
      IController controller) {
    if (!controller.isMount()) return null;

    final findController = AppProvider.get<T>(controller.buildContext);
    if (findController == null) return null;

    findController.get<K>()?.addListener(() {
      controller.get<J>().notify();
    });
    return findController;
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
