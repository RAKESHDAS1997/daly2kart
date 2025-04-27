import 'package:eshop_pro/cubits/favorites/addFavoriteCubit.dart';
import 'package:eshop_pro/cubits/favorites/getFavoriteCubit.dart';
import 'package:eshop_pro/cubits/favorites/removeFavoriteCubit.dart';
import 'package:eshop_pro/cubits/user_details_cubit.dart';
import 'package:eshop_pro/data/models/offlineFavorite.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/models/seller.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatelessWidget {
  final Product? product;
  final Seller? seller;
  final Color? unFavoriteColor;
  final Color? favoriteColor;
  final double? size;
  final bool isSeller;
  final int? sellerId;
  const FavoriteButton({
    super.key,
    this.product,
    this.seller,
    this.favoriteColor,
    this.unFavoriteColor,
    this.size = 24,
    this.isSeller = false,
    this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        return BlocConsumer<RemoveFavoriteCubit, RemoveFavoriteState>(
            listener: (context, state) {
          if (state is RemoveFavoriteSuccess) {
            if (product != null && product!.id == state.id) {
              product!.setFavoriteProduct(false);
            
            }
            if (seller != null && seller!.sellerId == state.id) {
              seller!.setFavoriteSeller(false);
            }
         
          }
        }, builder: (context, state) {
          return BlocConsumer<AddFavoriteCubit, AddFavoriteState>(
            listener: (context, state) {
              if (state is AddFavoriteSuccess) {
                if (product != null && product!.id == state.id) {
                  product!.setFavoriteProduct(true);
         
                }
                if (seller != null && seller!.sellerId == state.id) {
                  seller!.setFavoriteSeller(true);
                }
              }
            },
            builder: (context, state) {
              return GestureDetector(
                onTap: () {
                  if (product != null &&
                      product!.isFavoriteProduct(context, product!.type!)) {
                    context
                        .read<RemoveFavoriteCubit>()
                        .removeFavorite(context: context, params: {
                      Api.isSellerApiKey: 0,
                      Api.productIdApiKey: product!.id,
                      Api.productTypeApiKey: product!.type == comboProductType
                          ? 'combo'
                          : 'regular',
                    }, products: [
                      product!
                    ]);
                  } else if (seller != null &&
                      seller!.isFavoriteSeller(context)) {
                    context
                        .read<RemoveFavoriteCubit>()
                        .removeFavorite(context: context, params: {
                      Api.isSellerApiKey: 1,
                      Api.sellerIdApiKey: seller!.sellerId,
                    }, sellers: [
                      seller!
                    ]);
                  } else {
                    if (state is! AddFavoriteProgress) {
                      context.read<AddFavoriteCubit>().addToFavorites(
                            context: context,
                            favorite: context
                                    .read<UserDetailsCubit>()
                                    .isGuestUser()
                                ? OfflineFavorite(
                                    id: isSeller == true
                                        ? sellerId!
                                        : product!.id!,
                                    productType: isSeller == true
                                        ? ''
                                        : product!.type == comboProductType
                                            ? 'combo'
                                            : 'regular',
                                    type:
                                        isSeller == true ? 'seller' : 'product')
                                : null,
                            params: isSeller == true
                                ? {
                                    Api.isSellerApiKey: 1,
                                    Api.sellerIdApiKey: sellerId,
                                  }
                                : {
                                    Api.isSellerApiKey: 0,
                                    Api.productIdApiKey: product!.id,
                                    Api.productTypeApiKey:
                                        product!.type == comboProductType
                                            ? 'combo'
                                            : 'regular',
                                  },
                            products: product != null ? [product!] : null,
                            sellers: seller != null ? [seller!] : null,
                          );
                    }
                  }
                },
                child: Container(
                  width: size ?? 24,
                  height: size ?? 24,
                  padding: const EdgeInsetsDirectional.all(4),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.transparent),
                      color: Theme.of(context).colorScheme.onPrimary),
                  child: product != null
                      ? Icon(
                          product!.isFavoriteProduct(context, product!.type!)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: product!
                                  .isFavoriteProduct(context, product!.type!)
                              ? favoriteColor ??
                                  Theme.of(context).colorScheme.primary
                              : unFavoriteColor ??
                                  Theme.of(context).colorScheme.secondary,
                          size: (size ?? 24) * 0.6,
                        )
                      : seller != null
                          ? Icon(
                              seller!.isFavoriteSeller(context)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: seller!.isFavoriteSeller(context)
                                  ? favoriteColor ??
                                      Theme.of(context).colorScheme.primary
                                  : unFavoriteColor ??
                                      Theme.of(context).colorScheme.secondary,
                              size: (size ?? 24) * 0.6,
                            )
                          : const SizedBox.shrink(),
                ),
              );
            },
          );
        });
      },
    );
  }
}
