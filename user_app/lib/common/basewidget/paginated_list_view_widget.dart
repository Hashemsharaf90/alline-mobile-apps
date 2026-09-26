import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/helper/debounce_helper.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';

class PaginatedListView extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(int? offset) onPaginate;
  final int? totalSize;
  final int? offset;
  final int? limit;
  final Widget itemView;
  final bool enabledPagination;
  final bool reverse;
  final bool showEndMessage;
  final bool showProductSkeletonFooter;
  const PaginatedListView({
    super.key,
    this.scrollController,
    required this.onPaginate,
    required this.totalSize,
    required this.offset,
    required this.itemView,
    this.enabledPagination = true,
    this.reverse = false,
    this.limit = 10,
    this.showEndMessage = false,
    this.showProductSkeletonFooter = false,
  });

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  int? _offset;
  late List<int?> _offsetList;
  bool _isLoading = false;

  final DebounceHelper debounce = DebounceHelper(milliseconds: 500);

  @override
  void initState() {
    super.initState();

    _offset = 1;
    _offsetList = [1];

    if (widget.scrollController != null) {
      widget.scrollController?.addListener(() {
        if ((widget.scrollController?.position.extentAfter ??
                    double.infinity) <=
                360 &&
            widget.totalSize != null &&
            !_isLoading &&
            widget.enabledPagination) {
          if (mounted) {
            _paginate();
          }
        }
      });
    }
  }

  void _paginate() async {
    int pageSize = (widget.totalSize! / widget.limit!).ceil();
    if (_offset! < pageSize && !_offsetList.contains(_offset! + 1)) {
      setState(() {
        _offset = _offset! + 1;
        _offsetList.add(_offset);
        _isLoading = true;
      });
      await widget.onPaginate(_offset);
      setState(() {
        _isLoading = false;
      });
    } else {
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offset != null) {
      _offset = widget.offset;
      _offsetList = [];
      for (int index = 1; index <= widget.offset!; index++) {
        _offsetList.add(index);
      }
    }

    return _OnNotificationListenerWidget(
      isEnabled: widget.scrollController == null,
      onNotification: (scrollNotification) {
        if (scrollNotification!.metrics.extentAfter <= 360 &&
            widget.totalSize != null &&
            !_isLoading &&
            widget.enabledPagination) {
          if (mounted) {
            debounce.run(() {
              _paginate();
            });
          }
        }
      },
      child: Column(children: [
        widget.reverse ? const SizedBox() : widget.itemView,
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: widget.showProductSkeletonFooter
                ? const Row(children: [
                    Expanded(child: _PaginationSkeletonCard()),
                    SizedBox(width: 12),
                    Expanded(child: _PaginationSkeletonCard()),
                  ])
                : const CircularProgressIndicator(),
          )
        else if (widget.showEndMessage &&
            widget.totalSize != null &&
            _offset! >= (widget.totalSize! / (widget.limit ?? 10)).ceil())
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text(
              'تم عرض جميع المنتجات',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
          ),
        widget.reverse ? widget.itemView : const SizedBox(),
      ]),
    );
  }
}

class _PaginationSkeletonCard extends StatelessWidget {
  const _PaginationSkeletonCard();

  @override
  Widget build(BuildContext context) => Container(
        height: 180,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
      );
}

class _OnNotificationListenerWidget extends StatelessWidget {
  final bool isEnabled;
  final Widget child;
  final Function(ScrollNotification? scrollNotification) onNotification;
  const _OnNotificationListenerWidget(
      {required this.isEnabled,
      required this.child,
      required this.onNotification});

  @override
  Widget build(BuildContext context) {
    return isEnabled
        ? NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              onNotification(scrollNotification);

              return false;
            },
            child: child,
          )
        : child;
  }
}
