import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'custom_painters.dart';

class SubscribeButton extends StatefulWidget {
  final RxBool isSubscribed;
  final RxBool showParticles;
  final AnimationController particleAnimationController;
  final AnimationController bellAnimationController;
  final Animation<double> bellRotationAnimation;
  final VoidCallback onTap;

  const SubscribeButton({
    Key? key,
    required this.isSubscribed,
    required this.showParticles,
    required this.particleAnimationController,
    required this.bellAnimationController,
    required this.bellRotationAnimation,
    required this.onTap,
  }) : super(key: key);

  @override
  State<SubscribeButton> createState() => _SubscribeButtonState();
}

enum _ButtonState {
  initial, // "Subscribe" text, white background
  animating, // Hot pink, shrinking, showing bell
  finalState, // Gold, bell + arrow
}

class _SubscribeButtonState extends State<SubscribeButton> {
  static const _fullWidth = 150.0; // base dp before ScreenUtil
  static const _collapsedWidth =
      53.6; // 20% smaller than 92.0 (92 * 0.8 = 73.6)

  _ButtonState _buttonState = _ButtonState.initial;
  bool _showArrow = false;
  late final Worker _subWorker;

  Widget _buildParticleAnimation() {
    return AnimatedBuilder(
      animation: widget.particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            progress: widget.particleAnimationController.value,
            buttonWidth: 150.w,
            buttonHeight: 30.h,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Listen to subscription changes to reset button when unsubscribed
    _subWorker = ever<bool>(widget.isSubscribed, (subscribed) {
      if (!mounted) return;

      if (!subscribed) {
        // Reset to initial state when unsubscribed
        setState(() {
          _buttonState = _ButtonState.initial;
          _showArrow = false;
        });
      }
    });
  }

  void _handleButtonTap() {
    // Only start animation if in initial state
    if (_buttonState != _ButtonState.initial) {
      widget.onTap();
      return;
    }

    // Immediately change to hot pink and start shrinking
    setState(() {
      _buttonState = _ButtonState.animating;
      _showArrow = false;
    });

    // Trigger particle animation and subscription logic
    widget.onTap();

    // Ring bell once smoothly, show arrow immediately with bell ring
    try {
      widget.bellAnimationController.stop();
      widget.bellAnimationController.reset();

      // Show arrow immediately when bell starts ringing
      setState(() {
        _showArrow = true;
      });

      // Smooth bell animation: forward, pause, then reverse
      widget.bellAnimationController.forward(from: 0).then((_) {
        if (!mounted) return;
        // Small pause at peak for smoother feel
        Future.delayed(const Duration(milliseconds: 150), () {
          if (!mounted) return;
          // Reverse smoothly
          widget.bellAnimationController.reverse().then((_) {
            // Change to gold after bell finishes
            if (!mounted) return;
            setState(() {
              _buttonState = _ButtonState.finalState;
            });
          });
        });
      });
    } catch (_) {
      // If animation fails, show final state anyway
      if (mounted) {
        setState(() {
          _showArrow = true;
          _buttonState = _ButtonState.finalState;
        });
      }
    }
  }

  @override
  void dispose() {
    _subWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine button state based on local animation state
    final width = (_buttonState == _ButtonState.initial)
        ? _fullWidth.w
        : _collapsedWidth.w;

    // Background color: white → gold (on click) → gold (after bell)
    final bgColor = _buttonState == _ButtonState.initial
        ? Colors.white
        : const Color(0xFFEFBF04); // Your gold for both animating + final

    return GestureDetector(
      onTap: _handleButtonTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeInOutCubic,
          width: width,
          height: 30.h,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: _buttonState == _ButtonState.initial
                  ? Colors.white.withOpacity(0.2)
                  : const Color(0xFFEFBF04),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Inner border (keeps design consistent in both states)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEFBF04), width: 3),
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Center(
                  child: AnimatedSwitcher(
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
                    child: _buttonState == _ButtonState.initial
                        ? Center(
                            child: Text(
                              "Subscribe",
                              key: const ValueKey('subscribe_text'),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : AnimatedBuilder(
                            key: ValueKey('bell_${_showArrow}'),
                            animation: widget.bellAnimationController,
                            builder: (context, _) {
                              // Create natural left-right ring effect using sine wave
                              // Rotate from -0.5 to +0.5 radians (about -29° to +29°) for visible ring
                              final progress =
                                  widget.bellAnimationController.value;
                              // Use sine wave for natural bell ring motion (left-right oscillation)
                              // Forward: 0 to π (left to right), Reverse: π to 0 (right to left)
                              final angle = math.sin(progress * math.pi) * 0.5;

                              final bell = Transform.rotate(
                                angle: angle,
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                  size: 18.sp,
                                ),
                              );

                              if (!_showArrow) {
                                return Center(child: bell);
                              }

                              return Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    bell,
                                    SizedBox(width: 4.w),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                      size: 18.sp,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),

              // Particle animation overlay (only during subscribe tap flow)
              Obx(
                () => widget.showParticles.value
                    ? _buildParticleAnimation()
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
