import 'package:flutter/material.dart';

class AllineStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const AllineStatusBadge({super.key, required this.label, required this.color, this.icon = Icons.circle_outlined});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: color, size: 16), const SizedBox(width: 8),
      Flexible(child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
    ]),
  );
}
