import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'responsive_level.dart';
import 'utils.dart';


abstract class IController {
  List<SingleChildWidget> providers = [];

  List<Level> _levels = [];

  List<Level> get levels => _levels;

  PPage pageLevel;
  Load loadLevel;

  BuildContext buildContext;

  bool isMount() => buildContext != null;

  IController() {
    pageLevel = PPage(this);
    loadLevel = Load(this);
    useLevel(pageLevel);
    useLevel(loadLevel);
  }

  /// 当需要使用更多了level时，需要先调用该方法
  bool useLevel<T extends Level>([T level]) {
    if (get<T>() != null) {
      throw Exception("the $T level has been used");
    }

    Level _level = level;
    if (_level == null) {
      switch (T) {
        case Scope:
          _level = Scope();
          break;
        case ScopeA:
          _level = ScopeA();
          break;
        case ScopeB:
          _level = ScopeB();
          break;
        case ScopeC:
          _level = ScopeC();
          break;
        case ScopeD:
          _level = ScopeD();
          break;
        case Child:
          _level = Child();
          break;
        case ChildA:
          _level = ChildA();
          break;
        case ChildB:
          _level = ChildB();
          break;
        case ChildC:
          _level = ChildC();
          break;
        case ChildD:
          _level = ChildD();
          break;
        default:
          throw Exception("the argument of the customize $T level is null");
      }
    }

    _levels.add(_level);

    providers.add(ChangeNotifierProvider<T>.value(value: _level));

    return true;
  }

  T get<T extends Level>() {
    return _levels.firstWhere((element) => element.runtimeType == T, orElse: () => null);
  }

  mount(BuildContext context) => buildContext = context;

  unmount() => buildContext = null;

  /// 页面初始化时调用
  Future<int> load([int page]);

  _internalLoad([int page]) async {
    page ??= firstPageIndex;
    loadLevel
      ..status = await load(page);
    if (loadLevel.moreStatus == LoadState.moreFailed) {
      loadLevel.currentPage = max(page - 1, firstPageIndex);
    } else {
      loadLevel.currentPage = page;
    }
    loadLevel.notify();
  }

  /// 刷新页面
  Future refresh() async {
    loadLevel.loadStatus = LoadState.loading;
    loadLevel.currentPage = firstPageIndex;
    loadLevel.notify();

    await silence();
  }

  /// 静默刷新
  Future silence() async{
    await _internalLoad(firstPageIndex);

    loadLevel.refreshController.refreshCompleted();

    /// 刷新后，加载更多的状态也需要重新刷新
    if (loadLevel.moreStatus == LoadState.moreFailed) {
      loadLevel.refreshController.loadFailed();
    }
    if (loadLevel.moreStatus == LoadState.moreLoaded) {
      loadLevel.refreshController.loadComplete();
    }
    if (loadLevel.moreStatus == LoadState.noMore) {
      loadLevel.refreshController.loadNoData();
    }
  }

  /// 主动触发加载更多
  Future fetchMore([bool silence = true]) async {
    if (loadLevel.moreStatus == LoadState.noMore ||
        loadLevel.moreStatus == LoadState.moreLoading) {
      return;
    }

    loadLevel.refreshController.requestLoading();

    fetchMoreSilence();
  }

  /// 静默加载更多
  Future fetchMoreSilence() async {
    if (loadLevel.moreStatus == LoadState.noMore ||
        loadLevel.moreStatus == LoadState.moreLoading) {
      return;
    }

    loadLevel.moreStatus = LoadState.moreLoading;

    await _internalLoad(loadLevel.currentPage + 1);

    if (loadLevel.moreStatus == LoadState.moreFailed) {
      loadLevel.refreshController.loadFailed();
    }
    if (loadLevel.moreStatus == LoadState.moreLoaded) {
      loadLevel.refreshController.loadComplete();
    }
    if (loadLevel.moreStatus == LoadState.noMore) {
      loadLevel.refreshController.loadNoData();
    }
  }

  /// page: 当前加载的页数
  int computeErrorState(int page) {
    if (page == firstPageIndex) {
      return LoadState.failed;
    }

    return LoadState.moreFailed;
  }

  /// originData: 页面中缓存的数据，必须实例化过
  /// loadData: 刚加载来的数据
  /// page: 当前加载的页数
  /// total: 总的数据量
  /// pageRows: 每页加载的总条数
  /// 要求total、pageRows两个必须传一次
  int computeLoadingState<T>(List<T> originData, List<T> loadData, int page,
      {int total, int pageRows}) {
    if (total == null) {
      total = page * pageRows + 1;
    }

    if (page == firstPageIndex) {
      originData.clear();
      originData.addAll(loadData);
      if (loadData == null || loadData.isEmpty) {
        return LoadState.empty;
      }

      if (pageRows != null && loadData.length < pageRows) {
        return LoadState.loaded | LoadState.noMore;
      }

      if (loadData.length >= total) {
        return LoadState.loaded | LoadState.noMore;
      }

      return LoadState.loaded | LoadState.moreLoaded;
    } else {
      if (loadData == null || loadData.isEmpty) {
        return LoadState.noMore;
      }

      originData.addAll(loadData);

      if (pageRows != null && loadData.length < pageRows) {
        return LoadState.noMore;
      }

      if (originData.length >= total) {
        return LoadState.noMore;
      }

      return LoadState.moreLoaded;
    }
  }

  @mustCallSuper
  dispose() {
    if (isMount()) pageLevel.removeFromApp(buildContext);
    _levels.forEach((element) {
      element.dispose();
    });
    _levels.clear();
  }
}