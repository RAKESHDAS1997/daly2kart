import 'package:eshop_pro/data/models/address.dart';
import 'package:eshop_pro/data/repositories/addressRepository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GetAddressState {}

class GetAddressInitial extends GetAddressState {}

class GetAddressFetchInProgress extends GetAddressState {}

class GetAddressFetchSuccess extends GetAddressState {
  final List<Address> addresses;

  GetAddressFetchSuccess(this.addresses);
}

class GetAddressFetchFailure extends GetAddressState {
  final String errorMessage;

  GetAddressFetchFailure(this.errorMessage);
}

class GetAddressCubit extends Cubit<GetAddressState> {
  final AddressRepository _addressRepository = AddressRepository();

  GetAddressCubit() : super(GetAddressInitial());

  void getAddress() {
    emit(GetAddressFetchInProgress());

    _addressRepository
        .getAddress()
        .then((value) => emit(GetAddressFetchSuccess(value)))
        .catchError((e) {
      emit(GetAddressFetchFailure(e.toString()));
    });
  }

  emitSuccessState(List<Address> addresses) {
    emit(GetAddressFetchSuccess(addresses));
  }

  List getAddressList() {
    if (state is GetAddressFetchSuccess) {
      return (state as GetAddressFetchSuccess).addresses;
    }
    return [];
  }
}
