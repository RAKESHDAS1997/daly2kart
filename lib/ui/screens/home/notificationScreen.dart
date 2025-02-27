import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/notificationCubit.dart';
import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/data/models/notification.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';

import 'package:eshop_pro/ui/widgets/customAppbar.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';

import 'package:eshop_pro/ui/widgets/customTextButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';

import 'package:eshop_pro/ui/widgets/error_screen.dart';
import 'package:eshop_pro/utils/constants.dart';

import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../utils/utils.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  static Widget getRouteInstance() => BlocProvider(
        create: (context) => NotificationCubit(),
        child: BlocProvider(
          create: (context) => ProductsCubit(),
          child: const NotificationScreen(),
        ),
      );
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Notifications> newNotifications = [];
  bool _isExpanded = false;
  List<Notifications> earlierNotifications = [];
  DateFormat inputFormat = DateFormat('yyyy-MM-dd');
  List<Widget> notificationItemWidgets = [];
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      getNotifications();
    });
  }

  getNotifications() {
    context.read<NotificationCubit>().getNotification();
  }

  void loadMoreNotifications() {
    context.read<NotificationCubit>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppbar(titleKey: notificationsKey),
        body: BlocConsumer<NotificationCubit, NotificationState>(
          listener: (context, state) {
            if (state is NotificationFetchSuccess) {
              notificationItemWidgets.clear();
              newNotifications.clear();
              earlierNotifications.clear();
              newNotifications.addAll(state.notifications.where((notification) {
                return DateTime.now()
                        .difference(inputFormat.parse(notification.createdAt!))
                        .inHours <=
                    24;
              }).toList());
              earlierNotifications
                  .addAll(state.notifications.where((notification) {
                return DateTime.now()
                        .difference(inputFormat.parse(notification.createdAt!))
                        .inHours >
                    24;
              }).toList());
              if (newNotifications.isNotEmpty) {
                notificationItemWidgets.addAll([
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextContainer(
                        textKey: newKey,
                        style: Theme.of(context).textTheme.titleMedium,
                      )),
                  ...newNotifications.map((notification) =>
                      buildNotificationContainer(notification)),
                ]);
              }
              if (earlierNotifications.isNotEmpty) {
                notificationItemWidgets.addAll([
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CustomTextContainer(
                        textKey: earlierKey,
                        style: Theme.of(context).textTheme.titleMedium,
                      )),
                  ...earlierNotifications.map((notification) =>
                      buildNotificationContainer(notification)),
                ]);
              }
            }
          },
          builder: (context, state) {
            if (state is NotificationFetchSuccess) {
              return NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels ==
                      notification.metrics.maxScrollExtent) {
                    if (context.read<NotificationCubit>().hasMore()) {
                      loadMoreNotifications();
                    }
                  }
                  return true;
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RefreshIndicator(
                      onRefresh: () async {
                        getNotifications();
                      },
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            DesignConfig.smallHeightSizedBox,
                        padding: const EdgeInsetsDirectional.all(
                            appContentHorizontalPadding),
                        itemCount: 1,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          if (context.read<NotificationCubit>().hasMore()) {
                         
                            if (index == state.notifications.length - 1) {
                       
                              if (context
                                  .read<NotificationCubit>()
                                  .fetchMoreError()) {
                                return Center(
                                  child: CustomTextButton(
                                      buttonTextKey: retryKey,
                                      onTapButton: () {
                                        loadMoreNotifications();
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

                          return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: notificationItemWidgets);
                        },
                      ),
                    ),
                    if (state is ProductsFetchInProgress)
                      Center(
                        child: CustomCircularProgressIndicator(
                          indicatorColor: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              );
            }
            if (state is NotificationFetchFailure) {
              return ErrorScreen(
                  onPressed: getNotifications,
                  text: state.errorMessage,
                  image: state.errorMessage == noInternetKey
                      ? "no_internet"
                      : 'no_notification',
                  child: state is NotificationFetchInProgress
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
        ));
  }

  buildNotificationContainer(Notifications notification) {
    return StatefulBuilder(builder: (context, setState) {
      return GestureDetector(
        onTap: () {
          if (notification.type == 'notification' &&
              notification.link!.isNotEmpty) {
            Utils.launchURL(notification.link.toString());
          }
          if (notification.type == 'products') {
            Utils.navigateToScreen(
              context,
              Routes.productDetailsScreen,
              arguments: ProductDetailsScreen.buildArguments(
                  storeId: notification.storeId,
                  product: Product(id: int.parse(notification.typeId!)),
                  productIds: [int.parse(notification.typeId!)]),
            );
          }

          if (notification.type == 'categories') {
            if (notification.categoryData != null) {
              if (notification.categoryData!.children!.isEmpty) {
                Utils.navigateToScreen(context, Routes.exploreScreen,
                    arguments: ExploreScreen.buildArguments(
                        category: notification.categoryData,
                        storeId: notification.storeId));
              } else {
                Utils.navigateToScreen(context, Routes.subCategoryScreen,
                    arguments: {
                      'category': notification.categoryData,
                    });
              }
            }
          }
        },
        child: Column(
          children: [
            CustomDefaultContainer(
                borderRadius: 8,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (notification.image != null &&
                        notification.image!.isNotEmpty) ...[
                      CustomImageWidget(
                          url: notification.image ?? "",
                          width: 48,
                          height: 48,
                          borderRadius: 4),
                      const SizedBox(
                        width: 12,
                      ),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title ?? "",
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: _isExpanded ? null : 2,
                            overflow: _isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text.rich(
                            TextSpan(
                              text: _isExpanded
                                  ? notification.message
                                  : notification.message?.substring(
                                          0,
                                          notification.message!.length > 100
                                              ? 100
                                              : notification.message!.length) ??
                                      "",
                              children: [
                                if (notification.message != null &&
                                    notification.message!.length > 100)
                                  TextSpan(
                                    text: _isExpanded
                                        ? " Read Less"
                                        : "... Read More",
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        setState(() {
                                          _isExpanded = !_isExpanded;
                                        });
                                      },
                                  ),
                              ],
                            ),
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.8),
                                    ),
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            formatDate(notification.createdAt!.split(' ')[0]),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary
                                        .withOpacity(0.8)),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
            DesignConfig.smallHeightSizedBox
          ],
        ),
      );
    });
  }

  String formatDate(String dateStr) {
    DateTime dateTime = DateTime.parse(dateStr);
    DateFormat dateFormat = DateFormat('MMM dd, yyyy');
    return dateFormat.format(dateTime);
  }
}
