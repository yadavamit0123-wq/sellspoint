import 'package:eClassify/data/repositories/review/review_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddItemReviewState {}

class AddItemReviewInitial extends AddItemReviewState {}

class AddItemReviewInProgress extends AddItemReviewState {}

class AddItemReviewSuccess extends AddItemReviewState {
  AddItemReviewSuccess(this.message);

  final String message;
}

class AddItemReviewFailure extends AddItemReviewState {
  AddItemReviewFailure(this.error);

  final Object? error;
}

class AddItemReviewCubit extends Cubit<AddItemReviewState> {
  AddItemReviewCubit() : super(AddItemReviewInitial());
  final _repository = ReviewRepository.instance;

  Future<void> addItemReview({
    required int itemId,
    required int rating,
    required String review,
  }) async {
    try {
      emit(AddItemReviewInProgress());

      final response = await _repository.reviewItem(
        itemId: itemId,
        rating: rating,
        review: review,
      );

      emit(AddItemReviewSuccess(response));
    } on Exception catch (e) {
      emit(AddItemReviewFailure(e));
    }
  }
}
