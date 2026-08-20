import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/data/repositories/blogs_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PopularBlogListState {}

class PopularBlogListInitial extends PopularBlogListState {}

class PopularBlogListLoading extends PopularBlogListState {}

class PopularBlogListSuccess extends PopularBlogListState {
  PopularBlogListSuccess({required this.blogs});

  final List<Blog> blogs;
}

class PopularBlogListFailure extends PopularBlogListState {
  PopularBlogListFailure({required this.message});

  final String message;
}

class PopularBlogListCubit extends Cubit<PopularBlogListState> {
  PopularBlogListCubit() : super(PopularBlogListInitial());

  Future<void> getPopularBlogs() async {
    try {
      emit(PopularBlogListLoading());

      final blogs = await BlogRepository.instance.getPopularBlogs();

      emit(PopularBlogListSuccess(blogs: blogs));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(PopularBlogListFailure(message: e.toString()));
    }
  }
}
