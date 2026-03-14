import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Search for a song',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SearchBar(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
      trailing: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        ),
      ],
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20.0),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
    );
  }
}
