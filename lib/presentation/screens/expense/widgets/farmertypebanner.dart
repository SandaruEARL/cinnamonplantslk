import 'package:flutter/material.dart';
import '../../../../domain/entities/farmertype.dart';

class _FarmerTypeBanner extends StatelessWidget {
  final FarmerTypeConfig config;
  const _FarmerTypeBanner({required this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: config.color.withOpacity(0.08),
      child: Row(
        children: [
          Text(config.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                config.label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: config.color,
                ),
              ),
              Text(
                'Tracking: ${config.termLabel}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}