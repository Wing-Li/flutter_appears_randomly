import 'dart:math';

import 'package:flutter/material.dart';

class StaggerAnimation extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final double sizeRange;
  final int animMilliseconds;
  final Function onEnd;

  const StaggerAnimation({
    Key key,
    this.width,
    this.height,
    this.sizeRange,
    this.child,
    this.onEnd,
    this.animMilliseconds = 4000,
  }) : super(key: key);

  @override
  _StaggerAnimationState createState() => _StaggerAnimationState();
}

class _StaggerAnimationState extends State<StaggerAnimation> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<Size> _sizeTween;
  Animation<double> _opacity;

  bool isEnd = false;

  @override
  void initState() {
    super.initState();

    isEnd = false;

    _animationController = AnimationController(duration: Duration(milliseconds: widget.animMilliseconds), vsync: this)
      ..addListener(() {
        if (_animationController.status == AnimationStatus.dismissed) {
          setState(() {
            isEnd = true;
          });
          if (widget.onEnd != null) widget.onEnd();
        }
      });

    var random = widget.sizeRange * Random().nextDouble();
    _sizeTween = SizeTween(
      begin: Size(widget.width - random, widget.height - random),
      end: Size(widget.width + random, widget.height + random),
    ).animate(_animationController);

    _opacity = Tween<double>(begin: 0.0, end: 0.9).animate(
      // _animationController
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          0.0, 0.4, //间隔，前60%的动画时间
          curve: Curves.ease,
        ),
      ),
    );

    _playAnimation();
  }

  Future<Null> _playAnimation() async {
    try {
      //先正向执行动画
      await _animationController.forward().orCancel;
      //再反向执行动画
      await _animationController.reverse().orCancel;
    } on TickerCanceled {
      // the animation got canceled, probably because we were disposed
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEnd
        ? SizedBox()
        : AnimatedBuilder(
            animation: _animationController,
            builder: (BuildContext context, Widget c) {
              return Opacity(
                opacity: _opacity.value,
                child: SizedBox(
                  width: _sizeTween.value.width,
                  height: _sizeTween.value.height,
                  child: widget.child,
                ),
              );
            },
          );
  }
}
