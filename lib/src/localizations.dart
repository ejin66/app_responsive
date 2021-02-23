import 'package:flutter/material.dart';



abstract class ResponsiveString {

  String get loading;
  String get clickReload;
  String get noLoadData;
  String get noMoreData;
  String get loadingMore;

  static ResponsiveString of(BuildContext context) {
    final code = Localizations.localeOf(context)?.languageCode ?? "en";

    if (code == "zh") return ChResponsiveString();

    return EnResponsiveString();
  }
}

class EnResponsiveString extends ResponsiveString {
  @override
  String get clickReload => "Click reload";

  @override
  String get noLoadData => "No data available";

  @override
  String get loading => "Loading";

  @override
  String get loadingMore => "Loading more";

  @override
  String get noMoreData => "No more data";
}

class ChResponsiveString extends ResponsiveString {
  @override
  String get clickReload => "点击重新加载";

  @override
  String get noLoadData => "暂无数据";

  @override
  String get loading => "正在加载中";

  @override
  String get loadingMore => "正在加载更多数据";

  @override
  String get noMoreData => "没有更多数据了";
}