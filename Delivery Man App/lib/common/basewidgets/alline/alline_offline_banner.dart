import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllineOfflineBanner extends StatefulWidget {
  final Widget child;
  const AllineOfflineBanner({super.key, required this.child});
  @override
  State<AllineOfflineBanner> createState() => _AllineOfflineBannerState();
}

class _AllineOfflineBannerState extends State<AllineOfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _connection;
  bool _offline = false;
  void _changed(List<ConnectivityResult> result) {
    if (mounted) {
      setState(() => _offline = result.isNotEmpty &&
          result.every((entry) => entry == ConnectivityResult.none));
    }
  }

  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then(_changed).catchError((_) {});
    _connection = Connectivity().onConnectivityChanged.listen(_changed);
  }

  @override
  void dispose() {
    _connection?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        if (_offline)
          SafeArea(
              bottom: false,
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Semantics(
                    liveRegion: true,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.wifi_off_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer),
                            const SizedBox(width: 8),
                            Flexible(
                                child: Text('alline_offline'.tr,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onErrorContainer))),
                          ]),
                    )),
              )),
        Expanded(child: widget.child),
      ]);
}
