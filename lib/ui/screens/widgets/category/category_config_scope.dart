import 'package:eClassify/data/model/core/category.dart';
import 'package:flutter/widgets.dart';

typedef CategorySubtitleBuilder =
    Widget Function(BuildContext context, Category category);
typedef CategoryCallback<T> = T Function(Category);

/// A configuration scope that allows parent screens to customize category item rendering and behavior
/// (such as custom subtitles or disabled states) without modifying [CategoryPicker] directly.
///
/// ### Architecture Limitation & Future Scaling:
/// Currently, this class uses direct fields (like [subtitleBuilder] or direct predicates).
/// While this works for simple cases, adding more predicates (e.g., `isDisabled`, `isSelectable`, `badgeBuilder`)
/// will clutter the API and violate DRY.
///
/// Note that because current use cases share identical visual structures (only varying by simple state changes),
/// using predicates is sufficient for now. However, if a future requirement demands major layout or visual changes
/// per screen, a delegate builder pattern should be adopted instead.
///
/// **Future Overhaul Recommendation:**
/// If more state-driven behaviors or visual options are required:
/// 1. **Render Policy (Strategy Pattern):** Replace individual properties with a single policy builder,
///    e.g., `CategoryItemPolicy Function(BuildContext, Category)`. The policy class would group all custom attributes
///    (opacity, disabled state, trailing widgets, badges) under a single structure.
/// 2. **Component Delegation (Builder Pattern):** Provide custom card/tile builders in the scope
///    (e.g., `tileBuilder`) to completely override rendering on a screen-by-screen basis.
class CategoryConfigScope extends InheritedWidget {
  const CategoryConfigScope({
    super.key,
    this.subtitleBuilder,
    this.isDisabled,
    this.onDisabledTap,
    required super.child,
  });

  final CategorySubtitleBuilder? subtitleBuilder;
  final CategoryCallback<bool>? isDisabled;
  final CategoryCallback<void>? onDisabledTap;

  static CategoryConfigScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CategoryConfigScope>();
  }

  @override
  bool updateShouldNotify(CategoryConfigScope oldWidget) {
    return subtitleBuilder != oldWidget.subtitleBuilder;
  }
}
