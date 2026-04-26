import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/validators.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/advertisement_entity.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';

// ── Announcement categories & grades ────────────────────────────────────────

const _announcementCategories = ['Cinnamon Bales', 'Cinnamon Oils'];

const _cinnamonGrades = [
  'Alba',
  'C5 Special',
  'C5',
  'C4',
  'C3',
  'C2',
  'C1',
  'M5',
  'M4',
  'H2',
  'H1',
  'Hamburg Extra Special',
  'Hamburg Special',
  'Hamburg',
  'Mexican Grade',
];

// ────────────────────────────────────────────────────────────────────────────

class PostAdScreen extends StatefulWidget {
  final String type; // 'listing' | 'announcement'
  final AdvertisementEntity? existing;
  const PostAdScreen({super.key, this.type = 'listing', this.existing,});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedCategory = _announcementCategories[0];
  final List<String> _selectedGrades = [];
  final List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];

  bool get _isAnnouncement => widget.type == 'announcement';
  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _titleController.text = e.title;
      _descriptionController.text = e.description;
      _priceController.text = e.price.toString();
      _locationController.text = e.location;
      _selectedCategory = e.category;
      _existingImageUrls = List.from(e.imageUrls);
      if (e.grade != null) {
        _selectedGrades.addAll(e.grade!.split(', '));
      }
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
      borderSide:
      const BorderSide(color: AppColors.primaryGreen, width: 1.5),
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
      create: (_) => sl<MarketplaceBloc>(),
      child: BlocListener<MarketplaceBloc, MarketplaceState>(
        listener: (context, state) {
          if (state is MarketplaceAdCreated) {
            Fluttertoast.showToast(
              msg: _isAnnouncement
                  ? 'Announcement posted successfully!'
                  : l10n.adPostedSuccess,
              backgroundColor: AppColors.accentGreen,
              textColor: Colors.white,
            );
            Navigator.of(context).pop();
          } else if (state is MarketplaceError) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: AppColors.accentRed,
              textColor: Colors.white,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              _isAnnouncement ? 'Post Buying Announcement' : l10n.postAd,
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
                // ── Announcement banner (green, not orange) ──────────────
                if (_isAnnouncement) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.primaryGreen, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You\'re posting a buying announcement. Sellers will contact you directly.',
                            style: TextStyle(
                                color: AppColors.primaryGreen, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Image picker — listings only ─────────────────────────
                if (!_isAnnouncement) ...[
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
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 32, color: Color(0xFFAAAAAA)),
                                SizedBox(height: 6),
                                Text('Add image',
                                    style:
                                    TextStyle(color: Color(0xFFAAAAAA))),
                              ],
                            ),
                          ),
                        ),
                        ..._selectedImages.map((image) => Stack(
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
                                onTap: () => setState(
                                        () => _selectedImages.remove(image)),
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
                  const SizedBox(height: 16),
                ],

                // ── Category ─────────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDecoration(hint: 'Category'),
                  items: (_isAnnouncement
                      ? _announcementCategories
                      : AppConstants.productCategories)
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 16),

                // ── Title ────────────────────────────────────────────────
                TextFormField(
                  controller: _titleController,
                  validator: (val) => Validators.validateRequired(val,
                      requiredMessage:
                      l10n.validationFieldRequired(l10n.titleHint)),
                  decoration: _inputDecoration(
                    hint: _isAnnouncement
                        ? 'e.g. Looking for Alba grade cinnamon bales'
                        : l10n.titleHint,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Description ──────────────────────────────────────────
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  validator: (val) => Validators.validateRequired(val,
                      requiredMessage: l10n.validationFieldRequired(
                          l10n.descriptionHint)),
                  decoration: _inputDecoration(
                    hint: _isAnnouncement
                        ? 'Describe what you are looking for, preferred quality, etc.'
                        : l10n.descriptionHint,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Price ────────────────────────────────────────────────
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (val) => Validators.validatePrice(val,
                      requiredMessage: l10n.validationPriceRequired,
                      invalidMessage: l10n.validationPriceInvalid),
                  decoration: _inputDecoration(
                    hint: _isAnnouncement
                        ? 'Offered price (LKR/kg)'
                        : l10n.priceHint,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Grade multi-select ────────────────────────────────────
                _GradeMultiSelect(
                  selected: _selectedGrades,
                  onChanged: (grades) =>
                      setState(() {
                        _selectedGrades
                          ..clear()
                          ..addAll(grades);
                      }),
                ),
                const SizedBox(height: 16),

                // ── Location ─────────────────────────────────────────────
                TextFormField(
                  controller: _locationController,
                  validator: (val) => Validators.validateRequired(val,
                      requiredMessage: l10n.validationFieldRequired(
                          l10n.locationHint)),
                  decoration: _inputDecoration(hint: l10n.locationHint),
                ),
                const SizedBox(height: 32),

                // ── Submit ────────────────────────────────────────────────
                BlocBuilder<MarketplaceBloc, MarketplaceState>(
                  builder: (context, state) {
                    final isLoading = state is MarketplaceAdCreating;
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed:
                        isLoading ? null : () => _submitAd(context),
                        child: isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                                Colors.white),
                          ),
                        )
                            : Text(
                          _isAnnouncement
                              ? 'Post Announcement'
                              : l10n.submitForReview,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
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

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(
              () => _selectedImages.addAll(images.map((x) => File(x.path))));
    }
  }

  void _submitAd(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_isAnnouncement && _selectedImages.isEmpty) {
      Fluttertoast.showToast(msg: l10n.pleaseAddImage);
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    context.read<MarketplaceBloc>().add(MarketplaceAdCreateRequested(
      sellerId: authState.user.id,
      sellerName: authState.user.name,
      sellerPhone: authState.user.phone,
      sellerProfilePic: authState.user.profilePicUrl,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      price: double.parse(_priceController.text),
      grade: _selectedGrades.isEmpty ? null : _selectedGrades.join(', '),
      quantity: null, // removed qty field
      location: _locationController.text.trim(),
      images: _selectedImages,
      type: widget.type,
    ));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}

// ── Grade multi-select widget ────────────────────────────────────────────────

class _GradeMultiSelect extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  const _GradeMultiSelect({
    required this.selected,
    required this.onChanged,
  });

  void _openSheet(BuildContext context) {
    final temp = List<String>.from(selected);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            maxChildSize: 0.85,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        'Select Grades',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (temp.isNotEmpty)
                        TextButton(
                          onPressed: () => setSheetState(() => temp.clear()),
                          child: Text(
                            'Clear all',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _cinnamonGrades.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final grade = _cinnamonGrades[i];
                        final isSelected = temp.contains(grade);
                        return InkWell(
                          onTap: () => setSheetState(() => isSelected
                              ? temp.remove(grade)
                              : temp.add(grade)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              children: [
                                Text(
                                  grade,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primaryGreen
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : Colors.grey.shade300,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {
                            onChanged(List.from(temp));
                            Navigator.pop(context);
                          },
                          child: Text(
                            temp.isEmpty
                                ? 'Confirm'
                                : 'Confirm (${temp.length})',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: selected.isEmpty
            ? Row(
          children: [
            const Text(
              'Select grades',
              style: TextStyle(color: Color(0xFFAAAAAA)),
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down,
                color: Colors.grey.shade400, size: 20),
          ],
        )
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${selected.length} grade${selected.length > 1 ? 's' : ''} selected',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: selected
                  .map((g) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  g,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}