import 'package:eClassify/data/model/item/item_model.dart';
import 'package:eClassify/data/model/location/leaf_location.dart';
import 'package:eClassify/data/repositories/home/home_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class HomeItemsState {}

class HomeItemsInitial extends HomeItemsState {}

class HomeItemsLoading extends HomeItemsState {}

class HomeItemsSuccess extends HomeItemsState {
  HomeItemsSuccess({
    required this.items,
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.page,
    required this.total,
    this.message,
  });

  final List<ItemModel> items;
  final bool isLoadingMore;
  final bool loadingMoreError;
  final int page;
  final int total;
  final String? message;

  HomeItemsSuccess copyWith({
    List<ItemModel>? items,
    bool? isLoadingMore,
    bool? loadingMoreError,
    int? page,
    int? total,
    String? message,
  }) {
    return HomeItemsSuccess(
      items: items ?? this.items,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      page: page ?? this.page,
      total: total ?? this.total,
      message: message ?? this.message,
    );
  }

  bool get hasMore => items.length < total;
}

class HomeItemsFailure extends HomeItemsState {
  final dynamic error;

  HomeItemsFailure(this.error);
}

class HomeItemsCubit extends Cubit<HomeItemsState> {
  HomeItemsCubit() : super(HomeItemsInitial());

  final HomeRepository _homeRepository = HomeRepository.instance;

  void getHomeItems({LeafLocation? location}) async {
    try {
      emit(HomeItemsLoading());
      final result = await _homeRepository.fetchHomeAllItems(
        location: location,
        page: 1,
      );

      emit(
        HomeItemsSuccess(
          page: 1,
          isLoadingMore: false,
          loadingMoreError: false,
          items: result.modelList,
          total: result.total,
          message: result.extraData?.data as String?,
        ),
      );
    } catch (e) {
      emit(HomeItemsFailure(e.toString()));
    }
  }

  Future<void> getMoreHomeItems({required LeafLocation? location}) async {
    try {
      if (state is HomeItemsSuccess) {
        if ((state as HomeItemsSuccess).isLoadingMore) {
          return;
        }
        emit((state as HomeItemsSuccess).copyWith(isLoadingMore: true));
        final result = await _homeRepository.fetchHomeAllItems(
          page: (state as HomeItemsSuccess).page + 1,
          location: location,
        );

        HomeItemsSuccess itemModelState = (state as HomeItemsSuccess);
        itemModelState.items.addAll(result.modelList);
        emit(
          HomeItemsSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            items: itemModelState.items,
            page: (state as HomeItemsSuccess).page + 1,
            total: result.total,
            message: result.extraData?.data as String?,
          ),
        );
      }
    } catch (e) {
      emit(
        (state as HomeItemsSuccess).copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  bool get hasMoreData {
    if (state case final HomeItemsSuccess state) {
      return state.items.length < state.total;
    }
    return false;
  }
}
