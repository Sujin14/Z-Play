import 'package:flutter/material.dart';
import '../../../../../constants/themes.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onChanged;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.glassFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.glassBorder),
        boxShadow: [
          BoxShadow(color: theme.colorScheme.inputShadow, blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        onChanged: onChanged,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: style(fontSize: hi / 55, color: theme.textTheme.bodyLarge!.color),
        decoration: InputDecoration(
          hintText: "Search music files...",
          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
          border: InputBorder.none,
          hintStyle: TextStyle(color: theme.textTheme.bodyMedium!.color),
        ),
      ),
    );
  }
}
