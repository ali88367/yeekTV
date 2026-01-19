import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_painters.dart';

class AnimatedSignLogo extends StatelessWidget {
  final List<Animation<double>> ringAnimations;

  const AnimatedSignLogo({
    Key? key,
    required this.ringAnimations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;
    final offset = isMobile ? -5.h : -4.h;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Expanding Rings Container
        SizedBox(
          width: 45.w,
          height: 45.h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: List.generate(3, (index) {
              return AnimatedBuilder(
                animation: ringAnimations[index],
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(55.w, 55.h),
                    painter: ExpandingRingPainter(
                      progress: ringAnimations[index].value,
                      offset: offset,
                    ),
                  );
                },
              );
            }),
          ),
        ),

        // Sign Image (on top)
        Image.asset('assets/sign.png', height: 30.h, fit: BoxFit.contain),
      ],
    );
  }
}
