import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputWidget extends StatefulWidget {
  final List<TextEditingController> controllers;
  
  final dynamic autoFocus;

  const PinInputWidget({super.key, required this.controllers,  this.autoFocus = true});

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes.first.requestFocus();
      });
    }
  }


  @override
  void dispose() {
    for (var controller in widget.controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleBackspace(int index) {
    if (index > 0 && widget.controllers[index].text.isEmpty) {
      final prevIndex = index - 1;
      widget.controllers[prevIndex].clear();
      _focusNodes[prevIndex].requestFocus();
    }
  }

  @override

  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: widget.controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          final focusNode = _focusNodes[index];

          return SizedBox(
            width: 44,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: RawKeyboardListener(
                focusNode: FocusNode(),
                onKey: (RawKeyEvent event) {
                  if (event is RawKeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    _handleBackspace(index);
                  }
                },
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (value) {
                    if (value.length == widget.controllers.length) {
                      // if user paste 6 digit
                      for (int i = 0; i < widget.controllers.length; i++) {
                        widget.controllers[i].text = value[i];
                      }
                      _focusNodes.last.requestFocus();
                      return;
                    }

                    if (value.length == 1 &&
                        index < widget.controllers.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
