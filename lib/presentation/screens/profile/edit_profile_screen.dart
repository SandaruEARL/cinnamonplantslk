import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/services/firebase/auth_service.dart';
import '../../../domain/entities/user.dart';
import '../../../l10n/app_localizations.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget. user.name);
    _phoneController = TextEditingController(text: widget.user.phone);
    _locationController = TextEditingController(text: widget.user. location ??  '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfileTitle),
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
            const SizedBox(height: 16),
            TextFormField(
              initialValue: widget.user.userType,
              readOnly: true,
              decoration: InputDecoration(
                labelText: l10n.roleLabel,
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              validator: (val) => Validators.validateRequired(
                val,
                requiredMessage: l10n.validationFieldRequired(l10n.hintNurseryName),
              ),
              decoration: InputDecoration(
                  labelText: l10n.fullNameLabel,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              validator: (val) => Validators.validatePhone(
                val,
                requiredMessage: l10n.validationPhoneRequired,
                invalidMessage: l10n.validationPhoneInvalid,
              ),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  labelText: l10n.phoneNumberLabel,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: l10n.locationLabel,
                  hintText: l10n.locationHintEdit,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
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
                  : Text(l10n.saveChanges),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    final l10n = AppLocalizations.of(context)!;
    if (! _formKey.currentState!. validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().updateUserProfile(
        uid: widget.user.id,
        name: _nameController. text. trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text. trim(),
      );

      // Refresh user data
      context.read<AuthBloc>().add(AuthCheckRequested());

      if (mounted) {
        Fluttertoast.showToast(
          msg: l10n.profileUpdatedSuccess,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black45,
          textColor: Colors.white,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error: $e',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade400,
        textColor: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}