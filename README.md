# Swipe Widget
A Flutter Widget to make your widgets swipe to the sides.

## Features

* Your widget will be draggable with a smooth animation.
* When dragging to the sides and releasing, the widget will swipe away if it passes a certain threshold.
* You can set actions for swipe, left and right, and to when the distance changes.
* You can customize how it reacts when dragged, parameters are available when creating the widget.

## Getting started

Install it using pub:
```
flutter pub add swipe_widget
```

And import the package:
```dart
import 'package:swipe_widget/swipe_widget.dart';
```

## Usage

It's as simple as:
```dart
SwipeWidget(
    child: <widget>
);
```

If you want to add funcionalities you can add Functions:
```dart
SwipeWidget(
    onSwipe: () => print('Swiped!'),
    onSwipeLeft: () => print('Swiped left! I feel rejected...'),
    onSwipeRight: () => print('Swiped right!'),
    onUpdate: (distance) => print('The distance of the swipe is $distance (from 0 to 1)'),
    child: <widget>
);
```

You can change how the swipe should react:
```dart
SwipeWidget(
    distance: 0.5,
    angle: 0.4,
    rotation: 25,
    scale: 1,
    dragStrenght: 0.5,
    child: <widget>
);
```
* These properties are related to how far the widget is being dragged.
* **Distance** is the threshold needed to take action when released. (Example: If it was 0.5, you would only need to drag half way and releasing, it would act like a full swipe)
* **Angle** is in radians, while **rotation** is in degrees. (Angle has priority over rotation)

## GitHub

The widget code is available on Github: [Flutter - SwipeWidget](https://github.com/DrafaKiller/SwipeWidget)

## Widget Preview
Example 1

![SwipeWidget - Preview 1](https://user-images.githubusercontent.com/42767829/161968848-dba36f65-21ed-49a2-b763-f4288c61a28c.gif)

Example 2

![SwipeWidget - Preview 2](https://user-images.githubusercontent.com/42767829/161968853-c2eed51e-ea56-466d-9ee3-841d24280671.gif)
