import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final String? labelText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final Function(String)? onChanged;
  final Function(String)? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  const CustomTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.isPassword = false,
    this.onChanged,
    this.onSubmit,
    this.isEnabled = true,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.inputFormatters,
    this.readOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
      textInputAction: widget.inputAction,
      keyboardType: widget.inputType,
      cursorColor: Theme.of(context).primaryColor,
      maxLines: widget.maxLines,
      obscureText: widget.isPassword && _obscure,
      enabled: widget.isEnabled,
      readOnly: widget.readOnly,
      autocorrect: false,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffix,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeDefault,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).hintColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      onFieldSubmitted: (v) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus);
        }
        widget.onSubmit?.call(v);
      },
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
