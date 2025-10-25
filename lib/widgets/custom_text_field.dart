import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final String? initialValue;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.initialValue,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: isDark ? Colors.white70 : const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            initialValue: widget.initialValue,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                color: isDark ? Colors.white38 : const Color(0xFF9CA3AF),
                fontSize: 16,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: isDark ? Colors.white54 : const Color(0xFF6B7280),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : widget.suffixIcon,
              filled: true,
              fillColor: isDark 
                  ? const Color(0xFF2D2D2D)
                  : const Color(0xFFF9FAFB),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }
}

// Specialized email field
class EmailField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? initialValue;

  const EmailField({
    super.key,
    this.controller,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: 'Email Address',
      hint: 'Enter your email address',
      controller: controller,
      initialValue: initialValue,
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }
}

// Specialized password field
class PasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? hint;
  final String? initialValue;

  const PasswordField({
    super.key,
    this.controller,
    this.validator,
    this.hint,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: 'Password',
      hint: hint ?? 'Enter your password',
      controller: controller,
      initialValue: initialValue,
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
}

// Search field
class SearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CustomTextField(
      label: '',
      hint: hint ?? 'Search...',
      controller: controller,
      prefixIcon: Icon(
        Icons.search,
        color: isDark ? Colors.white54 : const Color(0xFF6B7280),
      ),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: Icon(
                Icons.clear,
                color: isDark ? Colors.white54 : const Color(0xFF6B7280),
              ),
              onPressed: onClear,
            )
          : null,
    );
  }
}
