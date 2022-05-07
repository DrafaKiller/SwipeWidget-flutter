library swipe_widget;

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// # Swipe Widget
/// 
/// A draggable Widget, that can be swiped to the left or right.
/// 
/// Swiping the widget will trigger the [onSwipe] callback. And [onSwipeLeft], [onSwipeRight] callbacks, depeding on the direction.
/// 
/// ```dart
/// SwipeWidget(
///     child: <your_widget>
/// );
/// ```
/// 
/// If you want to add funcionalities you can add Functions:
/// ```dart
/// SwipeWidget(
///     onSwipe: () => print('Swiped!'),
///     onSwipeLeft: () => print('Swiped left! I feel rejected...'),
///     onSwipeRight: () => print('Swiped right!'),
///     onUpdate: (distance) => print('The distance of the swipe is $distance (from 0 to 1)'),
///     child: <your_widget>
/// );
/// ```
/// 
/// You can change how the swipe should react:
/// ```dart
/// SwipeWidget(
///     distance: 0.5,
///     angle: 0.4,
///     rotation: 25,
///     scale: 1,
///     dragResistance: 0.5,
///     child: <your_widget>
/// );
/// ```
/// * These properties are related to how far the widget is being dragged.
/// * **Distance** is the threshold needed to take action when dropping. (Example: If it was 0.5, you would only need to drag half way and let it go, it would act like a full swipe)
/// * **Angle** is in radians, while **rotation** is in degrees. (Angle has priority)
class SwipeWidget extends StatefulWidget {
  final Widget child;

  final void Function()? onSwipe;
  final void Function()? onSwipeLeft;
  final void Function()? onSwipeRight;
  final void Function(double)? onUpdate;

  final double distance;
  final double dragResistance;
  final double angle;
  final double rotation;
  final double scale;

  final double minVelocity = 150;
  final double maxVelocity = 500;

  const SwipeWidget({
    Key? key, required this.child,
    this.onSwipe, this.onSwipeLeft, this.onSwipeRight, this.onUpdate,
    this.distance = 0.5, this.dragResistance = 0.5,
    double? angle, this.rotation = 25, this.scale = 1
  }) : angle = angle ?? math.pi * rotation / 180, super(key: key);

  @override
  State<SwipeWidget> createState() => _SwipeWidgetState();
}

class _SwipeWidgetState extends State<SwipeWidget> with TickerProviderStateMixin {
  final Tween<Offset> _tween = Tween<Offset>();
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  late Animation<Offset> _animation = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  Offset _offset = Offset.zero;
  Offset _velocity = Offset.zero;
  double _angle = 0;
  double _distance = 0;
  double _scale = 1;
  bool _fade = false;

  @override
  void initState() {
    super.initState();
    _animation.addListener(() => setOffset(_animation.value));
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: _offset,
      child: Transform.rotate(
        angle: _angle,
        child: Transform.scale(
          scale: _scale,
          child: Opacity(
            opacity: 1 - (_fade ? _controller.value : 0),
            child: GestureDetector(
              onPanUpdate: (details) => setOffset(_offset + details.delta * widget.dragResistance),
              onPanEnd: (details) {
                _velocity = details.velocity.pixelsPerSecond;
                
                if (_distance / widget.dragResistance > widget.distance) {
                  right();
                } else if (_distance / widget.dragResistance < -widget.distance) {
                  left();
                } else {
                  reset();
                }
              },
              child: widget.child,
            )
          ),
        ),
      ),
    );
  }
  
  /// Set the position of the Widget, taking into account the angle and scale.
  void setOffset(Offset offset) {
    setState(() {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;

      _offset = offset;
      _distance = (offset.dx / renderBox.size.width * 2).clamp(-1, 1);
      _angle = _distance * widget.angle;
      _scale = 1 + _distance.abs() * (widget.scale - 1);

      widget.onUpdate?.call(_distance);
    });
  }

  /// Moves the widget to a position, smoothly.
  void animateTo(Offset offset) {
    _fade = false;
    _animation = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _tween.begin = _offset;
    _tween.end = offset;
    _controller.reset();
    _controller.forward();
  }

  /// Reset the widget to the center position.
  void reset() {
    _fade = false;
    animateTo(Offset.zero);
  }
  
  /// Swipe to the left, while fading.
  void left() {
    animateTo(_offset - Offset(_velocity.dx.abs().clamp(widget.minVelocity, widget.maxVelocity), 0) + Offset(0, _velocity.dy / 10));
    _fade = true;
    _animation = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    widget.onSwipeLeft?.call();
    _controller.addStatusListener(_done);
  }

  /// Swipe to the right, while fading.
  void right() {
    animateTo(_offset + Offset(_velocity.dx.abs().clamp(widget.minVelocity, widget.maxVelocity), 0) + Offset(0, _velocity.dy / 10));
    _fade = true;
    _animation = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    widget.onSwipeRight?.call();
    _controller.addStatusListener(_done);
  }
  
  void _done(AnimationStatus status) {
    _controller.removeStatusListener(_done);
    if (status == AnimationStatus.completed) {
      widget.onSwipe?.call();
    }
  }
}