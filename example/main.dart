import 'package:app_responsive/app_responsive.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      child: MaterialApp(
        title: 'App responsive Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: ExamplePage(),
      ),
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
    return ListView.separated(
      padding: EdgeInsets.all(10),
      itemBuilder: (_, index) {
        return ListTile(title: Text(controller.data[index]));
      },
      separatorBuilder: (_, index) {
        return Divider(height: 1);
      },
      itemCount: controller.data.length,
    );
  }

  @override
  ExampleController get controller => _controller;
}

class ExampleController extends IController {
  String text = "android";

  List<String> data = [];

  @override
  Future<int> load([int page]) async {
    final newData = await _loadData(page);
    return computeLoadingState(data, newData, page, pageRows: 50);
  }

  Future<List<String>> _loadData(int page) async {
    await Future.delayed(Duration(seconds: 2));
    if (page > 3) return [];

    return List<String>.generate(
      50,
      (index) => ((page - 1) * 50 + index + 1).toString(),
    );
  }
}