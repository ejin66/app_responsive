import 'package:flutter/material.dart';
import 'app_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'icontroller.dart';

/// 一个页面中的多个组件，可以分别被多个level标记。当触发level时，被该level标记的组件即可刷新
/// Scaffold(
/// 	body: Column(
/// 		children: [
/// 			Text("part 1").watch<ScopeA>(),
/// 			Text("part 2").watch<ScopeB>(),
/// 		],
/// 	),
/// ).watch<Page>(),
/// 当[scopeA.notifyListeners]时，只有`Text("part 1")`会刷新
/// 当[scopeB.notifyListeners]时，只有`Text("part 2")`会刷新
/// 当[page.notifyListeners]时，整个[Scaffold]会刷新
class Level extends ChangeNotifier {
  bool get isActive => !_isDispose;
  bool _isDispose = false;

  @override
  void dispose() {
    if (_isDispose) return;

    super.dispose();
    _isDispose = true;
  }

  @override
  void notifyListeners() {
    if (_isDispose) {
      return;
    }
    super.notifyListeners();
  }

  notify() => notifyListeners();
}

/// 控制页面的刷新、加载更多、初始化数据失败等等情况下的ui切换
/// Scaffold(
/// 	body: Column(
/// 		children: [
/// 			...
/// 		],
/// 	),
/// ).load(),
///
/// 通过修改[load.status]来进行ui切换
class Load extends Level {
  final IController controller;

  int currentPage;

  int loadStatus = LoadState.idle;
  int moreStatus = LoadState.noMore;

  set status(int status) {
    if (status & 0xFF != 0) {
      loadStatus = status & 0xFF;
    }
    if (status & 0xFF00 != 0) {
      moreStatus = status & 0xFF00;
    }
  }

  RefreshController _refreshController;
  RefreshController get refreshController {
    if (_refreshController == null) {
      _refreshController = RefreshController();
    }

    return _refreshController;
  }

  Load(this.controller);

  Future refresh() => controller.refresh();
  Future silence() => controller.silence();
  Future fetchMore() => controller.fetchMore();
  Future fetchMoreSilence() => controller.fetchMoreSilence();
}

class LoadState {
  LoadState._();

  static const int idle = 0x0001;

  /// 刷新页面时对应的状态
  static const int loaded = 0x0002;
  static const int empty = 0x0003;
  static const int failed = 0x0004;
  static const int loading = 0x0005;

  /// 加载更多页面时对应的状态
  static const int moreLoaded = 0x0200;
  static const int noMore = 0x0300;
  static const int moreFailed = 0x0400;
  static const int moreLoading = 0x0500;
}

/// 页面级的[Level]
class PPage extends Level {
  final IController controller;

  PPage(this.controller);

  exposeToApp(BuildContext context) {
    AppProvider.expose(context, controller);
  }

  removeFromApp(BuildContext context) {
    AppProvider.remove(context, controller);
  }
}

/// 约定的次一级的[Level]
/// 约定的控制范围大小： Page > Scope > Child
class Scope extends Level {}

class ScopeA extends Level {}

class ScopeB extends Level {}

class ScopeC extends Level {}

class ScopeD extends Level {}

/// 约定的最低级的[Level]
/// 约定的控制范围大小： Page > Scope > Child
class Child extends Level {}

class ChildA extends Level {}

class ChildB extends Level {}

class ChildC extends Level {}

class ChildD extends Level {}
