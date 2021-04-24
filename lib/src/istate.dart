import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'icontroller.dart';

abstract class IState<T extends StatefulWidget, K extends IController>
    extends State<T> {
  bool get keepAlive => false;

  K get controller;

  @override
  void initState() {
    super.initState();
    controller.mount(this);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      controller.refresh();
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.unmount();
    if (!keepAlive) controller.dispose();
  }

  rebuild() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: controller.providers,
      child: buildChild(context),
    );
  }

  Widget buildChild(BuildContext context);
}
