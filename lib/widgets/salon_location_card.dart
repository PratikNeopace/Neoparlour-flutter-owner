import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'pin_salon_entrance_modal.dart';
import '../data/models/salon_location_model.dart';
import '../core/data/services/owner_geo_service.dart';
import 'package:geolocator/geolocator.dart';
import '../core/utils/flushbar_helper.dart';

class SalonLocationCard extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? shopOrFlatNo;
  final String? buildingName;
  final String? specificAddress;
  final String? landmark;
  final String? areaName;
  final String? cityName;
  final String? state;
  final List<String>? nearbyLandmarks;
  final ValueChanged<SalonLocationDetails> onLocationChanged;
  final bool enabled;
  final VoidCallback? onBeforeEdit;

  const SalonLocationCard({
    super.key,
    this.latitude,
    this.longitude,
    this.shopOrFlatNo,
    this.buildingName,
    this.specificAddress,
    this.landmark,
    this.areaName,
    this.cityName,
    this.state,
    this.nearbyLandmarks,
    required this.onLocationChanged,
    this.enabled = true,
    this.onBeforeEdit,
  });

  @override
  State<SalonLocationCard> createState() => _SalonLocationCardState();
}

class _SalonLocationCardState extends State<SalonLocationCard> {
  bool _isDetecting = false;

  bool get _isLocationCaptured =>
      widget.latitude != null &&
      widget.longitude != null &&
      widget.latitude != 0.0 &&
      widget.longitude != 0.0 &&
      widget.latitude!.isFinite &&
      widget.longitude!.isFinite;

  Future<void> _handleAutoDetect() async {
    widget.onBeforeEdit?.call();
    if (_isDetecting) return;
    setState(() => _isDetecting = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          FlushbarHelper.show(
            context,
            'Location services are disabled. Please enable GPS in device settings.',
          );
          await Geolocator.openLocationSettings();
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            FlushbarHelper.show(context, 'Location permission denied.');
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          FlushbarHelper.show(
            context,
            'Location permissions permanently denied. Please enable in App Settings.',
          );
          await Geolocator.openAppSettings();
        }
        return;
      }

      if (mounted) {
        FlushbarHelper.show(context, 'Detecting salon location...', isSuccess: true);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final geoService = OwnerGeoService();
      final details = await geoService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      widget.onLocationChanged(details);

      if (mounted) {
        FlushbarHelper.show(
          context,
          'Salon location captured successfully!',
          isSuccess: true,
        );
      }
    } catch (e) {
      debugPrint('Auto detect error: $e');
      if (mounted) {
        FlushbarHelper.show(context, 'Failed to detect location: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isDetecting = false);
      }
    }
  }

  Future<void> _handlePinOnMap() async {
    widget.onBeforeEdit?.call();
    final result = await PinSalonEntranceModal.show(
      context,
      initialLat: widget.latitude,
      initialLng: widget.longitude,
      initialLandmark: widget.landmark,
      initialArea: widget.areaName,
      initialCity: widget.cityName,
      initialState: widget.state,
      initialNearbyLandmarks: widget.nearbyLandmarks,
    );

    if (result != null) {
      widget.onLocationChanged(result);
    }
  }

  Future<void> _openGoogleMapsVerification() async {
    if (!_isLocationCaptured) return;
    final lat = widget.latitude!;
    final lng = widget.longitude!;

    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    try {
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          FlushbarHelper.show(context, 'Could not open map verification link');
        }
      }
    } catch (e) {
      debugPrint('Error launching map url: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB), // Soft warm cream/amber
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 1),
                child: Icon(
                  Icons.location_on,
                  size: 17,
                  color: Color(0xFFB45309),
                ),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'AUTO-DETECT SALON LOCATION',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Color(0xFF78350F),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'PHYSICAL PRESENCE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Instruction Text
          const Text(
            'Please ensure you are currently standing at the salon premises while completing registration. This ensures precise navigation for customers.',
            style: TextStyle(
              fontSize: 11.5,
              color: Color(0xFF92400E),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          // Two Action Buttons: PIN ON MAP & AUTO-DETECT
          Row(
            children: [
              // PIN ON MAP (Dark Slate Pill)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _handlePinOnMap,
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 15,
                    color: Colors.white,
                  ),
                  label: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'PIN ON MAP',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // AUTO-DETECT (Brand Red Pill)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isDetecting ? null : _handleAutoDetect,
                  icon: _isDetecting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.my_location,
                          size: 15,
                          color: Colors.white,
                        ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _isDetecting ? 'DETECTING...' : 'AUTO-DETECT',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF0B01),
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Green Coordinate Verification Status Badge
          if (_isLocationCaptured) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7), // Green 100
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC)), // Green 300
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Color(0xFF15803D),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'GPS: ${widget.latitude!.toStringAsFixed(5)}, ${widget.longitude!.toStringAsFixed(5)}  ✓ Location Captured',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF166534),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: _openGoogleMapsVerification,
                    child: const Text(
                      'Verify ↗',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
