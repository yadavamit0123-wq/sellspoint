import 'dart:async';
import 'dart:math';

import 'package:eClassify/data/model/chat/chat.dart';
import 'package:eClassify/data/model/chat/item_offer.dart';
import 'package:eClassify/data/repositories/chat_history_repository.dart';
import 'package:eClassify/data/services/chat/chat_event_bus.dart';
import 'package:eClassify/utils/extensions/lib/extensions.dart';
import 'package:eClassify/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SellerItemOffersState {}

class SellerItemOffersInitial extends SellerItemOffersState {}

class SellerItemOffersLoading extends SellerItemOffersState {}

class SellerItemOffersSuccess extends SellerItemOffersState {
  SellerItemOffersSuccess({
    required this.offers,
    this.lastUpdatedMessage,
    this.isLoadingMore = false,
  });

  final List<ItemOffer> offers;
  final ChatNotificationMessage? lastUpdatedMessage;
  final bool isLoadingMore;

  SellerItemOffersSuccess copyWith({
    List<ItemOffer>? offers,
    ChatNotificationMessage? lastUpdatedMessage,
    bool? isLoadingMore,
  }) => SellerItemOffersSuccess(
    offers: offers ?? this.offers,
    lastUpdatedMessage: lastUpdatedMessage ?? this.lastUpdatedMessage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

class SellerItemOffersFailure extends SellerItemOffersState {
  SellerItemOffersFailure({required this.error});

  final Object error;
}

class SellerItemOffersCubit extends Cubit<SellerItemOffersState> {
  SellerItemOffersCubit() : super(SellerItemOffersInitial()) {
    _eventSubscription = ChatEventBus.instance.eventStream.listen(_onChatEvent);
  }

  int page = 1;
  bool hasMore = true;
  List<ItemOffer>? _cachedOffers;
  String? search;
  late final StreamSubscription _eventSubscription;

  void _onChatEvent(ChatEvent event) {
    if (state is! SellerItemOffersSuccess) return;

    switch (event) {
      case ChatEvent(type: ChatEventType.read, data: {'item_id': int itemId}):
        removeUnreadCount(itemId);
      case ChatEvent(
        type: ChatEventType.messageReceived,
        data: {
          'message': ChatNotificationMessage message,
          'item_offer': ItemOffer? itemOffer,
        },
      ):
        if (itemOffer != null) {
          increaseUnreadCount(message, itemOffer);
        }
      case ChatEvent(
        type: ChatEventType.deleted,
        data: {
          'item_offer_ids': List<dynamic> itemOfferIds,
          'item_id': int? itemId,
        },
      ):
        if (itemId != null) {
          removeUsers(itemId, itemOfferIds.cast<int>());
        }
      default:
        break;
    }
  }

  Future<void> getOffers({String? search}) async {
    try {
      this.search = search;
      if (search.isNotNullAndNotEmpty) {
        _cachedOffers ??= (state as SellerItemOffersSuccess).offers;
        emit(SellerItemOffersLoading());
        final response = await ChatHistoryRepository.instance
            .getSellerItemOffers(search: search);
        emit(
          SellerItemOffersSuccess(
            offers: response['offers'] as List<ItemOffer>,
          ),
        );
      } else {
        if (_cachedOffers.isNotNullAndNotEmpty) {
          emit(SellerItemOffersSuccess(offers: _cachedOffers!));
          _cachedOffers = null;
        } else {
          emit(SellerItemOffersLoading());

          final response = await ChatHistoryRepository.instance
              .getSellerItemOffers();
          hasMore = response['has_more'] as bool;
          final offers = response['offers'] as List<ItemOffer>;
          emit(SellerItemOffersSuccess(offers: offers));
        }
      }
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(SellerItemOffersFailure(error: e));
    }
  }

  Future<void> getMoreOffers() async {
    if (state is! SellerItemOffersSuccess) return;
    final successState = state as SellerItemOffersSuccess;
    if (!hasMore ||
        successState.isLoadingMore ||
        (search != null && search!.isNotEmpty))
      return;
    try {
      emit(successState.copyWith(isLoadingMore: true));
      final response = await ChatHistoryRepository.instance.getSellerItemOffers(
        page: page + 1,
      );
      emit(
        SellerItemOffersSuccess(
          offers: [
            ...successState.offers,
            ...response['offers'] as List<ItemOffer>,
          ],
          isLoadingMore: false,
        ),
      );
      hasMore = response['has_more'] as bool;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(SellerItemOffersFailure(error: e));
    }
  }

  void removeUnreadCount(int itemId, [int? count]) {
    if (state is! SellerItemOffersSuccess) return;
    final successState = state as SellerItemOffersSuccess;
    final offers = successState.offers;
    final index = offers.indexWhere((element) {
      Log.debug('${element.id} ${itemId}');
      return element.id == itemId;
    });

    if (index != -1) {
      Log.debug('Found Offer');
      final offer = offers[index];
      final unreadCount = max(
        0,
        offer.unreadCount - (count ?? offer.unreadCount),
      );
      offers[index] = offer.copyWith(unreadCount: unreadCount);
    }

    emit(SellerItemOffersSuccess(offers: List.from(offers)));
  }

  void clearOfferUnreadCount(int itemId) {
    if (state is! SellerItemOffersSuccess) return;
    final successState = state as SellerItemOffersSuccess;
    final offers = successState.offers;
    final index = offers.indexWhere((element) => element.id == itemId);
    if (index != -1) {
      final offer = offers[index];
      offers[index] = offer.copyWith(offerUnreadCount: 0);
      emit(SellerItemOffersSuccess(offers: List.from(offers)));
    }
  }

  void increaseUnreadCount(
    ChatNotificationMessage message,
    ItemOffer itemOffer,
  ) {
    if (state is! SellerItemOffersSuccess) return;
    final successState = state as SellerItemOffersSuccess;
    final offers = successState.offers;
    final index = offers.indexWhere((element) => element.id == message.itemId);
    if (index == -1) {
      emit(
        SellerItemOffersSuccess(
          offers: List.from([itemOffer, ...offers]),
          lastUpdatedMessage: message,
        ),
      );
      return;
    }
    final offer = offers[index];
    final userExists = offer.users.any(
      (user) => user.id == itemOffer.users.first.id,
    );
    if (index != 0) {
      final newOffer = offer.copyWith(
        unreadCount: offer.unreadCount + message.unreadCount,
        users: userExists ? offer.users : [...itemOffer.users, ...offer.users],
      );
      offers.removeAt(index);
      emit(
        SellerItemOffersSuccess(
          offers: List.from([newOffer, ...offers]),
          lastUpdatedMessage: message,
        ),
      );
    } else {
      offers[index] = offer.copyWith(
        unreadCount: offer.unreadCount + message.unreadCount,
        users: userExists ? offer.users : [...itemOffer.users, ...offer.users],
      );
      emit(
        SellerItemOffersSuccess(
          offers: List.from(offers),
          lastUpdatedMessage: message,
        ),
      );
    }
  }

  void removeUsers(int itemId, List<int> offerIds) {
    if (state is! SellerItemOffersSuccess) return;
    final successState = state as SellerItemOffersSuccess;
    final offers = successState.offers;
    final offer = offers.firstWhere((element) => element.id == itemId);
    final index = offers.indexOf(offer);
    offer.users.removeWhere((element) => offerIds.contains(element.offerId));
    if (index != -1) {
      final newOffer = offer.copyWith(
        totalUsers: offer.totalUsers != null
            ? min(offer.totalUsers! - offerIds.length, 0)
            : null,
      );
      offers[index] = newOffer;
      if (offer.users.isEmpty) {
        offers.removeAt(index);
      }
    }
    emit(SellerItemOffersSuccess(offers: List.from(offers)));
  }

  void addOffer(ItemOffer offer) {
    if (state is! SellerItemOffersSuccess) return;
    final successState = state as SellerItemOffersSuccess;
    final offers = successState.offers;
    final index = offers.indexWhere((o) => o == offer);
    if (index != -1) {
      final existingOffer = offers[index];
      final newOffer = existingOffer.copyWith(
        unreadCount: existingOffer.unreadCount + 1,
        lastUpdatedAt: DateTime.now(),
        users: [...offer.users, ...existingOffer.users],
      );
      offers.removeAt(index);
      emit(SellerItemOffersSuccess(offers: [newOffer, ...offers]));
    } else {
      emit(SellerItemOffersSuccess(offers: [offer, ...offers]));
    }
  }

  void clear() => emit(SellerItemOffersInitial());

  @override
  Future<void> close() {
    _eventSubscription.cancel();
    return super.close();
  }
}
