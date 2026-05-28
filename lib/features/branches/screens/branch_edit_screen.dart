import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/config/environment.dart';
import 'package:moonjoin_cloud/features/branches/controllers/branches_controller.dart';
import 'package:moonjoin_cloud/features/branches/controllers/zone_check_controller.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/branch_model.dart';
import 'package:moonjoin_cloud/features/branches/widgets/zone_status_pill.dart';
import 'package:moonjoin_cloud/helper/custom_validator.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class BranchEditScreen extends StatefulWidget {
  /// `null` for create.
  final int? branchId;
  const BranchEditScreen({super.key, this.branchId});

  @override
  State<BranchEditScreen> createState() => _BranchEditScreenState();
}

class _BranchEditScreenState extends State<BranchEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  // Lagos default — moved as soon as the user drags the marker.
  LatLng _position = const LatLng(6.5244, 3.3792);
  GoogleMapController? _map;
  BranchModel? _existing;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.branchId != null) {
        final branches = Get.find<BranchesController>();
        _existing = branches.findById(widget.branchId!);
        if (_existing != null) {
          _name.text = _existing!.name;
          _address.text = _existing!.address;
          _phone.text = _existing!.phone ?? '';
          _email.text = _existing!.email ?? '';
          _position = LatLng(_existing!.latitude, _existing!.longitude);
          // Kick off a coverage check for the persisted coords.
          Get.find<ZoneCheckController>()
              .requestCheck(_position.latitude, _position.longitude);
          if (mounted) setState(() {});
        }
      } else {
        Get.find<ZoneCheckController>().clear();
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _phone.dispose();
    _email.dispose();
    _map?.dispose();
    super.dispose();
  }

  void _moveMarker(LatLng position) {
    setState(() => _position = position);
    Get.find<ZoneCheckController>()
        .requestCheck(position.latitude, position.longitude);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final zone = Get.find<ZoneCheckController>().result;
    if (zone == null || !zone.ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Pick a location inside an active delivery zone before saving.'),
      ));
      return;
    }
    final controller = Get.find<BranchesController>();
    if (widget.branchId == null) {
      final branch = await controller.create(
        name: _name.text.trim(),
        address: _address.text.trim(),
        latitude: _position.latitude,
        longitude: _position.longitude,
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
      );
      if (branch != null) Get.back();
    } else {
      final branch = await controller.updateBranch(
        widget.branchId!,
        name: _name.text.trim(),
        address: _address.text.trim(),
        latitude: _position.latitude,
        longitude: _position.longitude,
        phone: _phone.text.trim(),
        email: _email.text.trim(),
      );
      if (branch != null) Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.branchId == null;
    return GetBuilder<BranchesController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isCreate ? 'New branch' : 'Edit branch',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            children: [
              _MapPicker(
                position: _position,
                onCreated: (c) => _map = c,
                onMoved: _moveMarker,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              GetBuilder<ZoneCheckController>(builder: (zone) {
                return ZoneStatusPill(
                  result: zone.result,
                  checking: zone.checking,
                  errorMessage: zone.errorMessage,
                );
              }),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text('Coordinates',
                  style: robotoMedium.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: Dimensions.fontSizeSmall)),
              Text(
                '${_position.latitude.toStringAsFixed(5)}, ${_position.longitude.toStringAsFixed(5)}',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomTextField(
                controller: _name,
                labelText: 'Branch name',
                hintText: 'Lekki Phase 1',
                prefixIcon: Icons.label_outline,
                validator: (v) => (v ?? '').trim().length >= 2
                    ? null
                    : 'Required',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _address,
                labelText: 'Street address',
                hintText: '12 Admiralty Way, Lekki',
                prefixIcon: Icons.place_outlined,
                maxLines: 2,
                validator: (v) => (v ?? '').trim().length >= 4
                    ? null
                    : 'Enter a more specific address',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _phone,
                labelText: 'Phone (optional)',
                inputType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return null;
                  return CustomValidator.isPhone(value)
                      ? null
                      : 'Enter a valid phone number';
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _email,
                labelText: 'Email (optional)',
                inputType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return null;
                  return CustomValidator.isValidEmail(value)
                      ? null
                      : 'Enter a valid email';
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              CustomButton(
                buttonText: isCreate ? 'Create branch' : 'Save changes',
                isLoading: controller.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MapPicker extends StatelessWidget {
  final LatLng position;
  final ValueChanged<GoogleMapController> onCreated;
  final ValueChanged<LatLng> onMoved;
  const _MapPicker({
    required this.position,
    required this.onCreated,
    required this.onMoved,
  });

  @override
  Widget build(BuildContext context) {
    final mapKeyConfigured = Environment.googleMapsApiKey.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      child: SizedBox(
        height: 240,
        child: Stack(children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: position, zoom: 14),
            onMapCreated: onCreated,
            onTap: onMoved,
            markers: {
              Marker(
                markerId: const MarkerId('branch'),
                position: position,
                draggable: true,
                onDragEnd: onMoved,
              ),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            mapToolbarEnabled: false,
          ),
          if (!mapKeyConfigured)
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF6E0),
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                  border:
                      Border.all(color: const Color(0xFFE8D38A)),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Color(0xFFA66B00)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Map key not configured. Pass --dart-define=MAPS_KEY=… or inject it into web/index.html at build time. The picker still works for testing coordinates.',
                      style: robotoMedium.copyWith(
                          color: const Color(0xFFA66B00),
                          fontSize: Dimensions.fontSizeExtraSmall),
                    ),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
