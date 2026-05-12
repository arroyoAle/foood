import 'package:flutter/material.dart';

class NoAnimationPageRoute<T> extends PageRouteBuilder<T> {
  NoAnimationPageRoute({required super.pageBuilder})
    : super(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
}
