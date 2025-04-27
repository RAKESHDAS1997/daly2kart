import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/category/category_cubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/cubits/storesCubit.dart';
import 'package:eshop_pro/data/models/category.dart';
import 'package:eshop_pro/ui/screens/explore/exploreScreen.dart';
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
import 'package:eshop_pro/utils/utils.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CategoryScreen extends StatefulWidget {
  final bool shouldPop;
  final int? categoryId;
  final int? storeId;

  const CategoryScreen({
    Key? key,
    this.shouldPop = false,
    this.categoryId,
    this.storeId,
  }) : super(key: key);

  static Widget getRouteInstance() => CategoryScreen(
        shouldPop: Get.arguments['shouldPop'] as bool? ?? false,
        categoryId: Get.arguments['categoryId'] as int?,
        storeId: Get.arguments['storeId'] as int?,
      );
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  late SpeechToText _speechToText;
  bool _isListening = false;
  Category? _selectedCategory;
  bool _speechEnabled = false;
  bool _isSearchMode = false;
  late Size size;

  List<Category> categories = [];
  @override
  void initState() {
    _speechToText = SpeechToText();
    if (widget.categoryId != null) {
      getCategories(search: '');
    }
    initializeCategories();
    _initSpeech();
    super.initState();
  }

  getCategories({String? search}) {
    context.read<CategoryCubit>().fetchCategories(
          storeId: widget.storeId ??
              context.read<StoresCubit>().getDefaultStore().id!,
          search: _searchController.text.trim(),
          categoryId: widget.categoryId,
        );
  }

  void loadMoreCategories({String? search}) {
    context.read<CategoryCubit>().loadMore(
        storeId:
            widget.storeId ?? context.read<StoresCubit>().getDefaultStore().id!,
        search: _searchController.text.trim(),
        categoryId: widget.categoryId);
  }

  void initializeCategories() {
    Future.delayed(Duration.zero, () {
      if (context.read<CategoryCubit>().state is CategoryFetchSuccess) {
        final state =
            context.read<CategoryCubit>().state as CategoryFetchSuccess;
        categories = state.categories;
        _selectedCategory = state.categories.first;
        setState(() {});
      }
    });
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
        onStatus: (v) {}, onError: (errorNotification) {});
    if (mounted) setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    if (_speechEnabled) {
      setState(() {
        _isListening = true;
      });
      await _speechToText.listen(onResult: _onSpeechResult);
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _searchController.text = result.recognizedWords;
      getCategories(search: _searchController.text);
    });
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _toggleSearchMode() {
    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        setState(() {
          _searchController.clear();
          getCategories(search: '');
        });
        _stopListening();
      } else {
        FocusScope.of(context).requestFocus(_searchFocusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(context),
      body: buildCategoryList(),
    );
  }

  buildCategoryList() {
    return BlocConsumer<CategoryCubit, CategoryState>(
        listener: (context, state) {
      if (state is CategoryFetchSuccess) {
        categories = state.categories;
        _selectedCategory = state.categories.first;
      }
    }, builder: (context, state) {
      if (state is CategoryFetchSuccess) {
        return RefreshIndicator(
          onRefresh: () async {
            _searchController.clear();
            getCategories(search: '');
          },
          child: LayoutBuilder(builder: (context, boxConstraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  width: boxConstraints.maxWidth * 0.25,
                  child: NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels ==
                          notification.metrics.maxScrollExtent) {
                        if (context.read<CategoryCubit>().hasMore()) {
                          loadMoreCategories();
                        }
                      }
                      return true;
                    },
                    child: ListView.builder(
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        Category category = state.categories[index];
                        if (context.read<CategoryCubit>().hasMore()) {
                          if (index == state.categories.length - 1) {
                            if (context
                                .read<CategoryCubit>()
                                .fetchMoreError()) {
                              return Center(
                                child: CustomTextButton(
                                    buttonTextKey: retryKey,
                                    onTapButton: () {
                                      loadMoreCategories();
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
                        return _buildCategoryContainer(category: category);
                      },
                    ),
                  ),
                ),
                if (_selectedCategory != null)
                  if (_selectedCategory!.children!.isEmpty)
                    Padding(
                        padding: const EdgeInsetsDirectional.only(start: 50),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CustomTextContainer(
                                textKey: noSubCategoriesFoundKey),
                            DesignConfig.smallHeightSizedBox,
                            CustomTextButton(
                                buttonTextKey: gotoproductsKey,
                                textStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decorationColor:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline),
                                onTapButton: () {
                                  Utils.navigateToScreen(
                                      context, Routes.exploreScreen,
                                      arguments: ExploreScreen.buildArguments(
                                          storeId: widget.storeId,
                                          category: _selectedCategory));
                                })
                          ],
                        ))
                  else
                    Container(
                      width: boxConstraints.maxWidth * 0.75,
                      padding: const EdgeInsetsDirectional.all(
                          appContentHorizontalPadding),
                      child: ListView.separated(
                        separatorBuilder: (context, index) =>
                            DesignConfig.defaultHeightSizedBox,
                        itemCount: _selectedCategory!.children!.isNotEmpty
                            ? _selectedCategory!.children!.length
                            : 0,
                        itemBuilder: (context, index) {
                          return _buildSelectedCategoryView(
                            _selectedCategory!.children![index],
                          );
                        },
                      ),
                    ),
              ],
            );
          }),
        );
      }
      if (state is CategoryFetchFailure) {
        return ErrorScreen(text: state.errorMessage, onPressed: getCategories);
      }
      return CustomCircularProgressIndicator(
        indicatorColor: Theme.of(context).colorScheme.primary,
      );
    });
  }

  CustomAppbar buildAppbar(BuildContext context) {
    return CustomAppbar(
      titleKey: categoriesKey,
      showBackButton: widget.shouldPop ? true : false,
      leadingWidget: _isSearchMode || _isListening ? buildSearchField() : null,
      trailingWidget: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(_isSearchMode || _isListening
                ? Icons.close
                : Icons.search_outlined),
            onPressed: _toggleSearchMode,
          ),
          IconButton(
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
    );
  }

  Widget _buildCategoryContainer({
    required Category category,
  }) {
    final isSelected = category == _selectedCategory;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        if (category.children!.isEmpty) {
          Utils.navigateToScreen(context, Routes.exploreScreen,
              arguments: ExploreScreen.buildArguments(category: category));
        }
      },
      child: Stack(
        children: [
          isSelected
              ? Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Container(
                    width: 6.0,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).colorScheme.primary),
                  ),
                )
              : const SizedBox(),
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12, vertical: 8),
            child: Column(
              children: [
                CustomImageWidget(
                  url: category.image,
                  borderRadius: 50,
                  isCircularImage: true,
                ),
                CustomTextContainer(
                    textKey: category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildSelectedCategoryView(Category category) {
    //we will navigate to product screen if there are no children

    return GestureDetector(
      onTap: () {
        if (category.children!.isEmpty) {
          Utils.navigateToScreen(context, Routes.exploreScreen,
              arguments: ExploreScreen.buildArguments(category: category));
        }
      },
      child: CustomDefaultContainer(
          borderRadius: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: CustomTextContainer(
                        textKey: category.name.capitalizeFirst!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ),
                  if (category.children!.length > 6)
                    GestureDetector(
                      onTap: () => Utils.navigateToScreen(
                          context, Routes.subCategoryScreen,
                          arguments: {
                            'category': category,
                          },
                          preventDuplicates: false),
                      child: CustomTextContainer(
                        textKey: seeAllKey,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.67)),
                      ),
                    ),
                ],
              ),
              DesignConfig.defaultHeightSizedBox,
              if (category.children!.isNotEmpty) ...[
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  direction: Axis.horizontal,
                  spacing: 12,
                  runSpacing: appContentHorizontalPadding,
                  children: List.generate(
                      category.children!.length > 6
                          ? 6
                          : category.children!.length,
                      (index) => buildCategory(category.children![index])),
                )
              ] else
                CustomImageWidget(
                  url: category.image,
                  width: 66,
                  height: 75,
                  borderRadius: borderRadius,
                ),
            ],
          )),
    );
  }

  buildCategory(Category category) {
    return SizedBox(
      width: 66,
      height: 125,
      child: GestureDetector(
        onTap: () {
          if (category.children!.isEmpty) {
            Utils.navigateToScreen(context, Routes.exploreScreen,
                arguments: ExploreScreen.buildArguments(category: category));
          } else {
            Utils.navigateToScreen(
              context,
              Routes.subCategoryScreen,
              arguments: {
                'category': category,
              },
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomImageWidget(
              url: category.image,
              width: 66,
              height: 75,
              borderRadius: borderRadius,
            ),
            DesignConfig.smallHeightSizedBox,
            CustomTextContainer(
              textKey: category.name,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }

  buildSearchField() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 40,
      padding:
          const EdgeInsetsDirectional.only(start: appContentHorizontalPadding),
      child: TextFormField(
        controller: _searchController,
        autofocus: true,
        textAlignVertical: TextAlignVertical.center,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          contentPadding: const EdgeInsetsDirectional.symmetric(horizontal: 15),
          hintText: context
              .read<SettingsAndLanguagesCubit>()
              .getTranslatedValue(labelKey: searchCategoryKey),
          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.67)),
        ),
        onChanged: (value) {
          getCategories(search: _searchController.text);
        },
      ),
    );
  }
}
