// referral_cubit.dart
import 'package:eClassify/data/model/faq_response.dart';
import 'package:eClassify/data/model/refer/referral_history_model.dart';
import 'package:eClassify/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// States for ReferralBloc
abstract class ReferralListState {}

class ReferralListInitial extends ReferralListState {}

class ReferralListLoading extends ReferralListState {}

class ReferralListSuccess extends ReferralListState {
  final List<ReferralHistoryModel> referrals;
  ReferralListSuccess(this.referrals);
}

class ReferralListError extends ReferralListState {
  final String errorMessage;
  ReferralListError(this.errorMessage);
}

// ReferralBloc for referral data
class ReferralBloc extends Cubit<ReferralListState> {
  ReferralBloc() : super(ReferralListInitial());

  Future<void> fetchReferrals() async {
    emit(ReferralListLoading());
    try {

      // Replace with actual API endpoint for referrals
      final response = await Api.get(
        url: "${Api.referralHistoryApi}",
      );
      print('response ----------------------- ${response}');
      final data = response['data'] as List<dynamic>;
      final referrals = data.map((e) => ReferralHistoryModel.fromJson(e)).toList();
      emit(ReferralListSuccess(referrals));
    } catch (e) {
      emit(ReferralListError(e.toString()));
    }
  }
}

// States for ReferralCubit (FAQs)
abstract class ReferralState {}

class ReferralInitial extends ReferralState {}

class ReferralLoading extends ReferralState {}

class ReferralSuccess extends ReferralState {
  final List<FaqData> faqs;
  ReferralSuccess(this.faqs);
}

class ReferralError extends ReferralState {
  final String errorMessage;
  ReferralError(this.errorMessage);
}
List<FaqData>? _cachedFaqs; // local cache

// ReferralCubit for FAQs
class ReferralCubit extends Cubit<ReferralState> {
  ReferralCubit() : super(ReferralInitial());


  Future<void> fetchReferralFaqs() async {
    if (_cachedFaqs != null && _cachedFaqs!.isNotEmpty) {
      emit(ReferralSuccess(_cachedFaqs!));
      return;
    }

    emit(ReferralLoading());
    try {
      final response = await Api.get(url: Api.referralQuestionApi);
      final data = response['data'] as List<dynamic>;
      final faqs = data.map((e) => FaqData.fromJson(e)).toList();
      _cachedFaqs = faqs;
      emit(ReferralSuccess(faqs));
    } catch (e) {
      emit(ReferralError(e.toString()));
    }
  }
}
