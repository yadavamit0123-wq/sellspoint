import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/data/repositories/blogs_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlogDetailsState {}

class BlogDetailsInitial extends BlogDetailsState {}

class BlogDetailsLoading extends BlogDetailsState {}

class BlogDetailsSuccess extends BlogDetailsState {
  BlogDetailsSuccess({required this.blog, required this.relatedBlogs});

  final Blog blog;
  final List<Blog> relatedBlogs;
}

class BlogDetailsFailure extends BlogDetailsState {
  BlogDetailsFailure({required this.error});

  final Object error;
}

class BlogDetailsCubit extends Cubit<BlogDetailsState> {
  BlogDetailsCubit() : super(BlogDetailsInitial());

  Future<void> getBlogDetails({required int id}) async {
    try {
      emit(BlogDetailsLoading());

      final result = await BlogRepository.instance.getBlogDetails(id: id);

      emit(
        BlogDetailsSuccess(
          blog: result['blog'] as Blog,
          relatedBlogs: result['related'] as List<Blog>,
        ),
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogDetailsFailure(error: e));
    }
  }
}
