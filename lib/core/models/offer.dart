class Offer {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final DateTime validUntil;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.validUntil,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      discountPercentage: (json['discountPercentage'] ?? 0).toDouble(),
      validUntil: DateTime.parse(
        json['validUntil'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'validUntil': validUntil.toIso8601String(),
    };
  }
}
