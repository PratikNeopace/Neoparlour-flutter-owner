import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/salon_location_model.dart';
import '../core/data/services/owner_geo_service.dart';

class PinSalonEntranceModal extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialShopNo;
  final String? initialBuilding;
  final String? initialSpecificAddress;
  final String? initialLandmark;
  final String? initialArea;
  final String? initialCity;
  final String? initialState;
  final List<String>? initialNearbyLandmarks;

  const PinSalonEntranceModal({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialShopNo,
    this.initialBuilding,
    this.initialSpecificAddress,
    this.initialLandmark,
    this.initialArea,
    this.initialCity,
    this.initialState,
    this.initialNearbyLandmarks,
  });

  static Future<SalonLocationDetails?> show(
    BuildContext context, {
    double? initialLat,
    double? initialLng,
    String? initialShopNo,
    String? initialBuilding,
    String? initialSpecificAddress,
    String? initialLandmark,
    String? initialArea,
    String? initialCity,
    String? initialState,
    List<String>? initialNearbyLandmarks,
  }) {
    return showModalBottomSheet<SalonLocationDetails>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => PinSalonEntranceModal(
        initialLat: initialLat,
        initialLng: initialLng,
        initialShopNo: initialShopNo,
        initialBuilding: initialBuilding,
        initialSpecificAddress: initialSpecificAddress,
        initialLandmark: initialLandmark,
        initialArea: initialArea,
        initialCity: initialCity,
        initialState: initialState,
        initialNearbyLandmarks: initialNearbyLandmarks,
      ),
    );
  }

  @override
  State<PinSalonEntranceModal> createState() => _PinSalonEntranceModalState();
}

class _PinSalonEntranceModalState extends State<PinSalonEntranceModal> {
  final MapController _mapController = MapController();
  final OwnerGeoService _geoService = OwnerGeoService();

  late LatLng _currentCenter;
  bool _isGeocoding = false;
  bool _isSearching = false;
  bool _hasMoved = false;
  int _geocodeRequestId = 0;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _shopNoController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  List<Map<String, dynamic>> _searchResults = [];
  Timer? _searchDebounce;

  String _areaName = '';
  String _cityName = '';
  String _state = '';
  String? _pincode;
  List<String> _nearbyLandmarks = [];

  // Default coordinate if none provided (Pune center: 18.5204, 73.8567)
  static const LatLng _defaultCoord = LatLng(18.5204, 73.8567);

  @override
  void initState() {
    super.initState();

    final hasValidInitCoords = widget.initialLat != null &&
        widget.initialLng != null &&
        widget.initialLat! != 0.0 &&
        widget.initialLng! != 0.0;

    _currentCenter = hasValidInitCoords
        ? LatLng(widget.initialLat!, widget.initialLng!)
        : _defaultCoord;

    _shopNoController.text = '';
    _buildingController.text = '';
    _landmarkController.text = widget.initialLandmark ?? '';
    _areaName = widget.initialArea ?? '';
    _cityName = widget.initialCity ?? '';
    _state = widget.initialState ?? '';
    _nearbyLandmarks = List.from(widget.initialNearbyLandmarks ?? []);

    // If initial coords exist, do an initial reverse-geocode if address fields are empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasValidInitCoords && (_areaName.isEmpty || _cityName.isEmpty)) {
        _reverseGeocodeCenter();
      } else if (!hasValidInitCoords) {
        _detectCurrentPosition();
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _shopNoController.dispose();
    _buildingController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        // If the user has already typed a search or selected another area, don't overwrite with delayed GPS
        if (_searchController.text.trim().isNotEmpty || _searchResults.isNotEmpty) {
          return;
        }

        final newCoord = LatLng(pos.latitude, pos.longitude);
        setState(() {
          _currentCenter = newCoord;
          _landmarkController.clear();
          _nearbyLandmarks = [];
          _shopNoController.clear();
          _buildingController.clear();
        });
        _mapController.move(newCoord, 16.5);
        _reverseGeocodeCenter(newCoord, true);
      }
    } catch (e) {
      debugPrint('Error getting GPS in PinSalonEntranceModal: $e');
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    final clean = query.trim();

    // As soon as the user starts typing a search query, clear any previously selected landmark and suggestion chips
    setState(() {
      _landmarkController.clear();
      _nearbyLandmarks = [];
      _shopNoController.clear();
      _buildingController.clear();
    });

    if (clean.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      final results = await _geoService.searchSalonArea(clean);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _selectSearchResult(Map<String, dynamic> item) {
    _searchDebounce?.cancel();
    FocusScope.of(context).unfocus();

    final lat = (item['lat'] as num).toDouble();
    final lng = (item['lng'] as num).toDouble();
    final newCoord = LatLng(lat, lng);

    final itemName = (item['name'] ?? '').toString().trim();
    final itemArea = (item['area'] ?? '').toString().trim();
    final itemCity = (item['city'] ?? '').toString().trim();

    setState(() {
      _currentCenter = newCoord;
      _searchResults = [];
      _searchController.clear();
      _isSearching = false;
      _landmarkController.clear(); // Clear landmark selection for the new area
      _nearbyLandmarks = [];       // Clear previous area's landmark suggestions
      _shopNoController.clear();   // Clear shop no when selecting a new address
      _buildingController.clear(); // Clear building when selecting a new address
      if (itemArea.isNotEmpty) {
        _areaName = itemArea;
      }
      if (itemCity.isNotEmpty) {
        _cityName = itemCity;
      }
      if (item['state'] != null && (item['state'] as String).isNotEmpty) {
        _state = item['state'];
      }
    });

    _mapController.move(newCoord, 17.0);
    _reverseGeocodeCenter(newCoord, true);
  }

  Future<void> _reverseGeocodeCenter([LatLng? coord, bool clearLandmarks = false]) async {
    final targetCoord = coord ?? _currentCenter;
    final requestId = ++_geocodeRequestId;

    setState(() {
      _isGeocoding = true;
      if (clearLandmarks) {
        _landmarkController.clear();
        _nearbyLandmarks = [];
      }
    });

    try {
      final details = await _geoService.reverseGeocode(
        targetCoord.latitude,
        targetCoord.longitude,
      );

      // If a newer geocode request was made while this one was in-flight, discard this result!
      if (!mounted || requestId != _geocodeRequestId) return;

      setState(() {
        if (details.areaName.isNotEmpty) _areaName = details.areaName;
        if (details.cityName.isNotEmpty) _cityName = details.cityName;
        if (details.state.isNotEmpty) _state = details.state;
        if (details.pincode != null && details.pincode!.isNotEmpty) {
          _pincode = details.pincode;
        }

        if (clearLandmarks) {
          _landmarkController.clear();
        }

        // Always set nearby landmarks strictly from the newly resolved coordinates
        _nearbyLandmarks = List<String>.from(details.nearbyLandmarks);
      });
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    } finally {
      if (mounted && requestId == _geocodeRequestId) {
        setState(() {
          _isGeocoding = false;
          _hasMoved = false;
        });
      }
    }
  }

  String _buildAreaBadgeText() {
    final parts = <String>[];
    if (_areaName.isNotEmpty) parts.add(_areaName.toUpperCase());
    if (_areaName.isNotEmpty && _cityName.isNotEmpty && _areaName.toLowerCase() != _cityName.toLowerCase()) {
      parts.add(_areaName);
    }
    if (_cityName.isNotEmpty) parts.add(_cityName);
    if (_state.isNotEmpty) parts.add(_state);

    if (parts.isEmpty) {
      return 'Exact Pin: ${_currentCenter.latitude.toStringAsFixed(5)}, ${_currentCenter.longitude.toStringAsFixed(5)}';
    }
    return parts.join(', ');
  }

  void _saveLocation() {
    final details = SalonLocationDetails(
      latitude: _currentCenter.latitude,
      longitude: _currentCenter.longitude,
      shopOrFlatNo: _shopNoController.text.trim(),
      buildingName: _buildingController.text.trim(),
      landmark: _landmarkController.text.trim(),
      areaName: _areaName,
      cityName: _cityName,
      state: _state,
      pincode: _pincode,
      nearbyLandmarks: _nearbyLandmarks,
    );

    Navigator.pop(context, details);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Pin Salon Entrance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Drag map so pin points to the exact salon entrance/gate for accurate customer navigation',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF64748B)),
                  splashRadius: 20,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (query) async {
                        final clean = query.trim();
                        if (clean.isEmpty) return;
                        if (_searchResults.isNotEmpty) {
                          _selectSearchResult(_searchResults.first);
                        } else {
                          setState(() => _isSearching = true);
                          final results = await _geoService.searchSalonArea(clean);
                          if (mounted && results.isNotEmpty) {
                            _selectSearchResult(results.first);
                          } else if (mounted) {
                            setState(() => _isSearching = false);
                          }
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search area, road or landmark across India...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : (_searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchDebounce?.cancel();
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                        _isSearching = false;
                                        _landmarkController.clear();
                                        _nearbyLandmarks = [];
                                      });
                                    },
                                  )
                                : null),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Search Suggestions Dropdown
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        itemBuilder: (ctx, index) {
                          final item = _searchResults[index];
                          final subParts = [item['city'], item['state']]
                              .where((s) => s != null && s.toString().isNotEmpty)
                              .join(', ');
                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                            title: Text(
                              item['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: subParts.isNotEmpty
                                ? Text(
                                    subParts,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                    ),
                                  )
                                : null,
                            onTap: () => _selectSearchResult(item),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Interactive Map with Stationary Center Pin
                  Container(
                    height: 270,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentCenter,
                            initialZoom: 16.5,
                            minZoom: 4,
                            maxZoom: 19,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                            ),
                            onPositionChanged: (camera, hasGesture) {
                              _currentCenter = camera.center;
                              if (hasGesture && !_hasMoved) {
                                setState(() {
                                  _hasMoved = true;
                                  _landmarkController.clear();
                                  _nearbyLandmarks = [];
                                  _shopNoController.clear();
                                  _buildingController.clear();
                                });
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.neoparlour.owner',
                            ),
                          ],
                        ),

                        // Center Stationary Pin with "Get address" interactive button
                        Center(
                          child: FractionalTranslation(
                            translation: const Offset(0.0, -0.5),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isGeocoding ? null : () => _reverseGeocodeCenter(null, true),
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 7,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                        border: Border.all(
                                          color: _hasMoved
                                              ? const Color(0xFFFF0B01)
                                              : Colors.white24,
                                          width: 1.2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (_isGeocoding) ...[
                                            const SizedBox(
                                              width: 13,
                                              height: 13,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Getting address...',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ] else ...[
                                            const Icon(
                                              Icons.my_location,
                                              color: Color(0xFFFF0B01),
                                              size: 14,
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Get address',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                IgnorePointer(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        color: Color(0xFFFF0B01),
                                        size: 40,
                                      ),
                                      Container(
                                        width: 8,
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Locate Me Button (Top-Right)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Material(
                            elevation: 3,
                            shape: const CircleBorder(),
                            color: Colors.white,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _detectCurrentPosition,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(
                                  Icons.my_location,
                                  size: 20,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Zoom Controls (+ / -) (Bottom-Right)
                        Positioned(
                          bottom: 12,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    final currentZoom = _mapController.camera.zoom;
                                    final newZoom = (currentZoom + 1).clamp(4.0, 19.0);
                                    _mapController.move(_currentCenter, newZoom);
                                  },
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 1,
                                  width: 26,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                InkWell(
                                  onTap: () {
                                    final currentZoom = _mapController.camera.zoom;
                                    final newZoom = (currentZoom - 1).clamp(4.0, 19.0);
                                    _mapController.move(_currentCenter, newZoom);
                                  },
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(8),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(7),
                                    child: Icon(
                                      Icons.remove,
                                      size: 20,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Area Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _buildAreaBadgeText(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Side-by-Side: Shop / Floor No. & Building Name
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Shop / Unit / Floor No.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _shopNoController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Shop 4, 1st Floor',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF0B01),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Building / Complex / Mall',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _buildingController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Swapnali Apartments',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 12,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE2E8F0),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFFF0B01),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Landmark Input with Quick-Add Suggestion Chips
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nearby Landmark (helps customers find you)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _landmarkController,
                        style: const TextStyle(fontSize: 13),
                        onChanged: (val) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'e.g. Opposite Subway, Behind Bank of Baroda',
                          hintStyle: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                          suffixIcon: _landmarkController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18, color: Color(0xFF64748B)),
                                  onPressed: () {
                                    setState(() {
                                      _landmarkController.clear();
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF0B01),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      if (_nearbyLandmarks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _nearbyLandmarks.map((lm) {
                            final isSelected = _landmarkController.text.trim().toLowerCase() ==
                                lm.trim().toLowerCase();
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _landmarkController.clear();
                                  } else {
                                    _landmarkController.text = lm;
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFFBFDBFE),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected ? Icons.check : Icons.add,
                                      size: 12,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF2563EB),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        lm,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : const Color(0xFF1E40AF),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: SafeArea(
              top: false,
              bottom: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _saveLocation,
                        icon: const Icon(Icons.check, size: 18, color: Colors.white),
                        label: const Text(
                          'Save Salon Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
