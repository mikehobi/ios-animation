# Swift iOS Animation

A bunch of helper functions for animating in Swift. The goal of this helper is to combat excessive indentation and nesting that comes with using `UIView.animate`

## Features

### Animation Block

The smallest building block of composing our animations. Essentially a clone of `UIView.animate` with a friendly parameter for easing.

```swift
Animation({
    self.firstView.alpha = 1
}, duration: 0.4, delay: 0.2, easing: .easeInOutQuad)
```

It can be used independently by calling `.start()`

```swift
Animation({
    self.firstView.alpha = 1
}, duration: 0.4, delay: 0.2, easing: .easeInOutQuad).start()
```

Or it can be stored in a variable for later usage

```swift
// Stored
let myAnimation = Animation({
    self.firstView.alpha = 1
}, duration: 0.4, delay: 0.2, easing: .easeInOutQuad)

// Later
myAnimation.start()

// Composed
Animation.Sequence([
    // ... preceding animations ...
    myAnimation,
    // ... succeding animations ...
]).start()
```

### Sequence Animations

##### Before

```swift
UIView.animate(withDuration: 0.4, animations: {
    self.primaryView.alpha = 1
}, completion: { _ in
    UIView.animate(withDuration: 0.4, animations: {
        self.secondaryView.alpha = 1
    }, completion: { _ in
        UIView.animate(withDuration: 0.4, animations: {
            self.tertiaryView.alpha = 1
        }, completion: { _ in
            print("animation finished")
        })
    })
})
```

##### After

```swift
Animation.Sequence([
    Animation({
        self.firstView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.secondView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.thirdView.alpha = 1
    }, duration: 0.4),
]).start() {
    print("animation finished")
}
```

### Stagger Animations

##### Before

Notice the incrementing delays, this can be hard to keep track, especially with more fine-tuned values.

```swift
UIView.animate(withDuration: 0.4, animations: {
    self.firstView.alpha = 1
})
UIView.animate(withDuration: 0.4, delay: 0.25, animations: {
    self.secondView.alpha = 1
})
UIView.animate(withDuration: 0.4, delay: 0.5, animations: {
    self.thirdView.alpha = 1
})
UIView.animate(withDuration: 0.4, delay: 0.75, animations: {
    self.fourthView.alpha = 1
})
```

##### After

Each animation will fire `0.25` seconds after it's predecessor has animated.

```swift
Animation.Stagger([
    Animation({
        self.firstView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.secondView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.thirdView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.fourthView.alpha = 1
    }, duration: 0.4),
], interval: 0.25).start()
```

### Parallel Animations

Parallel animations by themselves do not add too much benefit, but when composing with sequences and staggers, you can create much more complex animations.

##### Before

```swift
UIView.animate(withDuration: 0.4, animations: {
    self.firstView.alpha = 1
})
UIView.animate(withDuration: 0.4, animations: {
    self.secondView.alpha = 1
})
UIView.animate(withDuration: 0.4, animations: {
    self.thirdView.alpha = 1
})
UIView.animate(withDuration: 0.4, animations: {
    self.fourthView.alpha = 1
})
```

##### After

```swift
Animation.Parellel([
    Animation({
        self.firstView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.secondView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.thirdView.alpha = 1
    }, duration: 0.4),
    Animation({
        self.fourthView.alpha = 1
    }, duration: 0.4),
]).start()
```

### Composing Animations

In the code below, the animations of `firstView` and `secondView` will fire in parallel, then after completion of the longest animation, a staggered animation of `thirdView` and `fourthView`.

```swift
Animation.Sequence([
    // 1. Fire `firstView` and `secondView` animations in parallel
    Animation.Parallel([
        Animation({
            self.firstView.alpha = 1
        }, duration: 0.3),
        Animation({
            self.secondView.alpha = 1
        }, duration: 0.4),
    ]),
    // 2. Stagger animation fires after our longest parallel animation
    Animation.Stagger([
        Animation({
            self.thirdView.alpha = 1
        }, duration: 0.5),
        Animation({
            self.fourthView.alpha = 1
        }, duration: 0.4),
    ], interval: 0.25),
    // 3. Last animation fires after last staggered animation
    Animation({
        self.fifthView.alpha = 1
    }, duration: 0.6),
]).start()
```

Creating this animation with default `UIView.animate` would look something like this:

```swift
UIView.animate(withDuration: 0.3, animations: {
    self.firstView.alpha = 1
})

UIView.animate(withDuration: 0.4, animations: {
    self.secondView.alpha = 1
}, completion: { _ in
    UIView.animate(withDuration: 0.5, animations: {
        self.thirdView.alpha = 1
    })
    UIView.animate(withDuration: 0.4, delay: 0.25, animations: {
        self.fourthView.alpha = 1
    }, completion: { _ in
        UIView.animate(withDuration: 0.6, animations: {
            self.fifthView.alpha = 1
        })
    })
})
```

### Custom Easing

```swift
Animation({
    self.firstView.alpha = 1
}, duration: 0.3, easing: CAMediaTimingFunction.easeInQuad).start()

Animation({
    self.secondView.alpha = 1
}, duration: 0.4, easing: CAMediaTimingFunction.easeOutQuad).start()
```

In order to achieve this in `UIView.animate` (using the CAMediaTimingFunction extension):

```swift
CATransaction.begin()
CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.easeInQuad)
UIView.animate(withDuration: 0.3, animations: {
    self.firstView.alpha = 1
})
CATransaction.commit()

CATransaction.begin()
CATransaction.setAnimationTimingFunction(CAMediaTimingFunction.easeOutQuad)
UIView.animate(withDuration: 0.4, animations: {
    self.secondView.alpha = 1
})
CATransaction.commit()
```

#### Available easing curves

| Enum             | CAMediaTimingFunction values                                      |
| ---------------- | ----------------------------------------------------------------- |
| `ease`           | `CAMediaTimingFunction(controlPoints: 0.17, 0.67, 0.83, 0.67)`    |
| `easeInSine`     | `CAMediaTimingFunction(controlPoints: 0.47, 0, 0.745, 0.715)`     |
| `easeOutSine`    | `CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1)`     |
| `easeInOutSine`  | `CAMediaTimingFunction(controlPoints: 0.445, 0.05, 0.55, 0.95)`   |
| `easeInQuad`     | `CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)`   |
| `easeOutQuad`    | `CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)`    |
| `easeInOutQuad`  | `CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)` |
| `easeInCubic`    | `CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)`  |
| `easeOutCubic`   | `CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)`     |
| `easeInOutCubic` | `CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)`    |
| `easeInQuart`    | `CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)`  |
| `easeOutQuart`   | `CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)`      |
| `easeInOutQuart` | `CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)`         |
| `easeInQuint`    | `CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)`  |
| `easeOutQuint`   | `CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)`          |
| `easeInOutQuint` | `CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)`          |
| `easeInExpo`     | `CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)`  |
| `easeOutExpo`    | `CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)`          |
| `easeInOutExpo`  | `CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)`                |
| `easeInCirc`     | `CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)`    |
| `easeOutCirc`    | `CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)`     |
| `easeInOutCirc`  | `CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)`  |
| `easeInBack`     | `CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)`  |
| `easeOutBack`    | `CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)` |
| `easeInOutBack`  | `CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)`  |
