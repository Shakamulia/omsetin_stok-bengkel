import 'package:flutter/material.dart';
import 'package:omsetin_stok/utils/colors.dart';

class SearchTextField extends StatelessWidget {
  //:: USAGE?
  // null can be used if the variable type has (?)

  // IF WANT USE prefixIcon || hintText
  //  CustomTextField(
  //   obscureText: false,
  //   height: 50.0,
  //   hintText: 'Email',
  //   prefixIcon: Icon(Icons.email_outlined),
  //  )

  // IF DON'T WANT TO USE prefixIcon || hintText
  //  CustomTextField(
  //   obscureText: false,
  //   height: 50.0,
  //   hintText: null,
  //   prefixIcon: null,
  //  )

  // prefixIcon for the TextField
  // Icon? means that the value can be an Icon or null

  //? note: If the TextField wants to use an Icon then just use the Widget Icon as usual in the prefixIcon argument, then if you don't want to use the prefixIcon then type null in the prefixIcon argument

  final Icon? prefixIcon;
  final Icon? suffixIcon;

  // hintText (placeholder) for the TextField
  final String? hintText;

  // boolean to determine whether the input text is obscured or not
  final bool obscureText;

  // maxLines for the TextField
  final int? maxLines;

  // custom color
  final Color color;

  final TextEditingController? controller;

  const SearchTextField({
    super.key,
    required this.obscureText,
    required this.hintText,
    required this.prefixIcon,
    required this.controller,
    required this.maxLines,
    required this.suffixIcon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      controller: controller,
      // Decoration for the TextField
      decoration: InputDecoration(
        // filled must be true to fill the TextField with fillColor
        filled: true,
        fillColor: color,

        // Add a hint text (placeholder)
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 17),

        // Add a prefix icon (icon on the left side of the TextField)
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
      // secure the text input
      obscureText: obscureText,
      // set the height of the TextField
      maxLines: maxLines,
    );
  }
}
