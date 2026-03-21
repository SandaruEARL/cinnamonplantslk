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
  final BusinessLocation? existing; // pass if editing

  const RegisterLocationScreen({
    super.key,
    required this.type,
    this.existing,
  });

  @override
  State<RegisterLocationScreen> createState() => _RegisterLocationScreenState();
}

class _RegisterLocationScreenState extends State<RegisterLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController        = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController       = TextEditingController();
  final _hoursController       = TextEditingController();
  final _addressController     = TextEditingController();

  double? _lat;
  double? _lng;
  final List<File> _newPhotos   = [];
  List<String> _existingPhotos  = [];
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

  String get _typeLabel =>
      widget.type == LocationType.nursery ? 'Nursery / Plantation' : 'Bale Buying Shop';

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
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: _lat,
          initialLng: _lng,
        ),
      ),
    );
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
        const SnackBar(content: Text('Please pick a location on the map')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      // Upload new photos
      List<String> uploadedUrls = [];
      if (_newPhotos.isNotEmpty) {
        final cloudinary = CloudinaryService();
        uploadedUrls = await cloudinary.uploadAdImages(_newPhotos);
      }

      final allPhotos = [..._existingPhotos, ...uploadedUrls];
      final now = DateTime.now();

      final location = BusinessLocation(
        id:             widget.existing?.id ?? '',
        userId:         authState.user.id,
        ownerName:      authState.user.name,
        ownerPhone:     _phoneController.text.trim(),
        ownerProfilePic: authState.user.profilePicUrl,
        type:           widget.type,
        businessName:   _nameController.text.trim(),
        description:    _descriptionController.text.trim(),
        address:        _addressController.text.trim(),
        latitude:       _lat!,
        longitude:      _lng!,
        openingHours:   _hoursController.text.trim().isEmpty
            ? null
            : _hoursController.text.trim(),
        photoUrls:      allPhotos,
        createdAt:      widget.existing?.createdAt ?? now,
        updatedAt:      now,
      );

      await context.read<FirestoreService>().saveLocation(location);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Your $_typeLabel location is pending approval. '
                  "It will appear on the map once approved.",
              style: TextStyle(fontSize: 14,
                  color: Colors.grey.shade600, height: 1.5),
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
                backgroundColor: AppColors.primaryBrown,
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
      appBar: AppBar(
        title: Text(widget.existing == null
            ? 'Register $_typeLabel'
            : 'Update $_typeLabel'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // Business name
            TextFormField(
              controller: _nameController,
              validator: (v) => v == null || v.isEmpty
                  ? 'Business name is required' : null,
              decoration: InputDecoration(
                labelText: '$_typeLabel name',
                prefixIcon: const Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              validator: (v) => v == null || v.isEmpty
                  ? 'Phone number is required' : null,
              decoration: const InputDecoration(
                labelText: 'Contact number',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              validator: (v) => v == null || v.isEmpty
                  ? 'Description is required' : null,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
                hintText: 'Describe your nursery or shop...',
              ),
            ),
            const SizedBox(height: 16),

            // Opening hours
            TextFormField(
              controller: _hoursController,
              decoration: const InputDecoration(
                labelText: 'Opening hours (optional)',
                prefixIcon: Icon(Icons.access_time),
                hintText: 'e.g. Mon–Sat 8am–6pm',
              ),
            ),
            const SizedBox(height: 16),

            // Location picker
            const Text('Location',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickLocation,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.primaryBrown),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _addressController.text.isEmpty
                            ? 'Tap to pick location on map'
                            : _addressController.text,
                        style: TextStyle(
                          color: _addressController.text.isEmpty
                              ? Colors.grey
                              : AppColors.textPrimary,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (_lat != null)
                      const Icon(Icons.check_circle,
                          color: AppColors.accentGreen, size: 20),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Photos
            const Text('Photos',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: _pickPhotos,
                    child: Container(
                      width: 110,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.divider, width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 36),
                          SizedBox(height: 6),
                          Text('Add Photos',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  // Existing photos
                  ..._existingPhotos.map((url) => Stack(
                    children: [
                      Container(
                        width: 110,
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
                        top: 4, right: 12,
                        child: GestureDetector(
                          onTap: () => setState(
                                  () => _existingPhotos.remove(url)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
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
                        width: 110,
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
                        top: 4, right: 12,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _newPhotos.remove(file)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
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

            // Submit
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white)))
                  : Text(widget.existing == null
                  ? 'Submit for Review'
                  : 'Update Location'),
            ),
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