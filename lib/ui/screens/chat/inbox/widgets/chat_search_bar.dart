import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/debounce_mixin.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/utils/app_icons.dart';

class ChatSearchBar extends StatefulWidget {
  const ChatSearchBar({
    required this.onSearch,
    required this.onClear,
    super.key,
  });

  final ValueChanged<String?> onSearch;
  final VoidCallback onClear;

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar>
    with DebounceMixin<ChatSearchBar, String?> {
  late final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void onDebounced(String? value) {
    if (value.isNullOrEmpty) {
      widget.onClear();
    } else {
      widget.onSearch(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      focusNode: _focusNode,
      controller: _searchController,
      onChanged: debounce,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: 'search'.translate(context),
        hintStyle: TextStyle(color: context.color.textLightColor),
        prefixIcon: Icon(
          AppIcons.magnifyingGlass,
          color: context.color.territoryColor,
        ),
        suffixIcon: ListenableBuilder(
          listenable: _searchController,
          builder: (context, child) {
            return _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onClear();
                    },
                    icon: Icon(
                      AppIcons.x,
                      color: context.color.textLightColor,
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        prefixIconConstraints: BoxConstraints.tight(const Size.square(38)),
        constraints: const BoxConstraints(maxHeight: 48),
      ),
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
    );
  }
}
