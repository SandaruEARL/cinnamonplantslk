import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/constants.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/firebase/firestore_service.dart';
import '../../../data/services/firebase/storage_service.dart';
import '../../../domain/entities/advertisement.dart';
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
  String?  _selectedGrade;
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Advertisement'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
            // Image Picker
            const Text(
            'Product Images',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                // Add image button
                GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.divider, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 40),
                      SizedBox(height: 8),
                      Text('Add Photos'),
                    ],
                  ),
                ),
              ),
              // Selected images
              ..._selectedImages.map((image) {
      return Stack(
      children: [
      Container(
      width: 120,
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
      onTap: () {
      setState(() {
      _selectedImages.remove(image);
      });
      },
      child: Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
      color: Colors.red,
      shape: BoxShape.circle,
      ),
      child: const Icon(
      Icons.close,
      color: Colors. white,
      size: 16,
      ),
      ),
      ),
      ),
      ],
      );
      }).toList(),
      ],
    ),
    ),

    const SizedBox(height: 24),

    // Category
    DropdownButtonFormField<String>(
    value: _selectedCategory,
    decoration: const InputDecoration(
    labelText: 'Category',
    prefixIcon: Icon(Icons.category),
    ),
    items: AppConstants. productCategories.map((category) {
    return DropdownMenuItem(
    value: category,
    child: Text(category),
    );
    }).toList(),
    onChanged: (value) {
    setState(() {
    _selectedCategory = value! ;
    });
    },
    ),

    const SizedBox(height: 16),

    // Title
    TextFormField(
    controller: _titleController,
    validator: (value) => Validators.validateRequired(value, 'Title'),
    decoration: const InputDecoration(
    labelText: 'Title',
    prefixIcon: Icon(Icons. title),
    hintText: 'e.g., Premium Alba Grade Cinnamon',
    ),
    ),

    const SizedBox(height: 16),

    // Description
    TextFormField(
    controller: _descriptionController,
    validator: (value) => Validators. validateRequired(value, 'Description'),
    maxLines: 4,
    decoration: const InputDecoration(
    labelText: 'Description',
    prefixIcon: Icon(Icons.description),
    hintText: 'Describe your product in detail.. .',
    alignLabelWithHint: true,
    ),
    ),

    const SizedBox(height: 16),

    // Price and Quantity Row
    Row(
    children: [
    Expanded(
    child: TextFormField(
    controller: _priceController,
    validator: Validators.validatePrice,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
    labelText: 'Price (Rs.)',
    prefixIcon: Icon(Icons.attach_money),
    ),
    ),
    ),
    const SizedBox(width: 16),
    Expanded(
    child: TextFormField(
    controller: _quantityController,
    keyboardType: TextInputType.number,
    decoration: const InputDecoration(
    labelText: 'Quantity (optional)',
    prefixIcon: Icon(Icons.inventory),
    ),
    ),
    ),
    ],
    ),

    const SizedBox(height: 16),

    // Grade (for cinnamon bales)
    if (_selectedCategory. contains('Bales'))
    DropdownButtonFormField<String>(
    value: _selectedGrade,
    decoration: const InputDecoration(
    labelText: 'Grade',
    prefixIcon: Icon(Icons.grade),
    ),
    items: AppConstants.cinnamonGrades.map((grade) {
    return DropdownMenuItem(
    value: grade,
    child: Text(grade),
    );
    }).toList(),
    onChanged: (value) {
    setState(() {
    _selectedGrade = value;
    });
    },
    ),

    if (_selectedCategory.contains('Bales')) const SizedBox(height: 16),

    // Location
    TextFormField(
    controller: _locationController,
    validator: (value) => Validators.validateRequired(value, 'Location'),
    decoration: const InputDecoration(
    labelText: 'Location',
    prefixIcon: Icon(Icons.location_on),
    hintText: 'e.g., Matale, Central Province',
    ),
    ),

    const SizedBox(height: 32),

    // Submit Button
    ElevatedButton(
    onPressed: _isLoading ? null : _submitAd,
    style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 16),
    ),
    child: _isLoading
    ? const SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    ),
    )
        : const Text('Post Advertisement'),
    ),
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
        _selectedImages.addAll(images. map((xFile) => File(xFile.path)));
      });
    }
  }

  Future<void> _submitAd() async {
    if (! _formKey.currentState! .validate()) return;

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _isLoading = true);

    try {
      // Upload images
      final storageService = context.read<StorageService>();
      final adId = DateTime.now().millisecondsSinceEpoch. toString();
      final imageUrls = await storageService.uploadAdImages(adId, _selectedImages);

      // Create advertisement
      final ad = Advertisement(
        id: adId,
        sellerId: authState.user.id,
        sellerName: authState.user. name,
        sellerPhone: authState.user.phone,
        sellerProfilePic: authState.user. profilePicUrl,
        sellerVerified: authState.user.isVerified,
        title: _titleController.text. trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        price: double.parse(_priceController.text),
        grade: _selectedGrade,
        quantity: _quantityController.text. isNotEmpty
            ? int.parse(_quantityController.text)
            : null,
        location: _locationController.text. trim(),
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
      );

      // Save to Firestore
      final firestoreService = context.read<FirestoreService>();
      await firestoreService.createAdvertisement(ad);

      if (mounted) {
        ScaffoldMessenger.of(context). showSnackBar(
          const SnackBar(
            content: Text('Advertisement posted successfully!'),
            backgroundColor: AppColors.accentGreen,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.accentRed,
        ),
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