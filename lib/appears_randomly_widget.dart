import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'stagger_animation.dart';

class AppearsRandomlyWidget extends StatefulWidget {
  final double width;
  final double height;
  final int itemCount;
  final ItemBuilder itemBuilder;
  final double itemWidth;
  final double itemHeight;
  final double itemSizeRange;
  final Size centerRestrictedArea;
  final Widget centerChild;

  /// 间隔时间，毫秒
  final int intervals;

  /// 动画时间，毫秒
  final int animMilliseconds;

  const AppearsRandomlyWidget({
    Key key,
    this.itemCount,
    this.itemBuilder,
    this.width,
    this.height,
    this.itemWidth,
    this.itemHeight,
    this.itemSizeRange,
    this.intervals = 2000,
    this.animMilliseconds = 5000,
    this.centerRestrictedArea,
    this.centerChild,
  }) : super(key: key);

  @override
  _AppearsRandomlyWidgetState createState() => _AppearsRandomlyWidgetState();
}

class _AppearsRandomlyWidgetState extends State<AppearsRandomlyWidget> {
  List<Widget> childList = [];
  BuildContext mContext;

  /// 控件的key
  GlobalKey _bodyKey = GlobalKey();
  double width;
  double height;

  List<Size> savedPoint = [];

  @override
  void initState() {
    super.initState();

    _initState();

    Future.delayed(Duration.zero, _loopMain);
  }

  _initState() {
    width = widget.width;
    height = widget.height;

    // 在控件渲染完成后执行的回调
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _findRenderObject();
    });

    if (widget.centerChild != null) {
      if (childList.length > 0) {
        childList.removeAt(0);
      }
      childList.insert(
          0,
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(child: widget.centerChild),
          ));
    }
  }

  /// 得到当前控件的宽高
  _findRenderObject() {
    RenderBox renderBox = _bodyKey.currentContext.findRenderObject();
    setState(() {
      width = renderBox.size.width;
      height = renderBox.size.height;
    });
  }

  /// 获取当前显示的图标位置
  Size _getShowXY() {
    double x = (width - widget.itemWidth) * Random().nextDouble() * 0.95;
    double y = (height - widget.itemHeight) * Random().nextDouble() * 0.95;

    try {
      if (widget.centerRestrictedArea != null) {
        double areaW = widget.centerRestrictedArea.width / 2 + widget.itemWidth / 2;
        double areaH = widget.centerRestrictedArea.height / 2 + widget.itemHeight / 2;
        // 随机值不能在中心禁区
        if (width / 2 - areaW - widget.itemWidth * 0.5 - widget.itemSizeRange < x &&
            x < width / 2 + areaW &&
            height / 2 - areaH - widget.itemHeight * 0.5 - widget.itemSizeRange < y &&
            y < height / 2 + areaH) {
          return _getShowXY();
        }
      }

      // 随机值，不能在已有的列表里
      for (int i = 0; i < savedPoint.length; i++) {
        var it = savedPoint[i];
        if (it.width - widget.itemWidth - widget.itemSizeRange < x &&
            x < it.width + widget.itemWidth + widget.itemSizeRange && //
            it.height - widget.itemHeight - widget.itemSizeRange < y &&
            y < it.height + widget.itemHeight + widget.itemSizeRange) {
          return Size(-100, -100);
        }
      }

      return Size(x, y);
    } catch (e) {
      // MyUtils.log("$x - $y == ${savedPoint.length}");

      return Size(x, y);
    }
  }

  _loopMain({int delayed = 30}) {
    Future.delayed(Duration(milliseconds: delayed), () {
      if (mContext != null) {
        if (widget.itemCount > 0) {
          int count = _random(1, 4);
          for (int i = 0; i < count; i++) {
            Size saveXY = _getShowXY();
            if (saveXY.width < 0) continue;

            savedPoint.add(saveXY);

            var childItem = Positioned(
              left: saveXY.width,
              bottom: saveXY.height,
              child: _buildChildItem(
                context,
                onEnd: () {
                  // MyUtils.log("end");
                  savedPoint.remove(saveXY);
                },
              ),
            );
            childList.add(childItem);
          }

          if (!isDispose) setState(() {});
        }
      }

      int delayed = _random(300, widget.intervals);
      _loopMain(delayed: delayed);
    });
  }

  _buildChildItem(BuildContext context, {Function onEnd}) {
    int randomIndex = Random().nextInt(widget.itemCount);

    return StaggerAnimation(
      width: widget.itemWidth,
      height: widget.itemHeight,
      sizeRange: widget.itemSizeRange,
      child: widget.itemBuilder(context, randomIndex),
      animMilliseconds: widget.animMilliseconds,
      onEnd: onEnd,
    );
  }

  @override
  void didUpdateWidget(covariant AppearsRandomlyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.width != oldWidget.width || widget.height != oldWidget.height) {
      _initState();
    }
  }

  bool isDispose = false;

  @override
  void dispose() {
    isDispose = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    mContext = context;

    return Container(
      key: _bodyKey,
      width: width,
      height: height,
      child: Stack(
        children: childList,
      ),
    );
  }

  int _random(int start, int end) {
    Random random = new Random();
    return random.nextInt(end) % (end - start + 1) + start;
  }
}

typedef ItemBuilder = Widget Function(BuildContext context, int index);
