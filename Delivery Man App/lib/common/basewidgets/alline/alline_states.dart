import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'alline_empty_state.dart';

class AllineSkeleton extends StatelessWidget {
  final int count;
  const AllineSkeleton({super.key, this.count = 3});
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'loading'.tr,
        child: Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.outline,
          highlightColor: Theme.of(context).colorScheme.surface,
          child: Column(
              children: List.generate(
                  count,
                  (_) => Container(
                        height: 96,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16)),
                      ))),
        ),
      );
}

class AllineErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;
  const AllineErrorState({super.key, this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) =>
      Column(mainAxisSize: MainAxisSize.min, children: [
        AllineEmptyState(
            title: message ?? 'alline_load_error'.tr,
            subtitle: '',
            icon: Icons.cloud_off_rounded),
        OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text('alline_retry'.tr)),
      ]);
}

class AllineMoneyRow extends StatelessWidget {
  final String label;
  final String value;
  const AllineMoneyRow({super.key, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(label)),
          const SizedBox(width: 16),
          Flexible(
              child: Text(value,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.titleSmall)),
        ]),
      );
}
