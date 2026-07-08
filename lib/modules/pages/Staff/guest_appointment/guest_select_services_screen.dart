import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neo_parlour_owner/core/utils/flushbar_helper.dart';
import 'package:neo_parlour_owner/data/models/service_model.dart';
import 'package:neo_parlour_owner/data/services/service_service.dart';
import 'guest_booking_state.dart';
import 'guest_select_date_time_screen.dart';

class GuestSelectServicesScreen extends StatefulWidget {
  final GuestBookingState bookingState;

  const GuestSelectServicesScreen({super.key, required this.bookingState});

  @override
  State<GuestSelectServicesScreen> createState() => _GuestSelectServicesScreenState();
}

class _GuestSelectServicesScreenState extends State<GuestSelectServicesScreen> {
  final ServiceService _serviceService = ServiceService();
  List<NeoService> _allServices = [];
  bool _isLoading = true;
  String _selectedCategory = "All";

  final List<String> _categories = [
    "All",
    "Hair Services",
    "Skin Care",
    "Hair Removal",
    "Nail Care",
    "Makeup",
    "Grooming",
    "Spa & Massage",
    "Hair Treatment"
  ];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final services = await _serviceService.fetchActiveServices();
      setState(() {
        _allServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        FlushbarHelper.show(context, "Error fetching services: $e");
      }
    }
  }

  bool _matchesCategory(NeoService service, String category) {
    if (category == "All") return true;
    final serviceCat = service.category.toLowerCase().trim();
    final filterCat = category.toLowerCase().trim();

    if (filterCat == "hair services") {
      return serviceCat.contains("cut") || serviceCat == "hair" || serviceCat == "hair services" || serviceCat == "hair cut";
    } else if (filterCat == "skin care") {
      return serviceCat == "skin care" || serviceCat == "facial" || serviceCat.contains("skin") || serviceCat.contains("facial");
    } else if (filterCat == "hair removal") {
      return serviceCat == "hair removal" || serviceCat.contains("removal");
    } else if (filterCat == "nail care") {
      return serviceCat == "nail care" || serviceCat.contains("nail") || serviceCat.contains("nails");
    } else if (filterCat == "makeup") {
      return serviceCat == "makeup" || serviceCat.contains("makeup");
    } else if (filterCat == "grooming") {
      return serviceCat == "grooming" || serviceCat.contains("grooming");
    } else if (filterCat == "spa & massage") {
      return serviceCat == "spa & massage" || serviceCat.contains("massage") || serviceCat.contains("spa");
    } else if (filterCat == "hair treatment") {
      return serviceCat == "hair treatment" || serviceCat.contains("treatment");
    }

    return serviceCat == filterCat || serviceCat.contains(filterCat) || filterCat.contains(serviceCat);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final scale = sw / 375.0;

    final filteredServices = _allServices.where((s) => _matchesCategory(s, _selectedCategory)).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "SELECT SERVICES",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18 * scale,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Category chips
              Container(
                height: 45 * scale,
                margin: EdgeInsets.symmetric(vertical: 10 * scale),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8 * scale),
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0XFFFF0B01) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(20 * scale),
                          border: Border.all(
                            color: isSelected ? const Color(0XFFFF0B01) : const Color(0XFFD0D0D0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cat,
                          style: GoogleFonts.poppins(
                            color: isSelected ? Colors.white : Colors.black,
                            fontSize: 13 * scale,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),

              // Services List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0XFFFF0B01))))
                    : filteredServices.isEmpty
                        ? Center(
                            child: Text(
                              "No services found in this category",
                              style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.fromLTRB(16 * scale, 10 * scale, 16 * scale, 100 * scale),
                            itemCount: filteredServices.length,
                            itemBuilder: (context, index) {
                              final service = filteredServices[index];
                              final isSelected = widget.bookingState.selectedServices.any((s) => s.id == service.id);

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      widget.bookingState.selectedServices.removeWhere((s) => s.id == service.id);
                                    } else {
                                      widget.bookingState.selectedServices.add(service);
                                    }
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 12 * scale),
                                  padding: EdgeInsets.all(12 * scale),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(9 * scale),
                                    border: Border.all(
                                      color: isSelected ? const Color(0XFFFF0B01) : const Color(0XFF909090),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x10000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              service.name,
                                              style: GoogleFonts.poppins(
                                                fontSize: 15 * scale,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 4 * scale),
                                            Text(
                                              "${service.duration} mins",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12 * scale,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "₹${service.price}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16 * scale,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0XFFFF0B01),
                                        ),
                                      ),
                                      SizedBox(width: 12 * scale),
                                      Icon(
                                        isSelected ? Icons.check_circle : Icons.radio_button_off,
                                        color: isSelected ? const Color(0XFFFF0B01) : const Color(0XFF909090),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),

          // Bottom Selection Bar
          Positioned(
            bottom: 20 * scale,
            left: 16 * scale,
            right: 16 * scale,
            child: SafeArea(
              child: Container(
                height: 68 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1F22),
                borderRadius: BorderRadius.circular(34 * scale),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(horizontal: 20 * scale),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.bookingState.selectedServices.isEmpty
                              ? "Select service"
                              : "${widget.bookingState.selectedServices.length} service${widget.bookingState.selectedServices.length > 1 ? 's' : ''}",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.bookingState.selectedServices.isNotEmpty)
                          Text(
                            widget.bookingState.selectedServices.map((s) => s.name).join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11 * scale,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.bookingState.selectedServices.isEmpty
                        ? () {
                            FlushbarHelper.show(context, "Please select at least one service");
                          }
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GuestSelectDateTimeScreen(bookingState: widget.bookingState),
                              ),
                            ).then((_) => setState(() {}));
                          },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 10 * scale),
                      decoration: BoxDecoration(
                        color: widget.bookingState.selectedServices.isEmpty ? Colors.white.withValues(alpha: 0.5) : Colors.white,
                        borderRadius: BorderRadius.circular(20 * scale),
                      ),
                      child: Text(
                        "Select slot",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.bold,
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
