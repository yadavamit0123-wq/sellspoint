import 'package:eClassify/utils/collection_notifiers.dart';
import 'package:eClassify/data/model/core/category.dart';
import 'package:eClassify/utils/log.dart';

/// A reactive notifier for the current category navigation path.
class CategoryPathNotifier extends ListNotifier<Category> {
  CategoryPathNotifier(super.value);

  /// Adds a category to the path if it's not already the last one.
  void push(Category category) => add(category);

  /// Updates the last category in the path.
  void updateLast(Category category) {
    if (isNotEmpty) {
      replaceAt(length - 1, category);
    }
  }

  /// Removes the last category from the path.
  void pop() => removeLast();

  /// Navigates back in the hierarchy to a specific node (or Root if null).
  void navigateTo(Category? category) {
    if (category == null) {
      clear();
    } else {
      final index = value.indexOf(category);
      Log.debug('$length $index');
      if (index != -1) {
        replaceAll(value.sublist(0, index + 1));
      }
    }
  }
}
