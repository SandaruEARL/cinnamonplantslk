import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/category_localizer.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/cloudinary/cloudinary_service.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../domain/entities/advertisement.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';

class PostAdScreen extends StatefulWidget {
  const PostAdScreen({super.key});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = AppConstants.productCategories[0];
  String? _selectedGrade;
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  // ── Shared input decoration ──────────────────────────────────────────
  InputDecoration _inputDecoration({String? hint}) {
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
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // ── AppBar ─────────────────────────────────────────────────────
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.postAd,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
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

            // ── Image Picker ──────────────────────────────────────────
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: Color(0xFFAAAAAA),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.addImage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAAAAAA),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  // Selected images
                  ..._selectedImages.map((image) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedImages.remove(image)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Category ──────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _inputDecoration(),
              items: l10n.localizedCategories.map((entry) {
                return DropdownMenuItem(
                  value: entry.value,
                  child: Text(entry.label),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),

            const SizedBox(height: 16),

            // ── Title ─────────────────────────────────────────────────
            TextFormField(
              controller: _titleController,
              validator: (val) => Validators.validateRequired(
                val,
                requiredMessage: l10n.validationFieldRequired(l10n.titleHint),
              ),
              decoration:
              _inputDecoration(hint: l10n.titleHint),
            ),

            const SizedBox(height: 16),

            // ── Description ───────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              validator: (val) => Validators.validateRequired(
                val,
                requiredMessage: l10n.validationFieldRequired(l10n.descriptionHint),
              ),
              maxLines: 4,
              decoration: _inputDecoration(hint: l10n.descriptionHint).copyWith(
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 16),

            // ── Price & Qty ───────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    validator: (val) => Validators.validatePrice(
                      val,
                      requiredMessage: l10n.validationPriceRequired,
                      invalidMessage: l10n.validationPriceInvalid,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: l10n.priceHint),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: l10n.quantityHint),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Grade (only for bales) ────────────────────────────────
            if (_selectedCategory.contains('Bales')) ...[
              DropdownButtonFormField<String>(
                value: _selectedGrade,
                decoration: _inputDecoration(hint: l10n.gradeHint),
                items: AppConstants.cinnamonGrades.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedGrade = value),
              ),
              const SizedBox(height: 16),
            ],

            // ── Location ──────────────────────────────────────────────
            TextFormField(
              controller: _locationController,
              validator: (val) => Validators.validateRequired(
                val,
                requiredMessage: l10n.validationFieldRequired(l10n.locationHint),
              ),
              decoration: _inputDecoration(
                  hint: l10n.locationHint),
            ),

            const SizedBox(height: 32),

            // ── Submit for Review button ──────────────────────────────
            DecoratedBox(

              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                  onPressed: _isLoading ? null : _submitAd,
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    l10n.submitForReview,
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

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _submitAd() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty) {
      Fluttertoast.showToast(
        msg: l10n.pleaseAddImage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      final cloudinaryService = CloudinaryService();
      final imageUrls =
      await cloudinaryService.uploadAdImages(_selectedImages);

      final ad = Advertisement(
        id: '',
        sellerId: authState.user.id,
        sellerName: authState.user.name,
        sellerPhone: authState.user.phone,
        sellerProfilePic: authState.user.profilePicUrl,
        sellerVerified: authState.user.isVerified,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        grade: _selectedGrade,
        quantity: _quantityController.text.isNotEmpty
            ? int.parse(_quantityController.text)
            : null,
        location: _locationController.text.trim(),
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );

      final firestoreService = context.read<FirestoreService>();
      await firestoreService.createAdvertisement(ad);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;

        Fluttertoast.showToast(
          msg: l10n.adPostedSuccess,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppColors.accentGreen,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        Navigator.of(context).pop();
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;

      Fluttertoast.showToast(
        msg: l10n.errorPrefix(e.toString()),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.accentRed,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}