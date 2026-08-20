import 'package:eClassify/data/cubits/blog/blog_tag_cubit.dart';
import 'package:eClassify/data/model/blog/blog_tag.dart';
import 'package:eClassify/ui/screens/widgets/shimmer_loading_container.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eClassify/utils/app_icons.dart';

class BlogTagList extends StatefulWidget {
  const BlogTagList({required this.onTagSelected, super.key});

  final ValueChanged<BlogTag?> onTagSelected;

  @override
  State<BlogTagList> createState() => _BlogTagListState();
}

class _BlogTagListState extends State<BlogTagList> {
  BlogTag? _currentTag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
      child: BlocBuilder<BlogTagCubit, BlogTagState>(
        builder: (context, state) {
          if (state is BlogTagInitial) {
            context.read<BlogTagCubit>().getBlogTags();
          }
          if (state is BlogTagFailure) {
            return const SizedBox.shrink();
          }
          if (state is BlogTagSuccess) {
            final tags = [
              BlogTag(value: null, label: 'all'.translate(context)),
              ...state.tags,
            ];
            return GestureDetector(
              onTap: () async {
                final tag = await showModalBottomSheet<BlogTag>(
                  context: context,
                  builder: (context) =>
                      _TagList(tags: tags, selectedTag: _currentTag),
                );
                widget.onTagSelected(tag);
                setState(() {
                  _currentTag = tag;
                });
              },
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentTag?.value != null
                              ? 'Tag: ${_currentTag?.label}'
                              : 'Tags',
                          style: context.titleMedium,
                        ),
                      ),
                      Icon(AppIcons.caretRight),
                    ],
                  ),
                ),
              ),
            );
          }
          return CustomShimmer(height: 60, borderRadius: 12);
        },
      ),
    );
  }
}

class _TagList extends StatefulWidget {
  const _TagList({required this.tags, required this.selectedTag});

  final List<BlogTag> tags;
  final BlogTag? selectedTag;

  @override
  State<_TagList> createState() => _TagListState();
}

class _TagListState extends State<_TagList> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Column(
        spacing: 20,
        children: [
          Padding(
            padding: Constant.appContentPadding,
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Search Tags'),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                final effectiveTags = widget.tags
                    .where(
                      (tag) => tag.label.toLowerCase().contains(
                        _controller.text.toLowerCase(),
                      ),
                    )
                    .toList();
                return ListView.separated(
                  itemBuilder: (context, index) {
                    final tag = effectiveTags[index];
                    return ListTile(
                      shape: const LinearBorder(),
                      onTap: () => Navigator.of(context).pop(tag),
                      title: Text(tag.label, style: context.titleMedium),
                      trailing: widget.selectedTag == tag
                          ? Icon(
                              AppIcons.check,
                              color: context.colorScheme.primary,
                            )
                          : null,
                    );
                  },
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemCount: effectiveTags.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
