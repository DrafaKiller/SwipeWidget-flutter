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