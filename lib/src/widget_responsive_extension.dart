import 'package:flutter/material.dart';
import 'widgets.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'localizations.dart';
import 'responsive_level.dart';
import 'utils.dart';

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
  WidgetBuilder load({bool refresh = false, bool loadMore = false}) {
    return (_) => Consumer<Load>(
          builder: (context, value, __) {
            return _wrapWidgetWithLoad(
                context, value, this(context), refresh, loadMore);
          },
        );
  }
}

Widget _wrapWidgetWithLoad(BuildContext context, Load load, Widget child,
    bool refresh, bool loadMore) {
  if (load.loadStatus == LoadState.idle) return SizedBox.shrink();

  if (load.loadStatus == LoadState.loading) {
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
    return EmptyComponent();
  }

  if (!refresh && !loadMore) {
    return child;
  }

  var footerHeight = 60.0;
  if (load.moreStatus == LoadState.noMore &&
      load.currentPage == firstPageIndex) {
    footerHeight = 0;
  }

  return SmartRefresher(
    controller: load.refreshController,
    enablePullUp: loadMore,
    enablePullDown: refresh,
    child: child,
    footer: _getFooter(footerHeight),
    onRefresh: () {
      load.silence();
    },
    onLoading: () {
      load.fetchMoreSilence();
    },
  );
}

Widget _getFooter(double height) {
  return CustomFooter(
    height: height,
    builder: (BuildContext context, LoadStatus mode) {
      Widget body;
      if (mode == LoadStatus.idle) {
        body = Container();
      } else if (mode == LoadStatus.loading) {
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
      } else if (mode == LoadStatus.failed) {
        body = Text(
          ResponsiveString.of(context).clickReload,
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        );
      } else if (mode == LoadStatus.canLoading) {
        body = Container();
      } else {
        body = Text(
          ResponsiveString.of(context).noLoadData,
          style: TextStyle(fontSize: 16, color: Colors.grey[400]),
        );
      }
      return Container(
        height: height,
        child: Center(child: body),
      );
    },
  );
}
