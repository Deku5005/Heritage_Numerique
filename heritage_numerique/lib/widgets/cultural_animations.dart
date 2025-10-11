import 'package:flutter/material.dart';

/// Widget contenant des animations culturelles inspirées du patrimoine malien
/// Animations simplifiées avec des effets de fondu et des transitions douces
class CulturalAnimations {
  // Couleurs inspirées du patrimoine malien
  static const Color _accentColor = Color(0xFFA56C00);
  static const Color _secondaryColor = Color(0xFF9F9646);
  static const Color _earthColor = Color(0xFF8B4513);
  static const Color _sunsetColor = Color(0xFFFF6B35);

  /// Animation de fondu en cascade simple
  static Widget fadeInCascade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: duration.inMilliseconds + delay),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu simple avec légère montée
  static Widget gentleFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de pulsation douce
  static Widget softPulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1.05),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de glissement horizontal doux
  static Widget slideIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    bool fromLeft = true,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fromLeft ? -1.0 : 1.0, end: 0.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * 50, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec zoom subtil
  static Widget fadeInZoom({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de respiration douce
  static Widget gentleBreath({
    required Widget child,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.98, end: 1.02),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec montée verticale
  static Widget fadeInUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 700),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec glissement diagonal
  static Widget fadeInDiagonal({
    required Widget child,
    Duration duration = const Duration(milliseconds: 900),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(20 * (1 - value), 15 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec rotation très subtile
  static Widget fadeInRotate({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.rotate(
            angle: (1 - value) * 0.1, // Rotation très subtile
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de vague
  static Widget waveFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 5 * (1 - value) * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de profondeur
  static Widget depthFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de flottement
  static Widget floatFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 3 * (1 - value) * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de glissement vertical
  static Widget slideUpFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 25 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de zoom doux
  static Widget zoomFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.85 + (0.15 * value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de glissement horizontal
  static Widget slideFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    bool fromLeft = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: fromLeft ? -1.0 : 1.0, end: 0.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1.0 - (value.abs() * 0.3),
          child: Transform.translate(
            offset: Offset(value * 40, 0),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animation de fondu avec effet de montée douce
  static Widget gentleRise({
    required Widget child,
    Duration duration = const Duration(milliseconds: 900),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value) * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}