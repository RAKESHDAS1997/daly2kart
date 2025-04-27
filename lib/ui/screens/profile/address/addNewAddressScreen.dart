import 'package:eshop_pro/cubits/address/addNewAddressCubit.dart';
import 'package:eshop_pro/cubits/address/cityCubit.dart';
import 'package:eshop_pro/data/models/address.dart';
import 'package:eshop_pro/data/models/zipcode.dart';
import 'package:eshop_pro/ui/widgets/customBottomButtonContainer.dart';
import 'package:eshop_pro/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../../app/routes.dart';
import '../../../../cubits/address/getAddressCubit.dart';
import '../../../../cubits/address/zipcodeCubit.dart';
import '../../../../data/models/city.dart';
import '../../../../utils/api.dart';
import '../../../../utils/validator.dart';
import '../../../widgets/customAppbar.dart';
import '../../../widgets/customDefaultContainer.dart';
import '../../../widgets/customTextFieldContainer.dart';

class AddNewAddressScreen extends StatefulWidget {
  final GetAddressCubit getAddressCubit;
  final bool isEditScreen;
  final Address? address;
  const AddNewAddressScreen(
      {Key? key,
      required this.getAddressCubit,
      required this.isEditScreen,
      required this.address})
      : super(key: key);
  static Widget getRouteInstance() {
    final arguments = Get.arguments as Map<String, dynamic>;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AddNewAddressCubit(),
        ),
        BlocProvider(
          create: (context) => CityCubit(),
        ),
        BlocProvider(
          create: (context) => ZipcodeCubit(),
        ),
      ],
      child: AddNewAddressScreen(
          getAddressCubit: arguments['bloc'] as GetAddressCubit,
          isEditScreen: arguments['isEditScreen'] as bool, 
          address: arguments['address'] as Address?),
    );
  }

  @override
  _AddNewAddressScreenState createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  bool _isDefaultAddress = false;
  String _selectedAddressType = 'home';
  bool _setCityFirstTime = true, _setZipcodeFirstTime = true;
  final _formKey = GlobalKey<FormState>();
  Map<String, TextEditingController> controllers = {};
  Map<String, FocusNode> focusNodes = {};
  bool serviceEnabled = false;
  City? _selectedCity;
  Zipcode? _selectedZipcode;
  bool _isLoading = false;
  final List formFields = [
    nameKey,
    mobileNumberKey,
    addressKey,
    stateKey,
    selectCityKey,
    selectPincodeKey,
    areaNameKey,
    latitudeKey,
    longitudeKey,
    searchCityKey,
    searchPincodeKey
  ];
  @override
  void initState() {
    super.initState();
    formFields.forEach((key) {
      controllers[key] = TextEditingController();
      focusNodes[key] = FocusNode();
    });
    Future.delayed(Duration.zero, () {
      context.read<CityCubit>().getCities();
    });
    setFieldValues();
  }

  setFieldValues() {
    if (widget.isEditScreen) {
      controllers[nameKey]!.text = widget.address!.name!;
      controllers[mobileNumberKey]!.text = widget.address!.mobile!;
      controllers[addressKey]!.text = widget.address!.address!;
      controllers[stateKey]!.text = widget.address!.state!;
      controllers[selectCityKey]!.text = widget.address!.city!;
      controllers[areaNameKey]!.text = widget.address!.area!;
      controllers[selectPincodeKey]!.text = widget.address!.pincode!;
      controllers[latitudeKey]!.text = widget.address!.latitude.toString();
      controllers[longitudeKey]!.text = widget.address!.longitude.toString();
      _selectedAddressType = widget.address!.type!;
      _isDefaultAddress = widget.address!.isDefault == 1 ? true : false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    focusNodes.forEach((key, focusNode) {
      focusNode.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppbar(titleKey: myAddressDetailsKey),
        bottomNavigationBar: buildSaveButton(),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AddNewAddressCubit, AddNewAddressState>(
              listener: (context, state) {
                if (state is AddNewAddressFetchSuccess) {
                  List<Address> addresses = [];
                  if (widget.getAddressCubit.state is GetAddressFetchSuccess) {
                    addresses =
                        (widget.getAddressCubit.state as GetAddressFetchSuccess)
                            .addresses;
                  }
                  // If the new or edited address is set as default
                  if (state.address.isDefault == 1) {
                    // Find the current default address and set its is_default to 0
                    final defaultIndex = addresses
                        .indexWhere((element) => element.isDefault == 1);
                    if (defaultIndex != -1) {
                      addresses[defaultIndex] =
                          addresses[defaultIndex].copyWith(isDefault: 0);
                    }
                  }
                  final index = addresses
                      .indexWhere((element) => element.id == state.address.id);

                  if (index != -1) {
                    addresses[index] = state.address;
                  } else {
                    addresses.insert(0, state.address);
                  }
                  widget.getAddressCubit.emitSuccessState(addresses);

                  // to do..doest show snackbar and thats why not popup screen
                  Utils.showSnackBar(
                      message: state.successMessage, context: context);
                  Navigator.of(context).pop();
                }

                if (state is AddNewAddressFetchFailure) {
                  Utils.showSnackBar(
                      message: state.errorMessage, context: context);
                }
              },
            ),
            BlocListener<CityCubit, CityState>(
              listener: (context, state) {
                if (state is CityFetchSuccess &&
                    widget.isEditScreen &&
                    _setCityFirstTime) {
                  setState(() {
                    _selectedCity = state.cities.firstWhereOrNull(
                      (element) => element.id == widget.address!.cityId,
                    );
                    context
                        .read<ZipcodeCubit>()
                        .getZipcodes(cityId: widget.address!.cityId);
                    _setCityFirstTime = false;
                  });
                }
              },
            ),
            BlocListener<ZipcodeCubit, ZipcodeState>(
              listener: (context, state) {
                if (state is ZipcodeFetchSuccess &&
                    widget.isEditScreen &&
                    _setZipcodeFirstTime) {
                  setState(() {
                    _selectedZipcode = state.zipcodes.firstWhereOrNull(
                      (element) => element.zipcode == widget.address!.pincode,
                    );

                    _setZipcodeFirstTime = false;
                  });
                }
              },
            ),
          ],
          child: buildForm(),
        ));
  }

  Padding buildForm() {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
          vertical: 12, horizontal: appContentHorizontalPadding),
      child: CustomDefaultContainer(
        borderRadius: 8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CustomTextFieldContainer(
                  hintTextKey: nameKey,
                  textEditingController: controllers[nameKey]!,
                  focusNode: focusNodes[nameKey],
                  textInputAction: TextInputAction.next,
                  isFieldValueMandatory: true,
                  validator: (v) => Validator.emptyValueValidation(context, v),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[mobileNumberKey]);
                  },
                ),
                CustomTextFieldContainer(
                  hintTextKey: mobileNumberKey,
                  textEditingController: controllers[mobileNumberKey]!,
                  focusNode: focusNodes[mobileNumberKey],
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Allow only digits
                    LengthLimitingTextInputFormatter(15), // Limit to 15 digits
                  ],
                  validator: (v) => Validator.validatePhoneNumber(v, context),
                  isFieldValueMandatory: true,
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNodes[addressKey]);
                  },
                ),
                CustomTextFieldContainer(
                  hintTextKey: addressKey,
                  textEditingController: controllers[addressKey]!,
                  focusNode: focusNodes[addressKey],
                  textInputAction: TextInputAction.next,
                  isFieldValueMandatory: true,
                  validator: (v) => Validator.emptyValueValidation(context, v),
                  suffixWidget: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CustomCircularProgressIndicator(
                            indicatorColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.my_location_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          onPressed: () async {
                            if (!_isLoading) {
                              setState(() {
                                _isLoading = true;
                              });
                              serviceEnabled =
                                  await Geolocator.isLocationServiceEnabled();
                              if (!serviceEnabled) {
                                // Location services are not enabled don't continue
                                // accessing the position and request users of the
                                // App to enable the location services.
                                Utils.showSnackBar(
                                    message: 'Location services are disabled.',
                                    context: context);
                                await Geolocator.openLocationSettings();
                                return;
                              }
                              LocationPermission permission;

                              permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission =
                                    await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied) {
                                  return Utils.showSnackBar(
                                      message:
                                          'Location services are disabled.',
                                      context: context);
                                }
                              }
                              if (permission ==
                                  LocationPermission.deniedForever) {
                                // Permissions are denied forever, handle appropriately.
                                return Utils.showSnackBar(
                                    message:
                                        'Location permissions are permanently denied, we cannot request permissions.',
                                    context: context);
                              }

                              Position position =
                                  await Geolocator.getCurrentPosition(
                                locationSettings: LocationSettings(
                                    accuracy: LocationAccuracy.high),
                              );

                              var result = await Utils.navigateToScreen(
                                  context, Routes.mapScreen,
                                  arguments: {
                                    latitudeKey: widget.isEditScreen &&
                                            (widget.address!.latitude != 0)
                                        ? widget.address!.latitude
                                        : position.latitude,
                                    longitudeKey: widget.isEditScreen &&
                                            (widget.address!.longitude != 0)
                                        ? widget.address!.longitude
                                        : position.longitude,
                                  });
                              if (mounted)
                                setState(() {
                                  _isLoading = false;
                                });

                              if (result != null) {
                                List<Placemark> placemark =
                                    await placemarkFromCoordinates(
                                  double.parse(result[latitudeKey]),
                                  double.parse(result[longitudeKey]),
                                );

                                var address;
                                address = placemark[0].name;
                                if (placemark[0].street != placemark[0].name) {
                                  address = address + ',' + placemark[0].street;
                                }
                                address =
                                    address + ',' + placemark[0].subLocality;
                                address = address + ',' + placemark[0].locality;

                                if (mounted) {
                                  setState(
                                    () {
                                      controllers[addressKey]!.text = address;
                                      controllers[stateKey]!.text =
                                          placemark[0].administrativeArea ?? '';
                                      controllers[latitudeKey]!.text =
                                          result[latitudeKey];
                                      controllers[longitudeKey]!.text =
                                          result[longitudeKey];
                                    },
                                  );
                                }
                              }
                            }
                          },
                        ),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context).requestFocus(focusNodes[stateKey]);
                  },
                ),
                CustomTextFieldContainer(
                  hintTextKey: stateKey,
                  textEditingController: controllers[stateKey]!,
                  focusNode: focusNodes[stateKey],
                  textInputAction: TextInputAction.next,
                  isFieldValueMandatory: true,
                  validator: (v) => Validator.emptyValueValidation(context, v),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[selectCityKey]);
                  },
                ),
                CustomTextFieldContainer(
                  readOnly: true,
                  hintTextKey: selectCityKey,
                  textEditingController: controllers[selectCityKey]!,
                  focusNode: focusNodes[selectCityKey],
                  textInputAction: TextInputAction.next,
                  isFieldValueMandatory: true,
                  validator: (v) => Validator.emptyValueValidation(context, v),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[areaNameKey]);
                  },
                  onTap: () => selectCityBottomsheet(context,
                      context.read<CityCubit>(), context.read<ZipcodeCubit>()),
                ),
                CustomTextFieldContainer(
                  hintTextKey: areaNameKey,
                  textEditingController: controllers[areaNameKey]!,
                  focusNode: focusNodes[areaNameKey],
                  textInputAction: TextInputAction.next,
                  isFieldValueMandatory: true,
                  validator: (v) => Validator.emptyValueValidation(context, v),
                  onFieldSubmitted: (v) {
                    FocusScope.of(context)
                        .requestFocus(focusNodes[selectPincodeKey]);
                  },
                ),
                CustomTextFieldContainer(
                  readOnly: true,
                  hintTextKey: selectPincodeKey,
                  textEditingController: controllers[selectPincodeKey]!,
                  focusNode: focusNodes[selectPincodeKey],
                  textInputAction: TextInputAction.done,
                  isFieldValueMandatory: true,
                  validator: (v) => Validator.emptyValueValidation(context, v),
                  onFieldSubmitted: (v) {
                    focusNodes[selectPincodeKey]!.unfocus();
                  },
                  onTap: () {
                    if (_selectedCity == null) {
                      Utils.showSnackBar(
                          message: pleaseSelectCityKey, context: context);
                      return;
                    }
                    selectZipcodeBottomsheet(
                        context, context.read<ZipcodeCubit>());
                  },
                ),
                DesignConfig.smallHeightSizedBox,
                CustomTextContainer(
                  textKey: saveThisAddressAsKey,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    buildRadioTile(homeKey, 'home'),
                    buildRadioTile(officeKey, 'office'),
                    buildRadioTile(otherKey, 'others'),
                  ],
                ),
                DesignConfig.smallHeightSizedBox,
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isDefaultAddress = !_isDefaultAddress;
                    });
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        visualDensity:
                            const VisualDensity(vertical: -4, horizontal: -4),
                        value: _isDefaultAddress,
                        onChanged: (value) {
                          setState(() {
                            _isDefaultAddress = value!;
                          });
                        },
                      ),
                      CustomTextContainer(
                        textKey: saveAddressAsDefaultKey,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  buildRadioTile(String title, String value) {
    return Expanded(
        child: GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressType = value;
        });
      },
      child: Row(
        children: <Widget>[
          Radio(
            value: value,
            groupValue: _selectedAddressType,
            onChanged: (value) {
              setState(() {
                _selectedAddressType = value!;
              });
            },
          ),
          CustomTextContainer(
              textKey: title, style: Theme.of(context).textTheme.bodyMedium)
        ],
      ),
    ));
  }

  buildSaveButton() {
    return BlocBuilder<AddNewAddressCubit, AddNewAddressState>(
      builder: (context, state) {
        return CustomBottomButtonContainer(
            child: CustomRoundedButton(
          widthPercentage: 1.0,
          buttonTitle: saveAddressKey,
          showBorder: false,
          child: state is AddNewAddressFetchInProgress
              ? const CustomCircularProgressIndicator()
              : null,
          onTap: () {
            if (_formKey.currentState!.validate()) {
              if (state is AddNewAddressFetchInProgress) {
                return;
              }

              FocusScope.of(context).unfocus();
              Map<String, dynamic> params = {
                Api.nameApiKey: controllers[nameKey]!.text.trim(),
                Api.mobileApiKey: controllers[mobileNumberKey]!.text.trim(),
                Api.addressApiKey: controllers[addressKey]!.text.trim(),
                Api.stateApiKey: controllers[stateKey]!.text.trim(),
                Api.cityNameApiKey: _selectedCity?.name,
                Api.cityIdApiKey: _selectedCity?.id,
                Api.areaNameApiKey: controllers[areaNameKey]!.text.trim(),
                Api.typeApiKey: _selectedAddressType,
                Api.isDefaultAddressApiKey: _isDefaultAddress ? 1 : 0,
                Api.latitudeApiKey: controllers[latitudeKey]!.text.trim(),
                Api.longitudeApiKey: controllers[longitudeKey]!.text.trim()
              };
              if (_selectedZipcode != null) {
                params.addAll({Api.pincodeApiKey: _selectedZipcode?.zipcode});
              } else {
                params.addAll({
                  Api.pincodeNameApiKey:
                      controllers[selectPincodeKey]!.text.trim()
                });
              }
              if (widget.isEditScreen) {
                params.addAll({Api.idApiKey: widget.address!.id});
              }
              if (controllers[latitudeKey]!.text.trim() != '') {
                params.addAll({
                  Api.latitudeApiKey: controllers[latitudeKey]!.text.trim()
                });
              }
              if (controllers[longitudeKey]!.text.trim() != '') {
                params.addAll({
                  Api.longitudeApiKey: controllers[longitudeKey]!.text.trim()
                });
              }
              context.read<AddNewAddressCubit>().addAddress(params: params);
            }
          },
        ));
      },
    );
  }

  selectCityBottomsheet(BuildContext buildContext, CityCubit cityCubit,
      ZipcodeCubit zipcodeCubit) {
    return Utils.openModalBottomSheet(buildContext,
            StatefulBuilder(builder: (context, StateSetter setState) {
      return BlocConsumer<CityCubit, CityState>(
        bloc: cityCubit,
        listener: (context, state) {},
        builder: (context, state) {
          return Container(
              height: MediaQuery.of(buildContext).size.height,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: appContentHorizontalPadding,
              ),
              child: Column(
                children: [
                  CustomTextFieldContainer(
                    hintTextKey: searchCityKey,
                    textEditingController: controllers[searchCityKey]!,
                    onChanged: (value) => cityCubit.getCities(
                        search: controllers[searchCityKey]!.text.trim()),
                    suffixWidget: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                              onTap: () => cityCubit.getCities(
                                  search:
                                      controllers[searchCityKey]!.text.trim()),
                              child: const Icon(Icons.search_outlined)),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  controllers[searchCityKey]!.clear();
                                  cityCubit.getCities(search: '');
                                });
                              },
                              child: const Icon(Icons.close)),
                        ],
                      ),
                    ),
                  ),
                  DesignConfig.smallHeightSizedBox,
                  state is CityFetchSuccess
                      ? Expanded(
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: state.cities.length,
                            itemBuilder: (_, index) {
                              City city = state.cities[index];
                              return buildTile(
                                  _selectedCity != null
                                      ? _selectedCity!.id == city.id
                                      : false,
                                  city.name!, () {
                                setState(() {
                                  _selectedCity = city;
                                  controllers[selectCityKey]!.text = city.name!;
                                  controllers[selectPincodeKey]!.clear();
                                  _selectedZipcode = null;
                                  zipcodeCubit.getZipcodes(cityId: city.id);
                                  Navigator.of(context).pop();
                                });
                              });
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return const SizedBox(height: 2);
                            },
                          ),
                        )
                      : state is CityFetchFailure
                          ? const Center(
                              child: CustomTextContainer(
                                  textKey: dataNotAvailableKey))
                          : CustomCircularProgressIndicator(
                              indicatorColor:
                                  Theme.of(context).colorScheme.primary)
                ],
              ));
        },
      );
    }), staticContent: false, isScrollControlled: true)
        .then((value) {
   
    });
  }

  selectZipcodeBottomsheet(
      BuildContext buildContext, ZipcodeCubit zipcodeCubit) {
    return Utils.openModalBottomSheet(buildContext,
        StatefulBuilder(builder: (context, StateSetter setState) {
      return BlocBuilder<ZipcodeCubit, ZipcodeState>(
          bloc: zipcodeCubit,
          builder: (context, state) {
            return Container(
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: appContentHorizontalPadding,
                ),
                child: Column(
                  children: [
                    //search will use for only shiprocket system
                    /*  CustomTextFieldContainer(
                      hintTextKey: searchPincodeKey,
                      textEditingController: controllers[searchPincodeKey]!,
                      onChanged: (value) => zipcodeCubit.getZipcodes(
                          search: controllers[searchPincodeKey]!.text.trim(),
                          cityId: _selectedCity!.id),
                      suffixWidget: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                                onTap: () => zipcodeCubit.getZipcodes(
                                    search: controllers[searchPincodeKey]!
                                        .text
                                        .trim(),
                                    cityId: _selectedCity!.id),
                                child: const Icon(Icons.search_outlined)),
                            GestureDetector(
                                onTap: () {
                                  setState(() {
                                    controllers[searchPincodeKey]!.clear();
                                    zipcodeCubit.getZipcodes(
                                        search: '', cityId: _selectedCity!.id);
                                  });
                                },
                                child: const Icon(Icons.close)),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: CustomTextContainer(
                            textKey: addZipcodeManuallyKey,
                            maxLines: 3,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        DesignConfig.smallWidthSizedBox,
                        CustomTextButton(
                            buttonTextKey: addKey,
                            textStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                            onTapButton: () {
                              if (controllers[searchPincodeKey]!
                                  .text
                                  .trim()
                                  .isEmpty) {
                                Utils.showSnackBar(
                                    message: emptyValueErrorMessageKey,
                                    context: context);
                                return;
                              }
                              controllers[selectPincodeKey]!.text =
                                  controllers[searchPincodeKey]!.text;
                              _selectedZipcode = null;
                              Navigator.of(context).pop();
                            })
                      ],
                    ), */
                    DesignConfig.smallHeightSizedBox,
                    state is ZipcodeFetchSuccess
                        ? Expanded(
                            child: ListView.separated(
                      
                              shrinkWrap: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: state.zipcodes.length,
                              itemBuilder: (_, index) {
                                Zipcode zipcode = state.zipcodes[index];
                                return buildTile(
                                    _selectedZipcode != null
                                        ? _selectedZipcode!.id == zipcode.id
                                        : false,
                                    zipcode.zipcode!, () {
                                  setState(() {
                                    _selectedZipcode = zipcode;
                                    controllers[selectPincodeKey]!.text =
                                        zipcode.zipcode!;

                                    Navigator.of(context).pop();
                                  });
                                });
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const SizedBox(height: 2);
                              },
                            ),
                          )
                        : state is ZipcodeFetchFailure
                            ? const Center(
                                child: CustomTextContainer(
                                    textKey: dataNotAvailableKey))
                            : CustomCircularProgressIndicator(
                                indicatorColor:
                                    Theme.of(context).colorScheme.primary)
                  ],
                ));
          });
    }), staticContent: false, isScrollControlled: true);
  }

  buildTile(bool isSelected, String title, VoidCallback onTap) {
    return ListTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        title: CustomTextContainer(
          textKey: title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.black,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              letterSpacing: 0.5),
        ),
        tileColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        onTap: onTap,
        trailing: isSelected
            ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
            : null);
  }
}
