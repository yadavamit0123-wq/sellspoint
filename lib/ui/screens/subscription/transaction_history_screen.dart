import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/data/cubits/subscription/bank_transfer_update_cubit.dart';
import 'package:eClassify/data/cubits/utility/fetch_transactions_cubit.dart';
import 'package:eClassify/data/model/transaction_model.dart';
import 'package:eClassify/ui/screens/widgets/animated_routes/blur_page_route.dart';
import 'package:eClassify/ui/screens/widgets/errors/no_data_found.dart';
import 'package:eClassify/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:eClassify/ui/screens/widgets/intertitial_ads_screen.dart';
import 'package:eClassify/ui/theme/theme.dart';
import 'package:eClassify/utils/constant.dart';
import 'package:eClassify/utils/custom_text.dart';
import 'package:eClassify/utils/extensions/extensions.dart';
import 'package:eClassify/utils/helper_utils.dart';
import 'package:eClassify/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  static Route route(RouteSettings settings) {
    return BlurredRouter(
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => FetchTransactionsCubit()),
            BlocProvider(create: (context) => BankTransferUpdateCubit()),
          ],
          child: const TransactionHistory(),
        );
      },
    );
  }

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  late final ScrollController _pageScrollController = ScrollController()
    ..addListener(_onScroll);

  bool _isUploadingReceipt = false;

  void _onScroll() {
    if (!_pageScrollController.hasClients) return;
    if (_pageScrollController.offset <
        _pageScrollController.position.maxScrollExtent - 200) {
      return;
    }
    final cubit = context.read<FetchTransactionsCubit>();
    if (cubit.hasMoreData()) {
      cubit.fetchTransactionsMore();
    }
  }

  @override
  void initState() {
    AdHelper.loadInterstitialAd();
    context.read<FetchTransactionsCubit>().fetchTransactions();
    super.initState();
  }

  @override
  void dispose() {
    _pageScrollController.dispose();
    super.dispose();
  }

  void _showReceiptPicker(String transactionId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      builder: (bc) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: CustomText('gallery'.translate(context)),
                onTap: () {
                  Navigator.pop(bc);
                  _pickReceipt(ImageSource.gallery, transactionId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: CustomText('camera'.translate(context)),
                onTap: () {
                  Navigator.pop(bc);
                  _pickReceipt(ImageSource.camera, transactionId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickReceipt(ImageSource source, String transactionId) async {
    if (_isUploadingReceipt) return;

    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 75,
    );
    if (pickedFile == null || !mounted) return;

    context.read<BankTransferUpdateCubit>().uploadReceipt(
          paymentTransactionId: transactionId,
          receiptFile: File(pickedFile.path),
        );
  }

  @override
  Widget build(BuildContext context) {
    AdHelper.showInterstitialAd();
    return BlocListener<BankTransferUpdateCubit, BankTransferUpdateState>(
      listener: (context, state) {
        if (state is BankTransferUpdateInProgress) {
          setState(() => _isUploadingReceipt = true);
        }
        if (state is BankTransferUpdateSuccess) {
          setState(() => _isUploadingReceipt = false);
          HelperUtils.showSnackBarMessage(context, state.message);
          context.read<FetchTransactionsCubit>().fetchTransactions();
        }
        if (state is BankTransferUpdateFailure) {
          setState(() => _isUploadingReceipt = false);
          HelperUtils.showSnackBarMessage(context, state.error.toString());
        }
      },
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: UiUtils.buildAppBar(context,
            showBackButton: true,
            title: 'transactionHistory'.translate(context)),
        body: BlocBuilder<FetchTransactionsCubit, FetchTransactionsState>(
          builder: (context, state) {
            if (state is FetchTransactionsInProgress) {
              return Center(child: UiUtils.progress());
            }
            if (state is FetchTransactionsFailure) {
              return const SomethingWentWrong();
            }
            if (state is FetchTransactionsSuccess) {
              if (state.transactionModel.isEmpty) {
                return NoDataFound(
                  onTap: () {
                    context.read<FetchTransactionsCubit>().fetchTransactions();
                  },
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _pageScrollController,
                      itemCount: state.transactionModel.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactionModel[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.color.secondaryColor,
                              border: Border.all(
                                  color: context.color.borderColor,
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: _transactionItem(context, transaction),
                          ),
                        );
                      },
                    ),
                  ),
                  if (state.isLoadingMore) UiUtils.progress(),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _transactionItem(
      BuildContext context, TransactionModel transaction) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 41,
            decoration: BoxDecoration(
              color: context.color.territoryColor,
              borderRadius: const BorderRadiusDirectional.only(
                topEnd: Radius.circular(4),
                bottomEnd: Radius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: context.color.territoryColor.withValues(alpha: 0.1),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 3, horizontal: 7),
                  child: CustomText(
                    transaction.paymentGateway ?? '',
                    fontSize: context.font.small,
                    color: context.color.territoryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        transaction.orderId?.toString() ?? '',
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await HapticFeedback.vibrate();
                        final orderId = transaction.orderId ?? '';
                        await Clipboard.setData(ClipboardData(text: orderId));
                        if (context.mounted) {
                          HelperUtils.showSnackBarMessage(
                            context,
                            'copied'.translate(context),
                          );
                        }
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: context.color.secondaryColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: context.color.borderColor, width: 1.5),
                        ),
                        child: Icon(Icons.copy, size: context.font.larger),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CustomText(
                  transaction.createdAt.toString().formatDate(),
                  fontSize: context.font.small,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                '${Constant.currencySymbol}\t${transaction.amount}',
                fontWeight: FontWeight.w700,
                color: context.color.territoryColor,
              ),
              const SizedBox(height: 6),
              _statusAndActions(context, transaction),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusAndActions(
      BuildContext context, TransactionModel transaction) {
    final gateway = transaction.paymentGateway ?? '';
    final status = transaction.paymentStatus ?? '';

    if (gateway == 'BankTransfer' && status == 'pending') {
      return UiUtils.buildButton(
        context,
        onPressed: () {
          if (_isUploadingReceipt || transaction.id == null) return;
          _showReceiptPicker(transaction.id.toString());
        },
        buttonTitle: 'uploadReceipt'.translate(context),
        width: 30,
        height: 35,
        fontSize: 12,
        radius: 5,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      );
    }

    final isSuccess = status == 'success' || status == 'succeed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomText(_localizedPaymentStatus(context, status)),
        if (isSuccess && transaction.id != null) ...[
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.transactionReceipt,
                arguments: {
                  'transactionId': transaction.id,
                  'transactionOrderId': transaction.orderId ?? '',
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: context.color.territoryColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: CustomText(
                'receipt'.translate(context),
                fontSize: context.font.smaller,
                color: context.color.territoryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _localizedPaymentStatus(BuildContext context, String status) {
    final key = status.toLowerCase();
    if (key == 'success' || key == 'succeed') {
      return 'success'.translate(context);
    }
    if (key == 'pending') {
      return 'pending'.translate(context);
    }
    return status.firstUpperCase();
  }
}
