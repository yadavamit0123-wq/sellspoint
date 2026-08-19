import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/data/repositories/blogs_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlogListState {}

class BlogListInitial extends BlogListState {}

class BlogListLoading extends BlogListState {}

class BlogListSuccess extends BlogListState {
  BlogListSuccess({required this.blogs, this.isPageLoading = false});

  final List<Blog> blogs;
  final bool isPageLoading;
}

class BlogListFailure extends BlogListState {
  BlogListFailure({required this.error});

  final Object error;
}

class BlogListCubit extends Cubit<BlogListState> {
  BlogListCubit(this.categoryId) : super(BlogListInitial());
  final int? categoryId;

  int page = 1;
  bool hasMore = true;
  String? activeTag;

  Future<void> getBlogs({String? tag}) async {
    try {
      emit(BlogListLoading());
      activeTag = tag;
      page = 1;

      final result = await BlogRepository.instance.getBlogs(
        categoryId: categoryId,
        tag: tag,
      );
      hasMore = result.total > result.modelList.length;

      emit(BlogListSuccess(blogs: result.modelList));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogListFailure(error: e));
    }
  }

  Future<void> getMoreBlogs() async {
    try {
      if (!hasMore) return;
      if (state case BlogListSuccess(isPageLoading: true)) return;

      final successState = state as BlogListSuccess;
      emit(BlogListSuccess(blogs: successState.blogs, isPageLoading: true));

      final result = await BlogRepository.instance.getBlogs(
        categoryId: categoryId,
        tag: activeTag,
        page: page + 1,
      );
      final updatedList = [...successState.blogs, ...result.modelList];
      hasMore = result.total > updatedList.length;
      if (hasMore) ++page;

      emit(BlogListSuccess(blogs: updatedList));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogListFailure(error: e));
    }
  }
}
