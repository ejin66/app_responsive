import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'localizations.dart';
import 'responsive_level.dart';
import 'utils.dart';
import 'widgets.dart';

class GlobalLoadingWidget {
  GlobalLoadingWidget._();

  static Widget? initLoading;
  static Widget? initFailed;
  static Widget? initEmpty;
  static Widget? moreLoading;
  static Widget? moreFailed;
  static Widget? moreEmpty;
}

typedef WidgetBuilder = Widget Function(BuildContext);

extension WidgetBuilderExtension on WidgetBuilder {
  WidgetBuilder watch<T extends Level>() {
    return (_) => Consumer<T>(
          builder: (context, value, __) {
            return this(context);
          },
        );
  }

  WidgetBuilder watch2<T extends Level, T2 extends Level>() {
    return (_) => Consumer2<T, T2>(
          builder: (context, value1, value2, __) {
            return this(context);
          },
        );
  }

  WidgetBuilder watch3<T extends Level, T2 extends Level, T3 extends Level>() {
    return (_) => Consumer3<T, T2, T3>(
          builder: (context, value1, value2, value3, __) {
            return this(context);
          },
        );
  }

  WidgetBuilder watch4<T extends Level, T2 extends Level, T3 extends Level,
      T4 extends Level>() {
    return (_) => Consumer4<T, T2, T3, T4>(
          builder: (context, value1, value2, value3, value4, __) {
            return this(context);
          },
        );
  }

  WidgetBuilder watch5<T extends Level, T2 extends Level, T3 extends Level,
      T4 extends Level, T5 extends Level>() {
    return (_) => Consumer5<T, T2, T3, T4, T5>(
          builder: (context, value1, value2, value3, value4, value5, __) {
            return this(context);
          },
        );
  }

  WidgetBuilder watch6<T extends Level, T2 extends Level, T3 extends Level,
      T4 extends Level, T5 extends Level, T6 extends Level>() {
    return (_) => Consumer6<T, T2, T3, T4, T5, T6>(
          builder:
              (context, value1, value2, value3, value4, value5, value6, __) {
            return this(context);
          },
        );
  }

  /// 页面加载、刷新、加载更多
  WidgetBuilder load({
    bool refresh = false,
    bool loadMore = false,
    Widget? initLoading,
    Widget? initFailed,
    Widget? initEmpty,
    Widget? moreLoading,
    Widget? moreFailed,
    Widget? moreEmpty,
  }) {
    return (_) => Consumer<Load>(
          builder: (context, value, __) {
            return _wrapWidgetWithLoad(
              context,
              value,
              this(context),
              refresh,
              loadMore,
              initLoading: initLoading ?? GlobalLoadingWidget.initLoading,
              initFailed: initFailed ?? GlobalLoadingWidget.initFailed,
              initEmpty: initEmpty ?? GlobalLoadingWidget.initEmpty,
              moreLoading: moreLoading ?? GlobalLoadingWidget.moreLoading,
              moreFailed: moreFailed ?? GlobalLoadingWidget.moreFailed,
              moreEmpty: moreEmpty ?? GlobalLoadingWidget.moreEmpty,
            );
          },
        );
  }

  Widget build(BuildContext context) {
    return this(context);
  }
}

Widget _wrapWidgetWithLoad(
  BuildContext context,
  Load load,
  Widget child,
  bool refresh,
  bool loadMore, {
  Widget? initLoading,
  Widget? initFailed,
  Widget? initEmpty,
  Widget? moreLoading,
  Widget? moreFailed,
  Widget? moreEmpty,
}) {
  if (load.loadStatus == LoadState.idle) return SizedBox.shrink();

  if (load.loadStatus == LoadState.loading) {
    if (initLoading != null) return initLoading;

    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(right: 10),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor:
                  AlwaysStoppedAnimation(Theme.of(context).primaryColor),
            ),
          ),
          DotLoading(
            ResponsiveString.of(context).loading,
            textStyle: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  if (load.loadStatus == LoadState.failed) {
    if (initFailed != null) return initFailed;

    return Container(
      alignment: Alignment.center,
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text(
            ResponsiveString.of(context).clickReload,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ),
        onTap: () {
          load.refresh();
        },
      ),
    );
  }

  if (load.loadStatus == LoadState.empty) {
    if (initEmpty != null) return initEmpty;

    return EmptyComponent();
  }

  if (!refresh && !loadMore) {
    return child;
  }

  Widget footer;
  if (load.moreStatus == LoadState.noMore &&
      load.currentPage == firstPageIndex) {
    footer = SliverToBoxAdapter(
      child: SizedBox.shrink(),
    );
  } else {
    footer = _getFooter(
      moreLoading: moreLoading,
      moreEmpty: moreEmpty,
      moreFailed: moreFailed,
    );
  }

  return SmartRefresher(
    controller: load.refreshController,
    enablePullUp: loadMore,
    enablePullDown: refresh,
    child: child,
    footer: footer,
    onRefresh: () {
      load.silence();
    },
    onLoading: () {
      load.fetchMoreSilence();
    },
  );
}

Widget _getFooter({
  Widget? moreLoading,
  Widget? moreFailed,
  Widget? moreEmpty,
}) {
  return CustomFooter(
    height: 60,
    builder: (context, mode) {
      late Widget body;

      if (mode == LoadStatus.idle) {
        body = Container();
      }

      if (mode == LoadStatus.loading) {
        if (moreLoading != null) {
          body = moreLoading;
        } else {
          body = Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                DotLoading(
                  ResponsiveString.of(context).loadingMore,
                  textStyle: TextStyle(fontSize: 16, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }
      }

      if (mode == LoadStatus.failed) {
        if (moreFailed != null) {
          body = moreFailed;
        } else {
          body = Text(
            ResponsiveString.of(context).clickReload,
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          );
        }
      }

      if (mode == LoadStatus.canLoading) {
        body = Container();
      }

      if (mode == LoadStatus.noMore) {
        if (moreEmpty != null) {
          body = moreEmpty;
        } else {
          body = Text(
            ResponsiveString.of(context).noMoreData,
            style: TextStyle(fontSize: 16, color: Colors.grey[400]),
          );
        }
      }
      return Container(
        height: 60,
        child: Center(child: body),
      );
    },
  );
}
