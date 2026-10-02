import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/live_tracking/controllers/location_tracking_controller.dart';

class AllineTrackingIndicator extends StatelessWidget {
  const AllineTrackingIndicator({super.key});
  @override
  Widget build(BuildContext context) =>
      GetBuilder<LocationTrackingController>(builder: (controller) {
        if (!controller.isTracking && !controller.hasError) {
          return const SizedBox.shrink();
        }
        return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Icon(
                  controller.hasError
                      ? Icons.location_off_outlined
                      : Icons.my_location_rounded,
                  color: controller.hasError
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                  child: Text((controller.hasError
                          ? 'alline_tracking_error'
                          : 'alline_tracking_active')
                      .tr)),
            ]));
      });
}
