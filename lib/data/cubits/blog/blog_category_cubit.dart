import 'package:eClassify/data/model/blog/blog_category.dart';
import 'package:eClassify/data/model/localized_string.dart';
import 'package:eClassify/data/repositories/blogs_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlogCategoryState {}

class BlogCategoryInitial extends BlogCategoryState {}

class BlogCategoryLoading extends BlogCategoryState {}

class BlogCategorySuccess extends BlogCategoryState {
  BlogCategorySuccess({required this.categories});

  final List<BlogCategory> categories;
}

class BlogCategoryFailure extends BlogCategoryState {
  BlogCategoryFailure({required this.error});

  final Object error;
}

class BlogCategoryCubit extends Cubit<BlogCategoryState> {
  BlogCategoryCubit() : super(BlogCategoryInitial());

  Future<void> getBlogCategories() async {
    try {
      emit(BlogCategoryLoading());

      final categories = await BlogRepository.instance.getBlogCategories();

      emit(
        BlogCategorySuccess(
          categories: [
            BlogCategory(id: null, name: LocalizedString(canonical: 'all')),
            ...categories,
          ],
        ),
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogCategoryFailure(error: e.toString()));
    }
  }
}
