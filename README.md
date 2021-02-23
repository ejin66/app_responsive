# app_responsive

flutter responsive library

## 简介
一个完整的页面，通常有IPage、IState、IController三个角色构成。

### IPage / IState
`IPage/IState`分别是继承自`StatefulWidget/State`，负责UI展示。 主要逻辑在`IState`中，控制`IController`的生命周期。

### IController
定位是逻辑控制类，配合View `IPage/IState`，实现页面的展现、刷新。

## 简单例子
```dart
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
			body: buildBody.watch<PPage>()(context),
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
  	Future.delayed(Duration(seconds: 2), () {
        text = "flutter";
        get<PPage>().notify();
    });
  	return LoadState.loaded;
  }

}
```
页面开始显示的是`android`, 2秒后会刷新为`flutter`。实现步骤如下：
1. 通过`buildBody.watch<PPage>()(context)`, `buildBody` widget 将纳入`PPage`的控制范围内。
2. 通过`IController`中的`get<PPage>()`可获取`PPage`实例。
3. 在`PPage.notify()`触发更新后，`buildBody`这个部分将会刷新。

## 问题

### `PPage`是啥？每个IController都有PPage吗？

`PPage` 继承自`Level`。`Level` 就是所有UI控制点的基类。

框架自带的UI控制点有：PPage、Load、Scope、Child。本质上都是一样的继承自`Level`, 但我们约定它们控制范围大小关系：

> PPage > Load > Scope > Child

我们也可以创建自定义的控制点，需要手动调用：`IController.useLevel<Your customize Level type>()`

 一个`IController`默认有两个`Level`: PPage、Load. 我们可以通过：

```dart
icontroller.get<PPage>();
icontroller.get<Load>();
```

也可以直接这样：

```dart
icontroller.pageLevel;
icontroller.loadLevel;
```

### 如何获取其他页面的数据
`PPage`是支持将关联的`IController`暴露出来的。通过`get<PPage>.exposeToApp(buildContext)`, 将当前的`IController`暴露出来。
在其他页面下，可通过`AppProvider.get<ExampleController>(buildContext)`方式获取到。该方法中的泛型即代表想获取的`IController`。

当然，这有个前提，需要在`MaterialApp`外包裹`AppProvider`。

### 如何添加页面的刷新、分页
上面的例子中，修改下写法：`buildBody.load(refresh: true, loadMore: true).watch<PPage>()(context)`即可。
`.load()`方法主要就是控制页面的初始化、刷新、加载更多等。