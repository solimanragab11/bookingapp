class PlaceStatsModel {
  final String id;
  final String name;
  final double revenue;
  final int appHours;
  final int manualHours;

  PlaceStatsModel({
    required this.id,
    required this.name,
    this.revenue = 0,
    this.appHours = 0,
    this.manualHours = 0,
  });
}
