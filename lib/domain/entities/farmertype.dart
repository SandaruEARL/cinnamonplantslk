import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

enum FarmerType { landOwner, nurseryOwner, baleBuyer }

class FarmerTypeConfig {
  final FarmerType type;
  final String label;
  final String emoji;
  final Color color;
  final List<ExpenseCategory> expenseCategories;
  final String termLabel; // e.g. "Season (6 months)"
  final bool hasProfitTracking;
  final String? profitLabel;

  const FarmerTypeConfig({
    required this.type,
    required this.label,
    required this.emoji,
    required this.color,
    required this.expenseCategories,
    required this.termLabel,
    this.hasProfitTracking = false,
    this.profitLabel,
  });

  static const landOwner = FarmerTypeConfig(
    type: FarmerType.landOwner,
    label: 'Land Owner',
    emoji: '',
    color: Color(0xFF2E7D32),
    termLabel: 'Season (6 months)',
    hasProfitTracking: true,
    profitLabel: 'Cinnamon Sale Revenue',
    expenseCategories: [
      ExpenseCategory(
        key: 'Fertilizer',
        label: 'Fertilizer',
        icon: null,
        color: Color(0xFF10b981),
        hint: 'e.g., Eppawala Rock Phosphate, Urea bags',
      ),
      ExpenseCategory(
        key: 'Labor',
        label: 'Labor Cost',
        icon: null,
        color: Color(0xFF3b82f6),
        hint: 'e.g., Weeding, pruning, harvesting workers',
      ),
      ExpenseCategory(
        key: 'WaterIrrigation',
        label: 'Water / Irrigation',
        icon: null,
        color: Color(0xFF06b6d4),
        hint: 'e.g., Pump fuel, irrigation pipes',
      ),
      ExpenseCategory(
        key: 'BabyPlants',
        label: 'Baby Plants (Seedlings)',
        icon: null,
        color: Color(0xFF84cc16),
        hint: 'e.g., Seedlings bought from nursery for gap filling',
      ),
      ExpenseCategory(
        key: 'Pesticides',
        label: 'Pesticides / Weed Control',
        icon: null,
        color: Color(0xFFec4899),
        hint: 'e.g., Fungicide, herbicide',
      ),
      ExpenseCategory(
        key: 'ProcessingWorkers',
        label: 'Processing Workers Share',
        icon: null,
        color: Color(0xFFf59e0b),
        hint: 'Peelers typically receive 1/3 to 1/2 of processed cinnamon value',
      ),
      ExpenseCategory(
        key: 'Transport',
        label: 'Transport',
        icon: null,
        color: Color(0xFF8b5cf6),
        hint: 'e.g., Delivery to bale buyer or factory',
      ),
      ExpenseCategory(
        key: 'Tools',
        label: 'Tools / Equipment',
        icon: null,
        color: Color(0xFFef4444),
        hint: 'e.g., Keththa knives, grass cutters',
      ),
      ExpenseCategory(
        key: 'Other',
        label: 'Other',
        icon: null,
        color: Color(0xFF6b7280),
        hint: '',
      ),
    ],
  );

  static const nurseryOwner = FarmerTypeConfig(
    type: FarmerType.nurseryOwner,
    label: 'Nursery Owner',
    emoji: '🪴',
    color: Color(0xFF388E3C),
    termLabel: 'Batch / Month',
    hasProfitTracking: true,
    profitLabel: 'Seedling Sales Revenue',
    expenseCategories: [
      ExpenseCategory(
        key: 'CinnamonSeeds',
        label: 'Cinnamon Seeds / Cuttings',
        icon: null,
        color: Color(0xFF10b981),
        hint: 'e.g., Seeds or stem cuttings for propagation',
      ),
      ExpenseCategory(
        key: 'Polythene',
        label: 'Polythene Bags',
        icon: null,
        color: Color(0xFF3b82f6),
        hint: 'e.g., 8×5 inch 250-gauge or 12×10 inch 300-gauge bags',
      ),
      ExpenseCategory(
        key: 'PottingMix',
        label: 'Potting Mix / Soil',
        icon: null,
        color: Color(0xFF92400e),
        hint: 'e.g., Topsoil, river sand, coir dust, dried cow dung',
      ),
      ExpenseCategory(
        key: 'ShadeNetting',
        label: 'Shade Netting / Structure',
        icon: null,
        color: Color(0xFF6366f1),
        hint: 'e.g., Shade cloth for first 2 months of nursery',
      ),
      ExpenseCategory(
        key: 'Labor',
        label: 'Labor Cost',
        icon: null,
        color: Color(0xFFf59e0b),
        hint: 'e.g., Seeding, watering, transplanting workers',
      ),
      ExpenseCategory(
        key: 'Water',
        label: 'Water / Irrigation',
        icon: null,
        color: Color(0xFF06b6d4),
        hint: 'e.g., Regular watering system costs',
      ),
      ExpenseCategory(
        key: 'Fertilizer',
        label: 'Fertilizer / Nutrients',
        icon: null,
        color: Color(0xFF84cc16),
        hint: 'e.g., Eppawala Rock Phosphate (25g per pit)',
      ),
      ExpenseCategory(
        key: 'PestControl',
        label: 'Pest & Disease Control',
        icon: null,
        color: Color(0xFFec4899),
        hint: 'e.g., Fungicide for Fusarium, pest sprays',
      ),
      ExpenseCategory(
        key: 'Transport',
        label: 'Transport / Delivery',
        icon: null,
        color: Color(0xFF8b5cf6),
        hint: 'e.g., Delivery of seedlings to farmers',
      ),
      ExpenseCategory(
        key: 'Other',
        label: 'Other',
        icon: null,
        color: Color(0xFF6b7280),
        hint: '',
      ),
    ],
  );

  static const baleBuyer = FarmerTypeConfig(
    type: FarmerType.baleBuyer,
    label: 'Bale Buyer Shop',
    emoji: '',
    color: Color(0xFF1B5E20),
    termLabel: 'Month',
    hasProfitTracking: true,
    profitLabel: 'Cinnamon Sales Revenue',
    expenseCategories: [
      ExpenseCategory(
        key: 'CinnamonPurchase',
        label: 'Cinnamon Bale Purchase',
        icon: null,
        color: Color(0xFF10b981),
        hint: 'e.g., Raw cinnamon bales bought from farmers',
      ),
      ExpenseCategory(
        key: 'PeelingLabor',
        label: 'Peeling / Processing Labor',
        icon: null,
        color: Color(0xFF3b82f6),
        hint: 'e.g., Skilled peelers (LKR 1,000-1,800/day)',
      ),
      ExpenseCategory(
        key: 'SortingGrading',
        label: 'Sorting & Grading Labor',
        icon: null,
        color: Color(0xFF8b5cf6),
        hint: 'e.g., Grading into Alba, C4, C5, Hamburg grades',
      ),
      ExpenseCategory(
        key: 'ExportCess',
        label: 'Export Cess / Tax',
        icon: null,
        color: Color(0xFFef4444),
        hint: 'e.g., Government export cess per kg',
      ),
      ExpenseCategory(
        key: 'Packaging',
        label: 'Packaging',
        icon: null,
        color: Color(0xFFf59e0b),
        hint: 'e.g., Bale wrapping, quill packaging, labels',
      ),
      ExpenseCategory(
        key: 'Storage',
        label: 'Storage / Warehouse',
        icon: null,
        color: Color(0xFF06b6d4),
        hint: 'e.g., Rent, fumigation, drying costs',
      ),
      ExpenseCategory(
        key: 'Transport',
        label: 'Transport / Logistics',
        icon: null,
        color: Color(0xFF84cc16),
        hint: 'e.g., Delivery to exporter or port',
      ),
      ExpenseCategory(
        key: 'QualityTesting',
        label: 'Quality Testing / Certification',
        icon: null,
        color: Color(0xFFec4899),
        hint: 'e.g., Lab tests, GMP certification costs',
      ),
      ExpenseCategory(
        key: 'Other',
        label: 'Other',
        icon: null,
        color: Color(0xFF6b7280),
        hint: '',
      ),
    ],
  );

  static FarmerTypeConfig fromString(String key) {
    switch (key) {
      case 'nurseryOwner': return nurseryOwner;
      case 'baleBuyer': return baleBuyer;
      default: return landOwner;
    }
  }

  String get typeKey {
    switch (type) {
      case FarmerType.landOwner: return 'landOwner';
      case FarmerType.nurseryOwner: return 'nurseryOwner';
      case FarmerType.baleBuyer: return 'baleBuyer';
    }
  }

  List<String> get categoryKeys => expenseCategories.map((e) => e.key).toList();
}

class ExpenseCategory {
  final String key;
  final String label;
  final IconData? icon;
  final Color color;
  final String hint;

  const ExpenseCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.hint,
  });
}

extension FarmerTypeL10n on FarmerTypeConfig {
  String localizedLabel(AppLocalizations l10n) {
    switch (type) {
      case FarmerType.landOwner:    return l10n.landOwnerLabel;
      case FarmerType.nurseryOwner: return l10n.nurseryOwnerLabel;
      case FarmerType.baleBuyer:    return l10n.baleBuyerShopLabel;
    }
  }

  String localizedTermLabel(AppLocalizations l10n) {
    switch (type) {
      case FarmerType.landOwner:    return l10n.farmerTypeTermLandOwner;
      case FarmerType.nurseryOwner: return l10n.farmerTypeTermNurseryOwner;
      case FarmerType.baleBuyer:    return l10n.farmerTypeTermBaleBuyer;
    }
  }

  String localizedProfitLabel(AppLocalizations l10n) {
    switch (type) {
      case FarmerType.landOwner:    return l10n.farmerTypeProfitLabelLandOwner;
      case FarmerType.nurseryOwner: return l10n.farmerTypeProfitLabelNurseryOwner;
      case FarmerType.baleBuyer:    return l10n.farmerTypeProfitLabelBaleBuyer;
    }
  }
}