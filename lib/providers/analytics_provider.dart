import 'package:flutter/material.dart';
import 'package:neo_parlour_owner/data/models/revenue_model.dart';
import 'package:neo_parlour_owner/data/services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  List<RevenuePointDTO> _revenuePoints = [];
  double _totalRevenue = 0.0;
  DashboardResponse? _dashboardData;
  Map<int, double> _offerRevenueMap = {};
  Map<int, double> _staffRevenueMap = {};
  bool _isLoading = false;
  bool _isOfferRevenueLoading = false;
  bool _isStaffRevenueLoading = false;
  bool _isRevenueMetric = false;
  String? _errorMessage;
  List<OfferUsageLimit> _offerUsageLimits = [];

  // Filters
  String _viewType = 'day';
  DateTime? _graphStartDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  DateTime? _graphEndDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  bool _onlyOffers = false;

  List<RevenuePointDTO> get revenuePoints => _revenuePoints;
  List<OfferUsageLimit> get offerUsageLimits => _offerUsageLimits;

  double get totalRevenue => _totalRevenue;

  DashboardResponse? get dashboardData => _dashboardData;

  Map<int, double> get offerRevenueMap => _offerRevenueMap;

  Map<int, double> get staffRevenueMap => _staffRevenueMap;

  bool get isLoading => _isLoading;

  bool get isOfferRevenueLoading => _isOfferRevenueLoading;

  bool get isStaffRevenueLoading => _isStaffRevenueLoading;

  bool get isRevenueMetric => _isRevenueMetric;

  String? get errorMessage => _errorMessage;

  String get viewType => _viewType;

  DateTime? get graphStartDate => _graphStartDate;

  DateTime? get graphEndDate => _graphEndDate;

  bool get onlyOffers => _onlyOffers;
  int? _currentSalonId;

  void setViewType(String type, {int? salonId}) {
    debugPrint("DEBUG: setViewType to $type");
    _viewType = type;
    _dashboardData = null;
    
    // Set standard date ranges based on view type
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (type == 'day') {
      _graphStartDate = today;
      _graphEndDate = today;
    } else if (type == 'week') {
      _graphStartDate = today.subtract(Duration(days: today.weekday - 1));
      _graphEndDate = today;
    } else if (type == 'month') {
      _graphStartDate = DateTime(today.year, today.month, 1);
      _graphEndDate = today;
    } else if (type == 'year') {
      _graphStartDate = DateTime(today.year, 1, 1);
      _graphEndDate = today;
    } else {
      _graphStartDate = null;
      _graphEndDate = null;
    }

    if (salonId != null) _currentSalonId = salonId;
    fetchRevenueGraph(salonId: _currentSalonId, onlyOffers: _onlyOffers);
    fetchTotalRevenue(salonId: _currentSalonId);
    fetchDashboardData();
  }

  void setDateRange(DateTime? start, DateTime? end, {int? salonId}) {
    _dashboardData = null;
    _graphStartDate = start;
    _graphEndDate = end;
    if (salonId != null) _currentSalonId = salonId;
    fetchRevenueGraph(salonId: _currentSalonId, onlyOffers: _onlyOffers);
    fetchTotalRevenue(salonId: _currentSalonId);
    fetchDashboardData();
  }

  Future<void> fetchOfferUsageLimits() async {
    _isLoading = true;
    _errorMessage = null;
    _offerUsageLimits = [];
    notifyListeners();

    try {
      _offerUsageLimits = await _analyticsService.getOfferUsageLimits();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRevenueGraph(
      {int? salonId, bool? onlyOffers, int? staffId, int? offerId}) async {
    if (salonId != null) _currentSalonId = salonId;
    if (onlyOffers != null) _onlyOffers = onlyOffers;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _revenuePoints = await _analyticsService.getRevenueGraph(
        _viewType,
        salonId: _currentSalonId,
        fromDate: _graphStartDate,
        toDate: _graphEndDate,
        onlyOffers: _onlyOffers,
        staffId: staffId,
        offerId: offerId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTotalRevenue(
      {int? salonId, DateTime? fromDate, DateTime? toDate, int? staffId, int? offerId, bool? onlyOffers}) async {
    if (salonId != null) _currentSalonId = salonId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint(
          "DEBUG: fetchTotalRevenue started. salonId: $salonId, fromDate: ${fromDate ??
              _graphStartDate}");
      _totalRevenue = await _analyticsService.getTotalRevenue(
        fromDate: fromDate ?? _graphStartDate,
        salonId: _currentSalonId,
        toDate: toDate ?? _graphEndDate,
        staffId: staffId,
        offerId: offerId,
        onlyOffers: onlyOffers ?? _onlyOffers,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRevenueForOffers(
      {required List<dynamic> offers, int? salonId}) async {
    if (salonId != null) _currentSalonId = salonId;
    _isOfferRevenueLoading = true;
    _offerRevenueMap.clear();
    notifyListeners();

    try {
      for (var offer in offers) {
        if (offer.id != null) {
          final revenue = await _analyticsService.getTotalRevenue(
            fromDate: _graphStartDate,
            toDate: _graphEndDate,
            salonId: _currentSalonId,
            offerId: offer.id,
          );
          _offerRevenueMap[offer.id!] = revenue;
          notifyListeners(); // Update UI as we get each result
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isOfferRevenueLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboardData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _analyticsService.getDashboardData(
        viewType: _viewType,
        fromDate: _graphStartDate,
        toDate: _graphEndDate,
      );
      
      // Sync totalRevenue for standard periods
      if (_viewType != 'custom') {
        _totalRevenue = _dashboardData?.revenue ?? 0.0;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRevenueForStaff({
    required List<dynamic> staffMembers,
    int? salonId,
    bool isRevenue = false,
  }) async {
    if (salonId != null) _currentSalonId = salonId;
    _isStaffRevenueLoading = true;
    _isRevenueMetric = isRevenue;
    _staffRevenueMap.clear();
    notifyListeners();

    try {
      final List<dynamic> results = isRevenue
          ? await _analyticsService.getStaffRevenueBulk(
        viewType: _viewType,
        fromDate: _graphStartDate,
        toDate: _graphEndDate,
        salonId: _currentSalonId,
      )
          : await _analyticsService.getStaffAppointmentsBulk(
        viewType: _viewType,
        fromDate: _graphStartDate,
        toDate: _graphEndDate,
        salonId: _currentSalonId,
      );

      for (var result in results) {
        final String name = result['staffName'] ?? '';
        double value = 0;

        if (isRevenue) {
          value = ((result['revenue'] ?? 0) as num).toDouble();
        } else {
          value = ((result['bookedCount'] ?? 0) as num).toDouble() +
              ((result['completedCount'] ?? 0) as num).toDouble();
        }

        // Find staff by name (case-insensitive)
        try {
          final staff = staffMembers.firstWhere(
                (s) => s.name.toLowerCase().trim() == name.toLowerCase().trim(),
          );
          if (staff != null && staff.id != null) {
            _staffRevenueMap[staff.id!] = value;
          }
        } catch (e) {
          debugPrint("DEBUG: No staff match found for name: $name");
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isStaffRevenueLoading = false;
      notifyListeners();
    }
  }

  String getPeriodLabel() {
    switch (_viewType) {
      case 'day':
        return 'Today';
      case 'week':
        return 'this Week';
      case 'month':
        return 'this Month';
      case 'year':
        return 'this Year';
      default:
        return 'Today';
    }
  }
}