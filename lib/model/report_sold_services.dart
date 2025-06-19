class ReportSoldServices {
  final int servicesId;
  final String servicesName;
  final String dateRange;
  final int servicesSold;

  ReportSoldServices({
    required this.servicesId,
    required this.servicesName,
    required this.servicesSold,
    required this.dateRange,
  });

  factory ReportSoldServices.fromJson(Map<String, dynamic> json) {
    return ReportSoldServices(
      servicesId: json['services_id'] as int,
      servicesName: json['services_name'],
      servicesSold: json['services_sold'],
      dateRange: json['date_range'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'services_id': servicesId,
      'services_name': servicesName,
      'services_sold': servicesSold,
      'date_range': dateRange,
    };
  }
}
