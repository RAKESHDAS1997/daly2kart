import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/customerSupport/getTicketCubit.dart';
import 'package:eshop_pro/ui/screens/profile/customerSupport/widgets/ticketItemContainer.dart';
import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customBottomButtonContainer.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({Key? key}) : super(key: key);
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => TicketCubit(),
        child: const CustomerSupportScreen(),
      );
  @override
  _CustomerSupportScreenState createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      getTickets();
    });
  }

  getTickets() {
    context.read<TicketCubit>().getTickets();
  }

  void loadMoreTickets() {
    context.read<TicketCubit>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(titleKey: customerSupportKey),
      bottomNavigationBar: CustomBottomButtonContainer(
        child: CustomRoundedButton(
          widthPercentage: 1.0,
          buttonTitle: askQueryKey,
          showBorder: false,
          onTap: () => Utils.navigateToScreen(context, Routes.askQueryScreen,
              arguments: {'ticketCubit': context.read<TicketCubit>()}),
        ),
      ),
      body: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
            vertical: 12, horizontal: appContentHorizontalPadding),
        child: Column(
          children: <Widget>[
            buildChatContainer(),
            DesignConfig.defaultHeightSizedBox,
            buildTicketList()
          ],
        ),
      ),
    );
  }

  buildChatContainer() {
    return GestureDetector(
      onTap: () => Utils.navigateToScreen(context, Routes.userListScreen),
      child: CustomDefaultContainer(
          child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 36,
            height: 36,
            child: Icon(
              Icons.chat_bubble_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          DesignConfig.smallWidthSizedBox,
          Expanded(
            child: CustomTextContainer(
              textKey: chatKey,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8)),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          )
        ],
      )),
    );
  }

  buildTicketList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          getTickets();
        },
        child: BlocBuilder<TicketCubit, TicketState>(
          builder: (context, state) {
            if (state is TicketFetchSuccess) {
              return NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent) {
                    if (context.read<TicketCubit>().hasMore()) {
                      loadMoreTickets();
                    }
                  }
                  return true;
                },
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      DesignConfig.smallHeightSizedBox,
                  shrinkWrap: true,
                  itemCount: state.tickets.length,
                  itemBuilder: (context, index) {
                    if (context.read<TicketCubit>().hasMore()) {
                    
                      if (index == state.tickets.length - 1) {
                 
                        if (context.read<TicketCubit>().fetchMoreError()) {
                          return Center(
                            child: CustomTextButton(
                                buttonTextKey: retryKey,
                                onTapButton: () {
                                  loadMoreTickets();
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
                    return TicketItemContainer(
                        state.tickets[index], context.read<TicketCubit>());
                  },
                ),
              );
            }
            if (state is TicketFetchFailure) {
              return ErrorScreen(
                  onPressed: getTickets,
                  text: state.errorMessage,
                  child: state is TicketFetchInProgress
                      ? CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        )
                      : null);
            }
            return Center(
              child: CustomCircularProgressIndicator(
                  indicatorColor: Theme.of(context).colorScheme.primary),
            );
          },
        ),
      ),
    );
  }
}
