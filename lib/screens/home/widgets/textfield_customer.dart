import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  CustomTextField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: Listener(
        onPointerDown: (_) {
          FocusScope.of(context).requestFocus(focusNode);
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          readOnly: true,
          showCursor: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(border: InputBorder.none),
          enableInteractiveSelection: false,
          keyboardAppearance: Brightness.dark,
        ),
      ),
    );
  }
}
