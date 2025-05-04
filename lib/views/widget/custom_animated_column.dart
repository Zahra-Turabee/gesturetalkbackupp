import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedColumn extends StatelessWidget {
  const AnimatedColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize,
    this.spacing,
    this.textBaseline,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.animationDuration,
  });

  final List<Widget> children;
  final MainAxisAlignment? mainAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final double? spacing;
  final CrossAxisAlignment? crossAxisAlignment;
  final int? animationDuration;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        MoveEffect(
          duration: Duration(milliseconds: animationDuration ?? 1000),
          begin: const Offset(0, 20),
        ),
      ],
      child: Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        mainAxisSize: mainAxisSize ?? MainAxisSize.max,
        children: spacing != null ? _addSpacing(children, spacing!) : children,
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing) {
    List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i != children.length - 1) {
        spacedChildren.add(SizedBox(height: spacing));
      }
    }
    return spacedChildren;
  }
}

class AnimatedListView extends StatelessWidget {
  const AnimatedListView({
    super.key,
    required this.children,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.animationDuration,
  });

  final List<Widget> children;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final int? animationDuration;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: padding,

      scrollDirection: scrollDirection,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index]
            .animate()
            .move(
              duration: Duration(milliseconds: animationDuration ?? 1000),
              begin: const Offset(0, 20),
            )
            .fade(duration: Duration(milliseconds: animationDuration ?? 1000));
      },
    );
  }
}
