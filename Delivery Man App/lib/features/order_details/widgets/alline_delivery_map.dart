import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/order/domain/models/order_model.dart';
import 'package:sixvalley_delivery_boy/helper/delivery_destination.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';

class AllineDeliveryMap extends StatefulWidget {
  final OrderModel order;
  const AllineDeliveryMap({super.key, required this.order});
  @override
  State<AllineDeliveryMap> createState() => _AllineDeliveryMapState();
}

class _AllineDeliveryMapState extends State<AllineDeliveryMap> {
  GoogleMapController? _mapController;
  LatLng? _destination;
  @override
  void initState() {
    super.initState();
    _destination = DeliveryDestination.coordinates(widget.order);
  }

  @override
  void didUpdateWidget(covariant AllineDeliveryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = DeliveryDestination.coordinates(widget.order);
    if (next != _destination) {
      _destination = next;
      if (next != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(next));
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_destination == null) {
      return Card(
          child: AllineEmptyState(
              title: (DeliveryDestination.isStore(widget.order)
                      ? 'alline_store_location_missing'
                      : 'location_not_available')
                  .tr,
              subtitle: DeliveryDestination.isStore(widget.order)
                  ? ''
                  : widget.order.shippingAddress?.address ?? '',
              icon: Icons.location_off_outlined));
    }
    return Container(
        height: 240,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.outline)),
        child: GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _destination!, zoom: 14),
            markers: {
              Marker(
                  markerId: const MarkerId('destination'),
                  position: _destination!,
                  infoWindow: InfoWindow(
                      title: (DeliveryDestination.isStore(widget.order)
                              ? 'store'
                              : 'customer')
                          .tr))
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
            zoomControlsEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false));
  }
}
