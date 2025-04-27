import 'package:eshop_pro/data/models/ticket.dart';
import 'package:eshop_pro/data/models/ticketType.dart';
import 'package:eshop_pro/utils/api.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/labelKeys.dart';

class TicketRepository {
  Future<({List<Ticket> tickets, int total})> getTickets({
    int? offset,
  }) async {
    try {
      final result = await Api.get(
          url: Api.getTickets,
          useAuthToken: true,
          queryParameters: {
            Api.limitApiKey: limit,
            Api.offsetApiKey: offset ?? 0,
          });

      return (
        tickets: ((result['data'] ?? []) as List)
            .map((ticket) => Ticket.fromJson(Map.from(ticket ?? {})))
            .toList(),
        total: int.parse((result['total'] ?? 0).toString()),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<List<TicketType>> getTicketTypes() async {
    try {
      final result = await Api.get(
        url: Api.getTicketTypes,
        useAuthToken: true,
      );
      return (result['data'] as List)
          .map((ticketType) => TicketType.fromJson(Map.from(ticketType ?? {})))
          .toList();
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }

  Future<
          ({
            Ticket ticket,
            String successMessage,
          })>
      addOrEditTicket(
          {required Map<String, dynamic> params, required bool isEdit}) async {
    try {
      var result;
      if (isEdit) {
        result = await Api.put(
            url: Api.editTicket, queryParameters: params, useAuthToken: true);
      } else {
        result = await Api.post(
            url: Api.addTicket, body: params, useAuthToken: true);
      }
      return (
        ticket: Ticket.fromJson(Map.from(result['data'] ?? {})),
        successMessage: result['message'].toString(),
      );
    } catch (e) {
      if (e is ApiException) {
        throw ApiException(e.toString());
      } else {
        throw ApiException(defaultErrorMessageKey);
      }
    }
  }
}
