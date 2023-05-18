
import 'package:flutter/services.dart';
import 'package:musikat_app/utils/exports.dart';


class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.controller,
    required this.validator,
    required this.hintText,
    this.prefixIcon,
    required this.obscureText,
    this.errorMaxLines,
    this.suffixIcon,
    this.inputFormatters,
    this.keyboardType,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hintText;
  final Widget? prefixIcon;
  final bool obscureText;
  final int? errorMaxLines;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: TextFormField(
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontFamily: 'Inter'
        ),
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          errorMaxLines: errorMaxLines,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
