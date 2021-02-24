import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'localizations.dart';

class EmptyComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          NoDataWidget(),
          SizedBox(height: 20),
          Text(
            ResponsiveString.of(context).noLoadData,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}

class DotLoading extends StatefulWidget {
  final String text;
  final TextStyle textStyle;

  DotLoading(this.text, {this.textStyle});

  @override
  _DotLoadingState createState() => _DotLoadingState();
}

class _DotLoadingState extends State<DotLoading> with TickerProviderStateMixin {
  Timer timer;
  int _count = 1;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _count = (_count + 1) % 4;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(widget.text, style: widget.textStyle),
        Padding(
          padding: EdgeInsets.only(top: (widget.textStyle?.fontSize ?? 0) / 2),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 0,
                child: Text(
                  _getDot(3),
                  style: widget.textStyle,
                ),
              ),
              Text(_getDot(_count), style: widget.textStyle),
            ],
          ),
        ),
      ],
    );
  }

  _getDot(int count) {
    var dot = "";
    for (int i = 1; i <= count; i++) {
      dot += "·";
    }
    return dot;
  }
}

class NoDataWidget extends StatefulWidget {
  final Color color;
  final Size size;
  final Duration duration;

  NoDataWidget({
    this.color = Colors.grey,
    this.size = const Size(190, 140),
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  _NoDataWidgetState createState() => _NoDataWidgetState(duration);
}

class _NoDataWidgetState extends State<NoDataWidget>
    with TickerProviderStateMixin {
  AnimationController animationController;

  _NoDataWidgetState(Duration duration) {
    animationController = AnimationController(vsync: this, duration: duration);
  }

  @override
  void initState() {
    super.initState();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.stop();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      builder: (BuildContext context, Widget child) {
        return CustomPaint(
          painter: NoDataPainter(animationController.value, widget.color),
          size: widget.size,
        );
      },
      animation: animationController,
    );
  }
}

class NoDataPainter extends CustomPainter {
  final painter = Paint();
  final Color color;

  double time;

  List<AnimatePath> animatedPathList;

  NoDataPainter(this.time, this.color) {
    painter.color = color;
    painter.style = PaintingStyle.stroke;
    painter.strokeCap = StrokeCap.round;

    animatedPathList = [
      AnimatedHorizontalLine(TimeRange(0, 0.5), Offset(0, 0), Offset(1, 0)),
      AnimatedHorizontalLine(TimeRange(0, 0.5), Offset(0, 0.2), Offset(1, 0.2)),
      AnimatedHorizontalLine(TimeRange(0, 0.5), Offset(0, 1), Offset(1, 1)),
      AnimatedVerticalLine(TimeRange(0.5, 1), Offset(0, 0), Offset(0, 0.2)),
      AnimatedVerticalLine(TimeRange(0.5, 1), Offset(0, 0.2), Offset(0, 1)),
      AnimatedVerticalLine(TimeRange(0.5, 1), Offset(1, 0), Offset(1, 0.2)),
      AnimatedVerticalLine(TimeRange(0.5, 1), Offset(1, 0.2), Offset(1, 0.6)),
      AnimatedCircle(TimeRange.max(), Offset(1, 0.8), 0.2),
      AnimatedPoint(TimeRange.point(0.1), Offset(0.1, 0.1)),
      AnimatedPoint(TimeRange.point(0.4), Offset(0.15, 0.1)),
      AnimatedPoint(TimeRange.point(0.7), Offset(0.2, 0.1)),
      AnimatedPoint(TimeRange.point(0.1), Offset(0.15, 0.4), thick: 0.04),
      AnimatedPoint(TimeRange.point(0.4), Offset(0.15, 0.6), thick: 0.04),
      AnimatedPoint(TimeRange.point(0.7), Offset(0.15, 0.8), thick: 0.04),
      AnimatedHorizontalLine(
          TimeRange(0.2, 0.6), Offset(0.25, 0.4), Offset(0.8, 0.4),
          thick: 0.04),
      AnimatedHorizontalLine(
          TimeRange(0.4, 0.8), Offset(0.25, 0.6), Offset(0.75, 0.6),
          thick: 0.04),
      AnimatedHorizontalLine(
          TimeRange(0.6, 1), Offset(0.25, 0.8), Offset(0.7, 0.8),
          thick: 0.04),
      AnimatedArc(TimeRange(0, 0.75), Offset(1, 0.75), 0.05, pi, 2.5 * pi,
          thick: 0.03),
      AnimatedVerticalLine(TimeRange(0.75, 1), Offset(1, 0.8), Offset(1, 0.85),
          thick: 0.03),
      AnimatedPoint(TimeRange.point(1), Offset(1, 0.92), thick: 0.03),
    ];
  }

  @override
  void paint(Canvas canvas, Size size) {
    painter.color = color;
    painter.style = PaintingStyle.stroke;
    canvas.save();
    canvas.translate(0.08 * size.width - 0.025 * size.height, 0);
    final _size = Size(
      size.width - 2 * 0.08 * size.width,
      size.height - 0.15 * size.height,
    );
    animatedPathList.forEach((element) {
      element.draw(canvas, _size, element.adjustPaint(painter, _size), time);
    });
    canvas.restore();

    painter.color = color.withAlpha(0xAA);
    painter.style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromLTRB(
          0, size.height - 0.15 * size.height + 5, size.width, size.height),
      -0.25 * pi,
      1.5 * pi,
      false,
      painter,
    );
  }

  @override
  bool shouldRepaint(covariant NoDataPainter oldDelegate) {
    return oldDelegate.time != this.time;
  }
}

class TimeRange {
  final double start, end;

  TimeRange(this.start, this.end);

  TimeRange.max()
      : start = 0,
        end = 1;

  TimeRange.point(double point)
      : start = point,
        end = point;

  double convert(double globalTime) {
    if (globalTime < start) return 0;
    if (globalTime > end) return 1;

    return (globalTime - start) / (end - start);
  }
}

abstract class AnimatePath {
  final TimeRange timeRange;

  AnimatePath(this.timeRange);

  /// time 0 - 1
  draw(Canvas canvas, Size size, Paint painter, double time) {}

  Paint adjustPaint(Paint painter, Size size) {
    return painter;
  }
}

class AnimatedPoint extends AnimatePath {
  final Offset offset;
  final double thick;

  AnimatedPoint(rangeTime, this.offset, {this.thick}) : super(rangeTime);

  @override
  draw(Canvas canvas, Size size, Paint painter, double time) {
    final convertTime = timeRange.convert(time);
    if (convertTime == 0) return;

    canvas.drawPoints(
        PointMode.points, [offset.scale(size.width, size.height)], painter);
  }

  @override
  Paint adjustPaint(Paint painter, Size size) {
    return painter..strokeWidth = (thick ?? 0.02) * size.width;
  }
}

class AnimatedArc extends AnimatePath {
  final Offset offset;
  final double radius;
  final double startAngle;
  final double endAngle;
  final double thick;

  AnimatedArc(TimeRange timeRange, this.offset, this.radius, this.startAngle,
      this.endAngle,
      {this.thick})
      : super(timeRange);

  double angleWhenCurrentTime(
      double startAngle, double endAngle, double currentTime) {
    return endAngle * currentTime + (1 - currentTime) * startAngle;
  }

  @override
  draw(Canvas canvas, Size size, Paint painter, double time) {
    final convertTime = timeRange.convert(time);
    if (convertTime == 0) return;

    canvas.drawArc(
      Rect.fromCircle(
          center: offset.scale(size.width, size.height),
          radius: radius * size.height),
      startAngle,
      angleWhenCurrentTime(startAngle, endAngle, convertTime) - startAngle,
      false,
      painter,
    );
  }

  @override
  Paint adjustPaint(Paint painter, Size size) {
    return painter..strokeWidth = (thick ?? 0.02) * size.width;
  }
}

class AnimatedCircle extends AnimatedArc {
  AnimatedCircle(TimeRange timeRange, offset, radius, {thick})
      : super(timeRange, offset, radius, 0, 2 * pi, thick: thick);
}

class AnimatedHorizontalLine extends AnimatePath {
  Offset start;
  Offset end;
  final double thick;

  AnimatedHorizontalLine(timeRange, this.start, this.end, {this.thick})
      : super(timeRange);

  double lengthWhenCurrentTime(
      double startLen, double endLen, double currentTime) {
    return currentTime + (1 - currentTime) * startLen / endLen;
  }

  @override
  draw(Canvas canvas, Size size, Paint painter, double time) {
    final convertTime = timeRange.convert(time);
    if (convertTime == 0) return;

    canvas.drawLine(
      start.scale(size.width, size.height),
      end.scale(
        lengthWhenCurrentTime(start.dx, end.dx, convertTime) * size.width,
        size.height,
      ),
      painter,
    );
  }

  @override
  Paint adjustPaint(Paint painter, Size size) {
    return painter..strokeWidth = (thick ?? 0.02) * size.width;
  }
}

class AnimatedVerticalLine extends AnimatedHorizontalLine {
  AnimatedVerticalLine(timeRange, Offset start, Offset end, {thick})
      : super(timeRange, start, end, thick: thick);

  @override
  draw(Canvas canvas, Size size, Paint painter, double time) {
    final convertTime = timeRange.convert(time);
    if (convertTime == 0) return;

    canvas.drawLine(
      start.scale(size.width, size.height),
      end.scale(
        size.width,
        lengthWhenCurrentTime(start.dy, end.dy, convertTime) * size.height,
      ),
      painter,
    );
  }
}
