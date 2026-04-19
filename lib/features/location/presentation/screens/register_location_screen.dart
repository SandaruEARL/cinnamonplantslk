import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_colors.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../features/location/presentation/screens/location_picker_screen.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/business_location_entity.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../bloc/location_state.dart';

class RegisterLocationScreen extends StatefulWidget {
  final LocationType type;
  final BusinessLocationEntity? existing;

  const RegisterLocationScreen({
    super.key,
    required this.type,
    this.existing,
  });

  @override
  State<RegisterLocationScreen> createState() =>
      _RegisterLocationScreenState();
}

class _RegisterLocationScreenState
    extends State<RegisterLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hoursController = TextEditingController();
  final _addressController = TextEditingController();

  double? _lat;
  double? _lng;
  final List<File> _newPhotos = [];
  List<String> _existingPhotos = [];

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameController.text = e.businessName;
      _descriptionController.text = e.description;
      _phoneController.text = e.ownerPhone;
      _hoursController.text = e.openingHours ?? '';
      _addressController.text = e.address;
      _lat = e.latitude;
      _lng = e.longitude;
      _existingPhotos = List.from(e.photoUrls);
    }
  }

  InputDecoration _inputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFAAAAAA)),
    filled: true,
    fillColor: const Color(0xFFF0F0F0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
          color: AppColors.primaryGreen, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => sl<LocationBloc>(),
      child: BlocListener<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is LocationSaved) {
            _showSuccessDialog(context);
          } else if (state is LocationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(l10n.errorPrefix(state.message)),
                  backgroundColor: AppColors.accentRed),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              _appBarTitle(l10n),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 8),

                // Business Name
                TextFormField(
                  controller: _nameController,
                  validator: (v) => v == null || v.isEmpty
                      ? l10n.validationRequired
                      : null,
                  decoration: _inputDecoration(
                    hint: widget.type == LocationType.nursery
                        ? l10n.hintNurseryName
                        : l10n.hintShopName,
                  ),
                ),
                const SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty
                      ? l10n.validationRequired
                      : null,
                  decoration: _inputDecoration(
                      hint: l10n.hintContactNumber),
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (v) => v == null || v.isEmpty
                      ? l10n.validationRequired
                      : null,
                  decoration:
                  _inputDecoration(hint: l10n.hintDescription),
                ),
                const SizedBox(height: 16),

                // Opening hours
                TextFormField(
                  controller: _hoursController,
                  decoration: _inputDecoration(
                      hint: l10n.hintOpeningHours),
                ),
                const SizedBox(height: 16),

                // Location picker
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _addressController.text.isEmpty
                                ? l10n.pickLocationHint
                                : _addressController.text,
                            style: TextStyle(
                              color: _addressController.text.isEmpty
                                  ? const Color(0xFFAAAAAA)
                                  : AppColors.textPrimary,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (_lat != null)
                          const Icon(Icons.check_circle,
                              color: AppColors.accentGreen,
                              size: 18),
                        const Icon(Icons.chevron_right,
                            color: Color(0xFFAAAAAA)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Photo picker
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: _pickPhotos,
                        child: Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 32,
                                  color: Color(0xFFAAAAAA)),
                              SizedBox(height: 6),
                              Text('Add image',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFAAAAAA))),
                            ],
                          ),
                        ),
                      ),
                      ..._existingPhotos.map((url) => Stack(
                        children: [
                          Container(
                            width: 100,
                            margin:
                            const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12),
                              image: DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _existingPhotos
                                      .remove(url)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    color: Colors.white,
                                    size: 14),
                              ),
                            ),
                          ),
                        ],
                      )),
                      ..._newPhotos.map((file) => Stack(
                        children: [
                          Container(
                            width: 100,
                            margin:
                            const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(12),
                              image: DecorationImage(
                                image: FileImage(file),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => setState(
                                      () => _newPhotos.remove(file)),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.close,
                                    color: Colors.white,
                                    size: 14),
                              ),
                            ),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit
                BlocBuilder<LocationBloc, LocationState>(
                  builder: (context, state) {
                    final isSaving = state is LocationSaving;
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: isSaving
                              ? null
                              : () => _submit(context),
                          child: isSaving
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                              AlwaysStoppedAnimation(
                                  Colors.white),
                            ),
                          )
                              : Text(
                            widget.existing == null
                                ? l10n.submitForReview
                                : l10n.updateLocation,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _appBarTitle(AppLocalizations l10n) {
    if (widget.type == LocationType.nursery) {
      return widget.existing == null
          ? l10n.registerNurseryTitle
          : l10n.updateNurseryTitle;
    }
    return widget.existing == null
        ? l10n.registerShopTitle
        : l10n.updateShopTitle;
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() =>
          _newPhotos.addAll(images.map((x) => File(x.path))));
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context)
        .push<LocationResult>(MaterialPageRoute(
      builder: (_) => LocationPickerScreen(
          initialLat: _lat, initialLng: _lng),
    ));
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _addressController.text = result.address;
      });
    }
  }

  void _submit(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.snackPickLocation)),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final now = DateTime.now();
    final location = BusinessLocationEntity(
      id: widget.existing?.id ?? '',
      userId: authState.user.id,
      ownerName: authState.user.name,
      ownerPhone: _phoneController.text.trim(),
      ownerProfilePic: authState.user.profilePicUrl,
      type: widget.type,
      businessName: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      address: _addressController.text.trim(),
      latitude: _lat!,
      longitude: _lng!,
      openingHours: _hoursController.text.trim().isEmpty
          ? null
          : _hoursController.text.trim(),
      photoUrls: _existingPhotos,
      createdAt: widget.existing?.createdAt ?? now,
      updatedAt: now,
    );

    context.read<LocationBloc>().add(LocationSaveRequested(
      location: location,
      newPhotos: _newPhotos,
    ));
  }

  void _showSuccessDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final typeLabel = widget.type == LocationType.nursery
        ? l10n.nurseryPlantations
        : l10n.baleBuyingShops;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle),
              child: Icon(Icons.hourglass_top_rounded,
                  size: 48, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 20),
            Text(l10n.locationSubmittedTitle,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(l10n.locationSubmittedBody(typeLabel),
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    height: 1.5),
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(l10n.gotIt),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _hoursController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}