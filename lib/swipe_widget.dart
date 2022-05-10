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
///     child: <widget>
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
///     child: <widget>
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
///     child: <widget>
/// );
/// ```
/// * These properties are related to how far the widget is being dragged.
/// * **Distance** is the threshold needed to take action when released. (Example: If it was 0.5, you would only need to drag half way and releasing, it would act like a full swipe)
/// * **Angle** is in radians, while **rotation** is in degrees. (Angle has priority over rotation)
class SwipeWidget extends StatefulWidget {

  /// The child widget.
  final Widget child;

  /// Called when the widget is swiped.
  final void Function()? onSwipe;

  /// Called when the widget is swiped to the left.
  final void Function()? onSwipeLeft;

  /// Called when the widget is swiped to the right.
  final void Function()? onSwipeRight;

  /// Called when the widget is being dragged, including the distance.
  final void Function(double distance)? onUpdate;

  /// ## Distance
  /// How far the widget is dragged before it is considered a swipe after it is released. From `0` to `1`.
  /// 
  /// The default is `0.5`, meaning that from the center to the side, it only needs to be dragged 50%, half way.
  final double distance;

  /// ## Drag Resistance
  /// When dragging, the widget can show resistance by staying behind the pointer/finger. From `0` to `1`.
  /// 
  /// The default is `0.5`, meaning that the widget will be displayed 50% between the center and the pointer/finger.
  /// 
  /// ***Example:** Resistance at `0` would make the widget be exactly where the pointer/finger is.*
  final double dragResistance;

  /// ## Angle
  /// Maximum rotation in **radians** of the widget when dragged.
  /// 
  /// The default is `0.436332` (25 degrees).
  /// 
  /// Alternatively you can use [rotation] for **degrees**.
  /// 
  /// [angle] has priority over [rotation].
  final double angle;

  /// ## Rotation
  /// Maximum rotation in **degrees** of the widget when dragged.
  /// 
  /// The default is `25` degrees.
  /// 
  /// Alternatively you can use [angle] for **radians**.
  /// 
  /// [angle] has priority over [rotation].
  final double rotation;

  /// ## Scale
  /// Scale of the widget when dragged.
  /// 
  /// The default is `1`.
  /// 
  /// ***Example:** To make the widget smaller when dragged, use a number smaller than 1.*
  final double scale;

  /// ## Velocity
  /// Minimum velocity of the widget after swiped.
  /// 
  /// The default is `150`.
  final double minVelocity = 150;

  /// ## Velocity
  /// Maximum velocity of the widget after swiped.
  /// 
  /// The default is `500`.
  final double maxVelocity = 500;

  /// ## Swipe Widget
  /// Creates a draggable Widget, that can be swiped to the left or right.
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
  
  /// Set the position of the Widget, changing the angle and scale, accordingly.
  /// 
  /// The position is always from the center of the widget, using a offset.
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

  /// Moves the widget to a position, smoothly with an animation.
  void animateTo(Offset offset) {
    _fade = false;
    _animation = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _tween.begin = _offset;
    _tween.end = offset;
    _controller.reset();
    _controller.forward();
  }

  /// Resets the widget back to the center position, smoothly.
  void reset() {
    _fade = false;
    animateTo(Offset.zero);
  }
  
  /// Programatically swipes the widget to the left, with a fading animation.
  void left() {
    animateTo(_offset - Offset(_velocity.dx.abs().clamp(widget.minVelocity, widget.maxVelocity), 0) + Offset(0, _velocity.dy / 10));
    _fade = true;
    _animation = _tween.animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    widget.onSwipeLeft?.call();
    _controller.addStatusListener(_done);
  }

  /// Programatically swipes the widget to the right, with a fading animation.
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