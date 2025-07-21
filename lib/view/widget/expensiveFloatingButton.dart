import 'package:flutter/material.dart';
import 'package:omzetin_bengkel/utils/colors.dart';
import 'package:omzetin_bengkel/utils/responsif/fsize.dart';

class ExpensiveFloatingButton extends StatelessWidget {
  final String? text;
  final VoidCallback onPressed;
  final double? bottom;
  final double? left;
  final double? right;
  final Widget? child;

  const ExpensiveFloatingButton({
    super.key,
    required this.onPressed,
    this.text,
    this.bottom,
    this.left,
    this.right,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom ?? 15,
      left: left ?? 0,
      right: right ?? 0,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 150.0, end: 0.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, value),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                // color: primaryColor,
                gradient: LinearGradient(
                    colors: const [primaryColor, secondaryColor],
                    begin: Alignment(0, 5),
                    end: Alignment(-0, -2)),
              ),
              child: TextButton(
                onPressed: onPressed,
                child: child ??
                    Text(
                      text ?? "SIMPAN",
                      style: TextStyle(
                          color: cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize:
                              SizeHelper.Fsize_expensiveFloatingButton(context),
                          fontFamily: 'Poppins'),
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
