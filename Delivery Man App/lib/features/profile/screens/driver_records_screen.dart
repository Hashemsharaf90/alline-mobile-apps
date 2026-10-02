import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/controllers/driver_onboarding_controller.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/domain/models/driver_onboarding_model.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/custom_app_bar_widget.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_empty_state.dart';
import 'package:sixvalley_delivery_boy/common/basewidgets/alline/alline_states.dart';

class DriverRecordsScreen extends StatefulWidget {
  final bool vehicle;
  const DriverRecordsScreen({super.key, required this.vehicle});
  @override
  State<DriverRecordsScreen> createState() => _DriverRecordsScreenState();
}

class _DriverRecordsScreenState extends State<DriverRecordsScreen> {
  late Future<DriverOnboardingProfileResponse?> _records;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _records =
        Get.find<DriverOnboardingController>().onboardingService.getProfile();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBarWidget(
          title: (widget.vehicle ? 'vehicle_step_label' : 'docs_step_label').tr,
          isBack: true),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<DriverOnboardingProfileResponse?>(
              future: _records,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const AllineSkeleton();
                }
                final records = snapshot.data;
                if (records == null) {
                  return AllineErrorState(onRetry: () => setState(_load));
                }
                if (widget.vehicle) {
                  final vehicle = records.vehicle;
                  if (vehicle == null) {
                    return AllineEmptyState(
                        title: 'alline_no_vehicle'.tr,
                        subtitle: '',
                        icon: Icons.two_wheeler_outlined);
                  }
                  return Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(children: [
                            AllineMoneyRow(
                                label: 'vehicle_type'.tr,
                                value: _type(vehicle.vehicleType)),
                            AllineMoneyRow(
                                label: 'vehicle_brand'.tr,
                                value: vehicle.brandOrModel ?? ''),
                            AllineMoneyRow(
                                label: 'plate_number'.tr,
                                value: vehicle.plateNumber ?? ''),
                            AllineMoneyRow(
                                label: 'vehicle_color'.tr,
                                value: vehicle.color ?? ''),
                            if (vehicle.registrationDocumentUrl?.isNotEmpty ??
                                false)
                              ListTile(
                                  leading:
                                      const Icon(Icons.description_outlined),
                                  title: Text('registration_doc_label'.tr),
                                  subtitle: Text('alline_document_on_file'.tr)),
                          ])));
                }
                final documents = records.documents ?? [];
                if (documents.isEmpty) {
                  return AllineEmptyState(
                      title: 'alline_no_documents'.tr,
                      subtitle: '',
                      icon: Icons.folder_open_outlined);
                }
                return Column(children: [
                  for (final document in documents)
                    Card(
                        child: ListTile(
                            leading: const Icon(Icons.description_outlined),
                            title: Text(_documentType(document.documentType)),
                            subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_status(document.reviewStatus)),
                                  if (document.reviewNote?.isNotEmpty ?? false)
                                    Text(document.reviewNote!),
                                ])))
                ]);
              })));
  String _status(String? status) => switch (status) {
        'approved' => 'alline_doc_approved'.tr,
        'rejected' => 'alline_doc_rejected'.tr,
        'pending' => 'alline_doc_pending'.tr,
        _ => 'alline_status_unavailable'.tr
      };
  String _documentType(String? type) => switch (type) {
        'identity' => 'national_id_card'.tr,
        'drivers_license' => 'driving_license'.tr,
        _ => 'alline_document'.tr
      };
  String _type(String? type) => switch (type) {
        'motorcycle' => 'vehicle_motorcycle'.tr,
        'car' => 'vehicle_car'.tr,
        'bicycle' => 'vehicle_bicycle'.tr,
        _ => 'vehicle_step_label'.tr
      };
}
