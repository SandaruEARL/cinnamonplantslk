import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/app_colors.dart';
import '../bloc/marketplace_bloc.dart';
import '../bloc/marketplace_event.dart';
import '../bloc/marketplace_state.dart';
import '../../domain/entities/advertisement_entity.dart';

const _cinnamonGrades = [
  'Alba', 'C5 Special', 'C5', 'C4', 'C3', 'C2', 'C1',
  'M5', 'M4', 'H2', 'H1',
  'Hamburg Extra Special', 'Hamburg Special', 'Hamburg', 'Mexican Grade',
];

const _listingCategories = [
  'Cinnamon Plants', 'Cinnamon Sticks', 'Cinnamon Powder',
  'Cinnamon Oil', 'Other',
];

const _announcementCategories = ['Cinnamon Bales', 'Cinnamon Oils'];

class AdEditScreen extends StatefulWidget {
  final AdvertisementEntity ad;
  const AdEditScreen({super.key, required this.ad});

  @override
  State<AdEditScreen> createState() => _AdEditScreenState();
}

class _AdEditScreenState extends State<AdEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _locationCtrl;
  late String _selectedCategory;
  final List<String> _selectedGrades = [];

  late List<String> _existingUrls;
  final List<File> _newImages = [];
  final _picker = ImagePicker();

  bool get _isAnnouncement => widget.ad.type == 'announcement';

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.ad.title);
    _descCtrl = TextEditingController(text: widget.ad.description);
    _priceCtrl =
        TextEditingController(text: widget.ad.price.toStringAsFixed(2));
    _locationCtrl = TextEditingController(text: widget.ad.location);
    _selectedCategory = widget.ad.category;
    _existingUrls = List.from(widget.ad.imageUrls);
    if (widget.ad.grade != null) {
      _selectedGrades.addAll(widget.ad.grade!.split(', '));
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() => _newImages.addAll(picked.map((x) => File(x.path))));
    }
  }

  void _removeExisting(int index) =>
      setState(() => _existingUrls.removeAt(index));

  void _removeNew(int index) => setState(() => _newImages.removeAt(index));

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final price = double.tryParse(_priceCtrl.text.trim());
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid price')),
      );
      return;
    }

    final bloc = context.read<MarketplaceBloc>();
    final grade = _isAnnouncement
        ? (_selectedGrades.isEmpty ? null : _selectedGrades.join(', '))
        : null;

    if (widget.ad.isPending) {
      bloc.add(MarketplaceAdUpdateRequested(
        adId: widget.ad.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory,
        price: price,
        grade: grade,
        location: _locationCtrl.text.trim(),
        existingImageUrls: _isAnnouncement ? [] : _existingUrls,
        newImages: _isAnnouncement ? [] : _newImages,
        type: widget.ad.type,
      ));
    } else {
      bloc.add(MarketplaceAdEditRequested(
        adId: widget.ad.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _selectedCategory,
        price: price,
        grade: grade,
        location: _locationCtrl.text.trim(),
        existingImageUrls: _isAnnouncement ? [] : _existingUrls,
        newImages: _isAnnouncement ? [] : _newImages,
        type: widget.ad.type,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = widget.ad.isApproved;

    return BlocConsumer<MarketplaceBloc, MarketplaceState>(
      listener: (context, state) {
        if (state is MarketplaceAdUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Updated successfully')),
          );
          Navigator.of(context).pop();
        } else if (state is MarketplaceAdEditSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Edit submitted for review. Your current ad stays live.'),
            ),
          );
          Navigator.of(context).pop();
        } else if (state is MarketplaceError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        final isBusy = state is MarketplaceAdCreating;

        return Scaffold(
          appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              _isAnnouncement
                  ? (isLive
                  ? 'Edit Announcement (Live)'
                  : 'Edit Announcement')
                  : (isLive ? 'Edit Listing (Live)' : 'Edit Listing'),
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
                // Live banner
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blue.shade700, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your ${_isAnnouncement ? 'announcement' : 'listing'} will stay live while your edits are reviewed by an admin.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Title
                _FieldLabel('Title'),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDec(_isAnnouncement
                      ? 'Announcement title'
                      : 'Listing title'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Category
                _FieldLabel('Category'),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: _inputDec(''),
                  items: (_isAnnouncement
                      ? _announcementCategories
                      : _listingCategories)
                      .map((c) =>
                      DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedCategory = v ?? _selectedCategory),
                ),
                const SizedBox(height: 14),

                // Price
                _FieldLabel(
                    _isAnnouncement ? 'Offered Price (Rs./kg)' : 'Price (Rs.)'),
                TextFormField(
                  controller: _priceCtrl,
                  decoration: _inputDec('e.g. 1500'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Grade — announcements only
                if (_isAnnouncement) ...[
                  _FieldLabel('Grade (optional)'),
                  _GradeMultiSelect(
                    selected: _selectedGrades,
                    onChanged: (grades) => setState(() {
                      _selectedGrades
                        ..clear()
                        ..addAll(grades);
                    }),
                  ),
                  const SizedBox(height: 14),
                ],

                // Location
                _FieldLabel('Location'),
                TextFormField(
                  controller: _locationCtrl,
                  decoration: _inputDec('e.g. Kandy'),
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Description
                _FieldLabel('Description'),
                TextFormField(
                  controller: _descCtrl,
                  decoration: _inputDec(_isAnnouncement
                      ? 'Describe what you want to buy'
                      : 'Describe your listing'),
                  maxLines: 4,
                  validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 20),

                // Images — listings only
                if (!_isAnnouncement) ...[
                  _FieldLabel('Images'),
                  const SizedBox(height: 8),
                  _ImageGrid(
                    existingUrls: _existingUrls,
                    newImages: _newImages,
                    onPickImages: _pickImages,
                    onRemoveExisting: _removeExisting,
                    onRemoveNew: _removeNew,
                  ),
                  const SizedBox(height: 28),
                ] else
                  const SizedBox(height: 8),

                // Submit
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isBusy ? null : () => _submit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isBusy
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : Text(
                      isLive ? 'Submit for Review' : 'Save Changes',
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

InputDecoration _inputDec(String hint) => InputDecoration(
  hintText: hint,
  contentPadding:
  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade300),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide:
    const BorderSide(color: AppColors.primaryGreen, width: 1.5),
  ),
  filled: true,
  fillColor: Colors.grey.shade50,
);

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary)),
  );
}

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
                          onPressed: () =>
                              setSheetState(() => temp.clear()),
                          child: Text('Clear all',
                              style: TextStyle(
                                  color: Colors.grey.shade500)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      itemCount: _cinnamonGrades.length,
                      separatorBuilder: (_, __) => Divider(
                          height: 1, color: Colors.grey.shade100),
                      itemBuilder: (_, i) {
                        final grade = _cinnamonGrades[i];
                        final isSelected = temp.contains(grade);
                        return InkWell(
                          onTap: () => setSheetState(() => isSelected
                              ? temp.remove(grade)
                              : temp.add(grade)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
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
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
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
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: selected.isEmpty
            ? Row(
          children: [
            const Text('Select grades',
                style: TextStyle(color: Color(0xFFAAAAAA))),
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
                  color: AppColors.primaryGreen
                      .withOpacity(0.1),
                  borderRadius:
                  BorderRadius.circular(20),
                ),
                child: Text(g,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w500,
                    )),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final List<String> existingUrls;
  final List<File> newImages;
  final VoidCallback onPickImages;
  final void Function(int) onRemoveExisting;
  final void Function(int) onRemoveNew;

  const _ImageGrid({
    required this.existingUrls,
    required this.newImages,
    required this.onPickImages,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...existingUrls.asMap().entries.map((e) => _Thumb(
          child: CachedNetworkImage(
            imageUrl: e.value,
            fit: BoxFit.cover,
            width: 80,
            height: 80,
          ),
          onRemove: () => onRemoveExisting(e.key),
        )),
        ...newImages.asMap().entries.map((e) => _Thumb(
          child: Image.file(e.value,
              fit: BoxFit.cover, width: 80, height: 80),
          onRemove: () => onRemoveNew(e.key),
        )),
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.add_photo_alternate_outlined,
                color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;
  const _Thumb({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(width: 80, height: 80, child: child),
      ),
      Positioned(
        top: 2,
        right: 2,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
                color: Colors.black54, shape: BoxShape.circle),
            child: const Icon(Icons.close,
                size: 14, color: Colors.white),
          ),
        ),
      ),
    ],
  );
}