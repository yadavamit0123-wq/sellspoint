// my_wallet_screen.dart
import 'package:eClassify/data/cubits/auth/user_profile_cubit.dart';
import 'package:eClassify/data/cubits/my_wallet/transaction_cubit.dart';
import 'package:eClassify/data/cubits/system/user_details.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// My Wallet Screen
class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) => const MyWalletScreen(),
    );
  }

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final TransactionBloc _transactionBloc;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _transactionBloc = TransactionBloc();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshWalletData(showLoader: true);
    });
  }

  Future<void> _refreshWalletData({bool showLoader = false}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    if (showLoader && mounted) setState(() {});

    await context.read<UserProfileCubit>().getUserProfile();
    final profileState = context.read<UserProfileCubit>().state;
    if (profileState is UserProfileSuccess && mounted) {
      context.read<UserDetailsCubit>().copy(profileState.user);
    }
    await _transactionBloc.fetchTransactions();

    _isRefreshing = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _transactionBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(
        context: context,
        statusBarColor: context.color.secondaryColor,
      ),
      child: BlocProvider(
        create: (context) => TransactionCubit()..fetchWalletFaqs(),
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: UiUtils.buildAppBar(
            showBackButton: true,
            context,
            title: "My Wallet".translate(context),
          ),
          body: ScrollConfiguration(
            behavior: RemoveGlow(),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Balance',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 5),
                          BlocBuilder<UserDetailsCubit, UserDetailsState>(
                            builder: (context, state) {
                              if (_isRefreshing &&
                                  state.user?.wallet == null) {
                                return const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              return Text(
                                state.user?.wallet?.toString() ?? '0',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(text: 'Transactions'),
                        Tab(text: 'FAQ'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          BlocProvider.value(
                            value: _transactionBloc,
                            child: BlocBuilder<TransactionBloc,
                                TransactionListState>(
                              builder: (context, state) {
                                if (state is TransactionListLoading ||
                                    (_isRefreshing &&
                                        state is! TransactionListSuccess)) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (state is TransactionListSuccess) {
                                  if (state.transactions.isEmpty) {
                                    return const Center(
                                      child: Text('No transactions found'),
                                    );
                                  }
                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    itemCount: state.transactions.length,
                                    itemBuilder: (context, index) {
                                      final transaction =
                                          state.transactions[index];
                                      final timeZone = transaction.createdAt
                                              ?.split('T')[1] ??
                                          '';
                                      final timeParts = timeZone.split(':');
                                      final time = timeParts.length >= 2
                                          ? '${timeParts[0]}:${timeParts[1]}'
                                          : '';
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                        ),
                                        child: ListTile(
                                          leading: Icon(
                                            transaction.tranType
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color: transaction.tranType
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          title: Text(
                                            transaction.title ?? 'null',
                                          ),
                                          subtitle: Text(
                                            '${transaction.createdAt?.split('T')[0]} - $time',
                                          ),
                                          trailing: Text(
                                            '\₹${transaction.amount?.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              color: transaction.tranType
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else if (state is TransactionListError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Failed to load transactions: ${state.errorMessage}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            _transactionBloc
                                                .fetchTransactions();
                                          },
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ),
                          BlocBuilder<TransactionCubit, TransactionFaqState>(
                            builder: (context, state) {
                              if (state is TransactionFaqLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (state is TransactionFaqSuccess) {
                                if (state.faqs.isEmpty) {
                                  return const Center(
                                    child: Text('No FAQs available'),
                                  );
                                }
                                return ListView(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16.0,
                                  ),
                                  children: state.faqs
                                      .map(
                                        (faq) => ExpansionTile(
                                          expandedAlignment:
                                              Alignment.centerLeft,
                                          title: Text(
                                            faq.quetions,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(16.0),
                                              child: Text(faq.answers),
                                            ),
                                          ],
                                        ),
                                      )
                                      .toList(),
                                );
                              } else if (state is TransactionFaqError) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Failed to load FAQs: ${state.errorMessage}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          context
                                              .read<TransactionCubit>()
                                              .fetchWalletFaqs();
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}
