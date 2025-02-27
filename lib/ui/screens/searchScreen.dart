import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/product/mostSearchedProductCubit.dart';
import 'package:eshop_pro/cubits/product/productsCubit.dart';
import 'package:eshop_pro/cubits/product/searchProductCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/product.dart';
import 'package:eshop_pro/data/models/searchedProduct.dart';
import 'package:eshop_pro/data/repositories/productRepository.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/productDetailsScreen.dart';
import 'package:eshop_pro/ui/screens/explore/productDetails/widgets/frequentlyWatchedProductsContainer.dart';

import 'package:eshop_pro/ui/widgets/customDefaultContainer.dart';
import 'package:eshop_pro/ui/widgets/customImageWidget.dart';
import 'package:eshop_pro/ui/widgets/customSearchContainer.dart';

import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SearchScreen extends StatefulWidget {
  String searchText = '';
  SearchScreen({super.key, this.searchText = ''});
  static Widget getRouteInstance() => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SearchProductCubit(),
          ),
          BlocProvider(
            create: (context) => MostSearchedProductCubit(),
          ),
          BlocProvider(
            create: (context) => ProductsCubit(),
          ),
        ],
        child: SearchScreen(
          searchText: Get.arguments ?? '',
        ),
      );

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  late SpeechToText _speechToText;

  /// we will use this param to decide whether to navigate to explore screen or not ..because when we are typing then we will not redirect to explore screen
  bool _nabvigateToExploreScreen = false;

  bool _isListening = false;

  bool _speechEnabled = false;
  List recentSearches = [];
  FocusNode _searchFocusNode = FocusNode();
  String _lastWords = '';

  @override
  void initState() {
    super.initState();

    _speechToText = SpeechToText();
    recentSearches = ProductRepository().getSearchHistory();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (widget.searchText.isNotEmpty) {
          _searchController.text = widget.searchText;
          FocusScope.of(context).requestFocus(_searchFocusNode);
        }
        context.read<MostSearchedProductCubit>().getMostSearchedProducts(
            storeId: context.read<StoresCubit>().getDefaultStore().id!);
      }
    });
    _initSpeech();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
        onStatus: (v) {}, onError: (errorNotification) {});
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(onResult: _onSpeechResult);
      setState(() {
        _isListening = true;
      });
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _searchController.text = _lastWords;
    });
    getProducts();
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  getProducts() {
    context.read<SearchProductCubit>().searchProducts(
        storeId: context.read<StoresCubit>().getDefaultStore().id!,
        query: _searchController.text);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(context),
      body: BlocListener<ProductsCubit, ProductsState>(
        listener: (context, state) {
          if (state is ProductsFetchSuccess) {
            Utils.navigateToScreen(context, Routes.productDetailsScreen,
                arguments: state.products[0].type == comboProductType
                    ? ProductDetailsScreen.buildArguments(
                        product: state.products[0], isComboProduct: true)
                    : ProductDetailsScreen.buildArguments(
                        product: state.products[0],
                      ));
          }
          if (state is ProductsFetchFailure) {
            Utils.showSnackBar(context: context, message: state.errorMessage);
          }
        },
        child: BlocBuilder<SearchProductCubit, SearchProductState>(
          builder: (context, state) {
            if (state is SearchProductFetchSuccess &&
                _searchController.text.isNotEmpty) {
              return Column(
                children: [
                  Expanded(
                      child: ListView.separated(
                          separatorBuilder: (context, index) =>
                              DesignConfig.smallHeightSizedBox,
                          shrinkWrap: true,
                          padding:
                              const EdgeInsets.all(appContentHorizontalPadding),
                          itemCount: state.searchProducts.length,
                          itemBuilder: (context, index) {
                            final product = state.searchProducts[index];
                            return GestureDetector(
                                onTap: () {
                                  addToRecentSearches();
                                  context.read<ProductsCubit>().getProducts(
                                      storeId: context
                                          .read<StoresCubit>()
                                          .getDefaultStore()
                                          .id!,
                                      isComboProduct:
                                          product.type == 'combo_products'
                                              ? true
                                              : false,
                                      productIds: [product.productId!]);
                                },
                                child: CustomDefaultContainer(
                                    borderRadius: 8,
                                    child: Row(
                                      children: <Widget>[
                                        CustomImageWidget(
                                          url: product.productImage!,
                                          height: 80,
                                          width: 80,
                                          borderRadius: 4,
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              CustomTextContainer(
                                                textKey:
                                                    product.productName ?? '',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                                maxLines: 2,
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              if (product.categoryName !=
                                                      null &&
                                                  product
                                                      .categoryName!.isNotEmpty)
                                                CustomTextContainer(
                                                  textKey:
                                                      'In ${product.categoryName}',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )));
                          })),
                ],
              );
            }
            return ListView(
              children: [
                DesignConfig.smallHeightSizedBox,
                if (recentSearches.isNotEmpty) ...[
                  _buildRecentSearches(),
                  DesignConfig.smallHeightSizedBox,
                ],
                _buildMostSearched(),
                BlocProvider(
                  create: (context) => ProductsCubit(),
                  child: const FrequentlyWatchedProductsContainer(),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  addToRecentSearches() {
    ProductRepository().addSearchInLocalHistory(_searchController.text.trim());
    if (!recentSearches.contains(_searchController.text.trim())) {
      if (recentSearches.length == maxSearchHistory) {
        recentSearches.removeAt(recentSearches.length - 1);
      }
      recentSearches.insert(0, _searchController.text.trim());
    }
  }

  AppBar buildAppbar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      surfaceTintColor: Colors.white,
      toolbarHeight: kToolbarHeight + MediaQuery.of(context).padding.top,
      title: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: appContentHorizontalPadding),
        child: BlocBuilder<SearchProductCubit, SearchProductState>(
          builder: (context, state) {
            return CustomSearchContainer(
              textEditingController: _searchController,
              focusNode: _searchFocusNode,
              prefixWidget: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).colorScheme.secondary,
                  )),
              onVoiceIconTap: _startVoiceRecognition,
              showVoiceIcon: false,
              suffixWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          context.read<SearchProductCubit>().resetState();
                        });
                      },
                    ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                ],
              ),
              onChanged: (value) {
                setState(() {});
                getProducts();
              },
              onFieldSubmitted: (p0) {
                addToRecentSearches();
                if (state is SearchProductFetchSuccess) {
                  navigatoToExploreScreen(state);
                }
              },
            );
          },
        ),
      ),
    );
  }

  navigatoToExploreScreen(SearchProductFetchSuccess state) {
    List<SearchedProduct> regularProducts = state.searchProducts
        .where((element) => element.type == 'products')
        .toList();
    List<SearchedProduct> comboProducts = state.searchProducts
        .where((element) => element.type == 'combo_products')
        .toList();
    Utils.navigateToScreen(context, Routes.exploreScreen,
            arguments: ExploreScreen.buildArguments(
                title: _searchController.text,
                productIds: regularProducts.map((e) => e.productId!).toList(),
                comboProductIds: comboProducts.isNotEmpty
                    ? comboProducts.map((e) => e.productId!).toList()
                    : [],
                fromSearchScreen: true),
            replacePrevious: true)!
        .then((value) => setState(() {
              _nabvigateToExploreScreen = true;
            }));
  }

  _buildRecentSearches() {
    return BlocListener<SearchProductCubit, SearchProductState>(
      listener: (context, state) {
        if (state is SearchProductFetchSuccess) {
          if (_nabvigateToExploreScreen) {
            navigatoToExploreScreen(state);
          }
        }
      },
      child: CustomDefaultContainer(
          child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              CustomTextContainer(
                textKey: recentSearchesKey,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              TextButton(
                onPressed: _clearRecentSearches,
                child: CustomTextContainer(
                    textKey: clearKey,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.67))),
              )
            ],
          ),
          Column(
            children: recentSearches
                .map((search) => ListTile(
                      visualDensity: const VisualDensity(vertical: -2),
                      leading: const Icon(Icons.history),
                      title: Text(search),
                      trailing: IconButton(
                          icon: const Icon(Icons.north_west),
                          onPressed: () {
                            _searchController.text = search;
                            FocusScope.of(context).requestFocus();
                          }),
                      onTap: () {
                        // Implement search based on recent search
                        _searchController.text = search;
                        FocusScope.of(context).unfocus();
                        getProducts();
                        setState(() {
                          _nabvigateToExploreScreen = true;
                        });
                      },
                    ))
                .toList(),
          )
        ],
      )),
    );
  }

  void _clearRecentSearches() {
    setState(() {
      recentSearches.clear();
      ProductRepository().clearSearchHistory();
    });
  }

  void _startVoiceRecognition() {
    // Implement voice recognition
  }

  _buildMostSearched() {
    return BlocBuilder<MostSearchedProductCubit, MostSearchedProductState>(
      builder: (context, state) {
        if (state is MostSearchedProductFetchSuccess) {
          return CustomDefaultContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextContainer(
                  textKey: mostSearchedKey,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                DesignConfig.defaultHeightSizedBox,
                Wrap(
                  spacing: appContentHorizontalPadding,
                  runSpacing: appContentHorizontalPadding,
                  children: state.searchHistory
                      .map((text) => GestureDetector(
                            onTap: () {
                              _searchController.text = text;
                              FocusScope.of(context).unfocus();
                              getProducts();
                            },
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 0.5)),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.trending_up,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    DesignConfig.smallWidthSizedBox,
                                    CustomTextContainer(
                                      textKey: text,
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    )
                                  ],
                                )),
                          ))
                      .toList(),
                ),
              ],
            ),
          );
        }
        // if (state is MostSearchedProductFetchInProgress) {
        //   return CustomCircularProgressIndicator(
        //     indicatorColor: Theme.of(context).colorScheme.primary,
        //   );
        // }
        return const SizedBox.shrink();
      },
    );
  }
}
