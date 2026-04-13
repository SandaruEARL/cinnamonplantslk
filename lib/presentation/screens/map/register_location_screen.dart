import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/location.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import 'location_picker_screen.dart';

class RegisterLocationScreen extends StatefulWidget {
  final LocationType type;
  final BusinessLocation? existing;

  const RegisterLocationScreen({
    super.key,
    required this.type,
    this.existing,
  });

  @override
  State<RegisterLocationScreen> createState() =>
      _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen> {
  final _formKey                = GlobalKey<FormState>();
  final _nameController         = TextEditingController();
  final _descriptionController  = TextEditingController();
  final _phoneController        = TextEditingController();
  final _hoursController        = TextEditingController();
  final _addressController      = TextEditingController();

  double? _lat;
  double? _lng;
  final List<File> _newPhotos  = [];
  List<String> _existingPhotos = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _nameController.text        = e.businessName;
      _descriptionController.text = e.description;
      _phoneController.text       = e.ownerPhone;
      _hoursController.text       = e.openingHours ?? '';
      _addressController.text     = e.address;
      _lat = e.latitude;
      _lng = e.longitude;
      _existingPhotos = List.from(e.photoUrls);
    }
  }

  String get _typeLabel => widget.type == LocationType.nursery
      ? 'Nursery / Plantation'
      : 'Bale Buying Shop';

  // ── Shared input decoration ──────────────────────────────────────────
  InputDecoration _inputDecoration({String? hint, int? maxLines}) {
    return InputDecoration(
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
        borderSide:
        BorderSide(color: AppColors.primaryGreen, width: 1.5),
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
  }

  Future<void> _pickPhotos() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _newPhotos.addAll(images.map((x) => File(x.path)));
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context)
        .push<LocationResult>(MaterialPageRoute(
      builder: (_) => LocationPickerScreen(
        initialLat: _lat,
        initialLng: _lng,
      ),
    ));
    if (result != null) {
      setState(() {
        _lat = result.latitude;
        _lng = result.longitude;
        _addressController.text = result.address;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_lat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please pick a location on the map')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      List<String> uploadedUrls = [];
      if (_newPhotos.isNotEmpty) {
        final cloudinary = CloudinaryService();
        uploadedUrls = await cloudinary.uploadAdImages(_newPhotos);
      }

      final allPhotos = [..._existingPhotos, ...uploadedUrls];
      final now = DateTime.now();

      final location = BusinessLocation(
        id:              widget.existing?.id ?? '',
        userId:          authState.user.id,
        ownerName:       authState.user.name,
        ownerPhone:      _phoneController.text.trim(),
        ownerProfilePic: authState.user.profilePicUrl,
        type:            widget.type,
        businessName:    _nameController.text.trim(),
        description:     _descriptionController.text.trim(),
        address:         _addressController.text.trim(),
        latitude:        _lat!,
        longitude:       _lng!,
        openingHours: _hoursController.text.trim().isEmpty
            ? null
            : _hoursController.text.trim(),
        photoUrls: allPhotos,
        createdAt: widget.existing?.createdAt ?? now,
        updatedAt: now,
      );

      await context.read<FirestoreService>().saveLocation(location);
      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.accentRed),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
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
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_top_rounded,
                  size: 48, color: Colors.orange.shade700),
            ),
            const SizedBox(height: 20),
            const Text('Location Submitted',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Your $_typeLabel location is pending approval. '
                  'It will appear on the map once approved.',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5),
              textAlign: TextAlign.center,
            ),
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
              child: const Text('Got it'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ─────────────────────────────────────────────────────
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.existing == null
              ? 'Register ${_typeLabel} location'
              : 'Update $_typeLabel',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration:
          const BoxDecoration(gradient: AppColors.primaryGradient),
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

            // ── Business Name ─────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
              decoration: _inputDecoration(
                hint: widget.type == LocationType.nursery
                    ? 'Nursery / Plantation Name'
                    : 'Bale Buying Shop Name',
              ),
            ),
            const SizedBox(height: 16),

            // ── Contact Number ────────────────────────────────────────
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
              decoration: _inputDecoration(hint: 'Contact Number'),
            ),
            const SizedBox(height: 16),

            // ── Description ───────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              validator: (v) =>
              v == null || v.isEmpty ? 'Required' : null,
              decoration: _inputDecoration(hint: 'Description'),
            ),
            const SizedBox(height: 16),

            // ── Opening Hours ─────────────────────────────────────────
            TextFormField(
              controller: _hoursController,
              decoration: _inputDecoration(hint: 'Opening Hours'),
            ),
            const SizedBox(height: 16),

            // ── Location Picker ───────────────────────────────────────
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
                            ? 'Pick your location from the map'
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
                          color: AppColors.accentGreen, size: 18),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFFAAAAAA)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Image Picker ──────────────────────────────────────────
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add button
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 32, color: Color(0xFFAAAAAA)),
                          SizedBox(height: 6),
                          Text('Add image',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFAAAAAA))),
                        ],
                      ),
                    ),
                  ),

                  // Existing photos
                  ..._existingPhotos.map((url) => Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
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
                                  () => _existingPhotos.remove(url)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  )),

                  // New photos
                  ..._newPhotos.map((file) => Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
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
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Submit Button ─────────────────────────────────────────
            DecoratedBox(
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
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                    ),
                  )
                      : Text(
                    widget.existing == null
                        ? 'Submit for Review'
                        : 'Update Location',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
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