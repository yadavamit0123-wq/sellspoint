import 'package:eClassify/data/model/blog/blog_tag.dart';
import 'package:eClassify/data/repositories/blogs_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlogTagState {}

class BlogTagInitial extends BlogTagState {}

class BlogTagLoading extends BlogTagState {}

class BlogTagSuccess extends BlogTagState {
  BlogTagSuccess({required this.tags});

  final List<BlogTag> tags;
}

class BlogTagFailure extends BlogTagState {
  BlogTagFailure({required this.message});

  final String message;
}

class BlogTagCubit extends Cubit<BlogTagState> {
  BlogTagCubit() : super(BlogTagInitial());

  Future<void> getBlogTags() async {
    try {
      emit(BlogTagLoading());

      final tags = await BlogRepository.instance.getBlogTags();

      emit(BlogTagSuccess(tags: tags));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogTagFailure(message: e.toString()));
    }
  }
}
