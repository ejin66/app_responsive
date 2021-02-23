import 'package:flutter/material.dart';

import 'app_responsive.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends IPage {
  @override
  IState<IPage, IController> createState() => ExampleState();
}

class ExampleState extends IState<ExamplePage, ExampleController> {

  final ExampleController _controller = ExampleController();

  @override
  Widget buildChild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("app responsive demo"),
      ),
      body: buildBody.load().watch<PPage>()(context),
    );
  }

  Widget buildBody(BuildContext context) {
    return Center(
      child: Text(controller.text),
    );
  }

  @override
  ExampleController get controller => _controller;

}

class ExampleController extends IController {

  String text = "android";

  @override
  Future<int> load([int page]) async {
    await Future.delayed(Duration(seconds: 2), () {
      text = "flutter";
      get<PPage>().notify();
    });
    return LoadState.empty;
  }

}