import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import 'rotating_search_hint.dart';

class LibrarySearchField extends StatefulWidget {
  const LibrarySearchField({
    super.key,
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<LibrarySearchField> createState() => _LibrarySearchFieldState();
}

class _LibrarySearchFieldState extends State<LibrarySearchField> {
  // Tracked so the hint stops rotating while the user is typing.
  final FocusNode _focus = FocusNode();

  static const double _prefixSize = 48;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screen, 20, AppSpacing.screen, 0),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        onChanged: widget.onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        textInputAction: TextInputAction.search,
        style: text.bodyLarge,
        decoration: InputDecoration(
          hint: RotatingSearchHint(paused: _focus.hasFocus),
          prefixIcon: const Padding(
            padding: EdgeInsetsDirectional.only(start: 16, end: 8),
            child: Icon(Icons.search_rounded),
          ),
          prefixIconConstraints: const BoxConstraints(
              minWidth: _prefixSize, minHeight: _prefixSize),
          suffixIcon: widget.hasQuery
              ? IconButton(
                  tooltip: 'Clear search',
                  onPressed: widget.onClear,
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
        ),
      ),
    );
  }
}
