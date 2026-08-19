// my_wallet_screen.dart
import 'package:eClassify/data/cubits/my_wallet/transaction_cubit.dart';
import 'package:eClassify/data/model/user_model.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/hive_utils.dart';
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

class _MyWalletScreenState extends State<MyWalletScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  UserModel? userModel;

  @override
  void initState() {
    super.initState();
    getMyData();
    _tabController = TabController(length: 2, vsync: this);
  }

  void getMyData(){
    userModel = HiveUtils.getUserDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context, statusBarColor: context.color.secondaryColor),
      child: BlocProvider(
        create: (context) => TransactionCubit()..fetchWalletFaqs(), // Moved to Scaffold level
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: UiUtils.buildAppBar(
            showBackButton: true,
            context,
            title: "My Wallet".translate(context),
            // actions: [
            //   IconButton(
            //     icon: const Icon(Icons.filter_list),
            //     onPressed: () {
            //       // Implement filter functionality
            //     },
            //   ),
            // ],
          ),
          body: ScrollConfiguration(
            behavior: RemoveGlow(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          userModel?.wallet?.toString() ?? '0',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
                        // Transactions Tab
                        BlocProvider(
                          create: (context) => TransactionBloc()..fetchTransactions(),
                          child: BlocBuilder<TransactionBloc, TransactionListState>(
                            builder: (context, state) {
                              if (state is TransactionListLoading) {
                                return const Center(child: CircularProgressIndicator());
                              } else if (state is TransactionListSuccess) {
                                if (state.transactions.isEmpty) {
                                  return const Center(child: Text('No transactions found'));
                                }
                                return ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  itemCount: state.transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = state.transactions[index];
                                    String timeZone = transaction.createdAt?.split("T")[1] ?? '';
                                    String time1 = timeZone.split(':')[0] ?? '';
                                    String time2 = timeZone.split(':')[1] ?? '';
                                    String time = "${time1}:${time2}";
                                    return Card(
                                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: ListTile(
                                        leading: Icon(
                                          transaction.tranType ? Icons.arrow_downward : Icons.arrow_upward,
                                          color: transaction.tranType ? Colors.green : Colors.red,
                                        ),
                                        title: Text(transaction.title ?? 'null'),
                                        subtitle: Text('${transaction.createdAt?.split('T')[0]} - $time'),
                                        trailing: Text(
                                          '\₹${transaction.amount?.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: transaction.tranType ? Colors.green : Colors.red,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Failed to load transactions: ${state.errorMessage}',
                                        style: const TextStyle(color: Colors.red),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed: () {
                                          context.read<TransactionBloc>().fetchTransactions();
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
                        // FAQ Tab
                        BlocBuilder<TransactionCubit, TransactionFaqState>(
                          builder: (context, state) {
                            if (state is TransactionFaqLoading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is TransactionFaqSuccess) {
                              if (state.faqs.isEmpty) {
                                return const Center(child: Text('No FAQs available'));
                              }
                              return ListView(
                                padding: const EdgeInsets.symmetric(vertical: 16.0),
                                children: state.faqs.map((faq) => ExpansionTile(
                                  expandedAlignment: Alignment.centerLeft,
                                  title: Text(faq.quetions, style: TextStyle(fontWeight: FontWeight.w900),),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(faq.answers),
                                    ),
                                  ],
                                )).toList(),
                              );
                            } else if (state is TransactionFaqError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Failed to load FAQs: ${state.errorMessage}',
                                      style: const TextStyle(color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        context.read<TransactionCubit>().fetchWalletFaqs();
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