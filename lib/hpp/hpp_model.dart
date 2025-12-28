class HppItem {
  final int id;
  final String name;
  final String type;
  final double quantity;
  final String? unit;
  final int materialCost;
  final int laborCost;
  final int overheadCost;
  final int otherCost;
  final int totalCost;
  final double costPerUnit;
  final String? aiRecommendation;
  final int? aiSuggestedPrice;
  final double? aiSuggestedMargin;
  final double? aiSuggestedMarkup;
  final DateTime createdAt;

  const HppItem({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.materialCost,
    required this.laborCost,
    required this.overheadCost,
    required this.otherCost,
    required this.totalCost,
    required this.costPerUnit,
    required this.aiRecommendation,
    required this.aiSuggestedPrice,
    required this.aiSuggestedMargin,
    required this.aiSuggestedMarkup,
    required this.createdAt,
  });

  factory HppItem.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, [double fallback = 0]) {
      if (value == null) return fallback;
      final parsed = double.tryParse(value.toString());
      return parsed ?? fallback;
    }

    int parseInt(dynamic value, [int fallback = 0]) {
      if (value == null) return fallback;
      final parsed = int.tryParse(value.toString());
      return parsed ?? fallback;
    }

    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      return DateTime.tryParse(value.toString()) ?? DateTime.now();
    }

    return HppItem(
      id: parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? 'PRODUCT').toString(),
      quantity: parseDouble(json['quantity'], 1),
      unit: json['unit']?.toString(),
      materialCost: parseInt(json['materialCost']),
      laborCost: parseInt(json['laborCost']),
      overheadCost: parseInt(json['overheadCost']),
      otherCost: parseInt(json['otherCost']),
      totalCost: parseInt(json['totalCost']),
      costPerUnit: parseDouble(json['costPerUnit']),
      aiRecommendation: json['aiRecommendation']?.toString(),
      aiSuggestedPrice: json['aiSuggestedPrice'] == null
          ? null
          : parseInt(json['aiSuggestedPrice']),
      aiSuggestedMargin: json['aiSuggestedMargin'] == null
          ? null
          : parseDouble(json['aiSuggestedMargin']),
      aiSuggestedMarkup: json['aiSuggestedMarkup'] == null
          ? null
          : parseDouble(json['aiSuggestedMarkup']),
      createdAt: parseDate(json['createdAt']),
    );
  }
}
