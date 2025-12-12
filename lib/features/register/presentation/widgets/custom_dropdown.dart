import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final T? value;
  final List<T> items;
  final Function(T?) onChanged;
  final String? Function(T?)? validator;
  final Widget Function(T) itemBuilder;
  final AutovalidateMode? autovalidateMode;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
    this.value,
    this.validator,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: itemBuilder(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
          ),
        ),
      ],
    );
  }
}