import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/helper/driver_journey.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';

class AllineJourneyTimeline extends StatelessWidget {
  final OrderModel order;
  const AllineJourneyTimeline({super.key, required this.order});
  @override
  Widget build(BuildContext context) {
    final current = DriverJourney.stages.indexOf(DriverJourney.status(order));
    if (current < 0) return const SizedBox.shrink();
    return Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      for (var i = 0; i < DriverJourney.stages.length; i++) Padding(
        padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [
          Icon(i < current ? Icons.check_circle_outline_rounded : i == current ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
            color: i <= current ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 12), Expanded(child: Text(DriverJourney.labelKey(DriverJourney.stages[i]).tr)),
        ]),
      ),
    ])));
  }
}
