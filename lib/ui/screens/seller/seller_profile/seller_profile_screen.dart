import 'package:eClassify/data/cubits/seller/fetch_seller_item_cubit.dart';
import 'package:eClassify/data/cubits/seller/fetch_seller_ratings_cubit.dart';
import 'package:eClassify/data/cubits/followers/follow_cubit.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_live_ads_widget.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_profile_header.dart';
import 'package:eClassify/ui/screens/seller/seller_profile/seller_ratings_widget.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key, required this.sellerId});
  final int sellerId;
  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => FetchSellerItemsCubit()),
          BlocProvider(create: (context) => FetchSellerRatingsCubit()),
          BlocProvider(create: (_) => FollowCubit()),
        ],
        child: SellerProfileScreen(sellerId: routeSettings.arguments! as int),
      ),
    );
  }
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    context.read<FetchSellerItemsCubit>().fetch(sellerId: widget.sellerId);
    context.read<FetchSellerRatingsCubit>().fetch(sellerId: widget.sellerId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SellerProfileHeader(
              controller: _tabController,
              sellerId: widget.sellerId,
            ),
          ];
        },
        body: Padding(
          padding: Constant.appContentPadding,
          child: TabBarView(
            controller: _tabController,
            children: [
              SellerLiveAdsWidget(sellerId: widget.sellerId),
              SellerRatingsWidget(sellerId: widget.sellerId),
            ],
          ),
        ),
      ),
    );
  }
}
