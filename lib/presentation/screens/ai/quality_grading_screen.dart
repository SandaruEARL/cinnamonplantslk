import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/app_colors.dart';
import '../../../data/services/ai/tflite_service.dart';


class QualityGradingScreen extends StatefulWidget {
  const QualityGradingScreen({super. key});

  @override
  State<QualityGradingScreen> createState() => _QualityGradingScreenState();
}

class _QualityGradingScreenState extends State<QualityGradingScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  File? _selectedImage;
  Map<String, dynamic>? _gradeResult;
  bool _isProcessing = false;
  final List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.high,
        );
        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Camera initialization error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Grading'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Camera/Image Preview
            _buildImageSection(),

            const SizedBox(height: 16),

            // Action Buttons
            _buildActionButtons(),

            const SizedBox(height: 24),

            // Results
            if (_gradeResult != null) _buildResults(),

            // History
            if (_history.isNotEmpty) _buildHistory(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _selectedImage != null
            ? Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              _selectedImage!,
              fit: BoxFit.contain,
            ),
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        )
            : _isCameraInitialized
            ?  CameraPreview(_cameraController!)
            : const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton. icon(
              onPressed: _isProcessing ? null : _capturePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton. styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isProcessing ?  null : _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final grade = _gradeResult! ['grade'] as String;
    final confidence = _gradeResult!['confidence'] as double;
    final probabilities = _gradeResult!['probabilities'] as Map<String, dynamic>;

    return Padding(
      padding: const EdgeInsets. all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grading Result',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Main result card
          Card(
            elevation: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.verified,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Grade: $grade',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Confidence: ${confidence.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Detailed probabilities
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detailed Analysis',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ... probabilities.entries.map((entry) {
                    final prob = entry. value as double;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(entry.key),
                              Text(
                                '${prob.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: prob / 100,
                            backgroundColor: AppColors.divider,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryBrown,
                            ),
                          ),
                        ],
                      ),
                    );
                  }). toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text(
          'Previous Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._history.reversed.take(5).map((result) {
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBrown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.accentGreen,
            ),
          ),
          title: Text(
            'Grade: ${result['grade']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${result['confidence'].toStringAsFixed(1)}% confidence',
          ),
          trailing: Text(
            result['timestamp'],
            style: const TextStyle(fontSize: 12),
          ),
        ),
      );
    }).toList(),
    ],
    ),
    );
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!. takePicture();
      setState(() {
        _selectedImage = File(photo.path);
      });
      await _processImage();
    } catch (e) {
      _showError('Failed to capture photo: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      await _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final tfliteService = context.read<TFLiteService>();
      final result = await tfliteService.predictGrade(_selectedImage!);

      setState(() {
        _gradeResult = result;
        _isProcessing = false;
        _history.add({
          ... result,
          'timestamp': DateTime.now().toString(). substring(0, 16),
        });
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to process image: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger. of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accentRed,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super. dispose();
  }
}