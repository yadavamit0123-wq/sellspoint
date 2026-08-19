import 'package:eClassify/data/model/blog/blog.dart';
import 'package:eClassify/data/repositories/blogs_repository.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlogFeedbackState {}

class BlogFeedbackInitial extends BlogFeedbackState {}

class BlogFeedbackLoading extends BlogFeedbackState {}

class BlogFeedbackSuccess extends BlogFeedbackState {
  BlogFeedbackSuccess({required this.feedback});

  final BlogFeedback? feedback;
}

class BlogFeedbackFailure extends BlogFeedbackState {
  BlogFeedbackFailure({required this.message});

  final String message;
}

class BlogFeedbackCubit extends Cubit<BlogFeedbackState> {
  BlogFeedbackCubit() : super(BlogFeedbackInitial());

  Future<void> addFeedback({
    required int blogId,
    required BlogFeedback? feedback,
  }) async {
    try {
      emit(BlogFeedbackLoading());

      await BlogRepository.instance.addBlogFeedback(
        feedback: feedback?.value,
        blogId: blogId,
      );

      emit(BlogFeedbackSuccess(feedback: feedback));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogFeedbackFailure(message: e.toString()));
    }
  }
}
