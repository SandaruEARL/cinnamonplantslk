import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'constants.dart';

extension CategoryLocalizer on AppLocalizations {
  /// Returns the localized display label for a canonical category key.
  String localizedCategory(String canonicalKey) {
    switch (canonicalKey) {
      case 'Cinnamon Plants':  return categoryCinnamonPlants;
      case 'Cinnamon Bales':   return categoryCinnamonBales;
      case 'Cinnamon Oil':     return categoryCinnamonOil;
      case 'Cinnamon Soap':    return categoryCinnamonSoap;
      case 'Cinnamon Scents':  return categoryCinnamonScents;
      case 'Other Products':   return categoryOtherProducts;
      default:                 return canonicalKey; // fallback
    }
  }

  /// Returns all categories as localized label → canonical key pairs.
  List<({String label, String value})> get localizedCategories {
    return AppConstants.productCategories.map((key) {
      return (label: localizedCategory(key), value: key);
    }).toList();
  }
}