import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customSearchContainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../cubits/storesCubit.dart';
import '../../../../data/models/store.dart';
import '../../../../utils/constants.dart';
import '../../../../utils/designConfig.dart';
import '../../../../utils/labelKeys.dart';
import '../../../../utils/utils.dart';
import '../../../widgets/circleButton.dart';
import '../../../widgets/customTextContainer.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Store defaultStore = context.read<StoresCubit>().getDefaultStore();
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Container(
        color: Theme.of(context).colorScheme.primaryContainer,
        padding: const EdgeInsetsDirectional.symmetric(
            horizontal: appContentHorizontalPadding, vertical: 8),
        child: AppBar(
          leadingWidth: 40,
          automaticallyImplyLeading: false,
          titleSpacing: 10,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: Align(
            alignment: Alignment.centerLeft,
            child: CustomImageWidget(
              url: defaultStore.image,
              borderRadius: 18,
              isCircularImage: true,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextContainer(
                textKey: shopForKey,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.67)),
              ),
              GestureDetector(
                onTap: () => openStoreList(context),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: CustomTextContainer(
                        textKey: defaultStore.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_drop_down,
                      size: 20,
                    )
                  ],
                ),
              )
            ],
          ),
          actions: [
            if (!context.read<UserDetailsCubit>().isGuestUser())
              GestureDetector(
                onTap: () =>
                    Utils.navigateToScreen(context, Routes.notificationScreen),
                child: Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            Utils.favoriteIcon(context)
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: CustomSearchContainer(
              autoFocus: false,
              readOnly: true,
              onTap: () => Utils.navigateToScreen(context, Routes.searchScreen),
            ),
          ),
        ),
      ),
    );
  }

  void openStoreList(BuildContext context) {
    Utils.openModalBottomSheet(
        context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsetsDirectional.all(appContentHorizontalPadding),
              child: CustomTextContainer(
                textKey: selectStoreKey,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            DesignConfig.defaultHeightSizedBox,
            BlocConsumer<StoresCubit, StoresState>(
              listener: (context, state) {},
              builder: (context, state) {
                return SizedBox(
                  height: 160,
                  child: ListView.separated(
                    separatorBuilder: (context, index) =>
                        DesignConfig.defaultWidthSizedBox,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsetsDirectional.symmetric(
                        horizontal: appContentHorizontalPadding),
                    shrinkWrap: true,
                    itemCount:
                        context.read<StoresCubit>().getAllStores().length,
                    itemBuilder: (context, index) {
                      Store store =
                          context.read<StoresCubit>().getAllStores()[index];
                      return InkWell(
                        onTap: () {
                          context.read<StoresCubit>().changeDefaultStore(
                              storeId: store.id ?? 0,
                              stores:
                                  context.read<StoresCubit>().getAllStores());
                          Future.delayed(const Duration(milliseconds: 500),
                              () => Utils.popNavigation(context));
                        },
                        hoverColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.5),
                        child: Column(
                          children: <Widget>[
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CustomImageWidget(
                                  url: store.image,
                                  height: 100,
                                  width: 100,
                                  boxFit: BoxFit.cover,
                                  borderRadius: 8,
                                ),
                                if (store.isDefaultStore == 1)
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: CircleButton(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        heightAndWidth: 40,
                                        child: Icon(
                                          Icons.check,
                                          size: 24,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        onTap: () {}),
                                  )
                              ],
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            SizedBox(
                              width: 100,
                              child: CustomTextContainer(
                                textKey: store.name,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
        staticContent: true);
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
