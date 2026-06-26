import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class AppShimmer extends StatelessWidget {
  const AppShimmer({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return Shimmer(
      colorOpacity: 0.3,
      color: Theme.of(context).colorScheme.onSurface,
      child: child,
    );
  }
}

/// Convenience shimmer box — use for skeleton placeholders.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) => AppShimmer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );
}
