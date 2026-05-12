import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Track thumbnail transition animation:
/// 0-35%: fade in + scale 0.5->0.6 (easeOut), starting from bottom-center
/// 35-65%: rotate -360deg (linear), keep scale 0.6, opacity 0.8
/// 65-100%: scale 0.6->1 + opacity 0.8->1 (easeIn)
/// Old image fades to 0.7 during transition.
class AnimatedTrackThumbnail extends StatefulWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final Color backgroundColor;

  const AnimatedTrackThumbnail({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.backgroundColor = Colors.black,
  });

  @override
  State<AnimatedTrackThumbnail> createState() => _AnimatedTrackThumbnailState();
}

class _AnimatedTrackThumbnailState extends State<AnimatedTrackThumbnail>
    with TickerProviderStateMixin {
  String? _displayedImageUrl;
  String? _nextImageUrl;
  bool _isAnimating = false;

  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _rotationDeg;

  @override
  void initState() {
    super.initState();

    // Start with no displayed image so even the first thumbnail
    // uses the same animated transition from bottom-center.
    _displayedImageUrl = null;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 0.8,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(0.8), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.8,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_controller);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.5,
          end: 0.6,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(0.6), weight: 30),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
    ]).animate(_controller);

    _rotationDeg = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 35),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -360.0,
        ).chain(CurveTween(curve: Curves.linear)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(-360.0), weight: 35),
    ]).animate(_controller);

    // Trigger initial animation if we already have an image URL on first build
    if (widget.imageUrl != null) {
      // Use a microtask so that context is fully ready for precacheImage
      scheduleMicrotask(() => _handleImageChange(widget.imageUrl!));
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedTrackThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl && widget.imageUrl != null) {
      _handleImageChange(widget.imageUrl!);
    }
  }

  Future<void> _handleImageChange(String newUrl) async {
    // If this URL is already the active one and no animation is running, skip.
    if (newUrl == _displayedImageUrl && !_isAnimating) return;
    // If an animation is already running for this same "next" URL, skip.
    if (_isAnimating && newUrl == _nextImageUrl) return;

    // Preload
    try {
      await precacheImage(CachedNetworkImageProvider(newUrl), context);
    } catch (_) {
      // If preload fails, still switch without animation.
      if (!mounted) return;
      setState(() {
        _displayedImageUrl = newUrl;
        _nextImageUrl = null;
        _isAnimating = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _nextImageUrl = newUrl;
      _isAnimating = true;
    });

    _controller.forward(from: 0.0);

    // After 1s animation, commit image.
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _displayedImageUrl = newUrl;
      _nextImageUrl = null;
      _isAnimating = false;
    });
    _controller.reset();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      placeholder: (context, _) => Center(
        child: Text(
          'Loading radio channel',
          style: TextStyle(
            fontFamily: 'YeekBold',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ),
      errorWidget: (context, _, __) => Container(
        color: const Color(0xFF1a1a1a),
        alignment: Alignment.center,
        child: Icon(
          Icons.music_note,
          color: const Color(0xFFEFBF04),
          size: 48.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Prefer real layout size (important when width/height are infinite)
        final w = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.width;
        final h = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.height;
        final safeH = h.isFinite && h > 0 ? h : 0.0;

        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_displayedImageUrl != null)
                AnimatedOpacity(
                  opacity: _isAnimating ? 0.7 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: w,
                    height: h,
                    child: _buildImage(_displayedImageUrl!),
                  ),
                ),

              if (_nextImageUrl != null && _isAnimating)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final radians =
                        _rotationDeg.value * 3.141592653589793 / 180.0;
                    // Keep animation inside container:
                    // when scale < 1, push the image DOWN by (1-scale)*h/2 so it starts at bottom-center.
                    final scale = _scale.value;
                    final dy = (1.0 - scale) * safeH / 2.0;

                    return Opacity(
                      opacity: _opacity.value,
                      child: Transform.translate(
                        offset: Offset(0, dy),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..scale(scale)
                            ..rotateZ(radians),
                          child: SizedBox(
                            width: w,
                            height: h,
                            child: _buildImage(_nextImageUrl!),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
