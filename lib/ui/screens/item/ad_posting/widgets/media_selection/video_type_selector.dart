import 'package:eClassify/data/model/item/product_video.dart';
import 'package:eClassify/ui/theme/theme_colors.dart';
import 'package:eClassify/ui/theme/theme_extensions.dart';
import 'package:eClassify/utils/app_icons.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class VideoTypeSelector extends StatefulWidget {
  const VideoTypeSelector({
    required this.onTypeChanged,
    this.selected = ProductVideoType.custom,
    super.key,
  });

  final ProductVideoType selected;
  final ValueChanged<ProductVideoType> onTypeChanged;

  @override
  State<VideoTypeSelector> createState() => _VideoTypeSelectorState();
}

class _VideoTypeSelectorState extends State<VideoTypeSelector> {
  late ProductVideoType selected = widget.selected;
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();

  @override
  void didUpdateWidget(covariant VideoTypeSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      selected = widget.selected;
    }
  }

  void _toggleMenu() {
    _overlayController.toggle();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return _VideoTypeDropdownMenu(
          layerLink: _layerLink,
          selected: selected,
          onTypeChanged: (type) {
            setState(() {
              selected = type;
            });
            widget.onTypeChanged(type);
          },
          onClose: () {
            _overlayController.hide();
          },
        );
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: _toggleMenu,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: context.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 4,
                children: [
                  Text(
                    selected.key.translate(context),
                    style: context.labelSmall,
                  ),
                  Icon(
                    AppIcons.caretDown,
                    size: 16,
                    color: context.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoTypeDropdownMenu extends StatelessWidget {
  const _VideoTypeDropdownMenu({
    required this.layerLink,
    required this.selected,
    required this.onTypeChanged,
    required this.onClose,
  });

  final LayerLink layerLink;
  final ProductVideoType selected;
  final ValueChanged<ProductVideoType> onTypeChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: onClose,
          behavior: HitTestBehavior.translucent,
          child: const SizedBox.expand(),
        ),
        CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: Material(
              elevation: 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ProductVideoType.values.map((type) {
                  final isSelected = selected == type;
                  return ListTile(
                    onTap: () {
                      onTypeChanged(type);
                      onClose();
                    },
                    tileColor: context.colorScheme.surface,
                    selected: isSelected,
                    selectedTileColor: context.colorScheme.primary.withValues(
                      alpha: .1,
                    ),
                    selectedColor: context.colorScheme.primary,
                    shape: LinearBorder.none,
                    dense: true,
                    title: Text(type.key.translate(context)),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
