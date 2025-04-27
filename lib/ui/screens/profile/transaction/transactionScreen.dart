import 'package:eshop_pro/cubits/transaction/transactionCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/transaction.dart';
import 'package:eshop_pro/ui/screens/profile/transaction/widgets/transactionInfoContainer.dart';
import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../../widgets/customTextButton.dart';

class TransactionScreen extends StatefulWidget {
  String transactionType;
  String? walletType;
  static GlobalKey<TransactionScreenState> withdrawScreenKey =
      GlobalKey<TransactionScreenState>();
  TransactionScreen(
      {super.key, required this.transactionType, this.walletType});

  static Widget getRouteInstance() {
    Map<String, dynamic> arguments = Get.arguments as Map<String, dynamic>;
    return BlocProvider(
      create: (context) => TransactionCubit(),
      child: TransactionScreen(
        transactionType: arguments['transactionType'],
        walletType: arguments['walletType'],
      ),
    );
  }

  @override
  TransactionScreenState createState() => TransactionScreenState();
}

class TransactionScreenState extends State<TransactionScreen>
    with AutomaticKeepAliveClientMixin<TransactionScreen> {
  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getTransactions();
    });
  }

  getTransactions() {
    context.read<TransactionCubit>().getTransaction(
        userId: context.read<UserDetailsCubit>().getUserId(),
        transactionType: widget.transactionType,
        type: widget.walletType);
  }

  void loadMoreTransactions() {
    context.read<TransactionCubit>().loadMore(
        userId: context.read<UserDetailsCubit>().getUserId(),
        transactionType: widget.transactionType,
        type: widget.walletType);
  }

  addItemInList(Transaction transaction) {
    List<Transaction> list =
        context.read<TransactionCubit>().getTransactionList();
    list.insert(0, transaction);
    context.read<TransactionCubit>().updateList(list);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: widget.transactionType == defaultTransactionType
          ? const CustomAppbar(titleKey: transactionKey)
          : null,
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state is TransactionFetchSuccess) {
            return NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                if (notification.metrics.pixels ==
                    notification.metrics.maxScrollExtent) {
                  if (context.read<TransactionCubit>().hasMore()) {
                    loadMoreTransactions();
                  }
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  getTransactions();
                },
                child: ListView.separated(
                  padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                  separatorBuilder: (context, index) =>
                      DesignConfig.smallHeightSizedBox,
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    if (context.read<TransactionCubit>().hasMore()) {
               
                      if (index == state.transactions.length - 1) {
            
                        if (context.read<TransactionCubit>().fetchMoreError()) {
                          return Center(
                            child: CustomTextButton(
                                buttonTextKey: retryKey,
                                onTapButton: () {
                                  loadMoreTransactions();
                                }),
                          );
                        }

                        return Center(
                          child: CustomCircularProgressIndicator(
                              indicatorColor:
                                  Theme.of(context).colorScheme.primary),
                        );
                      }
                    }
                    return TransactionInfoContainer(
                        transaction: state.transactions[index]);
                  },
                ),
              ),
            );
          }
          if (state is TransactionFetchFailure) {
            return ErrorScreen(
                text: state.errorMessage,
                onPressed: getTransactions,
                child: state is TransactionFetchInProgress
                    ? CustomCircularProgressIndicator(
                        indicatorColor: Theme.of(context).colorScheme.primary)
                    : null);
          }
          return Center(
            child: CustomCircularProgressIndicator(
                indicatorColor: Theme.of(context).colorScheme.primary),
          );
        },
      ),
    );
  }
}
