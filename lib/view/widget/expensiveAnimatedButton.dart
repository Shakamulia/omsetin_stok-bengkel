import 'package:flutter/material.dart';
import 'package:omsetin_bengkel/utils/colors.dart';

class ExpensiveAnimatedButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;

  const ExpensiveAnimatedButton({
    super.key,
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 100.0, end: 0.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value),
          child: child,
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: primaryColor

                    // gradient: LinearGradient(
                    //   begin: Alignment.topLeft,
                    //   end: Alignment(0.8, 1),
                    //   colors: const <Color>[
                    //     greenColor,
                    //     primaryColor
                    //   ], // Gradient from https://learnui.design/tools/gradient-generator.html
                    //   tileMode: TileMode.mirror,
                    // ),
                    ),
                child: TextButton(
                  onPressed: onPressed,
                  child: Text(
                    text ?? "Default",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
