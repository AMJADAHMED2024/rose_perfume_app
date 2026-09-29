import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/widgets/app_skeleton.dart';

class SelectedLocation {
  const SelectedLocation(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

Future<SelectedLocation?> showLocationPicker(
  BuildContext context, {
  double? latitude,
  double? longitude,
}) => showModalBottomSheet<SelectedLocation>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _LocationPickerSheet(
    initial: LatLng(latitude ?? 24.7136, longitude ?? 46.6753),
  ),
);

class LocationPickerButton extends StatelessWidget {
  const LocationPickerButton({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onChanged,
  });

  final double? latitude;
  final double? longitude;
  final ValueChanged<SelectedLocation> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = latitude != null && longitude != null;
    return OutlinedButton.icon(
      onPressed: () async {
        final location = await showLocationPicker(
          context,
          latitude: latitude,
          longitude: longitude,
        );
        if (location != null) onChanged(location);
      },
      icon: Icon(
        selected ? Icons.location_on : Icons.add_location_alt_outlined,
      ),
      label: Text(
        selected
            ? 'الموقع: ${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
            : 'حدد موقع التوصيل على الخريطة',
      ),
    );
  }
}

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({required this.initial});

  final LatLng initial;

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late final MapController _mapController;
  late LatLng _selected;
  bool _locating = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selected = widget.initial;
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _message = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const _LocationException(
          'فعّل خدمة الموقع في الهاتف ثم حاول مرة أخرى.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const _LocationException(
          'يلزم السماح بالموقع لتحديد العنوان الحالي.',
        );
      }
      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _selected = location);
      _mapController.move(location, 16);
    } on _LocationException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _message = 'تعذر الحصول على الموقع الحالي. اختر النقطة يدويًا.',
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .78,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حدد موقع التوصيل',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('المس الخريطة لوضع العلامة بدقة.'),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'استخدم موقعي الحالي',
                  onPressed: _locating ? null : _useCurrentLocation,
                  icon: _locating
                      ? const SkeletonInline(size: 20)
                      : const Icon(Icons.my_location_outlined),
                ),
              ],
            ),
          ),
          if (_message case final message?)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                message,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selected,
                initialZoom: 12,
                onTap: (_, point) => setState(() => _selected = point),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.roseperfume.rose_perfume_app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selected,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(
                  context,
                  SelectedLocation(_selected.latitude, _selected.longitude),
                ),
                icon: const Icon(Icons.check),
                label: const Text('تأكيد موقع التوصيل'),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _LocationException implements Exception {
  const _LocationException(this.message);
  final String message;
}
