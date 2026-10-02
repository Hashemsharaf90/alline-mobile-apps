import 'dart:math' as math;
import 'package:flutter/material.dart';

class AllineSwipeAction extends StatefulWidget {
  final String label;
  final Future<bool> Function() onSwipe;
  final bool isLoading, enabled;
  const AllineSwipeAction(
      {super.key,
      required this.label,
      required this.onSwipe,
      this.isLoading = false,
      this.enabled = true});
  @override
  State<AllineSwipeAction> createState() => _AllineSwipeActionState();
}

class _AllineSwipeActionState extends State<AllineSwipeAction> {
  double _drag = 0;
  bool _pending = false, _confirmed = false;
  bool get _blocked =>
      _pending || widget.isLoading || !widget.enabled || _confirmed;
  @override
  void didUpdateWidget(covariant AllineSwipeAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.label != widget.label) {
      _drag = 0;
      _confirmed = false;
    }
  }

  Future<void> _submit() async {
    if (_blocked) return;
    setState(() => _pending = true);
    bool success = false;
    try {
      success = await widget.onSwipe();
    } catch (_) {
      success = false;
    }
    if (!mounted) return;
    setState(() {
      _pending = false;
      _confirmed = success;
      _drag = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final scheme = Theme.of(context).colorScheme;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge),
      const SizedBox(height: 8),
      LayoutBuilder(builder: (context, constraints) {
        final travel = math.max(0.0, constraints.maxWidth - 60);
        return Container(
            height: 60,
            decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outline)),
            child: Stack(alignment: Alignment.center, children: [
              if (_pending || widget.isLoading)
                const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              if (!_pending && !widget.isLoading)
                PositionedDirectional(
                    start: 4 + _drag,
                    child: GestureDetector(
                        onHorizontalDragUpdate: _blocked
                            ? null
                            : (details) => setState(() => _drag = (_drag +
                                    (rtl
                                        ? -details.delta.dx
                                        : details.delta.dx))
                                .clamp(0.0, travel)),
                        onHorizontalDragEnd: _blocked
                            ? null
                            : (_) {
                                if (travel > 0 && _drag >= travel * .8) {
                                  _submit();
                                } else {
                                  setState(() => _drag = 0);
                                }
                              },
                        onHorizontalDragCancel: () => setState(() => _drag = 0),
                        child: IconButton.filled(
                            tooltip: widget.label,
                            onPressed: _blocked ? null : _submit,
                            style: IconButton.styleFrom(
                                minimumSize: const Size(52, 52),
                                backgroundColor: _confirmed
                                    ? scheme.onTertiaryContainer
                                    : scheme.primary,
                                foregroundColor: scheme.onPrimary),
                            icon: Icon(_confirmed
                                ? Icons.check_rounded
                                : rtl
                                    ? Icons.arrow_back_rounded
                                    : Icons.arrow_forward_rounded)))),
            ]));
      })
    ]);
  }
}
