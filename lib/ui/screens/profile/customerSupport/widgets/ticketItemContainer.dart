import 'package:eshop_pro/app/routes.dart';
import 'package:eshop_pro/cubits/customerSupport/getTicketCubit.dart';
import 'package:eshop_pro/cubits/settingsAndLanguagesCubit.dart';
import 'package:eshop_pro/data/models/ticket.dart';
import 'package:eshop_pro/ui/widgets/customRoundedButton.dart';
import 'package:eshop_pro/ui/widgets/customStatusContainer.dart';
import 'package:eshop_pro/ui/widgets/customTextContainer.dart';
import 'package:eshop_pro/utils/constants.dart';
import 'package:eshop_pro/utils/designConfig.dart';
import 'package:eshop_pro/utils/labelKeys.dart';
import 'package:eshop_pro/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TicketItemContainer extends StatelessWidget {
  final Ticket ticket;
  final TicketCubit ticketCubit;
  const TicketItemContainer(this.ticket, this.ticketCubit, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
          vertical: appContentHorizontalPadding),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsetsDirectional.symmetric(
                horizontal: appContentHorizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextContainer(
                  textKey: 'ID: #${ticket.id}',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.primary),
                ),
                if (ticket.status != null)
                  CustomStatusContainer(
                      getValueList: Utils.getTicketStatusTextAndColor,
                      status: ticket.status.toString())
              ],
            ),
          ),
          const Divider(
            thickness: 0.5,
          ),
          buildLabelAndValue(context, typeKey, ticket.ticketType ?? ''),
          buildLabelAndValue(context, subjectKey, ticket.subject ?? ''),
          buildLabelAndValue(
              context, descriptionKey, ticket.description.toString()),
          buildLabelAndValue(context, dateKey, ticket.createdAt.toString()),
          DesignConfig.defaultHeightSizedBox,
          Row(
            children: [
              CustomRoundedButton(
                  height: 28,
                  widthPercentage: 0.2,
                  horizontalPadding: 8,
                  buttonTitle: editKey,
                  showBorder: true,
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  borderColor: Theme.of(context).hintColor,
                  style: const TextStyle().copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onTap: () => Utils.navigateToScreen(
                          context, Routes.askQueryScreen,
                          arguments: {
                            'ticketCubit': ticketCubit,
                            'ticket': ticket,
                          })),
            ],
          )
        ],
      ),
    );
  }

  buildLabelAndValue(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(appContentHorizontalPadding,
          0, appContentHorizontalPadding, appContentHorizontalPadding / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context
                      .read<SettingsAndLanguagesCubit>()
                      .getTranslatedValue(labelKey: title),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextSpan(
                  text: ' : ',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomTextContainer(
              textKey: value,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.8)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
