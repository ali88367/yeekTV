# Subscribe Button - Complete Logic Documentation

## Overview
The Subscribe Button is an animated widget that handles subscription state with smooth animations, color transitions, bell ringing effects, and arrow indicators. It integrates with particle animations and subscription menu functionality.

## File Location
- **Main Component**: `lib/Widgets/audio_screen/subscribe_button.dart`
- **Parent Component**: `lib/Widgets/audio_screen/channel_info_box.dart`
- **Subscription Menu**: `lib/Widgets/audio_screen/subscription_menu.dart`

---

## Button States

The button uses an internal `_ButtonState` enum to manage its visual state:

```dart
enum _ButtonState {
  initial,      // "Subscribe" text, white background, full width
  animating,    // Gold background, shrinking, showing bell icon
  finalState,   // Gold background, bell + arrow icon, collapsed width
}
```

### State Transitions
1. **initial** → **animating**: On first tap (subscribe action)
2. **animating** → **finalState**: After bell animation completes
3. **finalState** → **initial**: When `isSubscribed.value` becomes `false` (unsubscribe)

---

## Size Animation (Shrinking/Growing)

### Width Values
- **Full Width**: `150.0` (using ScreenUtil: `150.w`)
- **Collapsed Width**: `53.6` (using ScreenUtil: `53.6.w`)
  - This is approximately 20% smaller than the original collapsed width of `92.0`
  - Width reduction: `96.4.w` (64.3% reduction)

### AnimatedContainer Properties
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 320),
  curve: Curves.easeInOutCubic,
  width: width,  // Animated property
  height: 30.h,  // Fixed height
  decoration: BoxDecoration(
    color: bgColor,  // Animated property
    borderRadius: BorderRadius.circular(18.r),
    border: Border.all(...),  // Animated property
    boxShadow: [...],  // Static
  ),
)
```

### Animation Details
- **Duration**: `320 milliseconds`
- **Curve**: `Curves.easeInOutCubic`
  - **Effect**: Smooth acceleration at start, smooth deceleration at end
  - **Formula**: `cubic(t) = t < 0.5 ? 4t³ : 1 - pow(-2t + 2, 3) / 2`
- **Widget**: `AnimatedContainer`
- **Animated Properties**: `width`, `color`, `border.color`

### Width Logic
```dart
final width = (_buttonState == _ButtonState.initial)
    ? _fullWidth.w      // 150.w when initial
    : _collapsedWidth.w; // 53.6.w when animating or finalState
```

### Animation Behavior

#### On Subscribe Click
1. **Immediate Trigger**: `setState()` changes `_buttonState` to `animating`
2. **Width Animation**: `150.w → 53.6.w` over `320ms`
3. **Easing**: `Curves.easeInOutCubic` provides smooth, natural motion
4. **Visual Effect**: Button shrinks horizontally while maintaining height

#### On Unsubscribe
1. **Trigger**: `ever` listener detects `isSubscribed.value = false`
2. **State Reset**: `_buttonState` changes to `initial`
3. **Width Animation**: `53.6.w → 150.w` over `320ms`
4. **Easing**: Same `Curves.easeInOutCubic` for consistent feel
5. **Visual Effect**: Button expands horizontally back to full width

### Animation Curve Visualization
```
Curves.easeInOutCubic:
  t=0.0: 0.0 (start)
  t=0.25: 0.0625 (slow start)
  t=0.5: 0.5 (midpoint)
  t=0.75: 0.9375 (fast middle)
  t=1.0: 1.0 (end)
```

---

## Color Animation

### Color States

#### Initial State (`_ButtonState.initial`)
- **Background Color**: `Colors.white` (`#FFFFFF`)
- **Border Color**: `Colors.white.withOpacity(0.2)` (`#FFFFFF` at 20% opacity)
- **Text Color**: `Colors.black` (`#000000`)
- **Inner Border**: `Color(0xFFEFBF04)` (Gold, `3px` width)

#### Animating State (`_ButtonState.animating`)
- **Background Color**: `Color(0xFFEFBF04)` (Gold, `#EFBF04`)
- **Border Color**: `Color(0xFFEFBF04)` (Gold, `#EFBF04`)
- **Icon Color**: `Colors.black` (`#000000`)
- **Inner Border**: `Color(0xFFEFBF04)` (Gold, `3px` width)

#### Final State (`_ButtonState.finalState`)
- **Background Color**: `Color(0xFFEFBF04)` (Gold, `#EFBF04`)
- **Border Color**: `Color(0xFFEFBF04)` (Gold, `#EFBF04`)
- **Icon Color**: `Colors.black` (`#000000`)
- **Inner Border**: `Color(0xFFEFBF04)` (Gold, `3px` width)

### Color Transition Properties
- **Duration**: `320 milliseconds` (synchronized with width animation)
- **Curve**: `Curves.easeInOutCubic` (same as width)
- **Implementation**: `AnimatedContainer` handles smooth color interpolation
- **Interpolation**: Flutter automatically interpolates between `Color` values

### Color Logic
```dart
final bgColor = _buttonState == _ButtonState.initial
    ? Colors.white
    : const Color(0xFFEFBF04); // Gold for both animating + final

// Border color logic
border: Border.all(
  color: _buttonState == _ButtonState.initial
      ? Colors.white.withOpacity(0.2)
      : const Color(0xFFEFBF04),
  width: 1,
),
```

### Color Animation Behavior

#### On Subscribe Click
1. **Immediate Change**: `setState()` triggers color update
2. **Background**: `#FFFFFF → #EFBF04` over `320ms`
3. **Border**: `#FFFFFF (20% opacity) → #EFBF04` over `320ms`
4. **Synchronization**: Color and width animations run simultaneously

#### On Unsubscribe
1. **Trigger**: `ever` listener resets state
2. **Background**: `#EFBF04 → #FFFFFF` over `320ms`
3. **Border**: `#EFBF04 → #FFFFFF (20% opacity)` over `320ms`
4. **Synchronization**: Color and width animations run simultaneously

### Inner Border (Static)
- **Color**: Always `Color(0xFFEFBF04)` (Gold)
- **Width**: `3px` (fixed)
- **Purpose**: Maintains consistent design in all states
- **Implementation**: Separate `Container` with `BoxDecoration.border`

---

## Bell Ring Animation

### Animation Controller Setup (from `audio_screen.dart`)
```dart
_bellAnimationController = AnimationController(
  vsync: this,  // TickerProviderStateMixin
  duration: const Duration(milliseconds: 500),
);

_bellRotationAnimation = Tween<double>(begin: 0.0, end: 0.3).animate(
  CurvedAnimation(
    parent: _bellAnimationController,
    curve: Curves.elasticOut,
  ),
);
```

### Animation Controller Properties
- **Controller**: `bellAnimationController` (passed from parent)
- **Duration**: `500 milliseconds` (total animation time)
- **VSync**: Provided by `TickerProviderStateMixin` from parent widget
- **Initial Tween**: `0.0` to `0.3` (but overridden in button with sine wave)

### Bell Ring Motion
The bell uses a **sine wave** for natural left-right oscillation:

```dart
final progress = widget.bellAnimationController.value;  // 0.0 to 1.0
final angle = math.sin(progress * math.pi) * 0.5;
```

**Mathematical Breakdown**:
- `progress * math.pi`: Maps `[0, 1]` to `[0, π]` radians
- `math.sin(...)`: Creates smooth oscillation from `0` to `1` and back to `0`
- `* 0.5`: Scales to `[-0.5, +0.5]` radians range

**Rotation Details**:
- **Rotation Range**: `-0.5` to `+0.5` radians
- **Degrees**: Approximately **-28.65° to +28.65°**
- **Motion Type**: Sine wave oscillation for natural bell ring feel
- **Forward Animation**: `progress: 0 → 1` → `angle: 0 → 0 → 0` (sine wave peak at 0.5)
- **Reverse Animation**: `progress: 1 → 0` → `angle: 0 → 0 → 0` (sine wave peak at 0.5)

**Visual Effect**:
- At `progress = 0.0`: `angle = sin(0) * 0.5 = 0` (center)
- At `progress = 0.5`: `angle = sin(π/2) * 0.5 = 0.5` (max right swing)
- At `progress = 1.0`: `angle = sin(π) * 0.5 = 0` (back to center)

### Animation Sequence

1. **Stop & Reset**:
   ```dart
   widget.bellAnimationController.stop();
   widget.bellAnimationController.reset();  // Sets value to 0.0
   ```

2. **Show Arrow Immediately**:
   ```dart
   setState(() {
     _showArrow = true;  // Arrow appears before bell starts
   });
   ```

3. **Forward Animation**:
   ```dart
   widget.bellAnimationController.forward(from: 0).then((_) {
     // Animation completes when value reaches 1.0
   });
   ```
   - Duration: `500ms`
   - Progress: `0.0 → 1.0`
   - Bell swings: Center → Right → Center (sine wave)

4. **Pause at Peak**:
   ```dart
   Future.delayed(const Duration(milliseconds: 150), () {
     // Small pause for smoother feel
   });
   ```
   - Delay: `150ms` after forward completes
   - Bell remains at center position (angle = 0)

5. **Reverse Animation**:
   ```dart
   widget.bellAnimationController.reverse().then((_) {
     // Animation completes when value reaches 0.0
   });
   ```
   - Duration: `500ms`
   - Progress: `1.0 → 0.0`
   - Bell swings: Center → Left → Center (sine wave)

6. **State Transition**:
   ```dart
   setState(() {
     _buttonState = _ButtonState.finalState;
   });
   ```

### Total Animation Time
- Forward: `500ms`
- Pause: `150ms`
- Reverse: `500ms`
- **Total**: `1150ms` (approximately 1.15 seconds)

### Bell Icon Properties
- **Icon**: `Icons.notifications`
- **Size**: `18.sp` (responsive)
- **Color**: `Colors.black`
- **Transform**: `Transform.rotate(angle: angle)`
- **Widget**: Wrapped in `AnimatedBuilder` for real-time updates

---

## Arrow Down Animation

### Arrow Appearance
- **Icon**: `Icons.keyboard_arrow_down`
- **Size**: `18.sp`
- **Color**: `Colors.black`
- **Spacing**: `4.w` between bell and arrow

### Timing
- **Appears**: **Immediately** when bell animation starts (not after)
- **Shown With**: Bell icon (side by side)
- **State**: `_showArrow = true` set at the same time bell animation begins

### Implementation
```dart
// Show arrow immediately when bell starts ringing
setState(() {
  _showArrow = true;
});

// Then start bell animation
widget.bellAnimationController.forward(from: 0)...
```

### Display Logic
```dart
if (!_showArrow) {
  return Center(child: bell);
}

return Center(
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      bell,
      SizedBox(width: 4.w),
      Icon(Icons.keyboard_arrow_down, ...),
    ],
  ),
);
```

---

## Click/Subscribe Logic

### Subscribe Flow (`_handleButtonTap()`)

When user taps the button in **initial state**:

1. **Immediate State Change**
   - Set `_buttonState = _ButtonState.animating`
   - Set `_showArrow = false` (will be set to true immediately after)
   - Button starts shrinking and changes to gold

2. **Trigger Parent Logic**
   - Call `widget.onTap()` which triggers:
     - Particle animation (`showParticles.value = true`)
     - Particle animation controller forward
     - After particle animation completes: `isSubscribed.value = true`

3. **Bell Animation**
   - Reset bell animation controller
   - Set `_showArrow = true` immediately
   - Start bell forward animation
   - Pause 150ms at peak
   - Reverse bell animation
   - After reverse completes: Set `_buttonState = _ButtonState.finalState`

### Subscribe Action (from `channel_info_box.dart`)
```dart
onTap: () {
  if (!isSubscribed.value) {
    // Trigger particle animation
    showParticles.value = true;
    particleAnimationController.forward(from: 0).then((_) {
      particleAnimationController.reset();
      showParticles.value = false;
      Future.delayed(const Duration(milliseconds: 200), () {
        isSubscribed.value = true;
      });
    });
  } else {
    // Show subscription menu (when already subscribed)
    SubscriptionMenu.show(...);
  }
}
```

---

## Unsubscribe Logic

### Unsubscribe Flow

When user clicks the button in **subscribed state** (`finalState`):

1. **Show Menu**: Opens `SubscriptionMenu` bottom sheet
2. **Menu Options**:
   - All notifications
   - Personalized notifications
   - None (no notifications)
   - **Unsubscribe** (destructive action)

3. **Unsubscribe Action**:
   ```dart
   isSubscribed.value = false;
   subscriptionPreference.value = 'All';
   Navigator.pop(context);
   ```

4. **Button Reset**:
   - `ever` listener detects `isSubscribed.value = false`
   - Resets button to `_ButtonState.initial`
   - Sets `_showArrow = false`
   - Button smoothly grows back to full width
   - Background changes back to white
   - "Subscribe" text reappears

### Reset Implementation
```dart
_subWorker = ever<bool>(widget.isSubscribed, (subscribed) {
  if (!mounted) return;
  
  if (!subscribed) {
    setState(() {
      _buttonState = _ButtonState.initial;
      _showArrow = false;
    });
  }
});
```

---

## Content Animation (Text ↔ Icons)

### AnimatedSwitcher Configuration
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 220),
  switchInCurve: Curves.easeOut,
  switchOutCurve: Curves.easeIn,
  transitionBuilder: (child, anim) {
    return FadeTransition(
      opacity: anim,
      child: SizeTransition(
        sizeFactor: anim,
        axis: Axis.horizontal,
        axisAlignment: -1.0,
        child: child,
      ),
    );
  },
  child: /* Text or Icons based on state */,
)
```

### Animation Properties
- **Duration**: `220 milliseconds`
- **Switch In Curve**: `Curves.easeOut`
  - **Effect**: Fast start, slow end (content appears quickly, then slows)
  - **Formula**: `1 - pow(1 - t, 3)`
- **Switch Out Curve**: `Curves.easeIn`
  - **Effect**: Slow start, fast end (content disappears slowly, then quickly)
  - **Formula**: `t³`
- **Transition Type**: Combined `FadeTransition` + `SizeTransition`

### Transition Breakdown

#### FadeTransition
- **Property**: `opacity`
- **Range**: `0.0` (transparent) to `1.0` (opaque)
- **Effect**: Content fades in/out smoothly

#### SizeTransition
- **Property**: `sizeFactor`
- **Range**: `0.0` (collapsed) to `1.0` (full size)
- **Axis**: `Axis.horizontal`
- **Alignment**: `-1.0` (left-aligned)
- **Effect**: Content expands/collapses horizontally from left

### Combined Effect
- **Text Disappearing**: Fades out (opacity: 1.0 → 0.0) while shrinking horizontally (size: 1.0 → 0.0)
- **Icons Appearing**: Fades in (opacity: 0.0 → 1.0) while expanding horizontally (size: 0.0 → 1.0)
- **Visual Result**: Smooth cross-fade with horizontal scaling

### Content States

#### Initial State
- **Content**: "Subscribe" text
- **Key**: `ValueKey('subscribe_text')`
- **Style**: 
  - Color: `Colors.black`
  - Font Size: `14.sp`
  - Font Weight: `FontWeight.w800`
  - Alignment: `Center`
- **Widget**: `Text` widget wrapped in `Center`

#### Animating/Final State
- **Content**: Bell icon (with optional arrow)
- **Key**: `ValueKey('bell_${_showArrow}')`
  - Changes when arrow appears/disappears to trigger re-animation
- **Animation**: `AnimatedBuilder` wrapping bell rotation
- **Widget**: `Transform.rotate` with `Icon` or `Row` of icons

### Animation Sequence

#### Subscribe (Text → Icons)
1. **Trigger**: `_buttonState` changes from `initial` to `animating`
2. **AnimatedSwitcher**: Detects key change (`'subscribe_text'` → `'bell_false'`)
3. **Outgoing (Text)**:
   - Opacity: `1.0 → 0.0` over `220ms` (easeIn)
   - Size: `1.0 → 0.0` horizontally over `220ms` (easeIn)
4. **Incoming (Bell)**:
   - Opacity: `0.0 → 1.0` over `220ms` (easeOut)
   - Size: `0.0 → 1.0` horizontally over `220ms` (easeOut)
5. **Result**: Text fades/shrinks out while bell fades/expands in

#### Arrow Appearance (Bell → Bell + Arrow)
1. **Trigger**: `_showArrow` changes from `false` to `true`
2. **AnimatedSwitcher**: Detects key change (`'bell_false'` → `'bell_true'`)
3. **Outgoing (Bell only)**:
   - Opacity: `1.0 → 0.0` over `220ms` (easeIn)
   - Size: `1.0 → 0.0` horizontally over `220ms` (easeIn)
4. **Incoming (Bell + Arrow)**:
   - Opacity: `0.0 → 1.0` over `220ms` (easeOut)
   - Size: `0.0 → 1.0` horizontally over `220ms` (easeOut)
5. **Result**: Bell-only fades/shrinks while bell+arrow fades/expands

#### Unsubscribe (Icons → Text)
1. **Trigger**: `_buttonState` changes from `finalState` to `initial`
2. **AnimatedSwitcher**: Detects key change (`'bell_true'` → `'subscribe_text'`)
3. **Outgoing (Icons)**:
   - Opacity: `1.0 → 0.0` over `220ms` (easeIn)
   - Size: `1.0 → 0.0` horizontally over `220ms` (easeIn)
4. **Incoming (Text)**:
   - Opacity: `0.0 → 1.0` over `220ms` (easeOut)
   - Size: `0.0 → 1.0` horizontally over `220ms` (easeOut)
5. **Result**: Icons fade/shrink out while text fades/expands in

---

## Particle Animation Integration

### Particle Animation Controller Setup (from `audio_screen.dart`)
```dart
_particleAnimationController = AnimationController(
  vsync: this,  // TickerProviderStateMixin
  duration: const Duration(milliseconds: 800),
);
```

### Animation Controller Properties
- **Controller**: `particleAnimationController` (passed from parent)
- **Duration**: `800 milliseconds` (total particle animation time)
- **VSync**: Provided by `TickerProviderStateMixin` from parent widget
- **Usage**: Single forward animation, then reset

### Particle Overlay Implementation
```dart
Widget _buildParticleAnimation() {
  return AnimatedBuilder(
    animation: widget.particleAnimationController,
    builder: (context, child) {
      return CustomPaint(
        painter: ParticlePainter(
          progress: widget.particleAnimationController.value,  // 0.0 to 1.0
          buttonWidth: 150.w,
          buttonHeight: 30.h,
        ),
        child: const SizedBox.expand(),
      );
    },
  );
}
```

### Particle Properties
- **Widget**: `CustomPaint` with `ParticlePainter`
- **Painter**: `ParticlePainter` from `custom_painters.dart`
- **Progress**: `0.0` (start) to `1.0` (end)
- **Button Dimensions**: `150.w × 30.h` (full button size)
- **Position**: Overlay on top of button (in `Stack`)
- **Visibility**: Controlled by `showParticles.value` (RxBool)

### Particle Animation Flow

#### Trigger (from `channel_info_box.dart`)
```dart
onTap: () {
  if (!isSubscribed.value) {
    // Trigger particle animation
    showParticles.value = true;
    particleAnimationController.forward(from: 0).then((_) {
      particleAnimationController.reset();
      showParticles.value = false;
      Future.delayed(const Duration(milliseconds: 200), () {
        isSubscribed.value = true;
      });
    });
  }
}
```

#### Animation Sequence
1. **Show Particles**: `showParticles.value = true`
   - `Obx` listener triggers rebuild
   - `_buildParticleAnimation()` is added to widget tree
   - `CustomPaint` with `ParticlePainter` appears

2. **Start Animation**: `particleAnimationController.forward(from: 0)`
   - Duration: `800ms`
   - Progress: `0.0 → 1.0`
   - `AnimatedBuilder` rebuilds on each frame
   - `ParticlePainter` receives updated `progress` value
   - Particles animate based on progress

3. **Animation Complete**: `.then((_) { ... })`
   - Controller value reaches `1.0`
   - Particles have completed their animation

4. **Reset & Hide**:
   ```dart
   particleAnimationController.reset();  // Sets value to 0.0
   showParticles.value = false;  // Hides particle overlay
   ```

5. **Delay & Subscribe**:
   ```dart
   Future.delayed(const Duration(milliseconds: 200), () {
     isSubscribed.value = true;
   });
   ```
   - `200ms` delay after particles complete
   - Sets `isSubscribed.value = true`

### Particle Visibility Logic
```dart
Obx(
  () => widget.showParticles.value
      ? _buildParticleAnimation()
      : const SizedBox(),
)
```

- **Reactive**: Uses `Obx` to listen to `showParticles.value`
- **When `true`**: Renders `_buildParticleAnimation()` (particles visible)
- **When `false`**: Renders `SizedBox()` (particles hidden)
- **Performance**: Particles only rendered when visible

### Particle Timing in Subscribe Flow
```
Time 0ms:     showParticles.value = true
              Particle overlay appears
              ↓
Time 0ms:     particleAnimationController.forward()
              Progress: 0.0 → 1.0 over 800ms
              ↓
Time 800ms:   Animation completes
              particleAnimationController.reset()
              showParticles.value = false
              Particle overlay disappears
              ↓
Time 1000ms:  isSubscribed.value = true (200ms delay)
```

### Synchronization with Button Animations
- **Particles Start**: Same time as button shrink/color change (`0ms`)
- **Particles End**: `800ms` (before bell animation completes at `1150ms`)
- **Subscribe State**: Set at `1000ms` (after particles, before bell completes)
- **Visual Effect**: Particles burst while button shrinks and changes color

---

## Component Dependencies

### Required Props
- `isSubscribed`: `RxBool` - Subscription state (reactive)
- `showParticles`: `RxBool` - Particle animation trigger
- `particleAnimationController`: `AnimationController` - Particle animation
- `bellAnimationController`: `AnimationController` - Bell ring animation
- `bellRotationAnimation`: `Animation<double>` - Bell rotation tween
- `onTap`: `VoidCallback` - Parent tap handler

### External Dependencies
- `flutter_screenutil` - Responsive sizing (`150.w`, `30.h`, etc.)
- `get` - Reactive state management (`RxBool`, `Obx`, `ever`)
- `custom_painters.dart` - `ParticlePainter` for particle effects

---

## Complete Animation Synchronization

### All Animations Running Simultaneously

When the subscribe button is tapped, **multiple animations run in parallel**:

1. **AnimatedContainer** (Width + Color): `320ms`
2. **AnimatedSwitcher** (Text → Icons): `220ms`
3. **Particle Animation**: `800ms`
4. **Bell Animation**: `1150ms` (forward + pause + reverse)
5. **Arrow Appearance**: Immediate (no animation, just state change)

### Animation Overlap Chart

```
Time (ms)    0     100    200    300    400    500    600    700    800    900    1000   1100   1200
            |      |      |      |      |      |      |      |      |      |      |      |      |
Width/Color  ████████████████████████████
             (320ms - AnimatedContainer)
            
Text→Icons   ████████████████
             (220ms - AnimatedSwitcher)

Particles    ████████████████████████████████████████████████████████████████████████████████████
             (800ms - ParticlePainter)

Bell Forward ████████████████████████████████████████████████████████████████████████████████████
             (500ms - forward animation)

Bell Pause   ████████████████
             (150ms delay)

Bell Reverse ████████████████████████████████████████████████████████████████████████████████████
             (500ms - reverse animation)

Arrow        ████████████████████████████████████████████████████████████████████████████████████
             (appears immediately, stays visible)
```

---

## Animation Timeline

### Subscribe Animation Sequence (Detailed)

```
Time 0ms:     ┌─ User taps button
              │
              ├─ setState() called
              │  • _buttonState = _ButtonState.animating
              │  • _showArrow = false (will be set true immediately)
              │
              ├─ AnimatedContainer starts
              │  • Width: 150.w → 53.6.w (320ms, easeInOutCubic)
              │  • Color: white → gold (320ms, easeInOutCubic)
              │  • Border: white(20%) → gold (320ms, easeInOutCubic)
              │
              ├─ AnimatedSwitcher starts
              │  • Text fades out (220ms, easeIn)
              │  • Bell fades in (220ms, easeOut)
              │
              ├─ widget.onTap() called
              │  • showParticles.value = true
              │  • particleAnimationController.forward()
              │
              ├─ Particle animation starts
              │  • Progress: 0.0 → 1.0 (800ms)
              │  • ParticlePainter animates
              │
              ├─ Bell animation setup
              │  • bellAnimationController.stop()
              │  • bellAnimationController.reset()
              │
              └─ setState() called again
                 • _showArrow = true
                 • AnimatedSwitcher triggers (bell → bell+arrow)

Time 0ms:     ┌─ Bell animation forward starts
              │  • bellAnimationController.forward(from: 0)
              │  • Progress: 0.0 → 1.0 (500ms)
              │  • Bell angle: sin(progress * π) * 0.5
              │  • AnimatedBuilder rebuilds on each frame
              │
              └─ Arrow visible
                 • Row with bell + arrow displayed

Time 220ms:   └─ AnimatedSwitcher completes
                 • Text fully faded out
                 • Bell fully faded in

Time 320ms:   └─ AnimatedContainer completes
                 • Width at 53.6.w
                 • Color fully gold
                 • Border fully gold

Time 500ms:   ┌─ Bell forward animation completes
              │  • Progress = 1.0
              │  • Bell at center (angle = 0)
              │
              └─ Pause starts
                 • Future.delayed(150ms)

Time 650ms:   └─ Pause ends
                 • Bell reverse animation starts
                 • bellAnimationController.reverse()
                 • Progress: 1.0 → 0.0 (500ms)

Time 800ms:   └─ Particle animation completes
                 • Progress = 1.0
                 • particleAnimationController.reset()
                 • showParticles.value = false
                 • Particles disappear

Time 1000ms:  └─ isSubscribed.value = true
                 • Set after 200ms delay from particle completion
                 • Subscription state updated

Time 1150ms:  ┌─ Bell reverse animation completes
              │  • Progress = 0.0
              │  • Bell at center (angle = 0)
              │
              └─ setState() called
                 • _buttonState = _ButtonState.finalState
                 • Button now in final subscribed state
```

### Unsubscribe Animation Sequence (Detailed)

```
Time 0ms:     ┌─ User taps subscribed button
              │
              └─ widget.onTap() called
                 • SubscriptionMenu.show() opens bottom sheet

Time Xms:     ┌─ User selects "Unsubscribe" from menu
              │
              ├─ Menu action executed
              │  • isSubscribed.value = false
              │  • subscriptionPreference.value = 'All'
              │  • Navigator.pop(context)
              │
              └─ ever listener triggers
                 • Detects isSubscribed.value = false
                 • setState() called
                    - _buttonState = _ButtonState.initial
                    - _showArrow = false

Time Xms:     ┌─ AnimatedContainer starts
              │  • Width: 53.6.w → 150.w (320ms, easeInOutCubic)
              │  • Color: gold → white (320ms, easeInOutCubic)
              │  • Border: gold → white(20%) (320ms, easeInOutCubic)
              │
              ├─ AnimatedSwitcher starts
              │  • Bell+Arrow fades out (220ms, easeIn)
              │  • Text fades in (220ms, easeOut)
              │
              └─ Bell animation (if any)
                 • Stops/resets if still running

Time X+220ms: └─ AnimatedSwitcher completes
                 • Icons fully faded out
                 • Text fully faded in and visible

Time X+320ms: └─ AnimatedContainer completes
                 • Width at 150.w
                 • Color fully white
                 • Border fully white(20%)
                 • Button back to initial state
```

---

## Animation Curves and Their Effects

### Curves.easeInOutCubic (Width & Color)
- **Usage**: `AnimatedContainer` for width and color transitions
- **Duration**: `320ms`
- **Formula**: `t < 0.5 ? 4t³ : 1 - pow(-2t + 2, 3) / 2`
- **Visual Effect**: 
  - Slow start (0-25% of duration)
  - Fast middle (25-75% of duration)
  - Slow end (75-100% of duration)
- **Why**: Creates natural, smooth motion that feels organic

### Curves.easeOut (AnimatedSwitcher - Incoming)
- **Usage**: Content appearing (text or icons)
- **Duration**: `220ms`
- **Formula**: `1 - pow(1 - t, 3)`
- **Visual Effect**: 
  - Fast start (content appears quickly)
  - Slow end (settles smoothly)
- **Why**: Makes new content feel responsive and immediate

### Curves.easeIn (AnimatedSwitcher - Outgoing)
- **Usage**: Content disappearing (text or icons)
- **Duration**: `220ms`
- **Formula**: `t³`
- **Visual Effect**: 
  - Slow start (content fades slowly)
  - Fast end (disappears quickly)
- **Why**: Creates smooth exit without lingering

### Curves.elasticOut (Bell Rotation - Initial Setup)
- **Usage**: Initial bell rotation animation setup (from parent)
- **Note**: Overridden in button with sine wave calculation
- **Formula**: Elastic bounce effect
- **Why**: Not used in final implementation (sine wave used instead)

### Sine Wave (Bell Rotation - Actual)
- **Usage**: Bell left-right oscillation
- **Formula**: `sin(progress * π) * 0.5`
- **Visual Effect**: 
  - Smooth oscillation from center to sides
  - Natural bell ring motion
- **Why**: Creates realistic bell swing motion

---

## AnimatedBuilder for Bell Rotation

### Implementation
```dart
AnimatedBuilder(
  key: ValueKey('bell_${_showArrow}'),
  animation: widget.bellAnimationController,
  builder: (context, _) {
    final progress = widget.bellAnimationController.value;
    final angle = math.sin(progress * math.pi) * 0.5;
    
    final bell = Transform.rotate(
      angle: angle,
      child: Icon(Icons.notifications, ...),
    );
    
    // Return bell or bell+arrow based on _showArrow
  },
)
```

### AnimatedBuilder Properties
- **Animation**: `widget.bellAnimationController`
- **Rebuild Frequency**: Every frame while animation is running (~60fps)
- **Purpose**: Rebuilds bell icon with updated rotation angle
- **Key**: `ValueKey('bell_${_showArrow}')` - Changes when arrow appears to trigger AnimatedSwitcher

### Performance
- **Optimization**: Only rebuilds bell icon, not entire button
- **Frame Rate**: Smooth 60fps during animation
- **Memory**: Minimal overhead (single icon rotation)

---

## Key Design Decisions

1. **Single Widget Animation**: Uses `AnimatedContainer` instead of swapping widgets for smooth transitions
   - **Benefit**: Single widget maintains state, smoother transitions
   - **Alternative**: Could use `AnimatedSwitcher` for entire button (rejected for performance)

2. **State Machine**: Internal `_ButtonState` enum manages flow independently of `isSubscribed`
   - **Benefit**: Animation state separate from subscription state
   - **Benefit**: Allows smooth transitions even if subscription state changes rapidly

3. **Immediate Arrow**: Arrow appears with bell, not after, for better UX
   - **Benefit**: User sees complete final state immediately
   - **Benefit**: No waiting for bell to finish before seeing arrow

4. **Sine Wave Bell**: Natural oscillation using `sin(progress * π) * 0.5`
   - **Benefit**: Realistic bell swing motion
   - **Benefit**: Smooth, continuous motion without jumps

5. **Gold Color**: Consistent gold (`#EFBF04`) throughout animating and final states
   - **Benefit**: Visual consistency
   - **Benefit**: Clear indication of subscribed state

6. **Reactive Reset**: `ever` listener automatically resets button on unsubscribe
   - **Benefit**: No manual state management needed
   - **Benefit**: Always in sync with subscription state

7. **Particle Integration**: Particles overlay button during subscribe flow
   - **Benefit**: Enhanced visual feedback
   - **Benefit**: Celebratory feel on subscribe

8. **Smooth Transitions**: All animations use easing curves for natural feel
   - **Benefit**: Professional, polished appearance
   - **Benefit**: Better user experience

9. **AnimatedBuilder for Bell**: Only rebuilds bell icon, not entire button
   - **Benefit**: Better performance
   - **Benefit**: Smooth 60fps animation

10. **Separate Animation Durations**: Different durations for different effects
    - **Benefit**: Each animation feels natural for its purpose
    - **Benefit**: Creates layered, complex animation feel

---

## Error Handling

### Animation Failures
```dart
try {
  // Bell animation sequence
} catch (_) {
  // If animation fails, show final state anyway
  if (mounted) {
    setState(() {
      _showArrow = true;
      _buttonState = _ButtonState.finalState;
    });
  }
}
```

### Mounted Checks
All async callbacks check `if (!mounted) return;` to prevent `setState()` on disposed widgets.

---

## Testing Considerations

1. **Subscribe Flow**: Verify all animations trigger in correct sequence
2. **Unsubscribe Flow**: Verify button resets correctly
3. **State Persistence**: Verify button state matches `isSubscribed.value`
4. **Animation Interruption**: Test behavior when user taps rapidly
5. **Widget Disposal**: Verify no `setState()` errors after disposal
6. **Responsive Sizing**: Test on different screen sizes with ScreenUtil

---

## Future Enhancements

Potential improvements:
- Haptic feedback on tap
- Sound effect for bell ring
- Customizable colors via theme
- Animation speed customization
- Accessibility labels for screen readers
