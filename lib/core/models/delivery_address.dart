class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.title,
    required this.street,
    required this.city,
    required this.country,
    this.countryCode,
    this.nationalAddressShortCode,
    this.latitude,
    this.longitude,
    this.isPrimary = false,
  });

  final int id;
  final String title;
  final String street;
  final String city;
  final String country;
  final String? countryCode;
  final String? nationalAddressShortCode;
  final double? latitude;
  final double? longitude;
  final bool isPrimary;

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: _asInt(json['id']),
        title: json['title']?.toString() ?? 'عنوان التوصيل',
        street: json['street']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        country: json['country']?.toString() ?? 'Saudi Arabia',
        countryCode: json['countryCode']?.toString(),
        nationalAddressShortCode: json['nationalAddressShortCode']?.toString(),
        latitude: _asNullableDouble(json['latitude']),
        longitude: _asNullableDouble(json['longitude']),
        isPrimary: json['isPrimary'] == true,
      );
}

int _asInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;

double? _asNullableDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
